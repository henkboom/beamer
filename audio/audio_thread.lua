local AudioThreadInterface = require 'audio.AudioThreadInterface'
local conf = require 'audio.conf'
local ffi = require 'ffi'
local Line = require 'audio.Line'
local logging = require 'system.logging'
local Matrix = require 'audio.Matrix'
local Message = require 'audio.Message'
local Synth = require 'audio.Synth'

local sample_rate = conf.sample_rate
local inv_sample_rate = conf.inv_sample_rate
local operator_count = conf.operator_count
local channel_count = conf.channel_count
local modulation_count = conf.modulation_count
local modulation_output_count = conf.modulation_output_count

ffi.cdef[[
void *malloc(size_t size);
void free(void *ptr);
]]

---- message queue

ffi.cdef [[
struct _message_list_s {
  struct _message_list_s *next;
  message_s message;
};
typedef struct _message_list_s message_list_s;

typedef struct {
  message_list_s *queued;
  message_list_s *free;
  message_list_s buffer[1024];
} message_queue_s;
]]

local message_queue_s

local message_buffer_length = 1024

local function message_queue()
  self = message_queue_s()

  self.queued = nil
  self.free = self.buffer[0]

  for i = 0, message_buffer_length-2 do
    self.buffer[i].next = self.buffer[i+1];
  end
  self.buffer[message_buffer_length-1].next = nil

  return self
end

local function message_queue_add(self, message)
  if self.free == nil then
    error('message queue full')
  end

  local node = self.free
  self.free = self.free.next

  node.message = message

  if self.queued == nil or message.time < self.queued.message.time then
    node.next = self.queued
    self.queued = node
  else
    local prev = self.queued

    while prev.next ~= nil and prev.next.message.time <= message.time do
      prev = prev.next
    end
    
    node.next = prev.next
    prev.next = node
  end
end

local function message_queue_filter(self, keep_fn)
  local previous = nil
  local node = self.queued
  while node ~= nil do
    if keep_fn(node.message) then
      previous = node
      node = node.next
    else
      if previous ~= nil then
        previous.next = node.next
      else
        self.queued = node.next
      end
      local deleted = node
      node = node.next
      deleted.next = self.free
      self.free = deleted
    end
  end
end

local function message_queue_peek(self)
  if self.queued ~= nil then
    return self.queued.message
  else
    return nil
  end
end

local function message_queue_remove_first(queue)
  if self.queued == nil then
    error('message queue empty')
  end

  local node = self.queued
  self.queued = node.next
  node.next = self.free
  self.free = node
end

message_queue_s = ffi.metatype('message_queue_s', {
  __index = {
    add = message_queue_add,
    filter = message_queue_filter,
    peek = message_queue_peek,
    remove_first = message_queue_remove_first,
  }
})

-- actual audio processing callback starts here

local c = Synth()
local inbox = {}
local messages = message_queue()
local sample_time = 0

return function (user_data, output, frame_count)
  local audio_thread_interface = AudioThreadInterface.from_pointer(user_data)

  local playing = true
  local output_index = 0

  while playing and output_index < frame_count do
    -- get incoming messages and queue them up
    local message = audio_thread_interface:receive_message()
    while message do
      if message.type == Message.types.stop then
        playing = false
        ffi.C.free(message)
      elseif message.type == Message.types.flush then
        for i = 1, #inbox do
          -- negative time values are relative to current time instead of
          -- absolute (e.g. -10 is 10 samples in the future
          if inbox[i].time < 0 then
            inbox[i].time = sample_time * inv_sample_rate - inbox[i].time
          end
          -- make sure the time is never negative
          if inbox[i].time < sample_time * inv_sample_rate then
            inbox[i].time = sample_time * inv_sample_rate
          end

          -- operator and modulation messages automatically cancel previously
          -- set events that are later than them
          if inbox[i].type == Message.types.operator_frequency or
             inbox[i].type == Message.types.operator_phase then
            messages:filter(function (m)
              return m.content[0] ~= inbox[i].content[0] or
                     m.time <= inbox[i].time
            end)
          elseif inbox[i].type == Message.types.modulation then
            messages:filter(function (m)
              return m.content[0] ~= inbox[i].content[0] or
                     m.content[1] ~= inbox[i].content[1] or
                     m.time <= inbox[i].time
            end)
          end

          messages:add(inbox[i][0])
          ffi.C.free(inbox[i])
          inbox[i] = nil
        end
        ffi.C.free(message)
      else
        table.insert(inbox, message)
      end
      message = audio_thread_interface:receive_message()
    end

    -- process messages that are due
    local message = messages:peek()
    local samples_until_next_message = message and
      message.time * sample_rate - sample_time

    while message ~= nil and samples_until_next_message <= 0 do
      messages:remove_first()

      local content = message.content

      if message.type == Message.types.operator_frequency then
        local line = Line(
            sample_time * inv_sample_rate,
            c.operators[content[0]].frequency:at(sample_time * inv_sample_rate),
            sample_time * inv_sample_rate + content[2],
            content[1])
        c.operators[content[0]].frequency = line
        --print('frequency', content[0], line.a, line.b)
      elseif message.type == Message.types.operator_phase then
        c.operators[content[0]].phase = content[1]
      elseif message.type == Message.types.modulation then
        local old_line = c.modulation:get(content[1], content[0])
        local line = Line(
            sample_time * inv_sample_rate,
            old_line:at(sample_time * inv_sample_rate),
            sample_time * inv_sample_rate + content[3],
            content[2])
        c.modulation:set(content[1], content[0], line)
        --print('modulation', content[0], content[1], line.a, line.b)
      end

      message = messages:peek()
      samples_until_next_message = message and
        message.time * sample_rate - sample_time
    end

    -- now run samples until our next message, with a reasonable maximum
    if message and samples_until_next_message < 1 then
      samples_until_next_message = 1
    end
    --if not message or samples_until_next_message > 512 then
    --  samples_until_next_message = 512
    --end
    --samples_until_next_message = math.ceil(samples_until_next_message)
    if message then
      samples_until_next_message =
        math.min(samples_until_next_message, frame_count - output_index)
    else
      samples_until_next_message = frame_count - output_index
    end

    -- set the 'current time' to the soonest possible time we could handle new
    -- messages
    --linda:set('current_time',
    --  inv_sample_rate * (sample_time + samples_until_next_message))

    for i = 1, samples_until_next_message do
      local sample = c:process_sample(sample_time * inv_sample_rate)
      output[output_index] = math.floor(-0x8000 + 0xffff * (1+sample)/2 + 0.5)
      output_index = output_index + 1
      sample_time = sample_time + 1
    end
  end

  while output_index < frame_count do
    output[output_index] = 0
    output_index = output_index + 1
  end

  return playing
end
