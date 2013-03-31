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
  {'headlight_renderer', {'graphics.MeshRenderer', 'self'}},
  {'headlight_renderer.transform', 'self.transform'},
  {'headlight_renderer.material', {'materials.Basic'}},
  {'headlight_renderer.material.uniforms.color', '{0.15, 0.15, 0.15}'},
  {'headlight_renderer.material.blend_dst', '"one"'},
  {'headlight_renderer.mesh', {'graphics.Mesh', {{
    elements = {0,1,2, 2,3,0},
    position = {
      -0.3, 0.8, 0,
       0.3, 0.8, 0,
       0.6, 2.5, 0,
      -0.6, 2.5, 0
    }
  }}}},
})
