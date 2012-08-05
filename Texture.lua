--- Texture
--- ============

local class = require 'class'
local ffi = require 'ffi'
local gl = require 'gl'

local gl_name = ffi.typeof('struct { GLuint name; }')

local Texture = class('Texture')

--- ### `Texture()`
--- Creates a new Texture object with its own OpenGL handle. `target`
--- should be a texture type, such as `gl.GL_TEXTURE_2D`.
---
--- The handle will be released when this object is garbage collected, but
--- `texture:delete()` can be called to delete it immediately.
function Texture:_init(target)
  assert(type(target) == 'number', 'invalid target given to Texture()')
  self.target = target
  self._texture = gl_name()

  local texture_name = ffi.new('GLuint[1]')
  gl.glGenTextures(1, texture_name)

  self._texture.name = texture_name[0]
  ffi.gc(self._texture, function () self:delete() end)
end

--- ### `texture:delete()`
--- Deletes the texture immediately, freeing up the OpenGL texture handle.
--- `texture` shouldn't be used after this call.
---
--- Calling this method is optional, but will release graphics resources
--- sooner.
function Texture:delete()
  if self._texture then
    local texture_name = ffi.new('GLuint[1]')
    texture_name[0] = self._texture.name
    gl.glDeleteTextures(1, texture_name)
    self._texture = false
  end
end

--- ### `texture:bind()`
--- Binds `texture` on its target.
function Texture:bind()
  assert(self._texture, 'texture:bind() called on a deleted texture')
  gl.glBindTexture(self.target, self:get_name())
end

--- ### `texture:unbind()`
--- Unbinds textures from this texture's target.
function Texture:unbind()
  gl.glBindTexture(self.target, 0)
end

--- ### `texture:get_name()`
--- Returns the native OpenGL handle.
function Texture:get_name()
  assert(self._texture, 'texture:get_name() called on deleted texture')
  return self._texture and self._texture.name
end

--- ### `texture:set_data(data, width, height, channels)
--- Sets the image data of the texture.
---
--- - `data` is `width*height*channels` bytes of image data to load.
--- - `width` is the image width in pixels.
--- - `height` is the image height in pixels.
--- - `channels` is the number of channels in the image data, and should be
---   either 3 or 4.
function Texture:set_data(image, width, height, channels)
  assert(self._texture, 'texture:set_data() called on deleted texture')
  assert(type(image) == 'cdata')
  assert(type(width) == 'number' and width > 0)
  assert(type(height) == 'number' and height > 0)
  assert(channels and (channels == 3 or channels == 4))

  local format = channels == 3 and gl.GL_RGB or gl.GL_RGBA

  gl.glBindTexture(self.target, self:get_name())
  gl.glTexParameterf(gl.GL_TEXTURE_2D, gl.GL_TEXTURE_MIN_FILTER, gl.GL_LINEAR)
  gl.glTexParameterf(gl.GL_TEXTURE_2D, gl.GL_TEXTURE_MAG_FILTER, gl.GL_LINEAR)
  gl.glTexImage2D(
    self.target, 0, format, width, height, 0, format, gl.GL_UNSIGNED_BYTE, image)
  gl.glBindTexture(self.target, 0)
end

return Texture
