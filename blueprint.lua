--- blueprint
--- =========
---
--- An ad hoc, informally-specified, bug-ridden, slow implementation of half of
--- Common Lisp.

local class = require 'class'

local function parse_address(address)
  local ret = {}
  local n = 1
  while n <= #address do
    local index = string.find(address, '.', n, true)
    if index == nil then
      index = #address+1
    end
    table.insert(ret, string.sub(address, n, index-1))
    n = index+1
  end
  return ret
end

local function eval(context, value)
  if type(value) == 'table' then
    assert(#value > 0, 'empty expression')
    if type(value[1]) == 'string' then
      local ctor = require(value[1])
      local args = {}
      for i = 2, #value do
        args[i-1] = eval(context, value[i])
      end
      return ctor(unpack(args))
    else
      return value[1]
    end
  elseif type(value) == 'string' then
    return setfenv(assert(assert(loadstring('return ' .. value))), context)()
  else
    return value
  end
end

local function assign(context, address_elements, value)
  local obj = context
  for i = 1, #address_elements-1 do
    obj = obj[address_elements[i]]
  end
  obj[address_elements[#address_elements]] = value
end

local function blueprint(name, base, instructions)
  local blueprint_class = class(name, require(base))
  function blueprint_class:_init(...)
    self:super(...)
    local context = setmetatable({self = self}, {__index = _G})
    for i = 1, #instructions do
      local instruction = instructions[i]
      assert(#instruction == 2, 'wrong number of elements in instruction')
      assign(context, parse_address(instruction[1]), eval(context, instruction[2]))
    end
  end
  return blueprint_class
end

return blueprint
