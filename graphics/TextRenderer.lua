--- graphics.TextRenderer
--- =====================

local class = require 'class'
local Component = require 'Component'
local gl = require 'gl'
local png = require 'png'
local Material = require 'graphics.Material'
local Mesh = require 'graphics.Mesh'
local MeshRenderer = require 'graphics.MeshRenderer'
local font = require 'font'
local Texture = require 'graphics.Texture'
local Transform = require 'Transform'
local Vector = require 'Vector'

local TextRenderer = class('TextRenderer', Component)

-- TODO this shouldn't be needed
local function put_vector(t, v)
  local len = #t
  t[len+1] = v.x
  t[len+2] = v.y
  t[len+3] = v.z
end

function TextRenderer:get_text()
  return self._text
end

function TextRenderer:set_text(str)
  self._text = str

  -- TODO calculate mesh lazily
  local elements = {}
  local position = {}
  local tex_coord = {}

  local index = 0
  local pos = Vector.zero

  for i = 1, #str do
    local byte = str:byte(i)
    local glyph = font[byte]

    if glyph ~= nil then
      elements[#elements+1] = index
      elements[#elements+1] = index+1
      elements[#elements+1] = index+2
      elements[#elements+1] = index+2
      elements[#elements+1] = index+3
      elements[#elements+1] = index

      local offset = Vector(glyph.offset[1], -glyph.offset[2])
      put_vector(position, (pos + offset + Vector(            0,             0))/64)
      put_vector(position, (pos + offset + Vector(glyph.rect[3],             0))/64)
      put_vector(position, (pos + offset + Vector(glyph.rect[3], -glyph.rect[4]))/64)
      put_vector(position, (pos + offset + Vector(            0, -glyph.rect[4]))/64)

      local rect = {
        glyph.rect[1] / font.width,
        glyph.rect[2] / font.height,
        glyph.rect[3] / font.width,
        glyph.rect[4] / font.height
      }
      put_vector(tex_coord, Vector(rect[1] +       0, rect[2] +       0))
      put_vector(tex_coord, Vector(rect[1] + rect[3], rect[2] +       0))
      put_vector(tex_coord, Vector(rect[1] + rect[3], rect[2] + rect[4]))
      put_vector(tex_coord, Vector(rect[1] +       0, rect[2] + rect[4]))

      index = index + 4
      pos = pos + Vector(glyph.advance, 0)
    end

    self.size = Vector(pos.x/64, 1)
  end

  if self._renderer.mesh then
    self._renderer.mesh:delete()
    self._renderer.mesh = false
  end
  self._renderer.mesh = Mesh({
    elements = elements,
    position = position,
    tex_coord = tex_coord
  })
end

local shader_cache
function TextRenderer:_init(parent)
  self:super(parent)

  self.transform = false

  self._renderer = MeshRenderer(self)
  if not material_cache then
    material_cache = require('materials.Text')()
  end
  self._renderer.material = material_cache
  self._renderer.mesh = Mesh()

  self.removed:add_handler(function ()
    if self._renderer.mesh then
      self._renderer.mesh:delete()
    end
  end)

  if not self.game.resources.font_texture then
    local tex = Texture(gl.GL_TEXTURE_2D)
    tex:set_data(png.load('font.png'))
    self.game.resources.font_texture = tex
  end

  local tex = self.game.resources.font_texture
  self._renderer.material.uniforms.tex = tex
  self._renderer.material.uniforms.color = {1, 1, 1, 1}

  self.size = Vector(0, 1)
  self.text = ''

  self.started:add_handler(function ()
    self.transform = self.transform or Transform()
    self._renderer.transform = self.transform
  end)
end

function TextRenderer:get_render_lists()
  return self._renderer.render_lists
end

function TextRenderer:set_render_lists(render_lists)
  self._renderer.render_lists = render_lists
end

return TextRenderer
