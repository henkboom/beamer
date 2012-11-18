--- graphics.VertexArrayObject
--- =================

local class = require 'class'
local ffi = require 'ffi'
local gl = require 'gl'

local gl_name = ffi.typeof('struct { GLuint name; }')

---- general ------------------------------------------------------------------

local VertexArrayObject = class()

function VertexArrayObject:_init()
  self._vertex_array = gl_name()
  self._element_type = false

  local vertex_array_name = ffi.new('GLuint[1]')
  gl.glGenVertexArrays(1, vertex_array_name)

  self._vertex_array.name = vertex_array_name[0]
  ffi.gc(self._vertex_array, function () self:delete() end)
end

function VertexArrayObject:get_name()
  return self._vertex_array and self._vertex_array.name
end

function VertexArrayObject:delete()
  if self._vertex_array then
    local vertex_array_name = ffi.new('GLuint[1]')
    vertex_array_name[0] = self._vertex_array.name
    gl.glDeleteVertexArrays(1, vertex_array_name)
    self._vertex_array = false
  end
end

---- drawing ------------------------------------------------------------------

function VertexArrayObject:draw(mode, first, count)

  gl.glBindVertexArray(self:get_name())
  gl.glDrawArrays(mode, first, count)
  gl.glBindVertexArray(0)
end

function VertexArrayObject:draw_elements(mode, count)
  gl.glBindVertexArray(self:get_name())
  gl.glDrawElements(mode, count, self.element_type, nil)
  gl.glBindVertexArray(0)
end

---- elements -----------------------------------------------------------------

function VertexArrayObject:set_element_array(buffer, element_type)
  assert(not buffer or
         element_type == gl.GL_UNSIGNED_BYTE or
         element_type == gl.GL_UNSIGNED_SHORT or
         element_type == gl.GL_UNSIGNED_INT)
  self.element_type = element_type
  gl.glBindVertexArray(self:get_name())
  gl.glBindBuffer(
    gl.GL_ELEMENT_ARRAY_BUFFER,
    buffer and buffer:get_name() or 0)
  gl.glBindVertexArray(0)
end

---- attributes ---------------------------------------------------------------

function VertexArrayObject:enable_attribute_array(index)
  assert(type(index) == 'number')
  gl.glBindVertexArray(self:get_name())
  gl.glEnableVertexAttribArray(index)
  gl.glBindVertexArray(0)
end

function VertexArrayObject:set_attribute_array(
    index, buffer, size, element_type, normalized, stride, pointer)
  assert(type(index) == 'number')
  assert(buffer)
  assert(size == 1 or size == 2 or size == 3 or size == 4 or
         size == gl.GL_BGRA)
  assert(element_type)
  normalized = normalized or true
  stride = stride or 0
  pointer = pointer or nil

  gl.glBindVertexArray(self:get_name())
  if index >= 0 then
    gl.glBindBuffer(gl.GL_ARRAY_BUFFER, buffer and buffer:get_name() or 0)
    gl.glVertexAttribPointer(
      index, size, element_type, normalized, stride, pointer)
    gl.glBindBuffer(gl.GL_ARRAY_BUFFER, 0)
  end
  gl.glBindVertexArray(0)
end

return VertexArrayObject
