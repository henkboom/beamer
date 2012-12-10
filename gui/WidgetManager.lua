--- WidgetManager
--- =============
---
--- Manages dispatching of global events into the widget tree.

local class = require 'class'
local Component = require 'Component'

local Vector = require 'Vector'
local VerticalContainer = require 'gui.VerticalContainer'
local TextLabel = require 'gui.TextLabel'

local WidgetManager = class('WidgetManager', Component)

function WidgetManager:_init(parent)
  self:super(parent)

  self.pointer_handlers = {}

  -- for testing
  self.root = VerticalContainer(self)
  local text1 = TextLabel(self)
  text1.text = 'first text label'
  local text2 = TextLabel(self)
  text2.text = 'second text label'
  self.root.children = { text1, text2 }

  self:add_handler_for('handle_event')
end

function WidgetManager:handle_event(_e)
  -- we do a bit of transformation on some of the events, so work on a copy
  local e = {}
  for k,v in pairs(_e) do
    e[k] = v
  end

  -- transform pointer event positions
  if e.type == 'pointer_down' or
     e.type == 'pointer_up' or
     e.type == 'pointer_motion' then
    local pos = Vector(
      (e.x / self.game.video.width - 0.5) * 2,
      (e.y / self.game.video.height - 0.5) * -2)
    pos = (self.game.gui_camera.projection_matrix *
           self.game.gui_camera.modelview_matrix):inverse() * pos
    e.x = pos.x
    e.y = pos.y
  end

  -- new pointer
  if e.type == 'pointer_down' then
    self.pointer_handlers[e.id] = self.root:handle_event(e) or false
    if self.pointer_handlers[e.id] then
      assert(type(self.pointer_handlers[e.id] == 'table') or
             type(self.pointer_handlers[e.id] == 'function'),
             'pointer_handler must be callable')
      self.pointer_handlers[e.id](e)
    end
  end

  -- only handle pointer motion/up/cancel events when the pointer was claimed
  if e.type == 'pointer_motion' and self.pointer_handlers[e.id] then
    self.pointer_handlers[e.id](e)
  end

  if (e.type == 'pointer_up' or e.type == 'pointer_cancel') and
     self.pointer_handlers[e.id] then
    self.pointer_handlers[e.id](e)
    self.pointer_handlers[e.id] = false
  end
end

return WidgetManager
