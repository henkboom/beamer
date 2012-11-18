--- graphics.Material
--- =================

local class = require 'class'
local gl = require 'gl'
local Matrix = require 'Matrix'
local Texture = require 'graphics.Texture'
local Vector = require 'Vector'

local Material = class('Material')

local depth_funcs = {
  never = gl.GL_NEVER,
  less = gl.GL_LESS,
  equal = gl.GL_EQUAL,
  lequal = gl.GL_LEQUAL,
  greater = gl.GL_GREATER,
  notequal = gl.GL_NOTEQUAL,
  gequal = gl.GL_GEQUAL,
  always = gl.GL_ALWAYS
}

local src_blend_modes = {
  zero = gl.GL_ZERO,
  one = gl.GL_ONE,
  src_color = gl.GL_SRC_COLOR,
  one_minus_src_color = gl.GL_ONE_MINUS_SRC_COLOR,
  src_alpha = gl.GL_SRC_ALPHA,
  one_minus_src_alpha = gl.GL_ONE_MINUS_SRC_ALPHA,
  dst_alpha = gl.GL_DST_ALPHA,
  one_minus_dst_alpha = gl.GL_ONE_MINUS_DST_ALPHA
}

local dst_blend_modes = {
  zero = gl.GL_ZERO,
  one = gl.GL_ONE,
  dst_color = gl.GL_DST_COLOR,
  one_minus_dst_color = gl.GL_ONE_MINUS_DST_COLOR,
  src_alpha = gl.GL_SRC_ALPHA,
  one_minus_src_alpha = gl.GL_ONE_MINUS_SRC_ALPHA,
  dst_alpha = gl.GL_DST_ALPHA,
  one_minus_dst_alpha = gl.GL_ONE_MINUS_DST_ALPHA
}

function Material:_init()
  self.program = false

  self.depth_write = true
  self.depth_func = 'lequal'

  self.blend_src = 'one'
  self.blend_dst = 'zero'

  self.uniforms = {}
end

function Material:render(mesh)
  assert(self.program, 'missing program on material')

  -- bind the shader program
  self.program:use()

  -- depth test
  assert(depth_funcs[self.depth_func], 'invalid depth function')
  if not self.depth_write and self.depth_func == 'always' then
    gl.glDisable(gl.GL_DEPTH_TEST)
  else
    gl.glEnable(gl.GL_DEPTH_TEST)
    gl.glDepthMask(self.depth_write)
    gl.glDepthFunc(depth_funcs[self.depth_func])
  end

  -- blend modes
  assert(src_blend_modes[self.blend_src])
  assert(dst_blend_modes[self.blend_dst])

  if self.blend_src == 'one' and self.blend_dst == 'zero' then
    gl.glDisable(gl.GL_BLEND)
  else
    gl.glEnable(gl.GL_BLEND)
    gl.glBlendFunc(
      src_blend_modes[self.blend_src],
      dst_blend_modes[self.blend_dst])
  end

  -- uniforms
  local next_texture_unit = 0
  local max_texture_units = 8
  for name, value in pairs(self.uniforms) do
    if type(value) == 'number' then
      self.program:set_uniform(name, value)
    elseif Vector.is_type_of(value) then
      self.program:set_uniform(name, value.x, value.y, value.z)
    elseif Matrix.is_type_of(value) then
      self.program:set_uniform_matrix(name, value)
    elseif Texture.is_type_of(value) then
      assert(next_texture_unit < max_texture_units, 'too many texture units used')
      gl.glActiveTexture(gl.GL_TEXTURE0 + next_texture_unit)
      value:bind()
      self.program:set_uniform_texture(name, next_texture_unit)
      next_texture_unit = next_texture_unit + 1
    elseif type(value) == 'table' then
      self.program:set_uniform(name, value[1], value[2], value[3], value[4])
    end
  end

  -- attributes
  local attribute_indices = {}
  for name, buffer in pairs(mesh.attributes) do
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

  gl.glBindBuffer(gl.GL_ELEMENT_ARRAY_BUFFER, mesh.elements:get_name())
  gl.glDrawElements(gl.GL_TRIANGLES, mesh.element_count, gl.GL_UNSIGNED_SHORT, nil)
  gl.glBindBuffer(gl.GL_ELEMENT_ARRAY_BUFFER, 0)

  for i = 1, #attribute_indices do
    gl.glDisableVertexAttribArray(attribute_indices[i])
  end

  self.program:disuse()
end

return Material
