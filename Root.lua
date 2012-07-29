local blueprint = require 'blueprint'
local Vector = require 'Vector'
local Quaternion = require 'Quaternion'

return blueprint('Root', 'Game', {
  {'self.video', {'Video', 'self'}},
  {'self.render_list', {'RenderList'}},
  {'self.camera', {'Camera', 'self'}},
  {'self.camera.transform', {'Transform',
    {'Vector', 0, 0, 2},
    {Quaternion.from_rotation(Vector.j, math.pi/2)}}},
  {'self.dummy_renderer', {'MeshRenderer', 'self'}},
  {'self.dummy_renderer.transform', {'Transform'}},
  {'self.dummy_renderer.program', {'shaders.basic'}},
  {'self.dummy_renderer.mesh', {'Mesh', {{
    elements = {1, 2, 3},
    position = {0,0,0, 2,0,0, 0,1,0}
  }}}}
})
