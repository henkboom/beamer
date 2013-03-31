--- graphics.AxesRenderer
--- =====================

local class = require 'class'
local Component = require 'Component'
local Mesh = require 'graphics.Mesh'
local MeshRenderer = require 'graphics.MeshRenderer'
local Transform = require 'Transform'
local Vector = require 'Vector'

local AxesRenderer = class('AxesRenderer', Component)

function AxesRenderer:_init(parent)
  self:super(parent)

  self.transform = false
  self._renderer = MeshRenderer(self)
  self._renderer.material = require('materials.VertexColor')()
  self._renderer.mesh = Mesh()
  
  self.started:add_handler(function ()
    self.transform = self.transform or Transform()
    self._renderer.transform = self.transform
  end)

  local position = { 0,0,0, 1,0,0, 0,1,0, 0,0,1 }
  local color    = { 0,0,0, 1,0,0, 0,1,0, 0,0,1 }

  local elements = {
    0, 1, 2,
    0, 2, 3,
    0, 3, 1
  }

  self._renderer.mesh = Mesh({
    elements = elements,
    position = position,
    color = color
  })

  self.removed:add_handler(function ()
    self._renderer.mesh:delete()
  end)
end

function AxesRenderer:get_render_lists()
  return self._renderer.render_lists
end

function AxesRenderer:set_render_lists(render_lists)
  self._renderer.render_lists = render_lists
end

return AxesRenderer
