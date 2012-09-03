--- BezierCurve
--- ===========

local class = require 'class'

-- for now only deals with quadratic bezier curves
local BezierCurve = class('BezierCurve')

function BezierCurve:_init(p0, p1, p2, p3)
  self.p0 = p0
  self.p1 = p1
  self.p2 = p2
  self.p3 = p3
end

function BezierCurve:__tostring()
  return string.format('BezierCurve(%s, %s, %s, %s)',
    tostring(self.p0), tostring(self.p1), tostring(self.p2), tostring(self.p3))
end

function BezierCurve:subdivide(t)
  t = t or 0.5
  local invt = 1 - t
  local p01 =   self.p0 * invt + self.p1 * t
  local p12 =   self.p1 * invt + self.p2 * t
  local p23 =   self.p2 * invt + self.p3 * t
  local p012 =  p01 * invt +     p12 * t
  local p123 =  p12 * invt +     p23 * t
  local p0123 = p012 * invt +    p123 * t
  return BezierCurve(self.p0, p01, p012, p0123),
         BezierCurve(p0123, p123, p23, self.p3)
end

local Vector = require 'Vector'
local b = BezierCurve(Vector(0,0),Vector(0,1), Vector(1,2), Vector(2,2))
print(b)
print(b:subdivide(0.5))
return BezierCurve
