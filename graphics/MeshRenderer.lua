--- graphics.MeshRenderer
--- =====================

local class = require 'class'
local Component = require 'Component'
local ffi = require 'ffi'
local gl = require 'gl'
local Matrix = require 'Matrix'
local RenderJob = require 'graphics.RenderJob'

MeshRenderer = class('MeshRenderer', Component)

function MeshRenderer:_init(parent)
  self:super(parent)

  self.transform = false
  self.mesh = false
  self.material = false

  self.render_lists = {self.game.render_list}
end

function MeshRenderer:_start()
  self.transform = assert(self.transform or self.parent.transform,
    'missing transform')
  assert(self.mesh, 'missing mesh')
  assert(self.material, 'missing material')

  -- add job to render list
  local job = RenderJob(function (camera) self:_render(camera) end)

  for _, render_list in ipairs(self.render_lists) do
    render_list:add_job(job)
    self.removed:add_handler(function ()
      render_list:remove_job(job)
    end)
  end
end

function MeshRenderer:_render(camera)
  -- update the camera/transform uniforms
  self.material.uniforms.projection = camera.projection_matrix
  self.material.uniforms.modelview = camera.modelview_matrix *
    Matrix.from_transform(self.transform.position, self.transform.orientation)

  self.material:render(self.mesh)
end

return MeshRenderer