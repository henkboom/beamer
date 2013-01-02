local blueprint = require 'blueprint'
local Vector = require 'Vector'

return blueprint('Track', 'Component', {
  {'wall1', {'TrackWall', 'self'}},
  {'wall1.curve', {'BezierCurve',
    {'Vector',   0, -64, 0},
    {'Vector',  32, -64, 0},
    {'Vector',  64, -32, 0},
    {'Vector',  64,   0, 0},
  }},

  {'wall2', {'TrackWall', 'self'}},
  {'wall2.curve', {'BezierCurve',
    {'Vector',   0,  64, 0},
    {'Vector',  32,  64, 0},
    {'Vector',  64,  32, 0},
    {'Vector',  64,   0, 0},
  }},

  {'wall3', {'TrackWall', 'self'}},
  {'wall3.curve', {'BezierCurve',
    {'Vector',   0, -64, 0},
    {'Vector', -32, -64, 0},
    {'Vector', -64, -32, 0},
    {'Vector', -64,   0, 0},
  }},

  {'wall4', {'TrackWall', 'self'}},
  {'wall4.curve', {'BezierCurve',
    {'Vector',   0,  64, 0},
    {'Vector', -32,  64, 0},
    {'Vector', -64,  32, 0},
    {'Vector', -64,   0, 0},
  }},


  {'wall5', {'TrackWall', 'self'}},
  {'wall5.curve', {'BezierCurve',
    {'Vector',   0, -32, 0},
    {'Vector',  32, -32, 0},
    {'Vector',  32, -32, 0},
    {'Vector',  32,   0, 0},
  }},

  {'wall6', {'TrackWall', 'self'}},
  {'wall6.curve', {'BezierCurve',
    {'Vector',   0,  32, 0},
    {'Vector',  32,  32, 0},
    {'Vector',  32,  32, 0},
    {'Vector',  32,   0, 0},
  }},

  {'wall7', {'TrackWall', 'self'}},
  {'wall7.curve', {'BezierCurve',
    {'Vector',   0, -32, 0},
    {'Vector', -32, -32, 0},
    {'Vector', -32, -32, 0},
    {'Vector', -32,   0, 0},
  }},

  {'wall8', {'TrackWall', 'self'}},
  {'wall8.curve', {'BezierCurve',
    {'Vector',   0,  32, 0},
    {'Vector', -32,  32, 0},
    {'Vector', -32,  32, 0},
    {'Vector', -32,   0, 0},
  }},
})
