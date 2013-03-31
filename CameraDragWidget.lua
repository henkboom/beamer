--- CameraDragWidget
--- ================

local class = require 'class'
local Component = require 'Component'
local Widget = require 'gui.Widget'
local Vector = require 'Vector'

local CameraDragWidget = class('CameraDragWidget', Widget)

local resize

function CameraDragWidget:_init(parent, camera)
  self:super(parent)

  self._pointer_count = 0
  self._camera = camera

  self:add_handler_for(self.parent.size_changed, function ()
    self.size = self.parent.size
  end)
  self.size = self.parent.size

  local t = self._camera.transform
  print(t.orientation:rotated_i(),
        t.orientation:rotated_j(),
        t.orientation:rotated_k())
end

function CameraDragWidget:handle_event(original_event)
  local old_pos = Vector.zero
  return function(e)
    if e.type == 'pointer_down' then
      self._pointer_count = self._pointer_count + 1
    elseif e.type == 'pointer_up' or e.type == 'pointer_cancel' then
      self._pointer_count = self._pointer_count - 1
    elseif e.type == 'pointer_motion' then
      -- meh
      local ratio = self.game.video.viewport.w / self.game.video.viewport.h
      local k = self._camera.transform.orientation:rotated_k()
      local i = self._camera.transform.orientation:rotated_i()
      local t = -k.z/i.z
      local mult = (k + t * i):magnitude()
      print(mult)
      local pos = Vector(e.dx / self.size.x * ratio * self._camera.orthographic_height,
                         e.dy / self.size.y * self._camera.orthographic_height)


      if pos ~= Vector.zero then
        if old_pos ~= Vector.zero then
          local t = self._camera.transform
          local up = t.orientation:rotated_k()
          local right = t.orientation:rotated_j()
          up = (up - up:project(Vector.k)):normalized()
          --print(t.orientation:rotated_i(),
          --      t.orientation:rotated_j(),
          --      t.orientation:rotated_k())
          t.position = t.position + up * pos.y * mult + right * pos.x
        end
        old_pos = pos
      end
    end
  end
end

return CameraDragWidget
