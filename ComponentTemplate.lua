--- ComponentName
--- =============

local class = require 'class'
local Component = require 'Component'

local ComponentName = class('ComponentName', Component)

function ComponentName:_init(parent)
  self:super(parent)
end

return ComponentName
