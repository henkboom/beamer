--- SoundEffectEditor
--- =================

local Button = require 'gui.Button'
local class = require 'class'
local Component = require 'Component'
local Dragger = require 'gui.Dragger'
local Widget = require 'gui.Widget'
local LinearContainer = require 'gui.LinearContainer'
local TextLabel = require 'gui.TextLabel'
local Vector = require 'Vector'

local audio_control = require 'audio.audio_control'

local SoundEffectEditor = class('SoundEffectEditor', LinearContainer)

function SoundEffectEditor:_init(parent)
  self:super(parent)

  local envelope_canvas = Widget(self)
  envelope_canvas.size = Vector(20, 10)
  local draggers = {
    Dragger(envelope_canvas),
    Dragger(envelope_canvas),
    Dragger(envelope_canvas),
    Dragger(envelope_canvas)
  }
  local play_container = LinearContainer(self)
  play_container.orientation = 'horizontal'
  local play_button = Button(play_container)
  TextLabel(play_container, 'play')

  audio_control.set_operator_frequency(0, 0, 220, 0)
  play_button.pressed:add_handler(function ()
    table.sort(draggers, function (a, b)
      return a.value.x < b.value.x
    end)
    audio_control.set_modulation(0, 0, 192, 1, 0)

    local previous_time = 0
    for i = 1, #draggers do
      local v = draggers[i].value
      audio_control.set_modulation(
        -previous_time, 0, 192, 1-v.y, v.x-previous_time)
      previous_time = v.x
    end
    audio_control.set_modulation(
      -previous_time, 0, 192, 0, 1-previous_time)
    audio_control.flush()
  end)

  audio_control.play()

  self.removed:add_handler(function ()
    audio_control.stop()
  end)
end

return SoundEffectEditor
