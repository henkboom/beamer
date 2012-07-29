--- Matrix
--- ======
---
--- 4x4 matrix, used to store three dimensional transformations. Matrix
--- elements are stored in column-major order, with indeces ranging from 0-15.

local ffi = require 'ffi'
local Vector = require 'Vector'

local matrix_type = ffi.typeof('struct { float n[16]; }')

local Matrix = setmetatable({}, {
  __call = function (...) return matrix_type(...) end
})

Matrix.type = matrix_type

function Matrix.is_type_of(value)
  return ffi.istype(matrix_type, value)
end

function Matrix.from_transform(position, orientation, scale)
  assert(position, 'missing position')
  assert(orientation, 'missing orientation')

  local m = Matrix()
  local i = orientation:rotated_i()
  local j = orientation:rotated_j()
  local k = orientation:rotated_k()

  local scale_x = scale and scale.x or 1
  local scale_y = scale and scale.y or 1
  local scale_z = scale and scale.z or 1

  -- i
  m.n[0] = i.x * scale_x
  m.n[1] = i.y * scale_x
  m.n[2] = i.z * scale_x
  -- j
  m.n[4] = j.x * scale_y
  m.n[5] = j.y * scale_y
  m.n[6] = j.z * scale_y
  -- k
  m.n[8] = k.x * scale_z
  m.n[9] = k.y * scale_z
  m.n[10] = k.z * scale_z

  -- translation
  m.n[12] = position.x
  m.n[13] = position.y
  m.n[14] = position.z
  m.n[15] = 1

  return m
end

function Matrix.perspective(fov_y, aspect, near, far)
  local m = Matrix()

  local f = 1/math.tan(fov_y/2)

  m.n[0] = f/aspect
  m.n[5] = f
  m.n[10] = (near+far)/(near-far)
  m.n[11] = -1
  m.n[14] = (2*far*near)/(near-far)

  --local top = near * math.tan(fov_y/2)
  --m.n[0] = near/(aspect * top)
  --m.n[5] = near/top
  --m.n[10] = -(far+near)/(far-near)
  --m.n[11] = -1
  --m.n[14] = -(2*far*near)/(far-near)

  return m
end

