--- WidgetManager
--- =============
---
--- Manages dispatching of global events into the widget tree.

local Button = require 'gui.Button'
local BlueprintView = require 'gui.BlueprintView'
local class = require 'class'
local Component = require 'Component'
local Dragger = require 'gui.Dragger'
local Vector = require 'Vector'
local Widget = require 'gui.Widget'
local TextLabel = require 'gui.TextLabel'

local WidgetManager = class('WidgetManager', Component)

function WidgetManager:_init(parent)
  self:super(parent)

  self._pointer_handlers = {}
  self._text_input_handler = false

  -- for testing
  self.root = Widget(self)

  self:add_handler_for('handle_event')
end

function WidgetManager:begin_text_entry(fn)
  self:end_text_entry()
  self._text_input_handler = fn
end

function WidgetManager:end_text_entry()
  if self._text_input_handler then
    self._text_input_handler({type = 'focus_lost'})
    self._text_input_handler = false
  end
end

function WidgetManager:handle_event(_e)
  -- we do a bit of transformation on some of the events, so work on a copy
  local e = {}
  for k,v in pairs(_e) do
    e[k] = v
  end

  ---- key input --------------------------------------------------------------

  if e.type == 'key_down' or e.type == 'key_up' or
     e.type == 'character_down' or e.type == 'character_up' then
    if self._text_input_handler then
      self._text_input_handler(e)
    end
  end

  ---- pointer ----------------------------------------------------------------

  -- transform pointer event positions
  if e.type == 'pointer_down' or
     e.type == 'pointer_up' or
     e.type == 'pointer_motion' then

    local viewport = self.game.video.viewport
    local inverse_matrix = (self.game.gui_camera.projection_matrix *
                            self.game.gui_camera.modelview_matrix):inverse()
    local pos = Vector(
      (e.x / viewport.w - 0.5) * 2,
      (e.y / viewport.h - 0.5) * -2)
    pos = inverse_matrix * pos
    e.x = pos.x
    e.y = pos.y

    if e.type == 'pointer_motion' then
      local delta = Vector(
        e.dx / viewport.w * 2 * inverse_matrix[0],
        e.dy / viewport.h * -2 * inverse_matrix[5])

      e.dx = delta.x
      e.dy = delta.y
    end
  end

  -- new pointer
  if e.type == 'pointer_down' then
    self._pointer_handlers[e.id] = self.root:handle_event(e) or false
    if self._pointer_handlers[e.id] then
      assert(type(self._pointer_handlers[e.id] == 'table') or
             type(self._pointer_handlers[e.id] == 'function'),
             'pointer_handler must be callable')
      self._pointer_handlers[e.id](e)
    end
  end

  -- only handle pointer motion/up/cancel events when the pointer was claimed
  if e.type == 'pointer_motion' and self._pointer_handlers[e.id] then
    self._pointer_handlers[e.id](e)
  end

  if (e.type == 'pointer_up' or e.type == 'pointer_cancel') and
     self._pointer_handlers[e.id] then
    self._pointer_handlers[e.id](e)
    self._pointer_handlers[e.id] = false
  end
end

return WidgetManager
