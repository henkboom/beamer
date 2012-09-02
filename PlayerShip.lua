--- PlayerShip
--- ==========

local blueprint = require 'blueprint'

return blueprint('PlayerShip', 'Ship', {
  {'self.player_input', {'PlayerInput', 'self'}}, -- eventually this is global
  {'self.player_ship_input', {'PlayerShipInput', 'self'}},
  {'self.player_ship_input.ship_motion', 'self.ship_motion'},
  {'self.player_ship_input.input', 'self.player_input'},
})
