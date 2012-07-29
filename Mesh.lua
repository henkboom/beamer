--- Mesh
--- ====

local BufferObject = require 'BufferObject'
local class = require 'class'
local ffi = require 'ffi'
local gl = require 'gl'

local Mesh = class('Mesh')

--- ### `Mesh([data])`
--- Creates a new mesh object. If `data` is given, it should be a table with
--- string keys. The text key 'elements', if present, has its value passed to
--- `mesh:set_elements()`, and for other keys the key-value pair is passed to
--- `mesh:set_attribute()`.
function Mesh:_init(data)
  self.elements = false
  self.element_count = 0
  self.attributes = {}
  if data ~= nil then
    for k,v in pairs(data) do
      if k == 'elements' then
        self:set_elements(v)
      else
        self:set_attribute(k, v)
      end
    end
  end
end

--- ### `mesh:set_elements(data)`
--- Sets the element data for this mesh. This should be an array of vertex
--- indices, each triple representing a triangle. `data` is a table or a cdata
--- containing a native array of GLushort elements.
function Mesh:set_elements(data)
  assert(type(data) == 'table' or type(data) == 'cdata')

  if type(data) == 'table' then
    local table_data = data
    data = ffi.new('GLushort[?]', #table_data)
    for i = 1, #table_data do
      data[i-1] = table_data[i]
    end
  end

  self.element_count = ffi.sizeof(data) / ffi.sizeof('GLushort');
  self.elements = BufferObject(gl.GL_ELEMENT_ARRAY_BUFFER, data)
end

--- ### `mesh:set_attribute(name, data)`
--- Sets the attribute named by `name`. `data` is either a table or a cdata
--- containing a native array of GLfloat elements. Either way, `data` is
--- interpreted as a tighly packed 3-array of vectors.
function Mesh:set_attribute(name, data)
  assert(type(data) == 'table' or type(data) == 'cdata')

  if type(data) == 'table' then
    local table_data = data
    data = ffi.new('GLfloat[?]', #table_data)
    for i = 1, #table_data do
      data[i-1] = table_data[i]
    end
  end

  self.attributes[name] = BufferObject(gl.GL_ARRAY_BUFFER, data)
end

return Mesh
