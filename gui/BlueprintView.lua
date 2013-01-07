--- gui.BlueprintView
--- =================

local class = require 'class'
local LinearContainer = require 'gui.LinearContainer'
local ExpressionView = require 'gui.ExpressionView'
local TextLabel = require 'gui.TextLabel'

local BlueprintView = class('BlueprintView', LinearContainer)

function BlueprintView:_init(parent, blueprint)
  self:super(parent)

  TextLabel(self, blueprint.name .. '(' ..  blueprint.base .. ')')
  for _, modification in ipairs(blueprint.modifications) do
    local row = LinearContainer(self)
    row.orientation = 'horizontal'

    TextLabel(row, modification[1] .. ' = ')
    ExpressionView(row, modification[2])
  end
end

return BlueprintView
