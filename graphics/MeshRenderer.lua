--- graphics.MeshRenderer
--- =====================

local class = require 'class'
local Component = require 'Component'
local ffi = require 'ffi'
local gl = require 'gl'
local Matrix = require 'Matrix'
local RenderJob = require 'graphics.RenderJob'
local Transform = require 'Transform'
local Vector = require 'Vector'

MeshRenderer = class('MeshRenderer', Component)

function MeshRenderer:_init(parent)
  self:super(parent)

  self.transform = false
  self.mesh = false
  self.material = false

  self.render_lists = false

  self.started:add_handler(function ()
    self.transform = self.transform or Transform()
    assert(self.mesh, 'missing mesh')
    assert(self.material, 'missing material')

    self.render_lists = self.render_lists or {self.game.render_list}

    -- add job to render list
    local job = RenderJob(function (camera) self:_render(camera) end)

    for _, render_list in ipairs(self.render_lists) do
      render_list:add_job(job)
      self.removed:add_handler(function ()
        render_list:remove_job(job)
      end)
    end
  end)
end

function MeshRenderer:_render(camera)
  -- update the camera/transform uniforms
  local viewport = self.game.video.viewport
  self.material.uniforms.screen_size = Vector(viewport.w, viewport.h)
  self.material.uniforms.projection = camera.projection_matrix
  self.material.uniforms.modelview = camera.modelview_matrix *
    Matrix.from_transform(self.transform.position, self.transform.orientation)

  self.material:render(self.mesh)
end

return MeshRenderer
