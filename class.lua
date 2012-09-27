local function class(name, base)
  assert(base == nil or type(base) == 'table', 'invalid base class')

  local c = {}

  local real_ctor

  if base then
    for k,v in pairs(base) do
      c[k] = v
    end

    c._init = nil
    c._base = base
    real_ctor = function (obj, ...)
      if c._init then
        obj.super = base._ctor
        c._init(obj, ...)
        obj.super = nil
      else
        base._ctor(obj, ...)
      end
    end
  else
    real_ctor = function (obj, ...)
      if c._init then
        c._init(obj, ...)
      end
    end
  end

  local getters = {}
  local setters = {}

  c._ctor = function (...)
    for k,v in pairs(c) do
      local name = string.match(k, '^get_(.*)$')
      if name then getters[name] = v end
      local name = string.match(k, '^set_(.*)$')
      if name then setters[name] = v end
    end

    c._ctor = real_ctor
    real_ctor(...)
  end

  c.__index = function (self, k)
    local getter = getters[k]

    if getter == nil then
      local val = c[k]
      if val == nil then
        error('field ' .. tostring(k) .. ' is not declared on ' ..
              tostring(self), 2)
      end
      return val
    end

    return getter(self)
  end

  c.__newindex = function (self, k, v)
    local setter = setters[k]

    if setter == nil then
      rawset(self, k, v)
    else
      setter(self, v)
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
      c._ctor(obj,...)
      return obj
    end,
    __tostring = function ()
      return 'class ' .. c._name
    end
  })

  return c
end

return class
