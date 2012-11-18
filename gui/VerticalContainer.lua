--- VerticalContainer
--- =================

local class = require 'class'
local Component = require 'Component'
local Container = require 'gui.Container'
local Vector = require 'Vector'

local VerticalContainer = class('VerticalContainer', Container)

function VerticalContainer:_init(parent)
  self:super(parent)
end

function VerticalContainer:refresh()
  local y = 0
  for _, child in ipairs(self.children) do
    child.transform.local_transform.position = Vector(0, y)
    y = y + child.size.y
  end

  Container.refresh(self)
end

return VerticalContainer
