--- Video
--- =====

local class = require 'class'
local Component = require 'Component'
local gl = require 'gl'
local glfw = require 'glfw'

local Video = class(Component)
Video._name = 'Video'

function Video:_init(parent)
  self:super(parent)
  self.width = 960
  self.height = 640
end

function Video:open_window()
  assert(glfw.glfwInit() == gl.GL_TRUE, 'glfw initialization failed')
  glfw.glfwOpenWindow(self.width, self.height, 8, 8, 8, 8, 24, 0, glfw.GLFW_WINDOW)
end

return Video
