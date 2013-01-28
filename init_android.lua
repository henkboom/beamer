require 'strict'
local system = require 'system'

system.platform = 'android'

local android = require 'bindings.android'
local glue = require 'bindings.android_native_app_glue'
local ffi = require 'ffi'
local video = require 'system.video'
local logging = require 'system.logging'

local android_app = ffi.cast('struct android_app*', (...))
system.init_android(android_app)

--------

local running = false

--------

local function handle_command(_, cmd)
  if cmd == glue.APP_CMD_INIT_WINDOW then
    running = true
  end
end

local function call_uncompiled(fn, ...)
  return fn(...)
end
jit.off(call_uncompiled)

local function main_loop()
  android_app.onAppCmd = handle_command
  android_app.onInputEvent = nil

  local events = ffi.new('int[1]')
  local poll_source = ffi.new('struct android_poll_source*[1]')
  while true do
    local ident = call_uncompiled(android.ALooper_pollAll,
      -1, nil, events, ffi.cast('void**', poll_source))
    while ident >= 0 do
      if poll_source[0] ~= nil then
        call_uncompiled(poll_source[0].process, android_app, poll_source[0])
      end

      if running then
        video.android_set_window(android_app.window)

        -- run game
        logging.log('starting game')
        local game = require('Root')()
        game:start_game_loop()
        logging.log('ending game')
        game = nil
        collectgarbage()

        running = false
        video.android_set_window(nil)
        android_app.onAppCmd = handle_command
        android_app.onInputEvent = nil
      end

      if android_app.destroyRequested ~= 0 then
        logging.log("destroy")
        return
      end

      ident = call_uncompiled(android.ALooper_pollAll,
        -1, nil, events, ffi.cast('void**', poll_source))
    end
  end
end

--------

main_loop()
