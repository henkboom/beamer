--- miditest
--- ========
--- 
--- Opens a midi device and puts out control messages to stdout.

local arg = ...
if arg then arg = tonumber(arg) end

local pm = require 'bindings.portmidi'
local ffi = require 'ffi'
local bit = require 'bit'

pm.Pm_Initialize()

local count = pm.Pm_CountDevices()
local default_input = pm.Pm_GetDefaultInputDeviceID()
local default_output = pm.Pm_GetDefaultOutputDeviceID()

if not arg then
  print('Devices found:')
  print()
  for i = 0, count-1 do
    local info = pm.Pm_GetDeviceInfo(i)
    print(
      i .. ' ' ..
      ffi.string(info.name) .. ' (via ' .. ffi.string(info.interf) .. ')' ..
      (info.input ~= 0 and ' (input)' or '') ..
      (info.output ~= 0 and ' (output)' or '') .. 
      (i == default_input and ' (default input)' or '') ..
      (i == default_output and ' (default output)' or ''))
  end
  print()
  print('please re-run with an input device index')
else

  local stream_ptr = ffi.new('PortMidiStream*[1]')
  
  assert(pm.Pm_OpenInput(stream_ptr, arg, nil, 1024, nil, nil) == pm.pmNoError)
  
  local stream = stream_ptr[0]
  
  local event = ffi.new('PmEvent')
  while true do
    if pm.Pm_Read(stream, event, 1) ~= 0 then
      if bit.band(event.message, 0x0000f0) == 0xB0 and
         bit.band(event.message, 0x00ff00) < 120 * 0x100 then
        -- control message, print control and value
        print(bit.band(event.message, 0x00ff00) / 0x100 .. ' ' ..
              bit.band(event.message, 0xff0000) / 0x10000)
      end
    end
  end

  pm.Pm_Close(stream)
end

pm.Pm_Terminate()
