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

  -- self properties
  self.transform = RelativeTransform()
  self.transform_changed = Event()
  self[_size] = Vector.zero
  self.size_changed = Event()

  -- child management
  self.children = {}
  self.child_changed = Event()

  self.started:add_handler(function ()
    local refresh = function () self.child_changed() end

    for _, child in ipairs(self.children) do
      child.transform.parent_transform = self.transform
      child.transform.changed:add_handler(refresh)
      child.size_changed:add_handler(refresh)
    end
  end)
end

function Widget:set_size(size)
  self[_size] = size
  self.size_changed(self)
end

function Widget:get_size()
  return self[_size]
end

function Widget:handle_event(event)
  if event.type == 'pointer_down' then
    for _, child in ipairs(self.children) do
      local pos = child.transform.position
      local size = child.size

      if pos.x <= event.x and event.x < pos.x + size.x and
         pos.y <= event.y and event.y < pos.y + size.y then

        local ret = child:handle_event(event)
        if ret then
          return ret
        end

      end
    end
    return false
  end
end

return Widget
