local blueprint = require 'blueprint'

return blueprint('Ship', 'Component', {
  {'self.transform', {'Transform'}},
  {'self.ship_motion', {'ShipMotion', 'self'}},
  {'self.renderer', {'graphics.MeshRenderer', 'self'}},
  {'self.renderer.transform', 'self.transform'},
  {'self.renderer.material', {'graphics.Material'}},
  {'self.renderer.material.program', {'shaders.basic'}},
  {'self.renderer.mesh', {'graphics.Mesh', {{
    elements = {0,1,2, 2,3,0},
    position = {
      -0.3,-0.5, 0,
       0.3,-0.5, 0,
       0.3, 0.5, 0,
      -0.3, 0.5, 0
    }
  }}}},
})
