local blueprint = require 'blueprint'
local Vector = require 'Vector'
local Quaternion = require 'Quaternion'

return blueprint('Root', 'Game', {
  {'self.video', {'Video', 'self'}},
  {'self.render_list', {'RenderList'}},
  {'self.camera', {'Camera', 'self'}},
  {'self.camera.transform', {'Transform',
    {'Vector', 0, 0, 0},
    {Quaternion.from_rotation(Vector.j, math.pi/4) *
     Quaternion.from_rotation(Vector.i, -math.pi/6)
   }}},
  {'self.camera.near_clipping_plane', -100},
  {'self.camera.far_clipping_plane', 100},
  {'self.camera.projection_mode', '"orthographic"'},
  {'self.camera.orthographic_height', 30},
  {'self.player_ship', {'PlayerShip', 'self'}},
  {'self.text', {'TextRenderer', 'self'}},
})
