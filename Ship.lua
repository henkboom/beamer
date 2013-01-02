local blueprint = require 'blueprint'

return blueprint('Ship', 'Component', {
  {'transform', {'Transform'}},
  {'ship_motion', {'ShipMotion', 'self'}},
  {'renderer', {'graphics.MeshRenderer', 'self'}},
  {'renderer.transform', 'self.transform'},
  {'renderer.material', {'graphics.Material'}},
  {'renderer.material.program', {'shaders.basic'}},
  {'renderer.mesh', {'graphics.Mesh', {{
    elements = {0,1,2, 2,3,0},
    position = {
      -0.3,-0.5, 0,
       0.3,-0.5, 0,
       0.3, 0.5, 0,
      -0.3, 0.5, 0
    }
  }}}},
})
