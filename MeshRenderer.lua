--- MeshRenderer
--- ============

local BufferObject = require 'BufferObject'
local class = require 'class'
local Component = require 'Component'
local ffi = require 'ffi'
local gl = require 'gl'
local Matrix = require 'Matrix'
local Program = require 'Program'
local RenderJob = require 'RenderJob'
local Shader = require 'Shader'
local Vector = require 'Vector'
local VertexArrayObject = require 'VertexArrayObject'

MeshRenderer = class('MeshRenderer', Component)

function MeshRenderer:_init(parent)
  self:super(parent)

  self.transform = false
  self.mesh = false
  self.program = false

  self._uniforms = {}
  self._attributes = {}
  self._elements = false

  self._element_count = 0
end

function MeshRenderer:_start()
  self.transform = assert(self.transform or self.parent.transform,
    'missing transform')
  assert(self.mesh, 'missing mesh')

  local vertices = self.mesh.vertices

  local position_list = {}
  for i = 1, #vertices do
    local position = vertices[i].position
    position_list[(i-1)*3+1] = position[1]
    position_list[(i-1)*3+2] = position[2]
    position_list[(i-1)*3+3] = position[3]
  end
  local positions = BufferObject(gl.GL_ARRAY_BUFFER)
  positions:set_data(position_list)
  self._attributes.position = positions

  local faces = self.mesh.faces
  local element_list = {}
  local n = 1
  for i = 1, #faces do
    local face = faces[i]

    element_list[n  ] = face[1] - 1
    element_list[n+1] = face[2] - 1
    element_list[n+2] = face[3] - 1
    n = n + 3

    if face[4] ~= nil then
      element_list[n  ] = face[3] - 1
      element_list[n+1] = face[4] - 1
      element_list[n+2] = face[1] - 1
      n = n + 3
    end
  end
  self._element_count = #element_list
  assert(#element_list <= 0xFFFF, 'too many elements for GLushort indeces')
  local element_data = ffi.new('GLushort[?]', #element_list)
  for i = 1, #element_list do
    element_data[i-1] = element_list[i]
  end
  local element_buffer = BufferObject(gl.GL_ELEMENT_ARRAY_BUFFER)
  element_buffer:set_data(element_data)
  self._elements = element_buffer

  -- add job to render list
  local job = RenderJob(function (camera) self:_render(camera) end)
  self.game.render_list:add_job(job)
  self.removed:add_handler(function ()
    self.game.render_list:remove_job(job)
  end)
end

function MeshRenderer:_render(camera)
  -- bind the shader program
  self.program:use()

  -- update the camera/transform uniforms
  self._uniforms.projection = camera.projection_matrix
  self._uniforms.modelview = camera.modelview_matrix *
    Matrix.from_transform(self.transform.position, self.transform.orientation)

  local next_texture_unit = 0
  local max_texture_units = 8

  -- uniforms
  for name, value in pairs(self._uniforms) do
    if type('value') == 'number' then
      self.program:set_uniform(name, value)
    elseif type('value') == 'table' then
      self.program:set_uniform(name, value[1], value[2], value[3], value[4])
    elseif Vector.is_type_of(value) then
      self.program:set_uniform(name, value.x, value.y, value.z)
    elseif Matrix.is_type_of(value) then
      self.program:set_uniform_matrix(name, value)
    elseif Texture.is_type_of(value) then
      assert(next_texture_unit < max_texture_units, 'too many texture units used')
      glActiveTexture(gl.GL_TEXTURE0 + next_texture_unit)
      value:bind()
      next_texture_unit = next_texture_unit + 1
    end
  end

  -- attributes
  local attribute_indices = {}
  for name, buffer in pairs(self._attributes) do
    local index = self.program:get_attribute_location(name)
    if index >= 0 then
      table.insert(attribute_indices, index)
      gl.glEnableVertexAttribArray(index)
      gl.glBindBuffer(gl.GL_ARRAY_BUFFER, buffer:get_name())
      -- TODO support other dimensions/types
      gl.glVertexAttribPointer(index, 3, gl.GL_FLOAT, true, 0, nil)
      gl.glBindBuffer(gl.GL_ARRAY_BUFFER, 0)
    end
  end
  gl.glBindBuffer(gl.GL_ARRAY_BUFFER, 0)

  gl.glBindBuffer(gl.GL_ELEMENT_ARRAY_BUFFER, self._elements:get_name())
  gl.glDrawElements(gl.GL_TRIANGLES, self._element_count, gl.GL_UNSIGNED_SHORT, nil)
  gl.glBindBuffer(gl.GL_ELEMENT_ARRAY_BUFFER, 0)

  for i = 1, #attribute_indices do
    gl.glDisableVertexAttribArray(attribute_indices[i])
  end
  for i = 0, next_texture_unit - 1 do
    glActiveTexture(gl.GL_TEXTURE0 + next_texture_unit)
    glBindTexture(gl.GL_TEXTURE_2D, 0)
  end

  self.program:disuse()
end

return MeshRenderer
