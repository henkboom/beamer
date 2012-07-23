--- Quaternion
--- ==========
---
--- Used to store rotations. Most of the functions except unit quaternions.

local ffi = require 'ffi'
local Vector = require 'Vector'

local quaternion_type = ffi.typeof('struct { double w, x, y, z; }')
local Quaternion = setmetatable({}, {
  __call = function (_, ...) return quaternion_type(...) end
})

Quaternion.__index = Quaternion
Quaternion.type = quaternion_type

function Quaternion.from_rotation(axis, angle)
  local s = math.sin(angle/2)
  local c = math.cos(angle/2)
  return quaternion_type(c, s * axis.x, s * axis.y, s * axis.z)
end

-- http://www.flipcode.com/documents/matrfaq.html#Q55
-- https://github.com/henkboom/rhizome/blob/master/quaternion.c#L39
--function Quaternion.from_ijk(...)
--  assert(false)
--end

--function Quaternion.look_at(direction, up)
--  assert(false)
--end

function Quaternion.__mul(a, b)
  return quaternion_type(
    a.w*b.w - a.x*b.x - a.y*b.y - a.z*b.z,
    a.w*b.x + a.x*b.w + a.y*b.z - a.z*b.y,
    a.w*b.y + a.y*b.w + a.z*b.x - a.x*b.z,
    a.w*b.z + a.z*b.w + a.x*b.y - a.y*b.x)
end

function Quaternion.square_magnitude(q)
  return q.w*q.w + q.x*q.x + q.y*q.y + q.z*q.z
end

function Quaternion.magnitude(q)
  return math.sqrt(square_magnitude(q))
end

function Quaternion.normalized(q)
  local sm = square_magnitude(q)
  if(math.abs(sm - 1) > 0.000001) then
    local mag = math.sqrt(sm)
    return quaternion_type(q.w/mag, q.x/mag, q.y/mag, q.z/mag)
  end
  return q
end

function Quaternion.conjugate(q)
  return quaternion_type(q.w, -q.x, -q.y, -q.z)
end

function Quaternion.nlerp(a, b, t)
  return norm(quaternion_type(
    a.w*(1-t) + b.w*t,
    a.x*(1-t) + b.x*t,
    a.y*(1-t) + b.y*t,
    a.z*(1-t) + b.z*t))
end

function Quaternion.rotate_vector(q, v)
  local result = q * quaternion_type(0, v.x, v.y, v.z) * conjugate(q)
  return Vector(result.x, result.y, result.z)
end

function Quaternion.rotated_i(q)
  return Vector(
    1 - 2*(q.y*q.y + q.z*q.z),
    2*(q.x*q.y + q.z*q.w),
    2*(q.x*q.z - q.y*q.w))
end

function Quaternion.rotated_j(q)
  return Vector(
    2*(q.x*q.y - q.z*q.w),
    1 - 2*(q.x*q.x + q.z*q.z),
    2*(q.y*q.z + q.x*q.w))
end

function Quaternion.rotated_k(q)
  return Vector(
    2*(q.x*q.z + q.y*q.w),
    2*(q.y*q.z - q.x*q.w),
    1 - 2*(q.x*q.x + q.y*q.y))
end

function Quaternion.to_ijk_string(q)
  return
    '[i = ' .. tostring(rotated_i(q)) ..
    ', j = ' .. tostring(rotated_j(q)) ..
    ', k = ' .. tostring(rotated_k(q)) .. ']'
end

function Quaternion.__tostring(q)
  return string.format('q(%f + %fi + %fj + %fk)', q.w, q.x, q.y, q.z)
end

ffi.metatype(quaternion_type, Quaternion)

Quaternion.identity = quaternion_type(1, 0, 0, 0)

return Quaternion
