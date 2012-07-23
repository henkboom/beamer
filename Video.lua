--- Video
--- =====

local class = require 'class'
local Component = require 'Component'
local gl = require 'gl'
local glfw = require 'glfw'

local Video = class('Video', Component)

function Video:_init(parent)
  self:super(parent)
  self.width = 960
  self.height = 640

  assert(glfw.glfwInit() == gl.GL_TRUE, 'glfw initialization failed')

  -- only open window if it's not already open
  if glfw.glfwGetWindowParam(glfw.GLFW_OPENED) == gl.GL_FALSE then
    assert(glfw.glfwOpenWindow(
      self.width, self.height, 8, 8, 8, 8, 24, 0, glfw.GLFW_WINDOW) == gl.GL_TRUE,
      'glfw open window failed')
  end

  self:add_handler_for('postdraw')

  self.removed:add_handler(function ()
    glfw.glfwCloseWindow()
  end)
end

function Video:postdraw()
  glfw.glfwSwapBuffers()
end

return Video
