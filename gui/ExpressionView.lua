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

  TextLabel(self, '{')

  for i, subexpr in ipairs(expression) do
    if i ~= 1 then
      TextLabel(self, ', ')
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
    elseif type(subexpr) == 'table' then
      ExpressionView(self, subexpr)
    else
      TextLabel(self, '<?>')
    end
  end

  TextLabel(self, '}')

end

return ExpressionView
