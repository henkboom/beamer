--- graphics.Buffer
--- ===============

local class = require 'class'
local ffi = require 'ffi'
local gl = require 'gl'
local GlObject = require 'graphics.GlObject'

local Buffer = class('Buffer', GlObject)

--- ### `Buffer(target[, data[, usage]])`
--- Creates a new Buffer object. `target` should be an opengl buffer type, such
--- as `gl.GL_ARRAY_BUFFER` or `gl.GL_ELEMENT_ARRAY_BUFFER`. If `data` and/or
--- `usage` are given then they are immediately passed to `set_data()`.
---
--- The handle will be released when this object is garbage collected, but
--- `buffer:delete()` can be called to delete it immediately.
function Buffer:_init(target, data, usage)
  assert(type(target) == 'number', 'invalid target given to Buffer()')
  self:super(gl.glGenBuffers, gl.glDeleteBuffers, gl.glBindBuffer, target)

  if data ~= nil then
    self:set_data(data, usage)
  end
end

--- ### `buffer:set_data(data, [usage = gl.GL_STATIC_DRAW])
--- Sets the buffer data. `data` is the data to be copied by OpenGL, either a
--- table-array of numbers or a cdata. `usage` should be any combination of
--- `gl.GL_`{`STREAM`, `STATIC`, `DYNAMIC`}`_`{`DRAW`, `READ`, `COPY`}.
--- 
--- If `data` is a table, it'll be converted to a native array of floats, while
--- as a cdata it'll be passed to opengl as-is. In both cases the data is
--- copied, no references to `data` are kept.
function Buffer:set_data(data, usage)
  assert(self.name, 'buffer:set_data() called on deleted buffer')
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

  self:bind()
  gl.glBufferData(self.target, ffi.sizeof(data), data, usage)
  self:unbind()
end

return Buffer
