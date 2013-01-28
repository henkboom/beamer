--- audio.Envelope
--- ==============

local class = require 'class'

local Envelope = class('Envelope')

function Envelope:_init(points)
  points = points or {}
  for i = 1, #points do
    assert(type(points[i]) == 'table' and #points[i] == 2 and
           type(points[i][1]) == 'number' and type(points[i][2]) == 'number',
           'points must be a list of {value, ramp_time} pairs')
  end
  self.points = points
end

-- returns an iterator that returns (time, value, ramp_duration) ramps starting
-- at a given time
function Envelope:ramps(time)
  local i = 0
  time = time or 0
  return function ()
    i = i + 1
    if i > #self.points then
      return nil
    else
      local start_time = time
      time = time + self.points[i][2]
      return start_time, self.points[i][1], self.points[i][2]
    end
  end
end

return Envelope
