--- RenderList
--- ==========

local class = require 'class' 

local RenderList = class()
RenderList._name = 'RenderList'

function RenderList:_init(parent)
  self.jobs = {}
end

function RenderList:add_job(job)
  order = order or 0

  self.jobs[job] = true
end

function RenderList:remove_job(job)
  self.jobs[job] = nil
end

return RenderList
