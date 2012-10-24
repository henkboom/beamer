--- physics
--- =======

local physics = {}

local Vector = require 'Vector'

function physics.collision_check(a_transform, a_support, b_transform, b_support)
  return not not gjk_origin_0(function(direction)
    return
      a_transform:transform_point(
        a_support(a_transform:inverse_transform_direction(direction))) +
      b_transform:transform_point(
        b_support(b_transform:inverse_transform_direction(-direction)))
  end)
end

--- gjk_origin
--- ---------------------------------------------------------------------------
--- Detects whether or not a shape (defined by a support function) contains the
--- origin.

local gjk_origin_0
local gjk_origin_1
local gjk_origin_2
local gjk_origin_3

function gjk_origin_0(support)
  print(0)
  return gjk_origin_1(support, support(Vector.i))
end

function gjk_origin_1(support, a)
  print(1, a)
  local direction = -a
  local new_vertex = support(direction)
  if Vector.dot(direction, new_vertex) >= 0 then
    return gjk_origin_2(support, new_vertex, a)
  else
    return nil
  end
end

function gjk_origin_2(support, a, b)
  print(2, a, b)
  if Vector.dot(-a, b-a) < 0 then
    -- a-end region
    return gjk_origin_1(support, a)
  else
    -- line region
    local direction = -(a + Vector.project(-a, b-a))
    local new_vertex = support(direction)
    print(direction, new_vertex, Vector.dot(direction, new_vertex))
    if Vector.dot(direction, new_vertex) >= 0 then
      return gjk_origin_3(support, new_vertex, a, b)
    else
      return nil
    end
  end
end

function gjk_origin_3(support, a, b, c)
  print(3, a, b, c)
  local normal = Vector.cross(b-a, c-a)
  local ab_out = Vector.cross(b-a,normal)
  local ac_out = Vector.cross(normal, c-a)
  
  if Vector.dot(ab_out, -a) > 0 then
    return gjk_origin_2(support, a, b)
  elseif Vector.dot(ac_out, -a) > 0 then
    return gjk_origin_2(support, a, c)
  else
    return {a, b, c}
  end
end

--- gjk does it work?
--- ---------------------------------------------------------------------------

local function make_mesh_support(vertices)
  return function (direction)
    local point
    local distance = -math.huge
    for i = 1, #vertices do
      local new_distance = Vector.dot(vertices[i], direction)
      if new_distance > distance then
        point = vertices[i]
        distance = new_distance
      end
    end
    return point
  end
end

print('answer', unpack(gjk_origin_0(function (d) return d == Vector.zero and Vector.i or d:normalized() end)))

return physics
