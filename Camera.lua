--- Camera
--- ======

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
  self.perspective_fov_y = math.pi/2

  self:add_handler_for('draw')
  self:add_handler_for('update', function ()
    -- TODO move this
    self.transform.position =
      self.transform.position * 0.9 +
      self.game.player_ship.transform.position * 0.1
  end)
end

function Camera:_start()
  self.tranform = assert(self.transform or self.parent.transform)
  self.render_lists = self.render_lists or {self.game.render_list}

  assert(self.projection_mode == 'orthographic' or
         self.projection_mode == 'perspective')
end

function Camera:draw()
  local ratio = self.game.video.width / self.game.video.height
  if self.projection_mode == 'perspective' then
    self.projection_matrix =
      Matrix.perspective(math.pi/2, ratio, 0.1, 10000)
  else
    self.projection_matrix = Matrix.orthographic(
      -self.orthographic_height*ratio/2, self.orthographic_height*ratio/2,
      -self.orthographic_height/2, self.orthographic_height/2,
      self.near_clipping_plane, self.far_clipping_plane)
  end

  self.modelview_matrix = Matrix.inverse(Matrix.from_transform(
    self.transform.position,
    rotation_offset * self.transform.orientation))

  -- enable depth writing so that the depth buffer clears properly
  gl.glEnable(gl.GL_DEPTH_TEST)
  gl.glDepthMask(gl.GL_TRUE)

  if(self.clear_color) then
    gl.glClearColor(0, 0, 0, 0)
    gl.glClear(gl.GL_COLOR_BUFFER_BIT + gl.GL_DEPTH_BUFFER_BIT)
  else
    gl.glClear(gl.GL_DEPTH_BUFFER_BIT)
  end

  gl.glEnable(gl.GL_BLEND)
  gl.glBlendFunc(gl.GL_SRC_ALPHA, gl.GL_ONE_MINUS_SRC_ALPHA)
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

  -- just for kicks, lets do some generic end-of-frame cleanup
  local max_texture_units = 8
  for i = 0, max_texture_units - 1 do
    gl.glActiveTexture(gl.GL_TEXTURE0 + i)
    gl.glBindTexture(gl.GL_TEXTURE_2D, 0)
  end
end

return Camera
