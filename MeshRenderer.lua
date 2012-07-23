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

  self._vao = false
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
  local element_data = ffi.new('GLuint[?]', #element_list)
  for i = 1, #element_list do
    element_data[i-1] = element_list[i]
  end
  local element_buffer = BufferObject(gl.GL_ELEMENT_ARRAY_BUFFER)
  element_buffer:set_data(element_data)

  self._vao = VertexArrayObject()

  self._vao:enable_attribute_array(self.program:get_attribute_location('position'))
  self._vao:set_attribute_array(
    self.program:get_attribute_location('position'), positions, 3, gl.GL_FLOAT)

  self._vao:set_element_array(element_buffer, gl.GL_UNSIGNED_INT)

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
  self._vao:draw_elements(gl.GL_TRIANGLES, self._element_count)
  self.program:disuse()
end

return MeshRenderer
