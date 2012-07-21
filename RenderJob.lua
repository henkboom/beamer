--- RenderJob
--- =========

local class = require 'class'

local RenderJob = class('RenderJob')

function RenderJob:_init(fn)
  self.fn = fn
  self.order = 0
end

return RenderJob
