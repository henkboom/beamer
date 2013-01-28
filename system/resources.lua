--- system.resources
--- ================
---
--- Platform-specific resource loading.

local system = require 'system'

local resources = {}

--- android
--- ---------------------------------------------------------------------------

if system.platform == 'android' then

  local android = require 'bindings.android'
  local ffi = require 'ffi'
  local input = require 'system.input'

  function resources.load(filename)
    local asset = android.AAssetManager_open(
      system.android.android_app.activity.assetManager,
      filename,
      android.AASSET_MODE_BUFFER)

    if asset == nil then
      return nil, 'asset not found'
    end

    local buffer_length = 512
    local buffer = ffi.new('char[?]', buffer_length)
    local strings = {}

    local count = android.AAsset_read(asset, buffer, buffer_length)
    while count > 0 do
      table.insert(strings, ffi.string(buffer, count))
      count = android.AAsset_read(asset, buffer, buffer_length)
    end

    android.AAsset_close(asset)

    return table.concat(strings)
  end

--- desktop
--- ---------------------------------------------------------------------------

else -- assume desktop otherwise

  function resources.load(filename)
    return assert(io.open(filename, 'rb')):read('*a')
  end

end

return resources