function Matrix.inverse(m)
  local inv = Matrix()
  inv.n[0] =   m.n[5]  * m.n[10] * m.n[15] - m.n[5]  * m.n[11] * m.n[14] - 
               m.n[9]  * m.n[6]  * m.n[15] + m.n[9]  * m.n[7]  * m.n[14] +
               m.n[13] * m.n[6]  * m.n[11] - m.n[13] * m.n[7]  * m.n[10];
  inv.n[4] =  -m.n[4]  * m.n[10] * m.n[15] + m.n[4]  * m.n[11] * m.n[14] + 
               m.n[8]  * m.n[6]  * m.n[15] - m.n[8]  * m.n[7]  * m.n[14] - 
               m.n[12] * m.n[6]  * m.n[11] + m.n[12] * m.n[7]  * m.n[10];
  inv.n[8] =   m.n[4]  * m.n[9]  * m.n[15] - m.n[4]  * m.n[11] * m.n[13] - 
               m.n[8]  * m.n[5]  * m.n[15] + m.n[8]  * m.n[7]  * m.n[13] + 
               m.n[12] * m.n[5]  * m.n[11] - m.n[12] * m.n[7]  * m.n[9];
  inv.n[12] = -m.n[4]  * m.n[9]  * m.n[14] + m.n[4]  * m.n[10] * m.n[13] +
               m.n[8]  * m.n[5]  * m.n[14] - m.n[8]  * m.n[6]  * m.n[13] - 
               m.n[12] * m.n[5]  * m.n[10] + m.n[12] * m.n[6]  * m.n[9];
  inv.n[1] =  -m.n[1]  * m.n[10] * m.n[15] + m.n[1]  * m.n[11] * m.n[14] + 
               m.n[9]  * m.n[2]  * m.n[15] - m.n[9]  * m.n[3]  * m.n[14] - 
               m.n[13] * m.n[2]  * m.n[11] + m.n[13] * m.n[3]  * m.n[10];
  inv.n[5] =   m.n[0]  * m.n[10] * m.n[15] - m.n[0]  * m.n[11] * m.n[14] - 
               m.n[8]  * m.n[2]  * m.n[15] + m.n[8]  * m.n[3]  * m.n[14] + 
               m.n[12] * m.n[2]  * m.n[11] - m.n[12] * m.n[3]  * m.n[10];
  inv.n[9] =  -m.n[0]  * m.n[9]  * m.n[15] + m.n[0]  * m.n[11] * m.n[13] + 
               m.n[8]  * m.n[1]  * m.n[15] - m.n[8]  * m.n[3]  * m.n[13] - 
               m.n[12] * m.n[1]  * m.n[11] + m.n[12] * m.n[3]  * m.n[9];
  inv.n[13] =  m.n[0]  * m.n[9]  * m.n[14] - m.n[0]  * m.n[10] * m.n[13] - 
               m.n[8]  * m.n[1]  * m.n[14] + m.n[8]  * m.n[2]  * m.n[13] + 
               m.n[12] * m.n[1]  * m.n[10] - m.n[12] * m.n[2]  * m.n[9];
  inv.n[2] =   m.n[1]  * m.n[6]  * m.n[15] - m.n[1]  * m.n[7]  * m.n[14] - 
               m.n[5]  * m.n[2]  * m.n[15] + m.n[5]  * m.n[3]  * m.n[14] + 
               m.n[13] * m.n[2]  * m.n[7]  - m.n[13] * m.n[3]  * m.n[6];
  inv.n[6] =  -m.n[0]  * m.n[6]  * m.n[15] + m.n[0]  * m.n[7]  * m.n[14] + 
               m.n[4]  * m.n[2]  * m.n[15] - m.n[4]  * m.n[3]  * m.n[14] - 
               m.n[12] * m.n[2]  * m.n[7]  + m.n[12] * m.n[3]  * m.n[6];
  inv.n[10] =  m.n[0]  * m.n[5]  * m.n[15] - m.n[0]  * m.n[7]  * m.n[13] - 
               m.n[4]  * m.n[1]  * m.n[15] + m.n[4]  * m.n[3]  * m.n[13] + 
               m.n[12] * m.n[1]  * m.n[7]  - m.n[12] * m.n[3]  * m.n[5];
  inv.n[14] = -m.n[0]  * m.n[5]  * m.n[14] + m.n[0]  * m.n[6]  * m.n[13] + 
               m.n[4]  * m.n[1]  * m.n[14] - m.n[4]  * m.n[2]  * m.n[13] - 
               m.n[12] * m.n[1]  * m.n[6]  + m.n[12] * m.n[2]  * m.n[5];
  inv.n[3] =  -m.n[1]  * m.n[6]  * m.n[11] + m.n[1]  * m.n[7]  * m.n[10] + 
               m.n[5]  * m.n[2]  * m.n[11] - m.n[5]  * m.n[3]  * m.n[10] - 
               m.n[9]  * m.n[2]  * m.n[7]  + m.n[9]  * m.n[3]  * m.n[6];
  inv.n[7] =   m.n[0]  * m.n[6]  * m.n[11] - m.n[0]  * m.n[7]  * m.n[10] - 
               m.n[4]  * m.n[2]  * m.n[11] + m.n[4]  * m.n[3]  * m.n[10] + 
               m.n[8]  * m.n[2]  * m.n[7]  - m.n[8]  * m.n[3]  * m.n[6];
  inv.n[11] = -m.n[0]  * m.n[5]  * m.n[11] + m.n[0]  * m.n[7]  * m.n[9] + 
               m.n[4]  * m.n[1]  * m.n[11] - m.n[4]  * m.n[3]  * m.n[9] - 
               m.n[8]  * m.n[1]  * m.n[7]  + m.n[8]  * m.n[3]  * m.n[5];
  inv.n[15] =  m.n[0]  * m.n[5]  * m.n[10] - m.n[0]  * m.n[6]  * m.n[9] - 
               m.n[4]  * m.n[1]  * m.n[10] + m.n[4]  * m.n[2]  * m.n[9] + 
               m.n[8]  * m.n[1]  * m.n[6]  - m.n[8]  * m.n[2]  * m.n[5];
  local det =
    m.n[0] * inv.n[0] + m.n[1] * inv.n[4] +
    m.n[2] * inv.n[8] + m.n[3] * inv.n[12];

  if det == 0 then
    return false
  else
    for i = 0, 15 do
      inv.n[i] = inv.n[i] / det
    end
    return inv
  end
end

function Matrix.__tostring(m)
  return '[[' .. m[ 0] .. ',' .. m[ 1] .. ',' .. m[ 2] .. ',' .. m[ 3] .. ']' ..
         ' [' .. m[ 4] .. ',' .. m[ 5] .. ',' .. m[ 6] .. ',' .. m[ 7] .. ']' ..
         ' [' .. m[ 8] .. ',' .. m[ 9] .. ',' .. m[10] .. ',' .. m[11] .. ']' ..
         ' [' .. m[12] .. ',' .. m[13] .. ',' .. m[14] .. ',' .. m[15] .. ']]'
end

function Matrix.__index(m, i)
  if type(i) == 'number' then
    return m.n[i]
  else
    return Matrix[i]
  end
end

function Matrix.to_array_reference(m)
  return m.n
end

