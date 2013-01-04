--- gui.ExpressionView
--- ==================

local class = require 'class'
local LinearContainer = require 'gui.LinearContainer'
local TextLabel = require 'gui.TextLabel'
local TextField = require 'gui.TextField'

local ExpressionView = class('ExpressionView', LinearContainer)

function ExpressionView:_init(parent, expression)
  self:super(parent)

  self.orientation = 'horizontal'

  table.insert(self.children, TextLabel(self, '{'))

  for i, subexpr in ipairs(expression) do
    if i ~= 1 then
      table.insert(self.children, TextLabel(self, ', '))
    end

    if type(subexpr) == 'string' or type(subexpr) == 'number' then
      table.insert(self.children, TextField(self, tostring(subexpr)))
    elseif type(subexpr) == 'table' then
      table.insert(self.children, ExpressionView(self, subexpr))
    else
      table.insert(self.children, TextLabel(self, '<?>'))
    end
  end

  table.insert(self.children, TextLabel(self, '}'))

end

return ExpressionView
