--- Program
--- =======

local ffi = require 'ffi'
local gl3 = mehve.gl3

local gl_name = ffi.typeof('struct { GLuint name; }')

local Program = class()
Program._name = 'Program'

Program._active_program = false

--- ### `Program()`
--- Creates a new program object with its own OpenGL handle.
---
--- The handle will be released when this object is garbage collected, but
--- `program:delete()` can be called to delete it immediately.
function Program:_init()
  self._program = gl_name()
  self._program.name = gl3.glCreateProgram()
  self._linked = false
  ffi.gc(self._program, function () self:delete() end)
end

--- ### `program:delete()`
--- Deletes the program immediately, freeing up the OpenGL program handle.
--- `program` shouldn't be used after this call.
---
--- Calling this method is optional, but will release graphics resources
--- sooner.
function Program:delete()
  if self._program then
    gl3.glDeleteProgram(self._program.name)
    self._program = false
    self._linked = false
  end
end

--- ### `program:get_name()`
--- Returns the native OpenGL handle.
function Program:get_name()
  assert(self._program, 'program:get_name() called on a deleted program')

  return self._program and self._program.name
end

--- ### `program:attach_shader(shader)`
--- Attaches `shader` to this program. This should only be called before
--- `program:link()`.
function Program:attach_shader(shader)
  assert(self._program, 'program:attach_shader() called on a deleted program')
  assert(not self._linked,
    'program:attach_shader() called on an already-linked program')

  gl3.glAttachShader(self:get_name(), shader:get_name())
end

--- ### `program:link()`
--- Links the program, returning `success, messages`. `success` is `true` if
--- linking succeeded, `false` otherwise. `messages` is either nil or a string
--- with linker warnings and/or errors.
function Program:link()
  assert(self._program, 'program:attach_shader() called on a deleted program')
  assert(not self._linked,
    'program:link() called on an already-linked program')

  local program_name = self:get_name()
  -- this is necessary on intel graphics (?!)
  -- TODO remove since I'm not going to use default attributes anymore
  gl3.glBindAttribLocation(program_name, 0, "position") 
  gl3.glLinkProgram(program_name)

  -- get messages
  local msg
  local length = ffi.new('GLint[1]')
  gl3.glGetProgramiv(program_name, gl3.GL_INFO_LOG_LENGTH, length);

  -- if there was an error message then return it
  if length[0] > 0 then
    local log = ffi.new('GLchar[' .. length[0] .. ']')
    gl3.glGetProgramInfoLog(program_name, length[0], nil, log)
    msg = ffi.string(log)
  end

  -- error ?
  local program_ok = ffi.new('GLint[1]')
  gl3.glGetProgramiv(program_name, gl3.GL_LINK_STATUS, program_ok)
  if program_ok[0] == gl3.GL_FALSE then
    if msg then
      return nil, 'shader link error: \n' .. msg
    else
      return nil, 'shader link error'
    end
  else
    self._linked = true
    if msg then
      return true, msg
    else
      return true
    end
  end

  --local program_ok = ffi.new('GLint[1]')
  --gl3.glGetProgramiv(program_name, gl3.GL_LINK_STATUS, program_ok)
  --if program_ok[0] == gl3.GL_FALSE then
  --  -- report errors
  --  local msg = 'program link error'

  --  -- get error length
  --  local length = ffi.new('GLint[1]')
  --  gl3.glGetProgramiv(program_name, gl3.GL_INFO_LOG_LENGTH, length);

  --  -- if there was an error message then print it
  --  if length[0] > 0 then
  --    local log = ffi.new('GLchar[' .. length[0] .. ']')
  --    gl3.glGetProgramInfoLog(program_name, length[0], nil, log)
  --    msg = msg .. ":\n" .. ffi.string(log)
  --  end
  --  return nil, msg
  --end
  --return true
end

--- ### `program:use()`
--- Sets `program` as the active program.
function Program:use()
  assert(self._program, 'program:use() called on a deleted program')
  assert(self._linked, 'program:use() called on an unlinked program')
  Program._active_program = self
  gl3.glUseProgram(self._program.name)
end

--- ### `program:disuse()`
--- Unsets `program` as the active program.
---
--- This isn't technically necessary since another program will most likely
--- replace ths program before rendering continues, but calling this will
--- prevent confusion when someone forgets to set the next program.
function Program:disuse()
  Program._active_program = false
  gl3.glUseProgram(0)
end

--- ### `program:get_uniform_location(name)
--- Gets the internal integer index of the uniform named by `name`. If the
--- named uniform doesn't exist zero is returned. As a convenience, if you pass
--- an integer as `name` it's returned as-is.
function Program:get_uniform_location(name)
  assert(self._program,
    'program:get_uniform_location() called on a deleted program')
  assert(self._linked,
    'program:get_uniform_location() called on an unlinked program')

  if type(name) == 'number' then
    return name
  else
    return gl3.glGetUniformLocation(self._program.name, name)
  end
end

function Program:set_uniform(name, x, y, z, w)
  assert(type(name) == 'string' or type(name) == 'number')
  local index = self:get_uniform_location(name)

  if index >= 0 then
    local old_program = program._active_program
    self:use()

    gl3.glUniform4f(index, x or 0, y or 0, z or 0, w or 1)

    if old_program then
      old_program:use()
    else
      self:disuse()
    end
  end
end

function Program:set_uniform_matrix(name, matrix)
  assert(type(name) == 'string' or type(name) == 'number')
  local index = self:get_uniform_location(name)
  
  if index >= 0 then
    local old_program = Program._active_program
    self:use()

    gl3.glUniformMatrix4fv(
      index, 1, false, matrix:to_reference())

    if old_program then
      old_program:use()
    else
      self:disuse()
    end
  end
end

--- ### `program:get_attribute_location(name)`
--- Gets the internal integer index of the vertex attribute named by `name`. If
--- the named attribute doesn't exist zero is returned. As a convenience, if
--- you pass an integer as `name` it's returned as-is.
function Program:get_attribute_location(name)
  assert(self._program,
    'program:get_attribute_location() called on a deleted program')
  assert(self._linked,
    'program:get_attribute_location() called on an unlinked program')
  if type(name) == 'number' then
    return name
  else
    return gl3.glGetAttribLocation(self._program.name, name)
  end
end

return Program
