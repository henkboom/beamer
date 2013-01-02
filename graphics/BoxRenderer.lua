--- graphics.BoxRenderer
--- ====================

local class = require 'class'
local Component = require 'Component'
local Material = require 'graphics.Material'
local Mesh = require 'graphics.Mesh'
local MeshRenderer = require 'graphics.MeshRenderer'
local basic_shader = require 'shaders.basic'
local Transform = require 'Transform'
local Vector = require 'Vector'

local BoxRenderer = class('BoxRenderer', Component)

function BoxRenderer:_init(parent)
  self:super(parent)

  self.transform = false
  self._renderer = MeshRenderer(self)
  self._renderer.material = Material()
  self._renderer.material.program = basic_shader()
  self._renderer.mesh = Mesh()
  
  self._size = Vector(1, 1)
  self._thickness = 1/16
  self._needs_update = true

  self:add_handler_for('predraw')
  self.removed:add_handler(function ()
    if self._renderer.mesh then
      self.mesh:delete()
    end
  end)
end

function BoxRenderer:get_thickness()
  return self._thickness
end

function BoxRenderer:set_thickness(thickness)
  assert(type(thickness) == 'number')
  if thickness ~= self._thickness then
    self._thickness = thickness
    self._needs_update = true
  end
end

function BoxRenderer:get_size()
  return self._size
end

function BoxRenderer:set_size(size)
  assert(Vector.is_type_of(size))
  if size ~= self._size then
    self._size = size
  end
end

function BoxRenderer:_update_mesh()
  local w = self._size.x
  local h = self._size.y
  local t = self._thickness

  local position = {
    0,0,0, w,0,0, w,h,0, 0,h,0,
    t,t,0, w-t,t,0, w-t,h-t,0, t,h-t,0,
  }

  local elements = {
    0,1,5, 5,4,0,
    1,2,6, 6,5,1,
    2,3,7, 7,6,2,
    3,0,4, 4,7,3,
  }

  if self._renderer.mesh then
    self._renderer.mesh:delete()
    self._renderer.mesh = false
  end
  self._renderer.mesh = Mesh({
    elements = elements,
    position = position
  })
end

function BoxRenderer:predraw()
  if self._needs_update then
    self._needs_update = false
    self:_update_mesh()
  end
end

function BoxRenderer:_start()
  self.transform = self.transform or Transform()
  self._renderer.transform = self.transform
end

function BoxRenderer:get_render_lists()
  return self._renderer.render_lists
end

function BoxRenderer:set_render_lists(render_lists)
  self._renderer.render_lists = render_lists
end

return BoxRenderer
