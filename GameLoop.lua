local class = require 'class'
local Event = require 'Event'
local gl = require 'gl'
local glfw = require 'glfw'

-- Allow for this much inaccuracy in the OS sleep operation
local sleep_error = 0.002

local GameLoop = class()

function GameLoop:_init()
  self.target_framerate = 60
  self.max_frame_time = 0.1

  self.update = Event()
  self.draw = Event()

  self._running = false
end

local function sleep_until(time)
  local time_to_sleep = time - glfw.glfwGetTime() - sleep_error
  if time_to_sleep > 0 then
    glfw.glfwSleep(time_to_sleep)
  end

  -- actually sleep until just barely past the given time
  while time + 0.00001 > glfw.glfwGetTime() do end
end

function GameLoop:enter_loop()
  assert(glfw.glfwInit() == gl.GL_TRUE, 'error initializing glfw')

  self._running = true

  local last_update_time = false
  local update_duration = 1 / self.target_framerate

  while true do
    -- update
    local time = glfw.glfwGetTime()
    last_update_time = last_update_time or time - update_duration - 0.00001
    last_update_time = math.max(last_update_time, time - self.max_frame_time)
    while last_update_time + update_duration < time do
      last_update_time = last_update_time + update_duration
      self.update()
      if not self._running then return end
    end

    self.draw()

    if not self._running then return end

    sleep_until(last_update_time + update_duration)
  end
end

function GameLoop:stop()
  self._running = false
end

return GameLoop
