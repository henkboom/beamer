--- Transform
--- =========
---
--- Holds a position and an orientation. Notifies through an event on changes.

local class = require 'class'
local Event = require 'Event'
local Quaternion = require 'Quaternion'
local Vector = require 'Vector'

local Transform = class('Transform')

function Transform:_init(position, orientation)
  self.changed = Event()
  self._position = position or Vector.zero
  self._orientation = orientation or Quaternion.identity
end

function Transform:get_position()
  return self._position
end

function Transform:set_position(position)
  if self._position ~= position then
    self._position = position
    self.changed(self)
  end
end

function Transform:get_orientation()
  return self._orientation
end

function Transform:set_orientation(orientation)
  if self._orientation ~= orientation then
    self._orientation = orientation
    self.changed(self)
  end
end

function Transform:transform_point(point)
  return self.orientation:rotate_vector(point) + self.position
end

function Transform:inverse_transform_point(point)
  return self.orientation:conjugate():rotate_vector(point - self.position)
end

function Transform:transform_direction(direction)
  return self.orientation:rotate_vector(direction)
end

function Transform:inverse_transform_direction(direction)
  return self.orientation:conjugate():rotate_vector(direction)
end

return Transform
