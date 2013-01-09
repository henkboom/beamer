local blueprint = require 'blueprint'
local Vector = require 'Vector'
local Quaternion = require 'Quaternion'

return blueprint('Root', 'Game', {
  {'video', {'Video', 'self'}},

  -- resources
  {'resources', '{}'},

  {'render_list', {'graphics.RenderList'}},

  -- main rendering
  {'camera', {'graphics.Camera', 'self'}},
  {'camera.transform', {'Transform',
    {'Vector', 0, 0, 0},
    {Quaternion.from_rotation(Vector.j, math.pi/4) *
     Quaternion.from_rotation(Vector.i, -math.pi/6)}
  }},
  {'camera.near_clipping_plane', -100},
  {'camera.far_clipping_plane', 100},
  {'camera.projection_mode', '"orthographic"'},
  {'camera.orthographic_height', 25},

  {'postprocess', {'graphics.PostProcess', 'self', 'self.camera'}},
  {'postprocess.material', {'graphics.Material'}},
  {'postprocess.material.program', {'shaders.textured'}},

  -- gui rendering
  {'gui_render_list', {'graphics.RenderList'}},
  {'gui_camera', {'graphics.Camera', 'self'}},
  {'gui_camera.transform', {'Transform', {'Vector', 0, 0, 0},
    {Quaternion.from_rotation(Vector.i, math.pi/2)}}},
  {'gui_camera.near_clipping_plane', -100},
  {'gui_camera.far_clipping_plane', 100},
  {'gui_camera.projection_mode', '"orthographic"'},
  {'gui_camera.orthographic_height', 30},
  {'gui_camera.orthographic_alignment', {'Vector', 1, 0}},
  {'gui_camera.render_lists', '{self.gui_render_list}'},
  {'gui_camera.clear_color', false},

  {'widget_manager', {'gui.WidgetManager', 'self'}},
  {'blueprint_view',
    {'gui.BlueprintView', 'self.widget_manager.root', 'require "Track"'}},

  -- player
  {'player_ship', {'PlayerShip', 'self'}},
  {'player_ship.transform.position', {'Vector', 48, 0, 0}},

  -- track
  {'track_colliders', '{}'},
  {'track', {'Track', 'self'}}
})
