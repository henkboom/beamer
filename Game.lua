--- Game
--- ====

local class = require 'class'
local Component = require 'Component'
local Event = require 'Event'
local GameLoop = require 'GameLoop'

local Game = class('Game', Component)

function Game:_init(update_events, draw_events)
  update_events = update_events or {'preupdate', 'update', 'postupdate'}
  draw_events = draw_events or {'predraw', 'draw', 'postdraw'}

  self.game = self

  self._game_loop = false

  ---- events ----
  -- ordered
  self.update_events = {}
  self.draw_events = {}
  -- by name
  self.events = {}

  self.events.handle_event = Event()

  -- fill them in
  for i = 1, #update_events do
    local e = Event()
    self.events[update_events[i]] = e
    self.update_events[i] = e
  end
  for i = 1, #draw_events do
    local e = Event()
    self.events[draw_events[i]] = e
    self.draw_events[i] = e
  end

  ---- components ----
  self.components = {}
  self._components_to_start = {}
  self._components_to_remove = {}

  -- self:super calls Game:add_component, so we need to call this last
  self:super(self)
  self.parent = false
end

function Game:start_game_loop()
  self._game_loop = GameLoop()
  self._game_loop.update:add_handler(function () self:_update() end)
  self._game_loop.draw:add_handler(function () self:_draw() end)
  self._game_loop.handle_event:add_handler(self.events.handle_event)
  self._game_loop:enter_loop()
end

function Game:add_component(child)
  table.insert(self.components, child)
  table.insert(self._components_to_start, child)
end

function Game:remove_component(component_to_remove)
  assert(not component_to_remove.dead, 'tried to remove dead component')
  self._components_to_remove[component_to_remove] = true
end

local function not_dead(c) return not c.dead end

function Game:_start_new_components()
  while #self._components_to_start > 0 do
    local components_to_start = self._components_to_start
    self._components_to_start = {}

    for i = 1, #components_to_start do
      local component = components_to_start[i]
      if not component.dead then
        component.started()
      end
      component:seal()
    end
  end
end

function Game:_update()
  for i = 1, #self.update_events do
    self:_start_new_components()
    self.update_events[i]()
  end

  if next(self._components_to_remove) ~= nil then
    -- transitive closure forwards
    for i = 1, #self.components do
      local component = self.components[i]
      if self._components_to_remove[component.parent] then
        self._components_to_remove[component] = true
      end
    end
    -- delete nodes reverse order (children first)
    for i = #self.components, 1, -1 do
      local component = self.components[i]
      if self._components_to_remove[component] then
        self._components_to_remove[component] = nil
        component.removed()
        component.dead = true
      end
    end

    -- compact out dead components
    local dst = 1
    for src = 1, #self.components do
      if not self.components[src].dead then
        self.components[dst] = self.components[src]
        dst = dst + 1
      end
    end
    for i = dst, #self.components do
      self.components[i] = nil
    end

    if self.dead then
      self._game_loop:stop()
    end
  end
end

function Game:_draw()
  for i = 1, #self.draw_events do
      self.draw_events[i]()
  end
end

return Game
