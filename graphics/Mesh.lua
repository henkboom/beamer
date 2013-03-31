--- graphics.Mesh
--- =============

local Buffer = require 'graphics.Buffer'
local class = require 'class'
local ffi = require 'ffi'
local gl = require 'gl'

local Mesh = class('Mesh')

--- ### `Mesh([data])`
--- Creates a new mesh object. If `data` is given, it should be a table with
--- string keys. The text key 'elements', if present, has its value passed to
--- `mesh:set_elements_from_data()`, and for other keys the key-value pair is
--- passed to `mesh:set_attribute_from_data()`.
function Mesh:_init(data)
  self.elements = false
  self.element_count = 0
  self.attributes = {}
  if data ~= nil then
    for k,v in pairs(data) do
      if k == 'elements' then
        self:set_elements_from_data(v)
      else
        self:set_attribute_from_data(k, v)
      end
    end
  end
end

--- ### `mesh:delete()`
--- Releases storage created for this Mesh
function Mesh:delete()
  if self.elements then
    self.elements:delete()
    self.elements = false
  end

  for key, attribute in pairs(self.attributes) do
    attribute:delete()
    self.attributes[key] = nil
  end
end

--- ### `mesh:set_elements_from_data(data)`
--- Sets the element data for this mesh. This should be an array of zero-based
--- vertex indices, each triple representing a triangle. `data` is a table or a
--- cdata containing a native array of GLushort elements.
function Mesh:set_elements_from_data(data)
  assert(type(data) == 'table' or type(data) == 'cdata')

  if type(data) == 'table' then
    local table_data = data
    data = ffi.new('GLushort[?]', #table_data)
    for i = 1, #table_data do
      data[i-1] = table_data[i]
    end
  end

  self.element_count = ffi.sizeof(data) / ffi.sizeof('GLushort');
  self.elements = Buffer(gl.GL_ELEMENT_ARRAY_BUFFER, data)
end

--- ### `mesh:set_attribute_from_data(name, data)`
--- Sets the attribute named by `name`. `data` is either a table or a cdata
--- containing a native array of GLfloat elements. Either way, `data` is
--- interpreted as a tighly packed 3-array of vectors.
function Mesh:set_attribute_from_data(name, data)
  assert(type(data) == 'table' or type(data) == 'cdata')

  if type(data) == 'table' then
    local table_data = data
    data = ffi.new('GLfloat[?]', #table_data)
    for i = 1, #table_data do
      data[i-1] = table_data[i]
    end
  end

  self.attributes[name] = Buffer(gl.GL_ARRAY_BUFFER, data)
end

return Mesh
