--- TextRenderer
--- ============

local class = require 'class'
local Component = require 'Component'
local gl = require 'gl'
local png = require 'png'
local Mesh = require 'Mesh'
local MeshRenderer = require 'MeshRenderer'
local font = require 'font'
local text_shader = require 'shaders.text'
local Texture = require 'Texture'
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

function TextRenderer:set_text(str)
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
      put_vector(position, (pos + offset + Vector(            0,             0))/64/4)
      put_vector(position, (pos + offset + Vector(glyph.rect[3],             0))/64/4)
      put_vector(position, (pos + offset + Vector(glyph.rect[3], -glyph.rect[4]))/64/4)
      put_vector(position, (pos + offset + Vector(            0, -glyph.rect[4]))/64/4)

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
  end

  self._renderer.mesh = Mesh({
    elements = elements,
    position = position,
    tex_coord = tex_coord
  })
end

function TextRenderer:_init(parent)
  self:super(parent)

  self._renderer = MeshRenderer(self)
  self._renderer.transform = Transform()
  self._renderer.program = text_shader()
  self._renderer.mesh = Mesh({
    elements = {0,1,2, 2,3,0},
    position = {0,0,0, 1,0,0, 1,1,0, 0,1,0},
    tex_coord = {0,1,0, 1,1,0, 1,0,0, 0,0,0}
  })
  self:set_text("TextRenderer.")

  local tex = Texture(gl.GL_TEXTURE_2D)
  tex:set_data(assert(png.load('font.png')))
  self._renderer._uniforms.tex = tex
  self._renderer._uniforms.color = {1, 1, 1, 1}
  self._renderer._uniforms.inner_threshold = 0.75
  self._renderer._uniforms.outer_threshold = 0.25
end

return TextRenderer
