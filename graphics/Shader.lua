--- graphics.Shader
--- ===============

local class = require 'class'
local ffi = require 'ffi'
local gl = require 'gl'
local system = require 'system'

local gl_name = ffi.typeof('struct { GLuint name; }')

local Shader = class('Shader')

--- ### `Shader(shader_type)`
--- Creates a new shader object with its own OpenGL handle. `shader_type`
--- should be an OpenGL shader type, such as `gl.GL_VERTEX_SHADER` or
--- `gl.GL_FRAGMENT_SHADER`.
---
--- The handle will be released when this object is garbage collected, but
--- `shader:delete()` can be called to delete it immediately.
function Shader:_init(shader_type)
  assert(type(shader_type) == 'number')
  self._shader = gl_name()
  self._shader.name = gl.glCreateShader(shader_type)
  ffi.gc(self._shader, function () self:delete() end)
end

--- ### `shader:delete()`
--- Deletes the shader immediately, freeing up the OpenGL shader handle.
--- `shader` shouldn't be used after this call.
---
--- It's safe to call this while the shader is being used by programs, since
--- OpenGL keeps its own internal references, preventing it from being deleted
--- while in use.
---
--- Calling this method is optional, but will release graphics resources
--- sooner.
function Shader:delete()
  if self._shader then
    gl.glDeleteShader(self._shader.name)
    self._shader = false
  end
end

--- ### `shader:get_name()`
--- Returns the native OpenGL handle.
function Shader:get_name()
  return self._shader and self._shader.name
end

--- ### `shader:load_from_string(...)`
--- Loads and compiles the shader from source code contained in the given
--- string(s), returning `success, messages`. `success` is `true` if
--- compilation succeeded, `false` otherwise. `messages` is either nil or a
--- string with compiler warnings and/or errors.
function Shader:load_from_string(...)
  local shader_name = self:get_name()
  local len = select('#', ...)

  local source = ffi.new('const GLchar*[?]', len)
  for i = 1, len do
    source[i-1] = select(i, ...)
  end
  gl.glShaderSource(shader_name, len, source, nil)
  gl.glCompileShader(shader_name)

  -- get messages
  local msg
  local length = ffi.new('GLint[1]')
  gl.glGetShaderiv(shader_name, gl.GL_INFO_LOG_LENGTH, length);

  -- if there was an error message then return it
  if length[0] > 1 then
    local log = ffi.new('GLchar[' .. length[0] .. ']')
    gl.glGetShaderInfoLog(shader_name, length[0], nil, log)
    msg = ffi.string(log)
  end

  -- error ?
  local shader_ok = ffi.new('GLint[1]')
  gl.glGetShaderiv(shader_name, gl.GL_COMPILE_STATUS, shader_ok)
  if shader_ok[0] == gl.GL_FALSE then
    if msg then
      return nil, 'shader compilation error: \n' .. msg
    else
      return nil, 'shader compilation error'
    end
  else
    if msg then
      return true, msg
    else
      return true
    end
  end

  --if shader_ok[0] == gl.GL_FALSE then
  --  -- report errors
  --  local msg = 'shader compilation error'

  --  -- get error length
  --  local length = ffi.new('GLint[1]')
  --  gl.glGetShaderiv(shader_name, gl.GL_INFO_LOG_LENGTH, length);

  --  -- if there was an error message then print it
  --  if length[0] > 0 then
  --    local log = ffi.new('GLchar[' .. length[0] .. ']')
  --    gl.glGetShaderInfoLog(shader_name, length[0], nil, log)
  --    msg = msg .. ":\n" .. ffi.string(log)
  --  end
  --  return nil, msg
  --end
  --return true
end

--- ### `shader:load_from_file(filename)`
--- Loads and compiles the shader contained in the file named `filename`.
--- Returns values in the same format as `shader:load_from_string()`.
function Shader:load_from_file(filename)
  local file = assert(io.open(filename, 'r'))
  local data = assert(file:read('*a'))
  file:close()
  return self:load_from_string(data)
end

function Shader:get_prelude()
  local version = ffi.string(gl.glGetString(gl.GL_VERSION))
  if version:match('OpenGL ES') then
    Shader.prelude = [=[
      #version 100
      precision lowp float;
    ]=]
  else
    Shader.prelude = [=[
      #version 120
    ]=]
  end

  return Shader.prelude
end

return Shader
