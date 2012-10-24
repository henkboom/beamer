--- System
--- ======
---
--- System info.

local system_mt = {}
local system = setmetatable({}, system_mt)

function system_mt:index(k)
  if k == 'platform' then
    system.init()
    return system[k]
  else
    return nil
  end
end

function system.init(platform)
  assert(rawget(system, 'platform') == nil,
    'system initialized multiple times')
  system.platform = platform or string.lower(jit.os)
end

return system
