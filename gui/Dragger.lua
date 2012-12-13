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

function Dragger:handle_event(e)
  return function(e)
    if e.type == 'pointer_motion' then
      self.transform.local_transform.position =
        self.transform.local_transform.position + Vector(e.dx, e.dy)
      print(self.transform.local_transform.position)
    end
  end
end

return Dragger
