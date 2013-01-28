local conf = require 'audio.conf'
local ffi = require 'ffi'
local Line = require 'audio.Line'
local Matrix = require 'audio.Matrix'

local sample_rate = conf.sample_rate
local inv_sample_rate = conf.inv_sample_rate
local operator_count = conf.operator_count
local channel_count = conf.channel_count
local modulation_count = conf.modulation_count
local modulation_output_count = conf.modulation_output_count

---- sine wave

local table_mask = 0x3ff
local table_size = table_mask + 1
local sine_table = ffi.new('double[?]', table_size)
for i = 0, table_size-1 do
  sine_table[i] = math.sin(i/table_size * 2 * math.pi)
end

local function sine_wave(phase)
  return sine_table[bit.band(phase * table_size, table_mask)]
end

---- phase modulation operator

ffi.cdef [[ typedef struct { line_s frequency; double phase; } operator_s; ]]
local operator_s = ffi.metatype("operator_s", {
  __index = {
    process_sample = function(self, time, offset)
      self.phase = (self.phase + self.frequency:at(time)*inv_sample_rate)
      return sine_wave(self.phase + offset)
    end
  }
})
 
---- synth

ffi.cdef([[
typedef struct {
  operator_s operators[$];
  matrix_s modulation;
  double buffer[$];
  double modulation_buffer[$];
} synth_s;
]], conf.operator_count, conf.operator_count, conf.modulation_output_count)

local synth_s = ffi.typeof('synth_s')

local sample_bytes = ffi.sizeof('double')

local function Synth()
  local self = synth_s()

  ffi.fill(self.buffer, operator_count * sample_bytes)

  self.modulation = Matrix()

  return self
end

local function synth_process_buffer(self, output, first, last)
  for i = first, last do
    output[i] = self:process_sample()
  end
end

local function synth_process_sample(self, time)
  self.modulation:multiply(time, self.buffer, self.modulation_buffer)

  for i = 0, operator_count-1, 8 do
    self.buffer[i  ] = self.operators[i  ]:process_sample(time, self.modulation_buffer[i  ])
    self.buffer[i+1] = self.operators[i+1]:process_sample(time, self.modulation_buffer[i+1])
    self.buffer[i+2] = self.operators[i+2]:process_sample(time, self.modulation_buffer[i+2])
    self.buffer[i+3] = self.operators[i+3]:process_sample(time, self.modulation_buffer[i+3])
    self.buffer[i+4] = self.operators[i+4]:process_sample(time, self.modulation_buffer[i+4])
    self.buffer[i+5] = self.operators[i+5]:process_sample(time, self.modulation_buffer[i+5])
    self.buffer[i+6] = self.operators[i+6]:process_sample(time, self.modulation_buffer[i+6])
    self.buffer[i+7] = self.operators[i+7]:process_sample(time, self.modulation_buffer[i+7])
  end

  return self.modulation_buffer[operator_count]
end

ffi.metatype('synth_s', {
  __index = {
    process_buffer = synth_process_buffer,
    process_sample = synth_process_sample,
  }
})

return Synth
