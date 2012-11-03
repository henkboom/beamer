local reload = {}

local pinned = {}

function reload.reload()
  for key in pairs(package.loaded) do
    if not pinned[key] then
      package.loaded[key] = nil
    end
  end
end

function reload.pin(module_name)
  pinned[module_name] = true
end

reload.pin(...)
reload.pin('bit')
reload.pin('coroutine')
reload.pin('debug')
reload.pin('ffi')
reload.pin('ffi.os')
reload.pin('io')
reload.pin('jit')
reload.pin('jit.opt')
reload.pin('jit.util')
reload.pin('math')
reload.pin('os')
reload.pin('package')
reload.pin('strict')
reload.pin('string')
reload.pin('table')

return reload