function Matrix.__mul(a, b)
  assert(a, 'missing left Matrix multiplication operand')
  assert(b, 'missing right Matrix multiplication operand')

  if type(a) == 'number' then
    a, b = b, a
  end

  if ffi.istype(matrix_type, b) then
    -- generated with
    --local num = function (n) return string.format('%2d', n) end
    --for j = 0, 3 do
    --  for i = 0, 3 do
    --    io.write('m.n[' .. num(i + j * 4) .. ']=')
    --    for k = 0, 3 do
    --      io.write('a.n[' .. num(i + k * 4) .. ']*' ..
    --      'b.n[' .. num(k + j * 4) .. ']')
    --      if k ~= 3 then
    --        io.write('+')
    --      end
    --    end
    --    io.write('\n')
    --  end
    --end
    local m = Matrix()
    m.n[ 0] = a.n[ 0]*b.n[ 0]+a.n[ 4]*b.n[ 1]+a.n[ 8]*b.n[ 2]+a.n[12]*b.n[ 3]
    m.n[ 1] = a.n[ 1]*b.n[ 0]+a.n[ 5]*b.n[ 1]+a.n[ 9]*b.n[ 2]+a.n[13]*b.n[ 3]
    m.n[ 2] = a.n[ 2]*b.n[ 0]+a.n[ 6]*b.n[ 1]+a.n[10]*b.n[ 2]+a.n[14]*b.n[ 3]
    m.n[ 3] = a.n[ 3]*b.n[ 0]+a.n[ 7]*b.n[ 1]+a.n[11]*b.n[ 2]+a.n[15]*b.n[ 3]
    m.n[ 4] = a.n[ 0]*b.n[ 4]+a.n[ 4]*b.n[ 5]+a.n[ 8]*b.n[ 6]+a.n[12]*b.n[ 7]
    m.n[ 5] = a.n[ 1]*b.n[ 4]+a.n[ 5]*b.n[ 5]+a.n[ 9]*b.n[ 6]+a.n[13]*b.n[ 7]
    m.n[ 6] = a.n[ 2]*b.n[ 4]+a.n[ 6]*b.n[ 5]+a.n[10]*b.n[ 6]+a.n[14]*b.n[ 7]
    m.n[ 7] = a.n[ 3]*b.n[ 4]+a.n[ 7]*b.n[ 5]+a.n[11]*b.n[ 6]+a.n[15]*b.n[ 7]
    m.n[ 8] = a.n[ 0]*b.n[ 8]+a.n[ 4]*b.n[ 9]+a.n[ 8]*b.n[10]+a.n[12]*b.n[11]
    m.n[ 9] = a.n[ 1]*b.n[ 8]+a.n[ 5]*b.n[ 9]+a.n[ 9]*b.n[10]+a.n[13]*b.n[11]
    m.n[10] = a.n[ 2]*b.n[ 8]+a.n[ 6]*b.n[ 9]+a.n[10]*b.n[10]+a.n[14]*b.n[11]
    m.n[11] = a.n[ 3]*b.n[ 8]+a.n[ 7]*b.n[ 9]+a.n[11]*b.n[10]+a.n[15]*b.n[11]
    m.n[12] = a.n[ 0]*b.n[12]+a.n[ 4]*b.n[13]+a.n[ 8]*b.n[14]+a.n[12]*b.n[15]
    m.n[13] = a.n[ 1]*b.n[12]+a.n[ 5]*b.n[13]+a.n[ 9]*b.n[14]+a.n[13]*b.n[15]
    m.n[14] = a.n[ 2]*b.n[12]+a.n[ 6]*b.n[13]+a.n[10]*b.n[14]+a.n[14]*b.n[15]
    m.n[15] = a.n[ 3]*b.n[12]+a.n[ 7]*b.n[13]+a.n[11]*b.n[14]+a.n[15]*b.n[15]
    return m
  elseif ffi.istype(Vector.type, b) then
    local x = a.n[0]*b.x + a.n[4]*b.y + a.n[ 8]*b.z + a.n[12]
    local y = a.n[1]*b.x + a.n[5]*b.y + a.n[ 9]*b.z + a.n[13]
    local z = a.n[2]*b.x + a.n[6]*b.y + a.n[10]*b.z + a.n[14]
    local w = a.n[3]*b.x + a.n[7]*b.y + a.n[11]*b.z + a.n[15]
    return Vector(x/w, y/w, z/w)
  elseif type(b) == 'number' then
    local m = Matrix()
    for i = 0, 15 do
      m.n[i] = a.n[i] * b
    end
    return m
  else
    error('multiplying Matrix by wrong type')
  end
end

ffi.metatype(matrix_type, Matrix)

Matrix.zero = Matrix()

Matrix.identity = Matrix()
Matrix.identity.n[0] = 1
Matrix.identity.n[5] = 1
Matrix.identity.n[10] = 1
Matrix.identity.n[15] = 1

return Matrix
