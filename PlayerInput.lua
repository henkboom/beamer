--- PlayerInput
--- ===========

local class = require 'class'
local Component = require 'Component'
local Event = require 'Event'
local Vector = require 'Vector'
local logging = require 'system.logging'

local PlayerInput = class('PlayerInput', Component)

local keys = {
  --up = glfw.GLFW_KEY_UP,
  --down = glfw.GLFW_KEY_DOWN,
  --left = glfw.GLFW_KEY_LEFT,
  --right = glfw.GLFW_KEY_RIGHT,
  a = string.byte('X'),
  b = string.byte('C')
}

function PlayerInput:_init(parent)
  self:super(parent)

  self.joystick_number = 0

  self.direction = Vector.zero
  self.a = false
  self.b = false

  self._delta = 0
  
  self.changed = Event()

  self:add_handler_for('preupdate')
  self:add_handler_for('handle_event')
end

--local axis_count = 6
--local button_count = 14
--local joyaxes = ffi.new('float[?]', axis_count)
--local joybuttons = ffi.new('unsigned char[?]', button_count)

local pointers_left = {}
local pointers_right = {}

function PlayerInput:handle_event(event)
  if event.type == 'pointer_motion' then
    local rect = self.game.video.viewport
    local origin = Vector(rect.x + rect.w/2, rect.y + rect.h/2)
    local old_pos = Vector(event.x-event.dx, event.y-event.dy) - origin
    local pos = Vector(event.x, event.y) - origin
    local angle = math.atan2(pos.y, pos.x) - math.atan2(old_pos.y, old_pos.x)
    angle = (angle + math.pi) % (math.pi * 2) - math.pi
    self._delta = self._delta + angle * 25
  end
  if event.type == 'key_down' then
    if event.key == 'left' then pointers_left.button = true end
    if event.key == 'right' then pointers_right.button = true end
  elseif event.type == 'key_up' then
    if event.key == 'left' then pointers_left.button = nil end
    if event.key == 'right' then pointers_right.button = nil end
  end
end

function PlayerInput:preupdate()
  self.direction = Vector(
    (next(pointers_left) and -1 or 0) + (next(pointers_right) and 1 or 0) + self._delta, 0)
  self._delta = self._delta * 0.7

  self.a = true
  self.b = false
  self.changed()

  --glfw.glfwGetJoystickPos(self.joystick_number, joyaxes, axis_count)
  --glfw.glfwGetJoystickButtons(self.joystick_number, joybuttons, button_count)

  --local horizontal = math.max(-1, math.min(1,
  --  (glfw.glfwGetKey(keys.left) == glfw.GLFW_PRESS and -1 or 0) +
  --  (glfw.glfwGetKey(keys.right) == glfw.GLFW_PRESS and 1 or 0) +
  --  (joyaxes and joyaxes[0]*joyaxes[0] or 0)))
  --local vertical = math.max(-1, math.min(1,
  --  (glfw.glfwGetKey(keys.down) == glfw.GLFW_PRESS and -1 or 0) +
  --  (glfw.glfwGetKey(keys.up) == glfw.GLFW_PRESS and 1 or 0) +
  --  (joyaxes and joyaxes[1]*joyaxes[1] or 0)))

  --self.direction = Vector(horizontal, vertical)

  --self.a = glfw.glfwGetKey(keys.a) == glfw.GLFW_PRESS or joybuttons[0] == glfw.GLFW_PRESS
  --self.b = glfw.glfwGetKey(keys.b) == glfw.GLFW_PRESS or joybuttons[1] == glfw.GLFW_PRESS

  self.changed()
end

return PlayerInput
