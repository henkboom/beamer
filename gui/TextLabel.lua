--- gui.TextLabel
--- =============

local class = require 'class'
local Component = require 'Component'
local Quaternion = require 'Quaternion'
local RelativeTransform = require 'RelativeTransform'
local TextRenderer = require 'graphics.TextRenderer'
local Transform = require 'Transform'
local Vector = require 'Vector'
local Widget = require 'gui.Widget'

local TextLabel = class('TextLabel', Widget)

function TextLabel:_init(parent)
  self:super(parent)

  self._text_renderer = TextRenderer(self)
  self._text_renderer.transform = RelativeTransform(self.transform,
    Transform(Vector.zero, Quaternion.from_rotation(Vector.i, math.pi)))
  self._text_renderer.render_lists = {self.game.gui_render_list}
end

function TextLabel:get_text()
  return self._text_renderer.text
end

function TextLabel:set_text(str)
  self._text_renderer.text = str
  self.size = self._text_renderer.size
end

return TextLabel
