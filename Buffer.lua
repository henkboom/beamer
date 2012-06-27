--- gl.buffer
--- =========

local ffi = require 'ffi'
local gl3 = mehve.gl3

local gl_name = ffi.typeof('struct { GLuint name; }')

local buffer = class()
buffer._name = 'buffer'

--- ### `gl.buffer()`
--- Creates a new buffer object with its own OpenGL handle. `target` should be
--- an opengl buffer type, such as `gl.GL_ARRAY_BUFFER` or
--- `gl.GL_ELEMENT_ARRAY_BUFFER`.
---
--- The handle will be released when this object is garbage collected, but
--- `buffer:delete()` can be called to delete it immediately.
function buffer:_init(target)
  assert(type(target) == 'number', 'invalid target given to gl.buffer()')
  self.target = target
  self._buffer = gl_name()

  local buffer_name = ffi.new('GLuint[1]')
  gl3.glGenBuffers(1, buffer_name)

  self._buffer.name = buffer_name[0]
  ffi.gc(self._buffer, function () self:delete() end)
end

--- ### `buffer:delete()`
--- Deletes the buffer immediately, freeing up the OpenGL buffer handle.
--- `buffer` shouldn't be used after this call.
---
--- Calling this method is optional, but will release graphics resources
--- sooner.
function buffer:delete()
  if self._buffer then
    local buffer_name = ffi.new('GLuint[1]')
    buffer_name[0] = self._buffer.name
    gl3.glDeleteBuffers(1, buffer_name)
    self._buffer = false
  end
end

--- ### `buffer:get_name()`
--- Returns the native OpenGL handle.
function buffer:get_name()
  assert(self._buffer, 'buffer:get_name() called on deleted buffer')
  return self._buffer and self._buffer.name
end

--- ### `buffer:set_data(data, usage = gl.GL_STATIC_DRAW)
--- Sets the buffer data. `data` is the data to be copied by OpenGL, either a
--- table-array of numbers or a cdata. `usage` should be any combination of
--- `gl.GL_`{`STREAM`, `STATIC`, `DYNAMIC`}`_`{`DRAW`, `READ`, `COPY`}.
--- 
--- If `data` is a table, it'll be converted to a native array of floats, while
--- as a cdata it'll be passed to opengl as-is. In both cases the data is
--- copied, no references to `data` are kept.
function buffer:set_data(data, usage)
  assert(self._buffer, 'buffer:set_data() called on deleted buffer')
  assert(type(data) == 'table' or type(data) == 'cdata')
  assert(usage == nil or type(usage) == 'number')
  usage = usage or gl3.GL_STATIC_DRAW

  if type(data) == 'table' then
    local t = data
    data = ffi.new('GLfloat[?]', #data)
    for i = 1, #t do
      data[i-1] = t[i]
    end
  end

  gl3.glBindBuffer(self.target, self:get_name())
  gl3.glBufferData(self.target, ffi.sizeof(data), data, usage)
  gl3.glBindBuffer(self.target, 0)
end

return buffer
