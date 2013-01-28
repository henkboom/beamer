local ffi = require 'ffi'
local Message = require 'audio.Message'
local thread = require 'system.thread'

local queue_mask = 0x3FF
local queue_length = queue_mask + 1

ffi.cdef([[
  typedef struct {
    $ mutex;
    message_s *queue[$];
    int next_write;
    int next_read;
  } audio_thread_interface_s;
]], thread.mutex_type, queue_length)
local audio_thread_interface_s = ffi.typeof('audio_thread_interface_s')
local audio_thread_interface_ptr = ffi.typeof('audio_thread_interface_s*')

local AudioThreadInterface = setmetatable({}, {
  __call = function (_)
    local self = audio_thread_interface_s()
    thread.mutex_init(self.mutex)
    self.next_write = 0
    self.next_read = 0
    return self
  end,
})
AudioThreadInterface.__index = AudioThreadInterface

function AudioThreadInterface.from_pointer(ptr)
  return ffi.cast(audio_thread_interface_ptr, ptr)
end

function AudioThreadInterface:send_message(message)
  thread.mutex_lock(self.mutex)
  assert(bit.band(self.next_write + 1, queue_mask) ~= self.next_read, 'full queue')
  self.queue[self.next_write] = message
  self.next_write = bit.band(self.next_write + 1, queue_mask)
  thread.mutex_unlock(self.mutex)
end

function AudioThreadInterface:receive_message()
  thread.mutex_lock(self.mutex)
  local message
  if self.next_read ~= self.next_write then -- if not empty
    message = self.queue[self.next_read]
    self.next_read = bit.band(self.next_read + 1, queue_mask)
  end
  thread.mutex_unlock(self.mutex)
  return message
end

ffi.metatype(audio_thread_interface_s, AudioThreadInterface)

return AudioThreadInterface
