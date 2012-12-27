local blueprint = require 'blueprint'
local Vector = require 'Vector'
local Quaternion = require 'Quaternion'

return blueprint('Root', 'Game', {
  {'self.video', {'Video', 'self'}},

  -- main rendering
  {'self.render_list', {'graphics.RenderList'}},
  {'self.camera', {'graphics.Camera', 'self'}},
  {'self.camera.transform', {'Transform',
    {'Vector', 0, 0, 0},
    {Quaternion.from_rotation(Vector.j, math.pi/4) *
     Quaternion.from_rotation(Vector.i, -math.pi/6)}
  }},
  {'self.camera.near_clipping_plane', -100},
  {'self.camera.far_clipping_plane', 100},
  {'self.camera.projection_mode', '"orthographic"'},
  {'self.camera.orthographic_height', 25},

  {'self.postprocess', {'graphics.PostProcess', 'self', 'self.camera'}},
  {'self.postprocess.material', {'graphics.Material'}},
  {'self.postprocess.material.program', {'shaders.textured'}},

  -- gui rendering
  {'self.gui_render_list', {'graphics.RenderList'}},
  {'self.gui_camera', {'graphics.Camera', 'self'}},
  {'self.gui_camera.transform', {'Transform', {'Vector', 0, 0, 0},
    {Quaternion.from_rotation(Vector.i, math.pi/2)}}},
  {'self.gui_camera.near_clipping_plane', -100},
  {'self.gui_camera.far_clipping_plane', 100},
  {'self.gui_camera.projection_mode', '"orthographic"'},
  {'self.gui_camera.orthographic_height', 20},
  {'self.gui_camera.orthographic_alignment', {'Vector', 1, 0}},
  {'self.gui_camera.render_lists', '{self.gui_render_list}'},
  {'self.gui_camera.clear_color', false},

  {'self.widget_manager', {'gui.WidgetManager', 'self'}},

  -- player
  {'self.player_ship', {'PlayerShip', 'self'}},
  {'self.player_ship.transform.position', {'Vector', 48, 0, 0}},

  -- track
  {'self.track_colliders', '{}'},

  {'self.wall1', {'TrackWall', 'self'}},
  {'self.wall1.transform', {'Transform'}},
  {'self.wall1.curve', {'BezierCurve',
    {'Vector',   0, -64, 0},
    {'Vector',  32, -64, 0},
    {'Vector',  64, -32, 0},
    {'Vector',  64,   0, 0},
  }},

  {'self.wall2', {'TrackWall', 'self'}},
  {'self.wall2.transform', {'Transform'}},
  {'self.wall2.curve', {'BezierCurve',
    {'Vector',   0,  64, 0},
    {'Vector',  32,  64, 0},
    {'Vector',  64,  32, 0},
    {'Vector',  64,   0, 0},
  }},

  {'self.wall3', {'TrackWall', 'self'}},
  {'self.wall3.transform', {'Transform'}},
  {'self.wall3.curve', {'BezierCurve',
    {'Vector',   0, -64, 0},
    {'Vector', -32, -64, 0},
    {'Vector', -64, -32, 0},
    {'Vector', -64,   0, 0},
  }},

  {'self.wall4', {'TrackWall', 'self'}},
  {'self.wall4.transform', {'Transform'}},
  {'self.wall4.curve', {'BezierCurve',
    {'Vector',   0,  64, 0},
    {'Vector', -32,  64, 0},
    {'Vector', -64,  32, 0},
    {'Vector', -64,   0, 0},
  }},


  {'self.wall5', {'TrackWall', 'self'}},
  {'self.wall5.transform', {'Transform'}},
  {'self.wall5.curve', {'BezierCurve',
    {'Vector',   0, -32, 0},
    {'Vector',  32, -32, 0},
    {'Vector',  32, -32, 0},
    {'Vector',  32,   0, 0},
  }},

  {'self.wall6', {'TrackWall', 'self'}},
  {'self.wall6.transform', {'Transform'}},
  {'self.wall6.curve', {'BezierCurve',
    {'Vector',   0,  32, 0},
    {'Vector',  32,  32, 0},
    {'Vector',  32,  32, 0},
    {'Vector',  32,   0, 0},
  }},

  {'self.wall7', {'TrackWall', 'self'}},
  {'self.wall7.transform', {'Transform'}},
  {'self.wall7.curve', {'BezierCurve',
    {'Vector',   0, -32, 0},
    {'Vector', -32, -32, 0},
    {'Vector', -32, -32, 0},
    {'Vector', -32,   0, 0},
  }},

  {'self.wall8', {'TrackWall', 'self'}},
  {'self.wall8.transform', {'Transform'}},
  {'self.wall8.curve', {'BezierCurve',
    {'Vector',   0,  32, 0},
    {'Vector', -32,  32, 0},
    {'Vector', -32,  32, 0},
    {'Vector', -32,   0, 0},
  }},
})
