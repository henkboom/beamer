local lanes = require 'lanes'
lanes.configure()

local audio_control = {}

local linda = lanes.linda()
local lane

-- TODO: less copypasta
audio_control.operator_count = 192

local message_types = {
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

function audio_control.get_current_time()
  return linda.get('current_time')
end

function audio_control.flush()
  linda:send('audio_thread',
    {0, message_types.flush})
end

function audio_control.set_operator_frequency(time, operator, value, ramp_time)
  linda:send('audio_thread',
    {time, message_types.operator_frequency, {operator, value, ramp_time}})
end

function audio_control.set_operator_phase(time, operator, phase)
  linda:send('audio_thread',
    {time, message_types.operator_phase, {operator, phase}})
end

function audio_control.set_modulation(time, op1, op2, value, ramp_time)
  linda:send('audio_thread',
    {time, message_types.modulation, {op1, op2, value, ramp_time}})
end

function audio_control.play()
  linda:set('current_time', 0)

  lane = lanes.gen('*', function()
    local status, err = xpcall(function ()
      require('audio.audio_thread')(linda)
    end, debug.traceback)
    if not status then
      require('system.logging').log(err)
      error(err)
    end
  end)()
end

function audio_control.stop()
  --linda:send('audio_thread',
  --  {0, message_types.stop})
  local _ = lane[0]
  return
end

return audio_control
