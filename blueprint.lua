
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
  
  local output_value

  local function output_table(output, t)
    table.insert(output, '{')
    local i = 1
    while t[i] ~= nil do
      output_value(output, t[i])
      table.insert(output, ', ')
      i = i + 1
    end
    for k,v in pairs(t) do
      if type(k) ~= 'number' or k ~= math.floor(k) then
        table.insert(output, '[')
        output_value(output, k)
        table.insert(output, '] = ')
        output_value(output, v)
        table.insert(output, ', ')
      end
    end
    table.insert(output, '}')
  end

  local function output_number(output, n)
    table.insert(output, tostring(n))
  end

  local function output_string(output, s)
    table.insert(output, string.format('%q', s))
  end

  function output_value(output, v)
    if type(v) == 'table' then
      output_table(output, v)
    elseif type(v) == 'number' then
      output_number(output, v)
    elseif type(v) == 'string' then
      output_string(output, v)
    elseif type(v) == 'nil' then
      table.insert(output, 'nil')
    else
      table.insert(output, '???')
      --error('unknown value ' .. tostring(v))
    end
  end

  function blueprint_class.serialize_blueprint_to_string()
    local output = {}
    table.insert(output, '-- generated blueprint\n')
    table.insert(output, 'local blueprint = require \'blueprint\'\n')
    table.insert(output, string.format('return blueprint(%q, %q, {\n',
      blueprint_class.name, blueprint_class.base))

    for i = 1, #modifications do
      table.insert(output, '  ')
      output_value(output, modifications[i])
      table.insert(output, ',\n')
    end

    table.insert(output, '})\n')

    return table.concat(output)
  end

  return blueprint_class
end

return blueprint
