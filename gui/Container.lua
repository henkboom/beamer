--- Container
--- =========
--- 
--- A Widget that holds other widgets as children. Children's positions are
--- relative to the parent widget. The parent's size is just large enough to hold
--- the children.


local class = require 'class'
local Component = require 'Component'
local Widget = require 'gui.Widget'
local Vector = require 'Vector'

local Container = class('Container', Widget)

function Container:_init(parent)
  self:super(parent)
  self.children = {}

  self.started:add_handler(function ()
    local refresh = function () self:refresh() end

    for _, child in ipairs(self.children) do
      child.transform.parent_transform = self.transform
      child.transform.changed:add_handler(refresh)
      child.size_changed:add_handler(refresh)
    end

    self:refresh()
  end)
end

function Container:handle_event(event)
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

function Container:refresh()
  local new_size = Vector(0, 0)

  for _, child in ipairs(self.children) do
    new_size = Vector(
      math.max(new_size.x, child.transform.local_transform.position.x + child.size.x),
      math.max(new_size.y, child.transform.local_transform.position.y + child.size.y))
  end

  self.size = new_size
end

return Container
