--- system.audio
--- ============
---
--- Platform-specific audio output.

local system = require 'system'

local audio = {}

--- android
--- ---------------------------------------------------------------------------

if system.platform == 'android' then

  function input.init()
  end

  function input.put_sample()
  end

  function uninit()
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

  function audio.init()
    check_error(pa.Pa_Initialize())

    local outputParams = ffi.new('struct PaStreamParameters')
    outputParams.device = pa.Pa_GetDefaultOutputDevice()
    outputParams.channelCount = 1
    outputParams.sampleFormat = pa.paFloat32
    outputParams.suggestedLatency =
      pa.Pa_GetDeviceInfo(outputParams.device).defaultHighOutputLatency
    outputParams.hostApiSpecificStreamInfo = nil

    check_error(pa.Pa_OpenStream(
      stream_ptr, nil, outputParams, 96000, buffer_size, 0, nil, nil))

    check_error(pa.Pa_StartStream(stream_ptr[0]))
  end

  local buffer = ffi.new('float[?]', buffer_size)
  local index = 0

  function audio.put_sample(sample)
    buffer[index] = sample
    index = index + 1
    if index == buffer_size then
      index = 0
      --check_error(pa.Pa_WriteStream(stream_ptr[0], buffer, buffer_size))
      pa.Pa_WriteStream(stream_ptr[0], buffer, buffer_size)
    end
  end

  function audio.uninit()
    check_error(pa.Pa_StopStream(stream_ptr[0]))
    check_error(pa.Pa_CloseStream(stream_ptr[0]))
    pa.Pa_Terminate()
  end

end
