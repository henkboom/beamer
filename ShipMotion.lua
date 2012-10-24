--- ShipMotion
--- ==========

local class = require 'class'
local Component = require 'Component'
local Quaternion = require 'Quaternion'
local Vector = require 'Vector'

local ShipMotion = class('ShipMotion', Component)

local ACCELERATION = 0.0025
local BRAKE_DAMPING = 0.04
local TURN_SPEED = 0.05

function ShipMotion:_init(parent)
  self:super(parent)

  self.transform = false

  -- inputs
  self.acceleration = 0
  self.steering = 0

  self._velocity = Vector.zero;

  self:add_handler_for('update')
end

function ShipMotion:_start()
  self.transform = assert(self.transform or self.parent.transform)
end

function ShipMotion:update()
  local t = self.transform
  local forwards = t.orientation:rotated_j()
  local right = t.orientation:rotated_i()

  -- turn
  t.orientation = t.orientation *
    Quaternion.from_rotation(Vector.k, -self.steering * TURN_SPEED)

  -- accelerate
  self._velocity = self._velocity + forwards * ACCELERATION * self.acceleration

  -- damping
  local straightness = math.min(1,
    self._velocity == Vector.zero and 0 or
      Vector.dot(self._velocity:normalized(), forwards))
  local damping
  if straightness <= 0 then
    damping = self._velocity * BRAKE_DAMPING
  else
    damping = Vector.project(self._velocity, right) * BRAKE_DAMPING
  end

  local boost = Vector.zero
  if damping ~= Vector.zero then
    boost = damping:project(self._velocity):magnitude() * forwards
      * straightness * straightness
  end
  self._velocity = self._velocity - damping + boost

  -- movement
  t.position = t.position + self._velocity
end

return ShipMotion
