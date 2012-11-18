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
end

function Container:_start()
  local refresh = function () self:refresh() end

  for _, child in ipairs(self.children) do
    child.transform.parent_transform = self.transform
    child.transform.changed:add_handler(refresh)
    child.size_changed:add_handler(refresh)
  end

  self:refresh()
end

function Container:refresh()
  local new_size = Vector(0, 0)

  for _, child in ipairs(self.children) do
    new_size = Vector(
      math.max(new_size.x, child.transform.position.x + child.size.x),
      math.max(new_size.y, child.transform.position.y + child.size.y))
  end

  self.size = new_size
end

return Container
