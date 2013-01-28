--- System
--- ======
---
--- System info.

local system_mt = {}
local system = setmetatable({}, system_mt)

local function init(platform)
  assert(rawget(system, 'platform') == nil or
         rawget(system, 'platform') == platform,
    'system initialized multiple times')
  system.platform = platform or string.lower(jit.os)
end

function system_mt:__index(k)
  if k == 'platform' then
    init()
    return system[k]
  else
    return nil
  end
end

function system.init_android(android_app)
  system.android = {
    android_app = android_app,
  }
  init('android')
end

return system
