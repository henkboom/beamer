--- PlayerInput
--- ===========

local class = require 'class'
local Component = require 'Component'
local Event = require 'Event'
local Vector = require 'Vector'
local glfw = require 'glfw'
local ffi = require 'ffi'

local PlayerInput = class('PlayerInput', Component)

local keys = {
  up = glfw.GLFW_KEY_UP,
  down = glfw.GLFW_KEY_DOWN,
  left = glfw.GLFW_KEY_LEFT,
  right = glfw.GLFW_KEY_RIGHT,
  a = string.byte('X'),
  b = string.byte('C')
}

function PlayerInput:_init(parent)
  self:super(parent)

  self.joystick_number = 0

  self.direction = Vector.zero
  self.action = 0
  
  self.changed = Event()

  self:add_handler_for('preupdate')
end

local axis_count = 6
local button_count = 14
local joyaxes = ffi.new('float[?]', axis_count)
local joybuttons = ffi.new('unsigned char[?]', button_count)

function PlayerInput:preupdate()
  glfw.glfwGetJoystickPos(self.joystick_number, joyaxes, axis_count)
  glfw.glfwGetJoystickButtons(self.joystick_number, joybuttons, button_count)

  local horizontal = math.max(-1, math.min(1,
    (glfw.glfwGetKey(keys.left) == glfw.GLFW_PRESS and -1 or 0) +
    (glfw.glfwGetKey(keys.right) == glfw.GLFW_PRESS and 1 or 0) +
    (joyaxes and joyaxes[0]*joyaxes[0] or 0)))
  local vertical = math.max(-1, math.min(1,
    (glfw.glfwGetKey(keys.down) == glfw.GLFW_PRESS and -1 or 0) +
    (glfw.glfwGetKey(keys.up) == glfw.GLFW_PRESS and 1 or 0) +
    (joyaxes and joyaxes[1]*joyaxes[1] or 0)))

  self.direction = Vector(horizontal, vertical)

  self.a = glfw.glfwGetKey(keys.a) == glfw.GLFW_PRESS or joybuttons[0] == glfw.GLFW_PRESS
  self.b = glfw.glfwGetKey(keys.b) == glfw.GLFW_PRESS or joybuttons[1] == glfw.GLFW_PRESS

  self.changed()
end

return PlayerInput
