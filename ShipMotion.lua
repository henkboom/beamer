--- ShipMotion
--- ==========

local class = require 'class'
local Component = require 'Component'
local Quaternion = require 'Quaternion'
local Vector = require 'Vector'
local Collider = require 'Collider'
local MeshCollisionShape = require 'MeshCollisionShape'

local ShipMotion = class('ShipMotion', Component)

local ACCELERATION = 0.0025
local BRAKE_DAMPING = 0.04
local TURN_SPEED = 0.05

function ShipMotion:_init(parent)
  self:super(parent)

  self.transform = false
  self.collider = false
  self.sweep_collider = false

  -- inputs
  self.acceleration = 0
  self.steering = 0

  self._velocity = Vector.zero;

  self:add_handler_for('update')
end

function ShipMotion:_start()
  self.transform = assert(self.transform or self.parent.transform)
  self.collider = Collider(self.transform, MeshCollisionShape({
    Vector(-0.3, -0.5),
    Vector( 0.3, -0.5),
    Vector( 0.3,  0.5),
    Vector(-0.3,  0.5)
  }))
  self.sweep_collider = Collider(self.transform, MeshCollisionShape({
    Vector(-0.2, -0.4),
    Vector( 0.2, -0.4),
    Vector( 0.2,  0.4),
    Vector(-0.2,  0.4)
  }))
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
  local movement_time = 1
  for i = 1, #self.game.track_colliders do
    local collision = self.sweep_collider:sweep(
      self._velocity, self.game.track_colliders[i])
    if collision and collision.time < movement_time then
      movement_time = collision.time
    end
  end
  t.position = t.position + movement_time * self._velocity

  -- collision (this could be improved, strictly ordered and such)
  for i = 1, #self.game.track_colliders do
    local collision = self.collider:check_collision_with(self.game.track_colliders[i])
    if collision then
      --print('collision', collision.penetration)
      self.transform.position = self.transform.position +
        collision.normal * collision.penetration
      if Vector.dot(self._velocity, collision.normal) < 0 then
        self._velocity = self._velocity - Vector.project(self._velocity, collision.normal)*1.2
      end
    end
  end

  -- TODO move this
  self.game.camera.transform.position =
    self.game.camera.transform.position * 0.9 +
    (self.transform.position + self._velocity*15) * 0.1
end

return ShipMotion
