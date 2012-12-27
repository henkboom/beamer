--- Video
--- =====

local class = require 'class'
local Component = require 'Component'
local gl = require 'gl'
local Event = require 'Event'
local Vector = require 'Vector'

local system_video = require 'system.video'

local Video = class('Video', Component)

function Video:_init(parent)
  self:super(parent)
  self.viewport = { x = 0, y = 0, w = 1, h = 1 }
  self.viewport_changed = Event()

  system_video.init()

  self:add_handler_for('postdraw')

  self.removed:add_handler(function ()
    --system_video.uninit()
  end)

  self:add_handler_for('handle_event')
end

-- TODO uhh get this information in better ways or something
function Video:get_size()
  if system_video.get_size then
    return Vector(unpack(system_video.get_size()))
  else
    return Vector(self.viewport.x + self.viewport.w, self.viewport.y + self.viewport.h)
  end
end

function Video:handle_event(event)
  if event.type == 'resize' then
    if self.viewport.x ~= event.x or
       self.viewport.y ~= event.y or
       self.viewport.w ~= event.w or
       self.viewport.h ~= event.h then
      self.viewport = {
        x = event.x,
        y = event.y,
        w = event.w,
        h = event.h
      }
      require('system.logging').log('resize', event.x, event.y, event.w, event.h)
      self.viewport_changed()
    end
  end
end

function Video:postdraw()
  system_video.swap_buffers()
end

return Video
