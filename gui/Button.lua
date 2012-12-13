--- gui.Button
--- ==========

local BoxRenderer = require 'graphics.BoxRenderer'
local class = require 'class'
local Component = require 'Component'
local Vector = require 'Vector'
local Widget = require 'gui.Widget'
local Event = require 'Event'

local Button = class('Button', Widget)

function Button:_init(parent)
  self:super(parent)

  self.size = Vector(1, 1)
  self.pressed = Event()

  self._renderer = BoxRenderer(self)
  self._renderer.size = self.size
  self._renderer.transform = self.transform
  self._renderer.render_lists = {self.game.gui_render_list}
  self.size_changed:add_handler(function (size) self._renderer.size = size end)
end

function Button:handle_event(e)
  return function(e)
    local pos = self.transform.position
    local size = self.size
    local over = pos.x <= e.x and e.x < pos.x + size.x and
                 pos.y <= e.y and e.y < pos.y + size.y
    if over and e.type == 'pointer_up' then
      self.pressed()
    end
  end
end

return Button
