--- PlayerInputWidget
--- =================

local class = require 'class'
local Component = require 'Component'
local MeshRenderer = require 'graphics.MeshRenderer'
local Mesh = require 'graphics.Mesh'
local Transform = require 'Transform'
local Widget = require 'gui.Widget'
local Vector = require 'Vector'
local Quaternion = require 'Quaternion'
local RelativeTransform = require 'RelativeTransform'

local PlayerInputWidget = class('PlayerInputWidget', Widget)

local resize

function PlayerInputWidget:_init(parent)
  self:super(parent)

  self.size = self.parent.size
  print(self.parent.size)

  self._renderer = MeshRenderer(self)

  self._renderer.transform = RelativeTransform(self.transform)
  self._renderer.material = require('materials.Basic')()
  self._renderer.material.uniforms.color = {0.1, 0.1, 0.1}
  self._renderer.render_lists = {self.game.gui_render_list}

  self._pointer_count = 0

  self:add_handler_for(self.parent.size_changed, function () resize(self) end)
  resize(self)
end

function PlayerInputWidget:handle_event(original_event)
  local old_pos = Vector.zero
  return function(e)
    if e.type == 'pointer_down' then
      self._pointer_count = self._pointer_count + 1
    elseif e.type == 'pointer_up' or e.type == 'pointer_cancel' then
      self._pointer_count = self._pointer_count - 1
    elseif e.type == 'pointer_motion' then
      local pos =
        self.transform:inverse_transform_point(Vector(e.x, e.y)) - self.size/2

      if pos ~= Vector.zero then
        if old_pos ~= Vector.zero then
          local angle = math.atan2(pos.y, pos.x) - math.atan2(old_pos.y, old_pos.x)
          angle = (angle + math.pi) % (math.pi * 2) - math.pi
          angle = angle / self._pointer_count
          self._renderer.transform.local_transform.orientation =
            self._renderer.transform.local_transform.orientation *
            Quaternion.from_rotation(Vector.k, angle)
        end
        old_pos = pos
      end
    end
  end
end

function resize(self)
  self.size = self.parent.size
  self._renderer.transform.local_transform.position = self.size/2


  if self._renderer.mesh then
    self._renderer.mesh:delete()
  end

  local elements = {}
  local positions = {}

  local radius = self.size.x/2 * 0.99
  local segments = 32
  for i = 0, segments-1 do
    local a1 = i/segments*2*math.pi
    local a2 = (i+0.5)/segments*2*math.pi

    positions[#positions+1] = math.sin(a1) * radius
    positions[#positions+1] = math.cos(a1) * radius
    positions[#positions+1] = 0
    positions[#positions+1] = math.sin(a1) * radius * 0.99
    positions[#positions+1] = math.cos(a1) * radius * 0.99
    positions[#positions+1] = 0
    positions[#positions+1] = math.sin(a2) * radius * 0.99
    positions[#positions+1] = math.cos(a2) * radius * 0.99
    positions[#positions+1] = 0
    positions[#positions+1] = math.sin(a2) * radius
    positions[#positions+1] = math.cos(a2) * radius
    positions[#positions+1] = 0

    elements[i*6+1] = i*4+0
    elements[i*6+2] = i*4+1
    elements[i*6+3] = i*4+2
    elements[i*6+4] = i*4+2
    elements[i*6+5] = i*4+3
    elements[i*6+6] = i*4+0
  end

  self._renderer.mesh = Mesh({
    elements = elements,
    position = positions
  })
end

return PlayerInputWidget
