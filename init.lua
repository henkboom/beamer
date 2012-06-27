local Game = require 'Game'
local Video = require 'Video'
local RenderList = require 'RenderList'
local Camera = require 'Camera'
local Transform = require 'Transform'

local game = Game(
  {'preupdate', 'update', 'postupdate'},
  {'predraw', 'draw', 'postdraw'})

game.video = Video(game)
game.video:open_window()

game.render_list = RenderList()
game.camera = Camera(game)
game.camera.transform = Transform()

game:start_game_loop()
