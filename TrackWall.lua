--- TrackWall
--- =============

local class = require 'class'
local Component = require 'Component'
local Collider = require 'Collider'
local Material = require 'graphics.Material'
local Mesh = require 'graphics.Mesh'
local MeshCollisionShape = require 'MeshCollisionShape'
local Transform = require 'Transform'
local Vector = require 'Vector'

local TrackWall = class('TrackWall', Component)

function TrackWall:_init(parent)
  self:super(parent)
  self.curve = false

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
  assert(self.curve, 'missing curve')
  
  local elements = {}
  local position = {}

  local segments = self.curve:adaptive_subdivision(0.2)
  for i = 1, #segments do
    local s = segments[i]
    elements[(i-1)*6+1] = (i-1)*4+0
    elements[(i-1)*6+2] = (i-1)*4+1
    elements[(i-1)*6+3] = (i-1)*4+2
    elements[(i-1)*6+4] = (i-1)*4+2
    elements[(i-1)*6+5] = (i-1)*4+3
    elements[(i-1)*6+6] = (i-1)*4+0

    local normal = Vector.cross(s.p3-s.p0, Vector.k):normalized()
    -- real line
    put_vector(position, s.p0 + normal*0.1)
    put_vector(position, s.p0 - normal*0.1)
    put_vector(position, s.p3 - normal*0.1)
    put_vector(position, s.p3 + normal*0.1)
    -- collider line
    --put_vector(position, s.p0)
    --put_vector(position, s.p3)
    --put_vector(position, (s.p0+s.p3)*0.5 + normal_right)
    table.insert(self.game.track_colliders, Collider(
      Transform(),
      MeshCollisionShape({
        s.p0, s.p3
        --s.p0 + normal*0.1,
        --s.p0 - normal*0.1,
        --s.p3 - normal*0.1,
        --s.p3 + normal*0.1
      }, {
        normal,
        -normal
      })))
  end

  self._renderer.mesh = Mesh({
    elements = elements,
    position = position
  })
end

return TrackWall
