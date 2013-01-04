--- gui.LinearContainer
--- ===================

local class = require 'class'
local Component = require 'Component'
local Container = require 'gui.Container'
local Vector = require 'Vector'

local LinearContainer = class('LinearContainer', Container)

local _orientation = {'orientation'}

function LinearContainer:_init(parent)
  self:super(parent)
  self.orientation = 'vertical'
end

function LinearContainer:get_orientation()
  return self[_orientation]
end

function LinearContainer:set_orientation(orientation)
  assert(orientation == 'vertical' or orientation == 'horizontal',
         'invalid orientation')
  self[_orientation] = orientation
  self:refresh()
end

function LinearContainer:refresh()
  local pos = Vector.zero
  for _, child in ipairs(self.children) do
    child.transform.local_transform.position = pos
    pos = pos + (self.orientation == 'horizontal'
      and Vector(child.size.x, 0)
      or Vector(0, child.size.y))
  end

  Container.refresh(self)
end

return LinearContainer
