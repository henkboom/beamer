require 'strict'

local restarting = true
local reload = require 'reload'

while restarting do
  restarting = false

  local glfw = require 'bindings.glfw'
  local game = require((...) or 'Root')()

  local released = false
  game.events.update:add_handler(function ()
    if glfw.glfwGetKey(string.byte('`')) == glfw.GLFW_RELEASE then
      released = true
    end
    if released and glfw.glfwGetKey(string.byte('`')) == glfw.GLFW_PRESS then
      game:remove()
      restarting = true
    end
  end)

  game:start_game_loop()
  game = nil
  collectgarbage()

  if restarting then
    local reload = require 'reload'
    reload.reload()
  end
end

