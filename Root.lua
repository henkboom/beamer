local blueprint = require 'blueprint'
local Vector = require 'Vector'
local Quaternion = require 'Quaternion'

return blueprint('Root', 'Game', {
  {'video', {'Video', 'self'}},

  -- resources
  {'resources', '{}'},

  {'render_list', {'graphics.RenderList'}},
  {'gui_render_list', {'graphics.RenderList'}},

  -- main rendering
  {'camera', {'TrackCamera', 'self'}},
  --{'postprocess', {'graphics.PostProcess', 'self', 'self.camera'}},
  --{'postprocess.material', {'materials.Textured'}},

  -- gui
  {'gui_camera', {'GuiCamera', 'self'}},

  {'widget_manager', {'gui.WidgetManager', 'self'}},
  {'player_input_widget',
    {'PlayerInputWidget', 'self.widget_manager.root'}},

  --{'blueprint_view',
  --  {'gui.BlueprintView', 'self.widget_manager.root', 'require "Track"'}},

  -- player
  {'player_ship', {'PlayerShip', 'self'}},
  {'player_ship.transform.position', {'Vector', 48, 0, 0}},

  -- track
  {'track_colliders', '{}'},
  {'track', {'Track', 'self'}}
})
