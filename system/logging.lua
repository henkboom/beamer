--- system.logging
--- ==============
---
--- Platform-specific logging.

local system = require 'system'

local logging = {}

local function concat_args(sep, ...)
  local t = {}
  for i=1,select('#',...) do
    t[i] = tostring(select(i, ...))
  end
  return table.concat(t, sep)
end

--- android
--- ---------------------------------------------------------------------------

if system.platform == 'android' then
  local android = require 'bindings.android'
  local android_log = require 'bindings.android_log'

  function logging.log(...)
    android_log.__android_log_write(
      android.ANDROID_LOG_INFO, 'beamer', concat_args('\t', ...))
  end

--- desktop
--- ---------------------------------------------------------------------------

else -- assume desktop otherwise

  function logging.log(...)
    io.stderr:write(concat_args('\t', ...), '\n')
  end

end

return logging
