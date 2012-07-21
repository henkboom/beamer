--- Camera
--- ======

local class = require 'class'
local Component = require 'Component'
local gl = require 'gl'
local Matrix = require 'Matrix'
local Vector = require 'Vector'
local Quaternion = require 'Quaternion'

Camera = class('Camera', Component)

local rotation_offset = Quaternion.from_rotation(Vector.j, -math.pi/2)

function Camera:_init(parent)
  self:super(parent)
  self.transform = false
  self.render_lists = false

  self.projection_matrix = Matrix.identity
  self.modelview_matrix = Matrix.identity

  self:add_handler_for('draw')
end

function Camera:_start()
  self.tranform = assert(self.transform or self.parent.transform)
  self.render_lists = self.render_lists or {self.game.render_list}
end

function Camera:draw()
  local ratio = self.game.video.width / self.game.video.height
  self.projection_matrix =
    Matrix.perspective(math.pi/2, ratio, 0.1, 10000)
  self.modelview_matrix = Matrix.inverse(Matrix.from_transform(
    self.transform.position,
    self.transform.orientation * rotation_offset))

  gl.glClearColor(0, 0, 0, 0)
  gl.glClear(gl.GL_COLOR_BUFFER_BIT + gl.GL_DEPTH_BUFFER_BIT)
  gl.glEnable(gl.GL_DEPTH_TEST)
  gl.glDepthFunc(gl.GL_LESS)
  local jobs = {}
  for i = 1, #self.render_lists do
    for job in pairs(self.render_lists[i].jobs) do
      local order = job.order
      jobs[order] = jobs[order] or {}
      table.insert(jobs[order], job.fn)
    end
  end

  local orders = {}
  for k in pairs(jobs) do
    table.insert(orders, k)
  end
  for i = 1, #orders do
    local jobs_of_order = jobs[orders[i]]
    for j = 1, #jobs_of_order do
      jobs_of_order[j](self)
    end
  end
end

return Camera
