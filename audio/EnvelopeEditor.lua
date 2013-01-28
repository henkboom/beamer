--- EnvelopeEditor
--- ==============

local BoxRenderer = require 'graphics.BoxRenderer'
local class = require 'class'
local Dragger = require 'gui.Dragger'
local Event = require 'Event'
local Envelope = require 'audio.Envelope'
local Widget = require 'gui.Widget'
local Vector = require 'Vector'

local EnvelopeEditor = class('EnvelopeEditor', Widget)

function EnvelopeEditor:_init(parent)
  self:super(parent)

  self.size = Vector(15, 8)

  -- box
  self._renderer = BoxRenderer(self)
  self._renderer.size = self.size
  self._renderer.transform = self.transform
  self._renderer.render_lists = {self.game.gui_render_list}

  self.value_changed = Event()
  self._value = Envelope()

  self._draggers = {}
  self:_add_node()
  self:_add_node()
  self:_add_node()
  self:_add_node()
  self:_refresh()
end

function EnvelopeEditor:get_value()
  return self._value
end

function EnvelopeEditor:set_value(value)
  self._value = value
  self:value_changed()
end

function EnvelopeEditor:_refresh()
  table.sort(self._draggers, function (a, b)
    return a.value.x < b.value.x
  end)
  local ramps = {}
  local previous_time = 0
  for i = 1, #self._draggers do
    local v = self._draggers[i].value
    table.insert(ramps, {1-v.y, v.x - previous_time})
    previous_time = v.x
  end
  self.value = Envelope(ramps)
end

function EnvelopeEditor:_add_node()
  local node = Dragger(self)
  table.insert(self._draggers, node)

  node.value_changed:add_handler(function () self:_refresh() end)
end

return EnvelopeEditor
