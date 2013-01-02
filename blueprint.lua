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
  local obj = context.self
  for i = 1, #address_elements-1 do
    obj = obj[address_elements[i]]
  end
  obj[address_elements[#address_elements]] = value
end

local function blueprint(name, base, modifications)
  local blueprint_class = class(name, require(base))
  blueprint_class.name = name
  blueprint_class.base = base
  blueprint_class.modifications = modifications

  function blueprint_class:_init(...)
    self:super(...)
    local context = setmetatable({self = self}, {__index = _G})
    for i = 1, #modifications do
      local modification = modifications[i]
      if #modification ~= 2 then
        error('wrong number of elements in modification '
              .. i .. ' of "' .. name .. '"')
      end
      assign(context, parse_address(modification[1]), eval(context, modification[2]))
    end
  end
  return blueprint_class
end

return blueprint
