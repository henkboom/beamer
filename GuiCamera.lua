local blueprint = require 'blueprint'
local Vector = require 'Vector'
local Quaternion = require 'Quaternion'

return blueprint('GuiCamera', 'graphics.Camera', {
  {'transform', {'Transform', {'Vector', 0, 0, 0},
   Quaternion.from_rotation(Vector.k, math.pi/2) *
   Quaternion.from_rotation(Vector.j, -math.pi/2)
  }},
  {'near_clipping_plane', -100},
  {'far_clipping_plane', 100},
  {'projection_mode', '"orthographic"'},
  {'orthographic_height', 30},
  {'orthographic_alignment', {'Vector', 1, 0}},
  {'render_lists', '{self.parent.gui_render_list}'},
  {'clear_color', false},
})
