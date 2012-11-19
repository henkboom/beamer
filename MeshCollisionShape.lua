--- MeshCollisionShape
--- ==================
---
-- TODO: rename to collision.MeshShape

local class = require 'class'
local Vector = require 'Vector'
local ffi = require 'ffi'

local MeshCollisionShape = class('MeshCollisionShape')

local vector_array_type = ffi.typeof('$[?]', Vector.type)

function MeshCollisionShape:_init(vertices, restricted_normals)
  self.vertices = vector_array_type(#vertices, vertices)
  self.vertex_count = #vertices

  self.restricted_normals = restricted_normals or false

  local min = self.vertices[0]
  local max = self.vertices[0]
  for i = 1, self.vertex_count-1 do
    min = Vector(
      math.min(max.x, self.vertices[i].x),
      math.min(max.y, self.vertices[i].y),
      math.min(max.z, self.vertices[i].z))
    max = Vector(
      math.max(max.x, self.vertices[i].x),
      math.max(max.y, self.vertices[i].y),
      math.max(max.z, self.vertices[i].z))
  end

  self.bounds_center = (min + max) * 0.5

  local radius_sqr = 0
  for i = 0, self.vertex_count-1 do
    radius_sqr = math.max(radius_sqr,
      (self.vertices[i] - self.bounds_center):square_magnitude())
  end
  self.bounds_radius = math.sqrt(radius_sqr)
end

function MeshCollisionShape:support(direction)
  local point
  local distance = -math.huge
  for i = 0, self.vertex_count-1 do
    local new_distance = Vector.dot(self.vertices[i], direction)
    if new_distance > distance then
      point = self.vertices[i]
      distance = new_distance
    end
  end
  return point
end

return MeshCollisionShape
