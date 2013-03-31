--- graphics.Camera
--- ===============

local class = require 'class'
local Component = require 'Component'
local gl = require 'gl'
local Matrix = require 'Matrix'
local Vector = require 'Vector'
local Quaternion = require 'Quaternion'

Camera = class('Camera', Component)

--local rotation_offset = Quaternion.from_rotation(Vector.j, -math.pi/2 ) *
--                        Quaternion.from_rotation(Vector.k, -math.pi/2)

-- opengl points in the forwards Z axis (left-handed), we point in the positive
-- X axis (right-handed).
-- IMPORTANT: matrix visually transposed in the code since matrices are column-major
local screen_matrix = Matrix(
  0, 0,-1, 0, -- game x maps to screen z
 -1, 0, 0, 0, -- game y maps to screen -x
  0, 1, 0, 0, -- game z maps to screen y
  0, 0, 0, 1
)

function Camera:_init(parent)
  self:super(parent)
  self.transform = false
  self.render_lists = false

  self.clear_color = {0, 0, 0, 0}
  self.clear_depth = 1

  -- TODO mark projection matrix as dirty when projection parameters are changed
  self.projection_matrix = Matrix.identity
  -- TODO mark modelview matrix as dirty when transform is changed
  self.modelview_matrix = Matrix.identity

  self.near_clipping_plane = 0.1
  self.far_clipping_plane = 10000

  self.projection_mode = 'orthographic'

  self.orthographic_height = 2
  self.orthographic_alignment = Vector(0.5, 0.5)
  self.perspective_fov_y = math.pi/2

  self.target_framebuffer = false

  self:add_handler_for('draw')

  self.started:add_handler(function ()
    self.transform = assert(self.transform or self.parent.transform)
    self.render_lists = self.render_lists or {self.game.render_list}

    assert(self.projection_mode == 'orthographic' or
           self.projection_mode == 'perspective')
  end)
end

function Camera:draw()
  -- viewport
  local viewport = self.game.video.viewport
  if self.target_framebuffer then
    self.target_framebuffer:bind()
    gl.glViewport(0, 0, viewport.w, viewport.h)
  else
    gl.glViewport(viewport.x, self.game.video.size.y - viewport.y - viewport.h,
                  viewport.w, viewport.h)
  end

  -- projection matrix
  local ratio = viewport.w / viewport.h
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

  -- modelview matrix
  self.modelview_matrix = screen_matrix *
    Matrix.inverse(Matrix.from_transform(
      self.transform.position, self.transform.orientation))

  -- clear buffers
  local clear_mask = 0

  if self.clear_color then
    gl.glColorMask(gl.GL_TRUE, gl.GL_TRUE, gl.GL_TRUE, gl.GL_TRUE)
    gl.glClearColor(unpack(self.clear_color))
    clear_mask = clear_mask + gl.GL_COLOR_BUFFER_BIT
  end

  if self.clear_depth then
    -- enable depth writing to clear the depth buffer
    gl.glEnable(gl.GL_DEPTH_TEST)
    -- depth writing is implicitly off when the depth test is, so turn it on
    gl.glDepthMask(gl.GL_TRUE)
    gl.glClearDepth(self.clear_depth)
    clear_mask = clear_mask + gl.GL_DEPTH_BUFFER_BIT
  end

  if clear_mask ~= 0 then
    gl.glClear(clear_mask)
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
