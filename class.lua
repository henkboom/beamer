local _sealed = {'_sealed'}

local function class(name, base)
  assert(base == nil or type(base) == 'table', 'invalid base class')

  local c = {}
  local c_mt

  if base then
    for k,v in pairs(base) do
      c[k] = v
    end

    c._init = nil
    c._base = base
    c._ctor = function (obj, ...)
      if rawget(c, '_init') then
        rawset(obj, 'super', base._ctor)
        c._init(obj, ...)
        rawset(obj, 'super', nil)
      else
        base._ctor(obj, ...)
      end
    end
  else
    c._base = false
    c._ctor = function (obj, ...)
      if c._init then
        c._init(obj, ...)
      end
    end
  end

  -- nil: unknown
  -- false: there isn't one
  local getters = {}
  local setters = {}

  c.__index = function (self, k)
    -- first check class
    if rawget(c, k)  ~= nil then
      return rawget(c, k)
    elseif type(k) == 'string' then
      -- then check class getters
      if getters[k] == nil and type(k) == 'string' then
        getters[k] = rawget(c, 'get_' .. k) or false
      end
      -- if there isn't a getter then we've got an error
      if not getters[k] then
        error('field "' .. tostring(k) .. '" is not declared on ' ..
              tostring(self), 2)
      end
      -- invoke the getter
      return getters[k](self)
    end
  end

  c.__newindex = function (self, k, v)
    -- check for a setter
    if setters[k] == nil and type(k) == 'string' then
      setters[k] = rawget(c, 'set_' .. k) or false
    end

    if setters[k] then
      setters[k](self, v)
    elseif not self[_sealed] then
      rawset(self, k, v)
    else
      error('field "' .. tostring(k) .. '" is not declared in assignment ' ..
            'to ' .. tostring(self) .. ' (a sealed object)', 2)
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
    local object_class = getmetatable(value)
    while object_class do
      if object_class == c then
        return true
      end
      object_class = object_class._base
    end
    return false
  end

  c.seal = function(self)
    self[_sealed] = true
  end

  c.unseal = function(self)
    self[_sealed] = false
  end

  c.class = c

  setmetatable(c, {
    __call = function (_, ...)
      local obj = setmetatable({}, c)
      c._ctor(obj,...)
      if rawget(obj, _sealed) == nil then
        obj[_sealed] = true
      end
      return obj
    end,
    __tostring = function ()
      return 'class ' .. c._name
    end,
    __index = c.__index,
    __newindex = c.__newindex
  })

  return c
end

return class
