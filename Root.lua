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
  {'self.renderer', {'MeshRenderer', 'self'}},
  {'self.renderer.transform', {'Transform'}},
  {'self.renderer.program', {'shaders.basic'}},
  {'self.renderer.mesh', {{
    vertices = {
      { position = {0, 0, 0} },
      { position = {2, 0, 0} },
      { position = {0, 1, 0} },
    },
    faces = { {1, 2, 3} }
  }}}
})
