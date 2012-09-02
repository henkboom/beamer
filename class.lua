local catch_undefined_access = true

local function class(name, base)
  assert(base == nil or type(base) == 'table', 'invalid base class')

  local c = {}

  if base ~= nil then
    for k,v in pairs(base) do
      c[k] = v
    end

    c._init = nil
    c._base = base
    c._ctor = function (obj, ...)
      if c._init then
        obj.super = base._ctor
        c._init(obj, ...)
        obj.super = nil
      else
        base._ctor(obj, ...)
      end
    end
  else
    c._ctor = function (obj, ...)
      if c._init then
        c._init(obj, ...)
      end
    end
  end

  c.__index = c
  if catch_undefined_access then
    c.__index = function (obj, k)
      local val = c[k]
      if val == nil then
        error('field ' .. tostring(k) .. ' is not declared on ' .. tostring(obj), 2)
      end
      return val
    end
  end
  c._name = name
  c.__tostring = function (obj)
    setmetatable(obj, nil)
    local str = c._name .. string.gsub(tostring(obj), 'table', '')
    setmetatable(obj, c)
    return str
  end

  c.is_type_of = function (value)
    return getmetatable(value) == c
  end

  setmetatable(c, {
    __call = function (_, ...)
      local obj = setmetatable({}, c)
      obj:_ctor(...)
      return obj
    end,
    __tostring = function ()
      return 'class ' .. c._name
    end
  })

  return c
end

return class
