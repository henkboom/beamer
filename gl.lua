local system = require 'system'

if system.platform == 'android' then
  return require 'bindings.gles2'
else
  return require 'bindings.gl3'
end
