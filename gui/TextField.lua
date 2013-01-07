--- TextField
--- =========

local class = require 'class'
local Event = require 'Event'
local LinearContainer = require 'gui.LinearContainer'
local TextLabel = require 'gui.TextLabel'

local TextField = class('TextField', LinearContainer)

function TextField:_init(parent, value)
  self:super(parent)

  self._value = false
  self._label = TextLabel(self)

  self.value_changed = Event()
  self:set_value(value or '')

  table.insert(self.children, self._label)
end

function TextField:get_value(value)
  return self._value
end

function TextField:set_value(value)
  if self._label.text ~= value then
    self._label.text = value
  end
  if self._value ~= value then
    self._value = value
    self.value_changed()
  end
end

function TextField:handle_event(e)
  if e.type == 'pointer_down' then

    self.game.widget_manager:begin_text_entry(function (event)
      if event.type == 'focus_lost' then
        self._label.text = self.value
      elseif event.type == 'key_down' and event.key == 'enter' then
        self.value = self._label.text
        self.game.widget_manager:end_text_entry()
      elseif event.type == 'key_down' and event.key == 'backspace' then
        if #self._label.text > 0 then
          self._label.text = self._label.text:sub(1, -2)
        end
      elseif event.type == 'character_down' then
        self._label.text = self._label.text .. event.character
      end
    end)

    return function () end
  end
end

return TextField
