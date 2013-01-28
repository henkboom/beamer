--- system.thread
--- =============
---
--- Platform-specific thread initialization.

local ffi = require 'ffi'
local pthread = require 'bindings.pthread'
local system = require 'system'

local thread = {}

local bootstrap_code = [[
local logging = require 'system.logging'
local ffi = require 'ffi'

local function entry_point (arg)
  local result, err = xpcall(function ()
    assert(loadstring(code))()(arg)
  end, debug.traceback)
  if not result then
    logging.log('error from secondary thread: ' .. err)
  end
end

return function (entry_point_ptr)
  -- TODO deallocate callback when thread closes
  ffi.cast('void*(**)(void*)', entry_point_ptr)[0] = entry_point
end
]]

local function call(L, nargs, nresults, errfunc)
  local result = lua.lua_pcall(L, nargs, nresults, errfunc)
  if result ~= 0 then
    local err = ffi.string(lua.lua_tolstring(L, -1, nil))
    error('ERROR: [' .. err .. ']')
  end
end

function thread.start(code, arg)
  local lua = require 'bindings.lua'
  local L = lua.luaL_newstate()
  lua.luaL_openlibs(L)
  lua.lua_getfield(L, lua.LUA_GLOBALSINDEX, 'debug');
  lua.lua_getfield(L, -1, 'traceback');
  lua.luaL_loadstring(L, string.format("local code = %q\n%s", code, bootstrap_code))
  call(L, 0, 1, -2)

  local entry_point_ptr = ffi.new('void *(*[1])(void*)')
  lua.lua_pushlightuserdata(L, entry_point_ptr)
  call(L, 1, 0, -3)

  -- TODO close the thread and lua state?
  local pthread_ptr = ffi.new('pthread_t[1]')
  pthread.pthread_create(pthread_ptr, nil, entry_point_ptr[0], arg)
end

thread.mutex_type = ffi.typeof('pthread_mutex_t')

function thread.mutex_init(mutex)
  pthread.pthread_mutex_init(mutex, nil)
end

function thread.mutex_destroy(mutex)
  pthread.pthread_mutex_destroy(mutex)
end

function thread.mutex_lock(mutex)
  pthread.pthread_mutex_lock(mutex)
end

function thread.mutex_try_lock(mutex)
  pthread.pthread_mutex_trylock(mutex)
end

function thread.mutex_unlock(mutex)
  pthread.pthread_mutex_unlock(mutex)
end

return thread
