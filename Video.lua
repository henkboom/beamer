--- Video
--- =====

local class = require 'class'
local Component = require 'Component'
local gl = require 'gl'

local system_video = require 'system.video'

local Video = class('Video', Component)

function Video:_init(parent)
  self:super(parent)
  self.width = 960
  self.height = 640

  system_video.init()

  self:add_handler_for('postdraw')

  self.removed:add_handler(function ()
    system_video.uninit()
  end)
end

function Video:postdraw()
  system_video.swap_buffers()
end

return Video
