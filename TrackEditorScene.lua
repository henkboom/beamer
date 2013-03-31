local blueprint = require 'blueprint'
local Vector = require 'Vector'
local Quaternion = require 'Quaternion'

return blueprint('TrackEditorScene', 'Game', {
  {'video', {'Video', 'self'}},

  -- resources
  {'resources', '{}'},

  {'render_list', {'graphics.RenderList'}},
  {'gui_render_list', {'graphics.RenderList'}},

  {'camera', {'TrackCamera', 'self'}},
  {'gui_camera', {'GuiCamera', 'self'}},
  {'widget_manager', {'gui.WidgetManager', 'self'}},
  {'camera_drag_widget', {'CameraDragWidget', 'self.widget_manager.root', 'self.camera'}},

  {'track_colliders', '{}'},
  {'track', {'Track', 'self'}},

  {'axes', {'AxesRenderer', 'self'}}
})
