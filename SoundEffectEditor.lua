--- SoundEffectEditor
--- =================

local Button = require 'gui.Button'
local class = require 'class'
local Component = require 'Component'
local Envelope = require 'audio.Envelope'
local EnvelopeEditor = require 'audio.EnvelopeEditor'
local LinearContainer = require 'gui.LinearContainer'
local TextField = require 'gui.TextField'
local TextLabel = require 'gui.TextLabel'

local audio_control = require 'audio.audio_control'

local SoundEffectEditor = class('SoundEffectEditor', LinearContainer)

function SoundEffectEditor:_init(parent)
  self:super(parent)

  local freq1 = TextField(self, "440")
  local envelope_editor = EnvelopeEditor(self)
  local freq2 = TextField(self, "440")
  local envelope_editor2 = EnvelopeEditor(self)

  local play_container = LinearContainer(self)
  play_container.orientation = 'horizontal'

  local play_button = Button(play_container)
  TextLabel(play_container, 'play')

  play_button.pressed:add_handler(function ()
    require('system.logging').log('playing')
    audio_control.set_operator_frequency(0, 0, tonumber(freq1.value), 0)
    audio_control.set_operator_frequency(0, 1, tonumber(freq2.value), 0)
    audio_control.set_modulation(0, 0, 1, envelope_editor.value)
    audio_control.set_modulation(0, 1, require('audio.conf').operator_count, envelope_editor2.value)
    audio_control.flush()
  end)

  audio_control.play()

  self.removed:add_handler(function ()
    audio_control.stop()
  end)
end

return SoundEffectEditor
