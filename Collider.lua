--- Collider
--- ========

local class = require 'class'
local collision = require 'collision'

local Collider = class('Collider')

function Collider:_init(transform, collision_shape)
  self.transform = transform
  self.collision_shape = collision_shape
end

function Collider:check_collision_with(other)
  return collision.collision_check(
    self.transform, function (...) return self.collision_shape:support(...) end,
    other.transform, function (...) return other.collision_shape:support(...) end,
    other.collision_shape.restricted_normals)
end

function Collider:sweep(sweep, other)
  return collision.collision_sweep(
    self.transform, function (...) return self.collision_shape:support(...) end,
    sweep,
    other.transform, function (...) return other.collision_shape:support(...) end)
end

return Collider
