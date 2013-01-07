--- Widget
--- ======
---
--- Widgets how do they work?
---
--- Widgets have a transform, a size, and a list of children. The transform is
--- always a RelativeTransform with the parent widget's transform as a parent.

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

  if Widget.is_type_of(parent) then
    self.transform.parent_transform = parent.transform
    parent:_add_child(self)
    self.removed:add_handler(function ()
      parent:_remove_child(self)
    end)
  end
end

function Widget:_add_child(child)
  assert(Widget.is_type_of(child))
  table.insert(self.children, child)

  local refresh = function () self.child_changed() end
  child.transform.changed:add_handler(refresh)
  child.size_changed:add_handler(refresh)

  self.child_changed()
end

function Widget:_remove_child(child)
  -- only happens when child is destroyed
  assert(Widget.is_type_of(child))
  local i = 1
  while self.children[i] ~= child and i <= #self.children do
    i = i + 1
  end
  if i <= #self.children then
    table.remove(self.children, i)
  else
    error('tried to remove a child that isn\'t in self.children')
  end
  self.child_changed()
end

function Widget:set_size(size)
  if self[_size] ~= size then
    self[_size] = size
    self.size_changed(self)
  end
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
