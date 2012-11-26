--- graphics.Framebuffer
--- ====================

local class = require 'class'
local ffi = require 'ffi'
local gl = require 'gl'
local GlObject = require 'graphics.GlObject'

local Framebuffer = class('Framebuffer', GlObject)

--- ### `Framebuffer()`
--- Creates a new Framebuffer object with its own OpenGL handle.
---
--- The handle will be released when this object is garbage collected, but
--- `framebuffer:delete()` can be called to delete it immediately.
function Framebuffer:_init()
  self:super(gl.glGenFramebuffers, gl.glDeleteFramebuffers,
             gl.glBindFramebuffer, gl.GL_FRAMEBUFFER)
end

function Framebuffer:attach_texture(attachment, texture)
  self:bind()
  gl.glFramebufferTexture2D(
    self.target, attachment, texture.target, texture.name, 0)
  self:unbind()
end

function Framebuffer:attach_renderbuffer(attachment, renderbuffer)
  self:bind()
  gl.glFramebufferRenderbuffer(
    self.target, attachment, renderbuffer.target, renderbuffer.name)
  self:unbind()
end

return Framebuffer
