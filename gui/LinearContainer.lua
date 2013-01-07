--- gui.LinearContainer
--- ===================

local class = require 'class'
local Component = require 'Component'
local Vector = require 'Vector'
local Widget = require 'gui.Widget'

local LinearContainer = class('LinearContainer', Widget)

local _orientation = {'orientation'}
local _refreshing = {'refreshing'}

function LinearContainer:_init(parent)
  self:super(parent)
  self.orientation = 'vertical'
  self[_refreshing] = false

  self.started:add_handler(function ()
    self:add_handler_for(self.child_changed, '_refresh')
    self:_refresh()
  end)
end

function LinearContainer:get_orientation()
  return self[_orientation]
end

function LinearContainer:set_orientation(orientation)
  assert(orientation == 'vertical' or orientation == 'horizontal',
         'invalid orientation')
  self[_orientation] = orientation
end

function LinearContainer:_refresh()
  if not self[_refreshing] then
    self[_refreshing] = true

    local pos = Vector.zero
    local thickness = 0
    for _, child in ipairs(self.children) do
      child.transform.local_transform.position = pos
      pos = pos + (self.orientation == 'horizontal'
        and Vector(child.size.x, 0)
        or Vector(0, child.size.y))
      thickness = math.max(thickness,
        self.orientation == 'horizontal' and child.size.y or child.size.x)
    end

    self.size = self.orientation == 'horizontal' and
      Vector(pos.x, thickness) or
      Vector(thickness, pos.y)

    self[_refreshing] = false
  end
end

return LinearContainer
