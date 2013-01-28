local blueprint = require 'blueprint'
local Vector = require 'Vector'
local Quaternion = require 'Quaternion'

return blueprint('Root', 'Game', {
  {'video', {'Video', 'self'}},

  -- resources
  {'resources', '{}'},

  -- gui rendering
  {'gui_render_list', {'graphics.RenderList'}},
  {'gui_camera', {'graphics.Camera', 'self'}},
  {'gui_camera.transform', {'Transform', {'Vector', 0, 0, 0},
    {Quaternion.from_rotation(Vector.i, math.pi/2)}}},
  {'gui_camera.near_clipping_plane', -100},
  {'gui_camera.far_clipping_plane', 100},
  {'gui_camera.projection_mode', '"orthographic"'},
  {'gui_camera.orthographic_height', 20},
  {'gui_camera.orthographic_alignment', {'Vector', 1, 0}},
  {'gui_camera.render_lists', '{self.gui_render_list}'},

  {'widget_manager', {'gui.WidgetManager', 'self'}},
  {'sound_effect_editor',
    {'SoundEffectEditor', 'self.widget_manager.root'}},
})
