--- BezierCurve
--- ===========
---
--- An implementation of quadratic Bezier curves. Immutable.

local class = require 'class'

local BezierCurve = class('BezierCurve')

function BezierCurve:_init(p0, p1, p2, p3)
  self._p0 = p0
  self._p1 = p1
  self._p2 = p2
  self._p3 = p3
end

function BezierCurve:get_p0() return self._p0 end
function BezierCurve:get_p1() return self._p1 end
function BezierCurve:get_p2() return self._p2 end
function BezierCurve:get_p3() return self._p3 end

function BezierCurve:__tostring()
  return string.format('BezierCurve(%s, %s, %s, %s)',
    tostring(self.p0), tostring(self.p1), tostring(self.p2), tostring(self.p3))
end

function BezierCurve:subdivide(t)
  t = t or 0.5
  local invt = 1 - t
  local p01 =   self._p0 * invt + self._p1 * t
  local p12 =   self._p1 * invt + self._p2 * t
  local p23 =   self._p2 * invt + self._p3 * t
  local p012 =       p01 * invt +      p12 * t
  local p123 =       p12 * invt +      p23 * t
  local p0123 =     p012 * invt +     p123 * t
  return BezierCurve(self._p0, p01, p012, p0123),
         BezierCurve(p0123, p123, p23, self._p3)
end

function BezierCurve:adaptive_subdivision(max_error, output)
  max_error = max_error or 0.1
  output = output or {}

  local line = self._p3 - self._p0
  local ctl1 = self._p1 - self._p0
  local ctl2 = self._p2 - self._p3
  if (ctl1 - ctl1:project(line)):square_magnitude() <= max_error*max_error and
     (ctl2 - ctl2:project(line)):square_magnitude() <= max_error*max_error then
    output[#output+1] = self
  else
    local b1, b2 = self:subdivide()
    b1:adaptive_subdivision(max_error, output)
    b2:adaptive_subdivision(max_error, output)
  end

  return output
end

return BezierCurve
