--- WidgetManager
--- =============
---
--- Manages dispatching of global events into the widget tree.

local class = require 'class'
local Component = require 'Component'

local VerticalContainer = require 'gui.VerticalContainer'
local TextLabel = require 'gui.TextLabel'

local WidgetManager = class('WidgetManager', Component)

function WidgetManager:_init(parent)
  self:super(parent)

  self.root = VerticalContainer(self)
  local text1 = TextLabel(self)
  text1.text = 'first text label'
  local text2 = TextLabel(self)
  text2.text = 'second text label'
  self.root.children = { text1, text2 }

  self:add_handler_for('handle_event')
end

function WidgetManager:handle_event(event)
  -- TODO
end

return WidgetManager
