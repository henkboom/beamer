local class = require 'class'
local Event = require 'Event'
local gl = require 'gl'
local input = require 'system.input'
local timing = require 'system.timing'

-- Allow for this much inaccuracy in the OS sleep operation
local sleep_error = 0.002

local GameLoop = class('GameLoop')

function GameLoop:_init()
  self.target_framerate = 60
  self.max_frame_time = 0.1

  self.update = Event()
  self.draw = Event()
  self.handle_event = Event()

  self._running = false
end

local function sleep_until(time)
  local time_to_sleep = time - timing.get_time() - sleep_error
  if time_to_sleep > 0 then
    timing.sleep(time_to_sleep)
  end

  -- actually sleep until just barely past the given time
  while time + 0.00001 > timing.get_time() do end
end

function GameLoop:enter_loop()
  input.init()
  timing.init()

  self._running = true

  local last_update_time = false
  local update_duration = 1 / self.target_framerate

  while true do
    -- handle events
    input.poll_events()
    local event = input.get_event()
    while event do
      self.handle_event(event)
      if event.type == 'kill' then
        self._running = false
      end
      event = input.get_event()
    end

    -- update
    local time = timing.get_time()
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
