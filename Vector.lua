--- Vector
--- ======

local ffi = require 'ffi'

local vector_type = ffi.typeof('struct { double x, y, z; }')
local Vector = setmetatable({}, {
  __call = function (_, ...) return vector_type(...) end
})

Vector.__index = Vector
Vector.type = vector_type

function Vector.is_type_of(value)
  return ffi.istype(vector_type, value)
end

function Vector.__add (a, b)
  return vector_type(a.x+b.x, a.y+b.y, a.z+b.z)
end

function Vector.__sub (a, b)
  return vector_type(a.x-b.x, a.y-b.y, a.z-b.z)
end

function Vector.__unm (v)
  return vector_type(-v.x, -v.y, -v.z)
end

function Vector.__mul (v, s)
  if not ffi.istype(vector_type, v) then
    v, s = s, v
  end
  return vector_type(s*v.x, s*v.y, s*v.z)
end

function Vector.__div (v, s)
  return vector_type(v.x/s, v.y/s, v.z/s)
end

function Vector.__eq (a, b)
  return a.x==b.x and a.y==b.y and a.z==b.z
end

local function is_small(num)
  return math.abs(num) < 1e-15
end
function Vector.__tostring (v)
  return '(' .. (is_small(v.x) and 0 or v.x) .. ', ' ..
                (is_small(v.y) and 0 or v.y) .. ', ' ..
                (is_small(v.z) and 0 or v.z) .. ')'
end

function Vector.dot (a, b)
  return a.x*b.x + a.y*b.y + a.z*b.z
end

function Vector.cross (a, b)
  return vector_type(
    a.y*b.z - a.z*b.y,
    a.z*b.x - a.x*b.z,
    a.x*b.y - a.y*b.x)
end

function Vector.project(a, b)
  return b * (Vector.dot(a, b) / Vector.dot(b, b))
end

function Vector.magnitude (v)
  return math.sqrt(Vector.square_magnitude(v))
end

function Vector.square_magnitude(v)
  return Vector.dot(v, v)
end

function Vector.normalized (v)
  return v / v:magnitude()
end

function Vector.coords (v)
  return v.x, v.y, v.z
end

function Vector.rotate(v, axis, angle)
  local q0 = math.cos(angle/2)
  local s = math.sin(angle/2)
  local q1 = s * axis.x
  local q2 = s * axis.y
  local q3 = s * axis.z
  return vector_type(
    ((q0*q0 + q1*q1 - q2*q2 - q3*q3) * v.x +
     2*(q1*q2 - q0*q3) * v.y +
     2*(q1*q3 + q0*q2) * v.z),
    (2*(q2*q1 + q0*q3) * v.x +
     (q0*q0 - q1*q1 + q2*q2 - q3*q3) * v.y +
     2*(q2*q3 - q0*q1) * v.z),
    (2*(q3*q1 - q0*q2) * v.x +
     2*(q3*q2 + q0*q1) * v.y +
     (q0*q0 - q1*q1 - q2*q2 + q3*q3) * v.z))
end

function Vector.is_small(v)
  return sqrmag(v) <= 0.00001
end

ffi.metatype(vector_type, Vector)

Vector.zero = Vector(0, 0, 0)
Vector.i =    Vector(1, 0, 0)
Vector.j =    Vector(0, 1, 0)
Vector.k =    Vector(0, 0, 1)

return Vector
