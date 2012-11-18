--- Widget
--- ======
---
--- Widgets how do they work?
---
--- Widgets have
--- - size, used by parents for layout purposes
--- - handle_event method

local class = require 'class'
local Component = require 'Component'
local Event = require 'Event'
local RelativeTransform = require 'RelativeTransform'
local Vector = require 'Vector'

local Widget = class('Widget', Component)

local _size = {'size'}

function Widget:_init(parent)
  self:super(parent)

  self.transform_changed = Event()
  self.size_changed = Event()
  self.transform = RelativeTransform()

  self[_size] = Vector(10, 10)
end

function Widget:set_size(size)
  self[_size] = size
  self.size_changed(self)
end

function Widget:get_size()
  return self[_size]
end

function Widget:handle_event(e)
  return false
end

return Widget
