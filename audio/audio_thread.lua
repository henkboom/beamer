local ffi = require 'ffi'

local sample_rate = 96000
local inv_sample_rate = 1/sample_rate

local operator_count = 192
local channel_count = 1
local modulation_count = operator_count * 2
local modulation_output_count = operator_count + channel_count

---- sine wave

local table_mask = 0x3ff
local table_size = table_mask + 1;
local sine_table = ffi.new('double[?]', table_size)
for i = 0, table_size-1 do
  sine_table[i] = math.sin(i/table_size * 2 * math.pi)
end

local function sine_wave(phase)
  return sine_table[bit.band(phase * table_size, table_mask)]
end

---- line

-- f(t) = a*t + b
ffi.cdef [[ typedef struct { double a, b; } line_s; ]]
local line_s = ffi.metatype('line_s', {
  __index = {
    at = function (self, t)
      return self.a*t + self.b
    end
  }
})

---- phase modulation operator

ffi.cdef [[ typedef struct { line_s frequency; double phase; } operator_s; ]]
local operator_s = ffi.metatype("operator_s", {
  __index = {
    process_sample = function(self, time, offset)
      self.phase = (self.phase + self.frequency:at(time)*inv_sample_rate)
      return sine_wave(self.phase + offset)
    end
  }
})
 
---- matrix

ffi.cdef [[
// compressed-row-storage matrix
typedef struct {
  line_s values[192*2];     // modulation_count
  int value_columns[192*2]; // modulation_count
  int row_indices[192+1+1]; // modulation_output_count+1
} crs_matrix_s;
]]

local crs_matrix_s = ffi.metatype('crs_matrix_s', {
  __index = {
    set = function (self, row, column, value)
      -- find the element
      local index = self.row_indices[row]
      local next_row = self.row_indices[row+1]
      while column ~= self.value_columns[index] or index == next_row do
        if index == next_row then
          -- expand the row
          assert(self.row_indices[modulation_output_count] < modulation_count,
                 'modulation matrix full')
          for i = self.row_indices[modulation_output_count], index, -1 do
            self.values[i+1] = self.values[i]
            self.value_columns[i+1] = self.value_columns[i]
          end
          for i = row+1, modulation_output_count+1 do
            self.row_indices[i] = self.row_indices[i]+1
          end
          next_row = self.row_indices[row+1]

          self.value_columns[index] = column
        else
          index = index + 1
        end
      end
      self.values[index] = value
    end,

    multiply = function (self, time, vector, output)
      for row = 0, modulation_output_count-1 do
        local val = 0
        for i = self.row_indices[row], self.row_indices[row+1]-1 do
          val = val + self.values[i]:at(time) * vector[self.value_columns[i]]
        end
        output[row] = val
      end
    end
  }
})

local function crs_matrix()
  return crs_matrix_s()
end

---- synth

ffi.cdef [[
typedef struct {
  operator_s operators[192];       // operator_count
  crs_matrix_s modulation;
  double buffer[192];              // operator_count
  double modulation_buffer[192+1]; // modulation_output_count
} synth_s;
]]

local synth_s = ffi.typeof('synth_s')

local sample_bytes = ffi.sizeof('double')

local function synth()
  local self = synth_s()

  ffi.fill(self.buffer, operator_count * sample_bytes)

  self.modulation = crs_matrix()

  return self
end

local function synth_process_buffer(self, output, first, last)
  for i = first, last do
    output[i] = self:process_sample()
  end
end

local function synth_process_sample(self, time)
  self.modulation:multiply(time, self.buffer, self.modulation_buffer)

  for i = 0, operator_count-1, 8 do
    self.buffer[i  ] = self.operators[i  ]:process_sample(time, self.modulation_buffer[i  ])
    self.buffer[i+1] = self.operators[i+1]:process_sample(time, self.modulation_buffer[i+1])
    self.buffer[i+2] = self.operators[i+2]:process_sample(time, self.modulation_buffer[i+2])
    self.buffer[i+3] = self.operators[i+3]:process_sample(time, self.modulation_buffer[i+3])
    self.buffer[i+4] = self.operators[i+4]:process_sample(time, self.modulation_buffer[i+4])
    self.buffer[i+5] = self.operators[i+5]:process_sample(time, self.modulation_buffer[i+5])
    self.buffer[i+6] = self.operators[i+6]:process_sample(time, self.modulation_buffer[i+6])
    self.buffer[i+7] = self.operators[i+7]:process_sample(time, self.modulation_buffer[i+7])
  end

  return self.modulation_buffer[operator_count]
end

ffi.metatype('synth_s', {
  __index = {
    process_buffer = synth_process_buffer,
    process_sample = synth_process_sample,
  }
})

---- message queue

local message_types = {
  -- in input stream only: add all preceding messages to the queue now
  flush = 0,
  -- set the frequency line of an operator (op_index, line_a, line_b)
  operator_frequency = 1,
  -- set the phase of an operator (op_index, phase)
  operator_phase = 2,
  -- set a modulation (op1_index, op2_index, line_a, line_b)
  modulation = 3,
}

ffi.cdef [[
typedef struct {
  double time;
  double type;
  double content[4];
} message_s;

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

local message_s = ffi.typeof('message_s')
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
    peek = message_queue_peek,
    remove_first = message_queue_remove_first,
  }
})

local portaudio = require 'portaudio'

return function (linda)
  print('audio thread')
  local c = synth()
  local inbox = {}
  local messages = message_queue()

  portaudio.init()

  local sample_time = 0
  while true do
    -- get incoming messages and queue them up
    local message = linda:receive(0, 'audio_thread')
    while message do
      message = message_s(unpack(message))
      if message.type == message_types.flush then
        for i = 1, #inbox do
          messages:add(inbox[i])
          inbox[i] = nil
        end
      else
        table.insert(inbox, message)
      end
      message = linda:receive(0, 'audio_thread')
    end

    -- process messages that are due
    local message = messages:peek()
    local samples_until_next_message = message and
      message.time * sample_rate - sample_time

    while message ~= nil and samples_until_next_message <= 0 do
      messages:remove_first()

      local content = message.content

      if message.type == message_types.operator_frequency then
        c.operators[content[0]].frequency =
          line_s(content[1], content[2])
      elseif message.type == message_types.operator_phase then
        c.operators[content[0]].phase = content[1]
      elseif message.type == message_types.modulation then
        c.modulation:set(content[1], content[0], line_s(content[2], content[3]))
      end

      message = messages:peek()
      samples_until_next_message = message and
        message.time * sample_rate - sample_time
    end

    -- now run samples until our next message, with a reasonable maximum
    if message and samples_until_next_message < 1 then
      samples_until_next_message = 1
    end
    if not message or samples_until_next_message > 512 then
      samples_until_next_message = 512
    end
    samples_until_next_message = math.ceil(samples_until_next_message)

    -- set the 'current time' to the soonest possible time we could handle new
    -- messages
    linda:set('current_time',
      inv_sample_rate * (sample_time + samples_until_next_message))

    for i = 1, samples_until_next_message do
      local sample = c:process_sample(sample_time * inv_sample_rate)
      portaudio.put_sample(sample)
      sample_time = sample_time + 1
    end
  end

  portaudio.uninit()
end

