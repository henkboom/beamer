return function ()
  local Camera = require 'Camera'
  local Game = require 'Game'
  local MeshRenderer = require 'MeshRenderer'
  local Quaternion = require 'Quaternion'
  local RenderList = require 'RenderList'
  local Transform = require 'Transform'
  local Video = require 'Video'
  local Vector = require 'Vector'
  local game = Game(
    {'preupdate', 'update', 'postupdate'},
    {'predraw', 'draw', 'postdraw'})

  local basic_shader = require 'shaders.basic'

  game.video = Video(game)
  game.video:open_window()
  
  game.render_list = RenderList()
  game.camera = Camera(game)
  game.camera.transform = Transform(Vector(0, 0, 2),
                                    Quaternion.from_rotation(Vector.j, math.pi/2))
  
  game.renderer = MeshRenderer(game)
  game.renderer.transform = Transform()
  game.renderer.program = basic_shader.load()
  game.renderer.mesh = {{
    vertices = {
      { position = {0, 0, 0} },
      { position = {2, 0, 0} },
      { position = {0, 1, 0} },
    },
    faces = { { 1, 2, 3 } }
  }}

  return game
end
