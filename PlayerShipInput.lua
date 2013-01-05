--- PlayerShipInput
--- ===============

local class = require 'class'
local Component = require 'Component'

local PlayerShipInput = class('PlayerShipInput', Component)

function PlayerShipInput:_init(parent)
  self:super(parent)

  self.input = false
  self.ship_motion = false

  self.started:add_handler(function ()
    assert(self.input)
    assert(self.ship_motion)
    self:add_handler_for(self.input.changed, function ()
      self.ship_motion.acceleration = self.input.a and 1 or 0
      self.ship_motion.steering = self.input.direction.x
    end)
  end)
end

return PlayerShipInput
