local AudioThreadInterface = require 'audio.AudioThreadInterface'
local conf = require 'audio.conf'
local system_audio = require 'system.audio'
local Envelope = require 'audio.Envelope'
local ffi = require 'ffi'
local Message = require 'audio.Message'
local resources = require 'system.resources'

local audio_control = {}

local audio_thread_interface

audio_control.operator_count = conf.operator_count

ffi.cdef[[
void *malloc(size_t size);
void free(void *ptr);
]]

--function audio_control.get_current_time()
--  return linda.get('current_time')
--end

local function malloc_message(...)
  -- TODO slow
  local ptr = ffi.cast('message_s*', ffi.C.malloc(ffi.sizeof(ffi.typeof('message_s'))))
  ptr[0] = Message(...)
  return ptr
end

function audio_control.flush()
  audio_thread_interface:send_message(malloc_message(0, Message.types.flush))
end

function audio_control.set_operator_frequency(time, operator, value, ramp_time)
  audio_thread_interface:send_message(
    malloc_message(time, Message.types.operator_frequency, {operator, value, ramp_time}))
end

function audio_control.set_operator_phase(time, operator, phase)
  audio_thread_interface:send_message(
    malloc_message(time, Message.types.operator_phase, {operator, phase}))
end

function audio_control.set_modulation(time, op1, op2, value, ramp_time)
  if type(value) == 'number' then
    ramp_time = ramp_time or 0
    assert(type(ramp_time) == 'number',
           'if given, ramp_time should be a number')
    audio_thread_interface:send_message(
      malloc_message(time, Message.types.modulation, {op1, op2, value, ramp_time or 0}))
  elseif Envelope.is_type_of(value) then
    local invert = time <= 0 and -1 or 1
    for start_time, target, ramp_time in value:ramps(time) do
      audio_thread_interface:send_message(malloc_message(start_time * invert,
        Message.types.modulation, {op1, op2, target, ramp_time}))
    end
  else
    assert('value should be an Envelope or a number')
  end
end

function audio_control.play()
  audio_thread_interface = AudioThreadInterface()
  system_audio.init(string.format([[
      package.preload[%q] = loadstring(%q, %q)
      package.preload[%q] = loadstring(%q, %q)
      package.preload[%q] = loadstring(%q, %q)
      package.preload[%q] = loadstring(%q, %q)
      package.preload[%q] = loadstring(%q, %q)
      package.preload[%q] = loadstring(%q, %q)
      package.preload[%q] = loadstring(%q, %q)
      package.preload[%q] = loadstring(%q, %q)
      package.preload[%q] = loadstring(%q, %q)

      local cb = require 'audio.audio_thread'

      --local phase = 0
      --local last_output = 0
      --local function temp(user_data, buffer, frame_count)
      --  for i = 0, frame_count-1 do
      --    phase = phase + 1/48000 * 220
      --    phase = phase - math.floor(phase)
      --    local last_output = phase * 0.05 + last_output * 0.95
      --    buffer[i] = math.floor(-0x8000 + 0xffff * last_output + 0.5)
      --  end
      --end

      return function (...)
        cb(...)
        --temp(...)
      end
    ]],
    'bindings.pthread', resources.load('bindings/pthread.lua'), 'bindings/pthread.lua',
    'system.thread', resources.load('system/thread.lua'), 'system/thread.lua',
    'audio.audio_thread', resources.load('audio/audio_thread.lua'), 'audio/audio_thread.lua',
    'audio.AudioThreadInterface', resources.load('audio/AudioThreadInterface.lua'), 'audio/AudioThreadInterface.lua',
    'audio.conf', resources.load('audio/conf.lua'), 'audio/conf.lua',
    'audio.Line', resources.load('audio/Line.lua'), 'audio/Line.lua',
    'audio.Matrix', resources.load('audio/Matrix.lua'), 'audio/Matrix.lua',
    'audio.Message', resources.load('audio/Message.lua'), 'audio/Message.lua',
    'audio.Synth', resources.load('audio/Synth.lua'), 'audio/Synth.lua'
  ),
  audio_thread_interface)
  --system_audio.init([[
  --local ffi = require 'ffi'
  --local phase = 0
  --return function (user_data, buffer, frame_count)
  --  for i = 0, frame_count-1 do
  --    phase = phase + 1/96000 * 220
  --    phase = phase - math.floor(phase)
  --    buffer[i] = phase
  --  end
  --end
  --]], audio_thread_interface)

  --lane = lanes.gen('*', function()
  --  local status, err = xpcall(function ()
  --    require('audio.audio_thread')(linda)
  --  end, debug.traceback)
  --  if not status then
  --    require('system.logging').log(err)
  --    error(err)
  --  end
  --end)()
end

function audio_control.stop()
  --audio_thread_interface:send_message('audio_thread',
  --  {0, Message.types.stop})
  local _ = lane[0]
  return
end

return audio_control
