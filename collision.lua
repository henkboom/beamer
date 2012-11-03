--- collision
--- =========

local collision = {}

local Transform = require 'Transform'
local Vector = require 'Vector'

local gjk_origin_0
local gjk_direction_3

-- directions to test for penetration direction
local directions_to_test = {}
for i = 1, 64 do
  directions_to_test[i] = Vector(math.cos(i/64*math.pi*2), math.sin(i/64*math.pi*2))
end

local function relative_transform(a_transform, b_transform)
  -- a relative to b
  return Transform(
    a_transform.position - b_transform.position,
    a_transform.orientation * b_transform.orientation:conjugate())
end

-- candidate_normals in b-space
function collision.collision_check(
    a_transform, a_support, b_transform, b_support, candidate_normals)
  candidate_normals = candidate_normals or directions_to_test

  -- we compute everything in b-space
  local rel_transform = relative_transform(a_transform, b_transform)

  local support = function(direction)
    if direction == Vector.zero then
      direction = Vector.i
    end
    return
      rel_transform:transform_point(
        a_support(rel_transform:inverse_transform_direction(direction))) -
      b_support(-direction)
  end

  local simplex = gjk_origin_0(support)
  if simplex then
    local direction
    local distance = math.huge
    for i = 1, #candidate_normals do
      local point = support(candidate_normals[i])
      local new_distance = Vector.dot(candidate_normals[i], point)
      if new_distance < distance then
        direction = candidate_normals[i]
        distance = new_distance
      end
    end
    return {
      normal = b_transform:transform_direction(-direction),
      penetration = distance
    }
  else
    return false
  end
end

function collision.collision_sweep(a_transform, a_support, a_sweep,
                                   b_transform, b_support, b_sweep)
  -- we're going to do all computations in b-space
  local rel_transform = relative_transform(a_transform, b_transform)

  -- sweep of a in b-space
  local sweep = b_transform:inverse_transform_direction(
    a_sweep - (b_sweep or Vector.zero))

  -- avoid some degenerate almost-zero-sweep cases
  if Vector.dot(sweep, sweep) == 0 then
    sweep = Vector.zero
  end

  local support = function(direction)
    if direction == Vector.zero then
      direction = Vector.i
    end
    return
      rel_transform:transform_point(
        a_support(rel_transform:inverse_transform_direction(direction))) +
      (Vector.dot(sweep, direction) > 0 and sweep or Vector.zero) -
      b_support(-direction)
  end

  local simplex = gjk_origin_0(support)
  if simplex then
    local penetration
    local a, b = unpack(gjk_direction_3(support, sweep, unpack(simplex)))

    -- a+t*ab = u*sweep
    --
    -- Ax+t*ABx = u*Sx
    -- Ay+t*ABy = u*Sy
    --
    -- t*ABx = u*Sx-Ax
    -- t*ABy = u*Sy-Ay
    --
    -- t = (u*Sx-Ax)/ABx
    -- t = (u*Sy-Ay)/ABy
    --
    -- (u*Sx-Ax)/ABx = (u*Sy-Ay)/ABy
    --
    -- (u*Sx-Ax)*ABy = (u*Sy-Ay)*ABx
    -- u*Sx*ABy - Ax*ABy = u*Sy*ABx - Ay*ABx
    -- u*(Sx*ABy - Sy*ABx) = Ax*ABy - Ay*ABx
    -- u = (Ax*ABy - Ay*ABx) / (Sx*ABy - Sy*ABx)
    -- u = Vector.cross(A, AB).z / Vector.cross(S, AB).z
    -- time = 1 - u

    local backtrack
    local denom = Vector.cross(sweep, b-a).z
    if denom == 0 then
      backtrack = math.max(
        Vector.dot(a, sweep) / Vector.dot(sweep, sweep),
        Vector.dot(b, sweep) / Vector.dot(sweep, sweep))
    else
      backtrack = Vector.cross(a, b-a).z / denom
    end
    local time = math.max(0, math.min(1, 1 - backtrack))

    return {
      time = time
    }
  else
    return false
  end
end

--- gjk_origin
--- ---------------------------------------------------------------------------
--- Detects whether or not a shape (defined by a support function) contains the
--- origin.

local gjk_origin_1
local gjk_origin_2
local gjk_origin_3

function gjk_origin_0(support)
  --print('gjk', 0)
  return gjk_origin_1(support, support(Vector.i))
end

function gjk_origin_1(support, a)
  --print('gjk', 1, a)
  local direction = -a
  local new_vertex = support(direction)
  if Vector.dot(direction, new_vertex) >= 1e-10 then
    return gjk_origin_2(support, new_vertex, a)
  else
    return nil
  end
end

function gjk_origin_2(support, a, b)
  --print('gjk', 2, a, b)
  if Vector.dot(-a, b-a) < 0 then
    -- a-end region
    return gjk_origin_1(support, a)
  else
    -- line region
    local direction = -(a + Vector.project(-a, b-a))
    local new_vertex = support(direction)
    if Vector.dot(direction, new_vertex) >= 1e-10 then
      return gjk_origin_3(support, new_vertex, a, b)
    else
      return nil
    end
  end
end

function gjk_origin_3(support, a, b, c)
  --print('gjk', 3, a, b, c)
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

--- gjk_direction
--- ---------------------------------------------------------------------------
--- Find the intersection of a ray from the origin with a convex shape
--- containing the origin. Starts with a simplex containing the origin.

-- dir a b
-- dir*t = a + ab*u
-- dir . ab != 0

local function line_segment_intersects(dir, a, b)
  local a_cross_dir = Vector.cross(a, dir)
  return
    -- opposide sides of dir
    Vector.dot(a_cross_dir, Vector.cross(b, dir)) <= 0 and
    -- same side of origin
    Vector.dot(a_cross_dir, Vector.cross(a, b)) >= 0
end

function gjk_direction_3(support, dir, a, b, c)
  --TODO would be better to pick the "most" intersecting line, like, if one is
  -- parallel to the direction but there's another not parallel, pick the
  -- nonparallel one
  local new_a, new_b
  if line_segment_intersects(dir, a, b) then
    new_a, new_b = a, b
  elseif line_segment_intersects(dir, a, c) then
    new_a, new_b = a, c
  else
    new_a, new_b = b, c
  end

  if Vector.cross(new_a, dir) == Vector.zero or
     Vector.cross(new_b, dir) == Vector.zero then
    return {a, b}
  else
    return gjk_direction_2(support, dir, new_a, new_b)
  end
end

function gjk_direction_2(support, dir, a, b)
  if a == b then
    return {a, b}
  end
  local support_direction = dir - Vector.project(dir, b-a)
  local c = support(support_direction)
  if a ~= c and b ~= c and Vector.dot(c-a, support_direction) > 0 then
    -- subdivide and recurse
    local c_cross_dir = Vector.cross(c, dir)
    if c_cross_dir == Vector.zero then
      return {a, c}
    elseif Vector.dot(Vector.cross(a, dir), c_cross_dir) <= 0 then
      return gjk_direction_2(support, dir, a, c)
    else
      return gjk_direction_2(support, dir, c, b)
    end
  else
    return {a, b}
  end
end

return collision
