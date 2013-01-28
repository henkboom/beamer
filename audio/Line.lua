local ffi = require 'ffi'

-- internal representation: f(t) = a*min(t, endpoint) + b
ffi.cdef [[ typedef struct { double a, b, endpoint; } line_s; ]]
local line_s = ffi.metatype('line_s', {
  __index = {
    at = function (self, t)
      return self.a*math.min(t, self.endpoint) + self.b
    end
  }
})

-- line from one point to another
function Line(time_a, value_a, time_b, value_b)
  print(time_a, value_a, time_b, value_b)
  if time_b - time_a == 0 then
    return line_s(0, value_b, time_b)
  else
    local a = (value_b - value_a) / (time_b - time_a)
    local b = value_a - time_a * a
    return line_s(a, b, time_b)
  end
end

return Line
