--- system.audio
--- ============
---
--- Platform-specific audio output.

local ffi = require 'ffi'
local logging = require 'system.logging'
local lua = require 'bindings.lua'
local resources = require 'system.resources'
local system = require 'system'

local audio = {}

-- generic call-with-error-handler
local function call(L, nargs, nresults, errfunc)
  local result = lua.lua_pcall(L, nargs, nresults, errfunc)
  if result ~= 0 then
    local err = ffi.string(lua.lua_tolstring(L, -1, nil))
    error('ERROR: [' .. err .. ']')
  end
end

--- android
--- ---------------------------------------------------------------------------

if system.platform == 'android' then

  local sl = require 'bindings.OpenSLES'

  local buffer_size = 2048

  local function check(result)
    assert(result == sl.SL_RESULT_SUCCESS, 'error initializing sound')
  end

  function audio.init(code, arg)
    logging.log('================ STARTING AUDIO SETUP')
    -- create the audio state and get its callback
    code = string.format([[
      collectgarbage('stop')
      local ffi = require 'ffi'
      package.preload[%q] = assert(loadstring(%q, %q))
      package.preload[%q] = assert(loadstring(%q, %q))
      package.preload[%q] = assert(loadstring(%q, %q))
      package.preload[%q] = assert(loadstring(%q, %q))
      package.preload[%q] = assert(loadstring(%q, %q))
      package.preload[%q] = assert(loadstring(%q, %q))
      package.preload[%q] = assert(loadstring(%q, %q))
      local system = require 'system'
      system.platform = 'android'
      local sl = require 'bindings.OpenSLES'
      local logging = require 'system.logging'
      local timing = require 'system.timing'
      logging.log('~~~~~~~~~~CALLBACK CODE STARTING UP!')

      local callback = assert(loadstring(%q, 'audio.init() caller code'))()

      local buffer_size = %d
      local buffer_bytes = buffer_size * ffi.sizeof(ffi.typeof('short'))
      local buffers = {ffi.new('short[?]', buffer_size),
                       ffi.new('short[?]', buffer_size)}

      ffi.cast('slBufferQueueCallback*', (...))[0] =
        function (caller, context)
          local success, val = xpcall(function ()
            --local time = timing.get_time()
            callback(context, buffers[1], tonumber(buffer_size))
            --logging.log('audio cpu usage: ' ..
            --  ((timing.get_time() - time)/(buffer_size/48000)))
          end, debug.traceback)
          if success then
            if caller[0].Enqueue(caller, buffers[1], buffer_bytes) ~=
                sl.SL_RESULT_SUCCESS then
              logging.log('Error enqueuing buffer')
            end
            buffers[1], buffers[2] = buffers[2], buffers[1]
          else
            logging.log('Error during sound processing: [' .. tostring(val) .. ']')
          end
        end
      ]],
      'system', resources.load('system.lua'), 'system.lua',
      'system.logging', resources.load('system/logging.lua'), 'system/logging.lua',
      'bindings.jni', resources.load('bindings/jni.lua'), 'bindings/jni.lua',
      'bindings.android', resources.load('bindings/android.lua'), 'bindings/android.lua',
      'bindings.android_log', resources.load('bindings/android_log.lua'), 'bindings/android_log.lua',
      'bindings.OpenSLES', resources.load('bindings/OpenSLES.lua'), 'bindings/OpenSLES.lua',
      'system.timing', resources.load('system/timing.lua'), 'system/timing.lua',
      code, buffer_size)
    logging.log(code)
    local callback_ptr = ffi.new('slBufferQueueCallback[1]')

    local L = lua.luaL_newstate()
    lua.luaL_openlibs(L)
    lua.lua_getfield(L, lua.LUA_GLOBALSINDEX, 'debug');
    lua.lua_getfield(L, -1, 'traceback');
    lua.luaL_loadstring(L,
      string.format("return assert(loadstring(%q, 'bootstrap'))", code))
    call(L, 0, 1, -2)
    --lua.luaL_loadstring(L, code)
    lua.lua_pushlightuserdata(L, callback_ptr)
    call(L, 1, 0, -3)

    -- initialize OpenSL ES

    -- engine
    local engine_object_ptr = ffi.new('SLObjectItf[1]')
    check(sl.slCreateEngine(engine_object_ptr, 0, nil, 0, nil, nil))
    check(engine_object_ptr[0][0].Realize(engine_object_ptr[0], sl.SL_BOOLEAN_FALSE))
    local engine_engine_ptr = ffi.new('SLEngineItf[1]')
    check(engine_object_ptr[0][0].GetInterface(engine_object_ptr[0], sl.SL_IID_ENGINE, engine_engine_ptr))

    -- output mix
    local output_mix_object_ptr = ffi.new('SLObjectItf[1]')
    check(engine_engine_ptr[0][0].CreateOutputMix(engine_engine_ptr[0], output_mix_object_ptr, 0, nil, nil))
    check(output_mix_object_ptr[0][0].Realize(output_mix_object_ptr[0], sl.SL_BOOLEAN_FALSE))

    -- audio source
    local loc_bufq = ffi.new('SLDataLocator_AndroidSimpleBufferQueue',
      sl.SL_DATALOCATOR_ANDROIDSIMPLEBUFFERQUEUE, 2)
    local format_pcm = ffi.new('SLDataFormat_PCM',
      sl.SL_DATAFORMAT_PCM, 1, sl.SL_SAMPLINGRATE_48,
      sl.SL_PCMSAMPLEFORMAT_FIXED_16, sl.SL_PCMSAMPLEFORMAT_FIXED_16,
      sl.SL_SPEAKER_FRONT_CENTER, sl.SL_BYTEORDER_LITTLEENDIAN)
    local audio_src = ffi.new('SLDataSource', loc_bufq, format_pcm)

    -- audio sink
    local loc_outmix = ffi.new('SLDataLocator_OutputMix',
      sl.SL_DATALOCATOR_OUTPUTMIX, output_mix_object_ptr[0])
    local audio_snk = ffi.new('SLDataSink', loc_outmix, nil)

    -- audio player
    local ids = ffi.new('SLInterfaceID[1]', sl.SL_IID_BUFFERQUEUE)
    local req = ffi.new('SLboolean[1]', sl.SL_BOOLEAN_TRUE)
    local bq_player_object_ptr = ffi.new('SLObjectItf[1]')
    check(engine_engine_ptr[0][0].CreateAudioPlayer(engine_engine_ptr[0],
      bq_player_object_ptr, audio_src, audio_snk, 1, ids, req))
    check(bq_player_object_ptr[0][0].Realize(bq_player_object_ptr[0], sl.SL_BOOLEAN_FALSE))
    local bq_player_play_ptr = ffi.new('SLPlayItf[1]')
    check(bq_player_object_ptr[0][0].GetInterface(bq_player_object_ptr[0], sl.SL_IID_PLAY, bq_player_play_ptr))
    local bq_player_buffer_queue_ptr = ffi.new('SLAndroidSimpleBufferQueueItf[1]')
    check(bq_player_object_ptr[0][0].GetInterface(bq_player_object_ptr[0],
      sl.SL_IID_BUFFERQUEUE, bq_player_buffer_queue_ptr))

    -- register callback
    check(bq_player_buffer_queue_ptr[0][0].RegisterCallback(bq_player_buffer_queue_ptr[0],
      callback_ptr[0], arg))
    check(bq_player_buffer_queue_ptr[0][0].Enqueue(bq_player_buffer_queue_ptr[0],
      ffi.new('short[2048]'), 2048 * ffi.sizeof(ffi.typeof('short'))))
    check(bq_player_buffer_queue_ptr[0][0].Enqueue(bq_player_buffer_queue_ptr[0],
      ffi.new('short[2048]'), 2048 * ffi.sizeof(ffi.typeof('short'))))

    -- play!
    check(bq_player_play_ptr[0][0].SetPlayState(bq_player_play_ptr[0],
      sl.SL_PLAYSTATE_PLAYING))

    logging.log('================ DONE AUDIO SETUP')
  end

  function audio.uninit()
  end

