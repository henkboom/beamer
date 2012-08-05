--- TextRenderer
--- ============

local class = require 'class'
local Component = require 'Component'
local gl = require 'gl'
local png = require 'png'
local Mesh = require 'Mesh'
local MeshRenderer = require 'MeshRenderer'
local font = require 'font'
local texture_shader = require 'shaders.textured'
local Texture = require 'Texture'
local Transform = require 'Transform'

local TextRenderer = class('TextRenderer', Component)

function TextRenderer:_init(parent)
  self:super(parent)

  self._renderer = MeshRenderer(self)
  self._renderer.transform = Transform()
  self._renderer.program = texture_shader()
  self._renderer.mesh = Mesh({
    elements = {0,1,2, 2,3,0},
    position = {0,0,0, 1,0,0, 1,1,0, 0,1,0},
    tex_coord = {0,0,0, 1,0,0, 1,1,0, 0,1,0}
  })

  local tex = Texture(gl.GL_TEXTURE_2D)
  tex:set_data(assert(png.load('font.png')))
  self._renderer._uniforms.tex = tex
end

return TextRenderer
