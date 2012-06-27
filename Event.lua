--- Event
--- =====
---
--- Provides an interface to register handlers for arbitrary events.

local class = require 'class'

local Event = class()

function Event:_init()
  self._count = 0 -- number of handlers
  self._length = 0 -- length of sparse array
  self._indices = {} -- handler->index
  self._handlers = {} -- list of handlers
  self._running = false -- true when traversing the handler array
end

function Event:__call(...)
  self._running = true

  local handlers = self._handlers
  for i = 1, self._length do
    local f = handlers[i]
    if f ~= nil then
      f(...)
    end
  end

  self._running = false

  -- we never trigger filters while in the event call loop, so try one now
  self:_filter_if_appropriate()
end

function Event:add_handler(f)
  assert(f ~= nil, 'tried to add a nil handler')
  assert(self._indices[f] == nil, 'two of the same handler added to one event')
  self._length = self._length + 1
  self._count = self._count + 1

  self._handlers[self._length] = f
  self._indices[f] = self._length
end

function Event:remove_handler(f)
  local handlers = self._handlers
  local indices = self._indices

  assert(f ~= nil)
  assert(indices[f] ~= nil, 'removing handler that isn\'t on this event')

  handlers[indices[f]] = nil
  indices[f] = nil
  self._count = self._count - 1

  self:_filter_if_appropriate()
end

local function filter_out_nils_in_place(t, length)
  local src = 1
  while src <= length and t[src] ~= nil do
    -- [1..src) were already compacted
    -- [src..length] left to check
    src = src + 1
  end
  -- [1..src) were already compacted
  -- [src..length] left to compact
  local dest = src
  while src <= length do
    -- [1..dest) compacted
    -- [src..length] to compact
    if t[src] ~= nil then
      t[dest] = t[src]
      dest = dest + 1
    end
    src = src + 1
  end
  -- [1, dest) compacted
  -- [dest, length] garbage to nil out
  while dest <= length do
    t[dest] = nil
    dest = dest + 1
  end
end

function Event:_filter_if_appropriate()
  if not self._running and  self._count < self._length/2 then
    local handlers = self._handlers
    local indices = self._indices

    filter_out_nils_in_place(handlers, self._length)
    self._length = self._count

    for i = 1, #handlers do
      indices[handlers[i]] = i
    end

    assert(self._length == #handlers)
  end
end

return Event
