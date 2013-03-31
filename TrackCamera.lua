local blueprint = require 'blueprint'
local Vector = require 'Vector'
local Quaternion = require 'Quaternion'

return blueprint('Root', 'graphics.Camera', {
  {'transform', {'Transform',
    {'Vector', 0, 0, 0},
    Quaternion.from_rotation(Vector.k,  math.pi/4) *
    Quaternion.from_rotation(Vector.j,  math.pi/6)}},
  {'near_clipping_plane',  -100},
  {'far_clipping_plane', 100},
  {'projection_mode', '"orthographic"'},
  {'orthographic_height', 20},
  {'axes', {'AxesRenderer', 'self'}}
})
