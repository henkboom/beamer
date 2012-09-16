--- TrackWall
--- =============

local class = require 'class'
local Component = require 'Component'
local Material = require 'Material'
local Mesh = require 'Mesh'
local Vector = require 'Vector'

local TrackWall = class('TrackWall', Component)

function TrackWall:_init(parent)
  self:super(parent)
  self.curve = false
  self.transform = false

  self._renderer = MeshRenderer(self)
  self._renderer.material = Material()
  self._renderer.material.program = require('shaders.basic')()
end

local function put_vector(t, v)
  local len = #t
  t[len+1] = v.x
  t[len+2] = v.y
  t[len+3] = v.z
end

function TrackWall:_start(parent)
  assert(self.transform, 'missing  transform')
  assert(self.curve, 'missing curve')
  
  local elements = {}
  local position = {}

  local segments = self.curve:adaptive_subdivision(0.01)
  for i = 1, #segments do
    local s = segments[i]
    elements[(i-1)*6+1] = (i-1)*4+0
    elements[(i-1)*6+2] = (i-1)*4+1
    elements[(i-1)*6+3] = (i-1)*4+2
    elements[(i-1)*6+4] = (i-1)*4+2
    elements[(i-1)*6+5] = (i-1)*4+3
    elements[(i-1)*6+6] = (i-1)*4+0

    local normal1 = Vector.cross(s.p1-s.p0, Vector.k):normalized() * 0.1
    local normal2 = Vector.cross(s.p1-s.p0, Vector.k):normalized() * 0.1
    put_vector(position, s.p0 + normal1)
    put_vector(position, s.p0 - normal1)
    put_vector(position, s.p3 - normal2)
    put_vector(position, s.p3 + normal2)
  end

  self._renderer.mesh = Mesh({
    elements = elements,
    position = position
  })
end

return TrackWall
