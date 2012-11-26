--- graphics.Renderbuffer
--- =====================

local class = require 'class'
local ffi = require 'ffi'
local gl = require 'gl'
local GlObject = require 'graphics.GlObject'

local Renderbuffer = class('Renderbuffer', GlObject)

--- ### `Renderbuffer()`
--- Creates a new Renderbuffer object with its own OpenGL handle.
---
--- The handle will be released when this object is garbage collected, but
--- `renderbuffer:delete()` can be called to delete it immediately.
function Renderbuffer:_init()
  self:super(gl.glGenRenderbuffers, gl.glDeleteRenderbuffers,
             gl.glBindRenderbuffer, gl.GL_RENDERBUFFER)
end

-- the intersection of OpenGL 3 and OpenGL ES 2 restricts us to these
local valid_formats = {
  [gl.GL_RGBA4] = true,
  [gl.GL_RGB5_A1] = true,
  [gl.GL_DEPTH_COMPONENT16] = true,
  [gl.GL_STENCIL_INDEX8] = true
}

function Renderbuffer:create_storage(format, width, height)
  assert(format and valid_formats[format],
         'invalid format given to renderbuffer:create_storage()')
  self:bind()
  gl.glRenderbufferStorage(self.target, format, width, height)
  self:unbind()
end

return Renderbuffer
