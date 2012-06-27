local class = require 'class'
local Vector = require 'Vector'
local Quaternion = require 'Quaternion'

local Transform = class()
Transform._name = 'Transform'

function Transform:_init(position, orientation)
  self.position = position or Vector.zero
  self.orientation = orientation or Quaternion.identity
end

return Transform
