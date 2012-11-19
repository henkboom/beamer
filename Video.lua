--- Video
--- =====

local class = require 'class'
local Component = require 'Component'
local gl = require 'gl'
local Event = require 'Event'

local system_video = require 'system.video'

local Video = class('Video', Component)

function Video:_init(parent)
  self:super(parent)
  self.width = 1
  self.height = 1
  self.size_changed = Event()

  system_video.init()

  self:add_handler_for('postdraw')

  self.removed:add_handler(function ()
    --system_video.uninit()
  end)

  self:add_handler_for('handle_event')
end

function Video:handle_event(event)
  if event.type == 'resize' then
    if self.width ~= event.width or self.height ~= event.height then
      self.width = event.width
      self.height = event.height
      self.size_changed()
    end
  end
end

function Video:postdraw()
  system_video.swap_buffers()
end

return Video
