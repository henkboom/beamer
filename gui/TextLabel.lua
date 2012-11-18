--- TextLabel
--- =========

local class = require 'class'
local Component = require 'Component'
local TextRenderer = require 'TextRenderer'
local Widget = require 'gui.Widget'
local Vector = require 'Vector'

local TextLabel = class('TextLabel', Widget)

function TextLabel:_init(parent)
  self:super(parent)

  self._text_renderer = TextRenderer(self)
  self._text_renderer.transform = self.transform
  -- TODO this is ugly
  self._text_renderer._renderer.render_lists = {self.game.gui_render_list}
  self.size = Vector(1, 1)

end

function TextLabel:get_text()
  return self._text_renderer.text
end

function TextLabel:set_text(str)
  self._text_renderer.text = str
end

return TextLabel
