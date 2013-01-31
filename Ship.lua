local blueprint = require 'blueprint'

return blueprint('Ship', 'Component', {
  {'transform', {'Transform'}},
  {'ship_motion', {'ShipMotion', 'self'}},
  {'renderer', {'graphics.MeshRenderer', 'self'}},
  {'renderer.transform', 'self.transform'},
  {'renderer.material', {'materials.Basic'}},
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
