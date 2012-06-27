--- ComponentName
--- =============

local class = require 'class'
local Component = require 'Component'

local ComponentName = class(Component)
ComponentName._name = 'ComponentName'

function ComponentName:_init(parent)
  self:super(parent)
end

return ComponentName
