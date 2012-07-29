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
  --self._attributes = {}
  --self._elements = false

  self._element_count = 0
end

function MeshRenderer:_start()
  self.transform = assert(self.transform or self.parent.transform,
    'missing transform')
  assert(self.mesh, 'missing mesh')

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
  for name, buffer in pairs(self.mesh.attributes) do
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

  gl.glBindBuffer(gl.GL_ELEMENT_ARRAY_BUFFER, self.mesh.elements:get_name())
  gl.glDrawElements(gl.GL_TRIANGLES, self.mesh.element_count, gl.GL_UNSIGNED_SHORT, nil)
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
