--- gui.Dragger
--- ==========

local BoxRenderer = require 'graphics.BoxRenderer'
local class = require 'class'
local Component = require 'Component'
local Vector = require 'Vector'
local Widget = require 'gui.Widget'
local Event = require 'Event'

local Dragger = class('Dragger', Widget)

function Dragger:_init(parent)
  self:super(parent)

  self.size = Vector(1, 1)
  self.pressed = Event()

  self._renderer = BoxRenderer(self)
  self._renderer.size = self.size
  self._renderer.transform = self.transform
  self._renderer.render_lists = {self.game.gui_render_list}
  self._renderer.thickness = 1/4
  self.size_changed:add_handler(function (size) self._renderer.size = size end)
end

function Dragger:get_value()
  local bounds = self.parent.size - self.size
  local pos = self.transform.local_transform.position
  return Vector(bounds.x == 0 and 0 or pos.x / bounds.x,
                bounds.y == 0 and 0 or pos.y / bounds.y)
end

function Dragger:handle_event(e)
  local offset = self.transform.local_transform.position - Vector(e.x, e.y)
  return function(e)
    if e.type == 'pointer_motion' then
      local bounds = self.parent.size - self.size
      local pos = self.transform.local_transform.position
      pos = Vector(
        math.min(math.max(offset.x + e.x, 0), bounds.x),
        math.min(math.max(offset.y + e.y, 0), bounds.y))
      self.transform.local_transform.position = pos
    end
  end
end

return Dragger