--- desktop
--- ---------------------------------------------------------------------------

else -- assume desktop otherwise

  local pa = require 'bindings.portaudio'

  local buffer_size = 2048

  local function check_error(err)
    if err == pa.paUnanticipatedHostError then
      assert(false, ffi.string(pa.Pa_GetLastHostErrorInfo().errorText))
    elseif err ~= pa.paNoError then
      assert(false, ffi.string(pa.Pa_GetErrorText(err)))
    end
  end

  local stream_ptr = ffi.new('PaStream*[1]')

  -- code is lua code that returns the callback function
  -- arg is an argument passed to that function, it must be castable to void*
  function audio.init(code, arg)
    -- create the audio state and get its callback
    code = string.format([[
      local ffi = require 'ffi'
      package.preload[%q] = assert(loadstring(%q, %q))
      package.preload[%q] = assert(loadstring(%q, %q))
      package.preload[%q] = assert(loadstring(%q, %q))
      local pa = require 'bindings.portaudio'
      local timing = require 'system.timing'
      local logging = require 'system.logging'

      local callback = assert(loadstring(%q, 'audio.init() caller code'))()

      local buffer_size = %d

      ffi.cast('PaStreamCallback**', (...))[0] =
        function (input, output, frame_count, time_info, status_flags, user_data)
          local success, val = xpcall(function ()
            local time = timing.get_time()
            callback(user_data, ffi.cast('short*', output), tonumber(frame_count))
            logging.log('audio cpu usage: ' ..
              ((timing.get_time() - time)/(buffer_size/48000)))
          end, debug.traceback)
          if success then
            return pa.paContinue
          else
            print('Error during sound processing: [' .. tostring(val) .. ']')
            return pa.paAbort
          end
        end
    ]], 'bindings.portaudio', resources.load('bindings/portaudio.lua'),
        'bindings/portaudio.lua',
        'system.logging', resources.load('system/logging.lua'), 'system/logging.lua',
        'system.timing', resources.load('system/timing.lua'), 'system/timing.lua',
        code, buffer_size)
    local callback_ptr = ffi.new('PaStreamCallback*[1]')

    local L = lua.luaL_newstate()
    lua.luaL_openlibs(L)
    lua.lua_getfield(L, lua.LUA_GLOBALSINDEX, 'debug');
    lua.lua_getfield(L, -1, 'traceback');
    lua.luaL_loadstring(L, code)
    lua.lua_pushlightuserdata(L, callback_ptr)
    call(L, 1, 0, -3)

    -- initialize portaudio
    check_error(pa.Pa_Initialize())
    local outputParams = ffi.new('struct PaStreamParameters')
    outputParams.device = pa.Pa_GetDefaultOutputDevice()
    outputParams.channelCount = 1
    outputParams.sampleFormat = pa.paInt16
    outputParams.suggestedLatency =
      pa.Pa_GetDeviceInfo(outputParams.device).defaultHighOutputLatency
    outputParams.hostApiSpecificStreamInfo = nil

    check_error(pa.Pa_OpenDefaultStream(
      stream_ptr, 0, 1, pa.paInt16, 48000, buffer_size, callback_ptr[0], arg))

    check_error(pa.Pa_StartStream(stream_ptr[0]))
  end

  function audio.uninit()
    check_error(pa.Pa_StopStream(stream_ptr[0]))
    check_error(pa.Pa_CloseStream(stream_ptr[0]))
    pa.Pa_Terminate()
  end

end

return audio
