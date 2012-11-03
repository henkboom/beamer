--- MeshCollisionShape
--- ==================
---
-- TODO: rename to collision.MeshShape

local class = require 'class'
local Vector = require 'Vector'

local MeshCollisionShape = class('MeshCollisionShape')

function MeshCollisionShape:_init(vertices, restricted_normals)
  self.vertices = vertices;
  self.restricted_normals = restricted_normals or false
end

function MeshCollisionShape:support(direction)
  local point
  local distance = -math.huge
  for i = 1, #self.vertices do
    local new_distance = Vector.dot(self.vertices[i], direction)
    if new_distance > distance then
      point = self.vertices[i]
      distance = new_distance
    end
  end
  return point
end

return MeshCollisionShape
