--- graphics.PostProcess
--- ====================

local class = require 'class'
local Component = require 'Component'
local Framebuffer = require 'graphics.Framebuffer'
local Mesh = require 'graphics.Mesh'
local Matrix = require 'Matrix'
local Renderbuffer = require 'graphics.Renderbuffer'
local Texture = require 'graphics.Texture'
local gl = require 'gl'

local PostProcess = class('PostProcess', Component)

function PostProcess:_init(parent, camera)
  self:super(parent)

  -- set up mesh
  self.mesh = Mesh({
    elements = {0,1,2, 2,3,0},
    position = {-1,-1,0, 1,-1,0, 1,1,0, -1,1,0},
    tex_coord = {0,0,0, 1,0,0, 1,1,0, 0,1,0},
  })

  -- set up framebuffer
  self.framebuffer = Framebuffer()

  self.colorbuffer = Texture(gl.GL_TEXTURE_2D)
  self.depthbuffer = Renderbuffer()

  self:_refresh_resolution()

  self.framebuffer:attach_texture(gl.GL_COLOR_ATTACHMENT0, self.colorbuffer)
  self.framebuffer:attach_renderbuffer(gl.GL_DEPTH_ATTACHMENT, self.depthbuffer)

  self.framebuffer:bind()
  local status = gl.glCheckFramebufferStatus(gl.GL_FRAMEBUFFER)
  if status ~= gl.GL_FRAMEBUFFER_COMPLETE then
    error(string.format("framebuffer not complete (0x%x)", status))
  end
  self.framebuffer:unbind()

  -- register on camera
  camera.target_framebuffer = self.framebuffer

  self:add_handler_for(
    self.game.video.viewport_changed, '_refresh_resolution')
  self:add_handler_for('draw')

  self.started:add_handler(function ()
    assert(self.material, 'missing material on PostProcess')
    self.material.depth_write = false
    self.material.depth_func = 'always'
    self.material.uniforms.tex = self.colorbuffer
    self.material.uniforms.projection = Matrix.identity;
    self.material.uniforms.modelview = Matrix.identity;
  end)
end

function PostProcess:_refresh_resolution()
  local viewport = self.game.video.viewport

  self.colorbuffer:set_data(false, viewport.w, viewport.h, 4)
  self.depthbuffer:create_storage(gl.GL_DEPTH_COMPONENT16,
    viewport.w, viewport.h)
end

function PostProcess:draw()
  local viewport = self.game.video.viewport
  gl.glViewport(viewport.x, self.game.video.size.y - viewport.y - viewport.h,
                viewport.w, viewport.h)
  gl.glClear(gl.GL_DEPTH_BUFFER_BIT)
  self.material:render(self.mesh)
end

return PostProcess
