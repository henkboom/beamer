--- PlayerShip
--- ==========

local blueprint = require 'blueprint'

return blueprint('PlayerShip', 'Ship', {
  {'player_input', {'PlayerInput', 'self'}}, -- eventually this is global
  {'player_ship_input', {'PlayerShipInput', 'self'}},
  {'player_ship_input.ship_motion', 'self.ship_motion'},
  {'player_ship_input.input', 'self.player_input'},
})
