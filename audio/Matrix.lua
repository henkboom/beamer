local ffi = require 'ffi'

local conf = require 'audio.conf'
local Line = require 'audio.Line'

local sample_rate = conf.sample_rate
local inv_sample_rate = conf.inv_sample_rate
local operator_count = conf.operator_count
local channel_count = conf.channel_count
local modulation_count = conf.modulation_count
local modulation_output_count = conf.modulation_output_count

ffi.cdef([[
// compressed-row-storage matrix
typedef struct {
  line_s values[$];
  int value_columns[$];
  int row_indices[$];
} matrix_s;
]], modulation_count, modulation_count, modulation_output_count+1)

local matrix_s = ffi.metatype('matrix_s', {
  __index = {
    set = function (self, row, column, value)
      -- find the element
      local index = self.row_indices[row]
      local next_row = self.row_indices[row+1]
      while column ~= self.value_columns[index] or index == next_row do
        if index == next_row then
          -- expand the row
          assert(self.row_indices[modulation_output_count] < modulation_count,
                 'modulation matrix full')
          for i = self.row_indices[modulation_output_count], index, -1 do
            self.values[i+1] = self.values[i]
            self.value_columns[i+1] = self.value_columns[i]
          end
          for i = row+1, modulation_output_count+1 do
            self.row_indices[i] = self.row_indices[i]+1
          end
          next_row = self.row_indices[row+1]

          self.value_columns[index] = column
        else
          index = index + 1
        end
      end
      self.values[index] = value
    end,

    get = function (self, row, column)
      local index = self.row_indices[row]
      local next_row = self.row_indices[row+1]
      while column ~= self.value_columns[index] and index < next_row do
        index = index + 1
      end
      if index == next_row then
        return Line(0, 0, 0, 0)
      else
        return self.values[index]
      end
    end,

    multiply = function (self, time, vector, output)
      for row = 0, modulation_output_count-1 do
        local val = 0
        for i = self.row_indices[row], self.row_indices[row+1]-1 do
          val = val + self.values[i]:at(time) * vector[self.value_columns[i]]
        end
        output[row] = val
      end
    end
  }
})

local function Matrix()
  return matrix_s()
end

return Matrix

