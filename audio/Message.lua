local ffi = require 'ffi'

ffi.cdef [[
typedef struct {
  double time;
  double type;
  double content[4];
} message_s;
]]

local message_s = ffi.typeof('message_s')
local Message = setmetatable({}, {__call = function (_, ...) return message_s(...) end})

Message.types = {
  -- in input stream only: stop the audio thread
  stop = 0,
  -- in input stream only: add all preceding messages to the queue now
  flush = 1,

  -- set the frequency line of an operator (op_index, value, ramp_time)
  operator_frequency = 2,
  -- set the phase of an operator (op_index, phase)
  operator_phase = 3,
  -- set a modulation (op1_index, op2_index, value, ramp_time)
  modulation = 4,
}

return Message
