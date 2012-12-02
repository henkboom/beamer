--- Component
--- =========

local class = require 'class'
local Event = require 'Event'

local Component = class('Component')

function Component:_init(parent)
  assert(parent, 'invalid parent passed to Component constructor')
  self.game = parent.game
  self.parent = parent
  self.removed = Event()
  self.dead = false
  -- private
  self[Component] = { subscriptions = {} }

  self.removed:add_handler(function ()
    local subscriptions = self[Component].subscriptions
    for event, callback in pairs(subscriptions) do
      event:remove_handler(callback)
      subscriptions[event] = nil
    end
  end)

  self:unseal()
  self.game:add_component(self)
end

-- optional method for subclasses
Component._start = false

function Component:remove()
  self.game:remove_component(self)
end

function Component:add_handler_for(event, callback)
  if type(event) == 'string' then
    if callback == nil then
      callback = event
    end
    event = self.game.events[event]
  end
  if type(callback) == 'string' then
    local method = self[callback]
    assert(method)
    callback = function(...) return method(self, ...) end
  end

  local subscriptions = self[Component].subscriptions
  assert(subscriptions[event] == nil,
         "can't have two subscriptions to the same event")
  subscriptions[event] = callback
  event:add_handler(callback)
end

function Component:remove_handler_for(event)
  if type(event) == 'string' then
    event = self.game.events[event]
  end
  local subscriptions = self[Component].subscriptions
  event:remove_handler(subscriptions[event])
  subscriptions[event] = nil
end

return Component
