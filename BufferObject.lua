--- BufferObject
--- ============

local class = require 'class'
local ffi = require 'ffi'
local gl = require 'gl'

local gl_name = ffi.typeof('struct { GLuint name; }')

local BufferObject = class('BufferObject')

--- ### `BufferObject(target[, data[, usage]])`
--- Creates a new BufferObject object with its own OpenGL handle. `target`
--- should be an opengl buffer type, such as `gl.GL_ARRAY_BUFFER` or
--- `gl.GL_ELEMENT_ARRAY_BUFFER`. If `data` and/or `usage` are given then they
--- are immediately passed to `set_data()`.
---
--- The handle will be released when this object is garbage collected, but
--- `buffer_object:delete()` can be called to delete it immediately.
function BufferObject:_init(target, data, usage)
  assert(type(target) == 'number', 'invalid target given to BufferObject()')
  self.target = target
  self._buffer = gl_name()

  local buffer_name = ffi.new('GLuint[1]')
  gl.glGenBuffers(1, buffer_name)

  self._buffer.name = buffer_name[0]
  ffi.gc(self._buffer, function () self:delete() end)

  if data ~= nil then
    self:set_data(data, usage)
  end
end

--- ### `buffer_object:delete()`
--- Deletes the buffer immediately, freeing up the OpenGL buffer handle.
--- `buffer_object` shouldn't be used after this call.
---
--- Calling this method is optional, but will release graphics resources
--- sooner.
function BufferObject:delete()
  if self._buffer then
    local buffer_name = ffi.new('GLuint[1]')
    buffer_name[0] = self._buffer.name
    gl.glDeleteBuffers(1, buffer_name)
    self._buffer = false
  end
end

--- ### `buffer_object:get_name()`
--- Returns the native OpenGL handle.
function BufferObject:get_name()
  assert(self._buffer, 'buffer_object:get_name() called on deleted buffer')
  return self._buffer and self._buffer.name
end

--- ### `buffer_object:set_data(data, [usage = gl.GL_STATIC_DRAW])
--- Sets the buffer data. `data` is the data to be copied by OpenGL, either a
--- table-array of numbers or a cdata. `usage` should be any combination of
--- `gl.GL_`{`STREAM`, `STATIC`, `DYNAMIC`}`_`{`DRAW`, `READ`, `COPY`}.
--- 
--- If `data` is a table, it'll be converted to a native array of floats, while
--- as a cdata it'll be passed to opengl as-is. In both cases the data is
--- copied, no references to `data` are kept.
function BufferObject:set_data(data, usage)
  assert(self._buffer, 'buffer_object:set_data() called on deleted buffer')
  assert(type(data) == 'table' or type(data) == 'cdata')
  assert(usage == nil or type(usage) == 'number')
  usage = usage or gl.GL_STATIC_DRAW

  if type(data) == 'table' then
    local t = data
    data = ffi.new('GLfloat[?]', #data)
    for i = 1, #t do
      data[i-1] = t[i]
    end
  end

  gl.glBindBuffer(self.target, self:get_name())
  gl.glBufferData(self.target, ffi.sizeof(data), data, usage)
  gl.glBindBuffer(self.target, 0)
end

return BufferObject
