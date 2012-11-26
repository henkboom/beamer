--- graphics.Texture
--- ================

local class = require 'class'
local gl = require 'gl'
local GlObject = require 'graphics.GlObject'

local Texture = class('Texture', GlObject)

--- ### `Texture()`
--- Creates a new Texture object with its own OpenGL handle. `target`
--- should be a texture type, such as `gl.GL_TEXTURE_2D`.
---
--- The handle will be released when this object is garbage collected, but
--- `texture:delete()` can be called to delete it immediately.
function Texture:_init(target)
  assert(type(target) == 'number', 'invalid target given to Texture()')
  self:super(gl.glGenTextures, gl.glDeleteTextures, gl.glBindTexture, target)
end

--- ### `texture:set_data(data, width, height, channels)
--- Sets the image data of the texture.
---
--- - `data` is `width*height*channels` bytes of image data to load, or `false`
---   if this texture is going to be used as a render target.
--- - `width` is the image width in pixels.
--- - `height` is the image height in pixels.
--- - `channels` is the number of channels, which should be either 3 or 4.
function Texture:set_data(image, width, height, channels)
  assert(self.name, 'texture:set_data() called on deleted texture')
  assert(image == false or type(image) == 'cdata')
  assert(type(width) == 'number' and width > 0)
  assert(type(height) == 'number' and height > 0)
  assert(channels and (channels == 3 or channels == 4),
         'invalid number of channels, must be 3 or 4')

  local format = channels == 3 and gl.GL_RGB or gl.GL_RGBA

  self:bind()
  gl.glTexParameterf(gl.GL_TEXTURE_2D, gl.GL_TEXTURE_MIN_FILTER, gl.GL_LINEAR)
  gl.glTexParameterf(gl.GL_TEXTURE_2D, gl.GL_TEXTURE_MAG_FILTER, gl.GL_LINEAR)
  gl.glTexImage2D(
    self.target, 0, format, width, height, 0, format, gl.GL_UNSIGNED_BYTE, image or nil)
  self:unbind()
end

return Texture
