--- Collider
--- ========

local class = require 'class'
local collision = require 'collision'

local Collider = class('Collider')

function Collider:_init(transform, collision_shape)
  self.transform = transform
  self.collision_shape = collision_shape
end

local function square(x)
  return x*x
end

function Collider:get_bounds_center()
  return self.transform:transform_point(self.collision_shape.bounds_center)
end

function Collider:get_bounds_radius()
  return self.collision_shape.bounds_radius
end

function Collider:check_collision_with(other)
  if (self.bounds_center - other.bounds_center):square_magnitude() <=
     square(self.bounds_radius + other.bounds_radius)
  then
    return collision.collision_check(
      self.transform, function (...) return self.collision_shape:support(...) end,
      other.transform, function (...) return other.collision_shape:support(...) end,
      other.collision_shape.restricted_normals)
  else
    return false
  end
end

function Collider:sweep(sweep, other)
  local bounds_center = self.bounds_center + sweep * 0.5
  local bounds_radius = self.bounds_radius + sweep:magnitude() * 0.5

  if (bounds_center - other.bounds_center):square_magnitude() <=
     square(bounds_radius + other.bounds_radius)
  then
    return collision.collision_sweep(
      self.transform, function (...) return self.collision_shape:support(...) end,
      sweep,
      other.transform, function (...) return other.collision_shape:support(...) end)
  else
    return false
  end
end

return Collider
