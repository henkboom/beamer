--- gui.BlueprintView
--- =================

local class = require 'class'
local LinearContainer = require 'gui.LinearContainer'
local ExpressionView = require 'gui.ExpressionView'
local TextLabel = require 'gui.TextLabel'

local BlueprintView = class('BlueprintView', LinearContainer)

function BlueprintView:_init(parent, blueprint)
  self:super(parent)

  table.insert(self.children,
    TextLabel(self, blueprint.name .. '(' ..  blueprint.base .. ')'))
  for _, modification in ipairs(blueprint.modifications) do
    local row = LinearContainer(self)
    row.orientation = 'horizontal'

    table.insert(row.children, TextLabel(row, modification[1] .. ' = '))
    table.insert(row.children, ExpressionView(row, modification[2]))

    table.insert(self.children, row)
  end
end

return BlueprintView
