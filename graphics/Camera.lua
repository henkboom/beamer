--- graphics.Camera
--- ===============

local class = require 'class'
local Component = require 'Component'
local gl = require 'gl'
local Matrix = require 'Matrix'
local Vector = require 'Vector'
local Quaternion = require 'Quaternion'

Camera = class('Camera', Component)

-- opengl points in the negative Z axis, we point in the positive Y axis
local rotation_offset = Quaternion.from_rotation(Vector.i, math.pi/2)

function Camera:_init(parent)
  self:super(parent)
  self.transform = false
  self.render_lists = false

  self.clear_color = {0, 0, 0, 0}

  self.projection_matrix = Matrix.identity
  self.modelview_matrix = Matrix.identity

  self.near_clipping_plane = 0.1
  self.far_clipping_plane = 10000

  self.projection_mode = 'orthographic'

  self.orthographic_height = 2
  self.orthographic_alignment = Vector(0.5, 0.5)
  self.perspective_fov_y = math.pi/2

  self.target_framebuffer = false

  self:add_handler_for('draw')
end

function Camera:_start()
  self.transform = assert(self.transform or self.parent.transform)
  self.render_lists = self.render_lists or {self.game.render_list}

  assert(self.projection_mode == 'orthographic' or
         self.projection_mode == 'perspective')
end

function Camera:draw()
  if self.target_framebuffer then
    self.target_framebuffer:bind()
  end

  gl.glViewport(0, 0, self.game.video.width, self.game.video.height)

  local ratio = self.game.video.width / self.game.video.height
  if self.projection_mode == 'perspective' then
    self.projection_matrix =
      Matrix.perspective(math.pi/2, ratio,
                         self.near_clipping_plane, self.far_clipping_plane)
  else
    local align = self.orthographic_alignment
    self.projection_matrix = Matrix.orthographic(
      -self.orthographic_height*ratio/2 * align.x*2,
      self.orthographic_height*ratio/2 * (1-align.x)*2,
      -self.orthographic_height/2 * align.y*2,
      self.orthographic_height/2 * (1-align.y)*2,
      self.near_clipping_plane,
      self.far_clipping_plane)
  end

  self.modelview_matrix = Matrix.inverse(Matrix.from_transform(
    self.transform.position,
    rotation_offset * self.transform.orientation))

  -- enable depth writing so that the depth buffer clears properly
  gl.glEnable(gl.GL_DEPTH_TEST)
  gl.glDepthMask(gl.GL_TRUE)

  if(self.clear_color) then
    gl.glColorMask(gl.GL_TRUE, gl.GL_TRUE, gl.GL_TRUE, gl.GL_TRUE)
    gl.glClearColor(unpack(self.clear_color))
    gl.glClear(gl.GL_COLOR_BUFFER_BIT + gl.GL_DEPTH_BUFFER_BIT)
  else
    gl.glClear(gl.GL_DEPTH_BUFFER_BIT)
  end

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

  -- just for kicks, lets do some generic end-of-frame cleanup
  local max_texture_units = 8
  for i = 0, max_texture_units - 1 do
    gl.glActiveTexture(gl.GL_TEXTURE0 + i)
    gl.glBindTexture(gl.GL_TEXTURE_2D, 0)
  end

  if self.target_framebuffer then
    self.target_framebuffer:unbind()
  end
end

return Camera
