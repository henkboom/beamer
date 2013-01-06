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
      local field = TextField(self, tostring(subexpr))
      field.value_changed:add_handler(function ()
        local value = field.value
        if type(subexpr) == 'number' then
          value = tonumber(value)
          if value == nil then
            -- recurses immediately
            field.value = tostring(expression[i])
            return
          end
        end
        expression[i] = value
      end)
      -- TODO need to update in the other direction as well
      table.insert(self.children, field)
    elseif type(subexpr) == 'table' then
      table.insert(self.children, ExpressionView(self, subexpr))
    else
      table.insert(self.children, TextLabel(self, '<?>'))
    end
  end

  table.insert(self.children, TextLabel(self, '}'))

end

return ExpressionView
