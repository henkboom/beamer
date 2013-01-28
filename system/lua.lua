--- system.lua
--- ==========
---
--- Platform-specific lua vm startup.
---
--- Mostly this is because you might want the packages.* paths to work
--- differently on different platforms.

local system =  require 'system'
local resources = require 'system.resources'

local liblua = require 'bindings.lua'

local bootstrap_android = [[
package.preload['bindings.jni'] = ]] ..
  string.format('%q', resources.load('bindings/jni.lua')) .. [[
package.preload['bindings.android'] = ]] ..
  string.format('%q', resources.load('bindings/android.lua')) .. [[
package.preload['bindings.android'] = ]] ..
  string.format('%q', resources.load('bindings/android.lua')) .. [[
]]

function lua.open()
end

function lua.close()
