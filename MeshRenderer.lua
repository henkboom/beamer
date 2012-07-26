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
local VertexArrayObject = require 'VertexArrayObject'

MeshRenderer = class('MeshRenderer', Component)

function MeshRenderer:_init(parent)
  self:super(parent)

  self.transform = false
  self.mesh = false
  self.program = false

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
  local modelview = camera.modelview_matrix *
    Matrix.from_transform(self.transform.position, self.transform.orientation)

  self.program:set_uniform_matrix('projection', camera.projection_matrix)
  self.program:set_uniform_matrix('modelview', modelview)

  self.program:use()
  local position_index = self.program:get_attribute_location('position')

  -- TODO support other attributes than 'position'
  gl.glEnableVertexAttribArray(position_index)
  gl.glBindBuffer(gl.GL_ARRAY_BUFFER, self._attributes.position:get_name())
  gl.glVertexAttribPointer(position_index, 3, gl.GL_FLOAT, true, 0, nil)
  gl.glBindBuffer(gl.GL_ARRAY_BUFFER, 0)

  gl.glBindBuffer(gl.GL_ELEMENT_ARRAY_BUFFER, self._elements:get_name())
  gl.glDrawElements(gl.GL_TRIANGLES, self._element_count, gl.GL_UNSIGNED_SHORT, nil)
  gl.glBindBuffer(gl.GL_ELEMENT_ARRAY_BUFFER, 0)

  gl.glVertexAttribPointer(position_index, 3, gl.GL_FLOAT, true, 0, nil)
  gl.glDisableVertexAttribArray(self.program:get_attribute_location('position'))
  self.program:disuse()
end

return MeshRenderer
