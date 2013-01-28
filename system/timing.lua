--- system.timing
--- =============
---
--- Platform-specific timing functions.

local system = require 'system'

local timing = {}

--- android
--- ---------------------------------------------------------------------------

if system.platform == 'android' then

  local ffi = require 'ffi'

  -- taken from android headers
  ffi.cdef[[
    int usleep(unsigned long);

    static const int CLOCK_MONOTONIC = 1;
    typedef long time_t;
    struct timespec { time_t tv_sec; long tv_nsec; };
    int clock_gettime(int, struct timespec *);
  ]]

  local timespec = ffi.new('struct timespec')

  function timing.init()
  end

  function timing.get_time()
    ffi.C.clock_gettime(ffi.C.CLOCK_MONOTONIC, timespec)
    return tonumber(timespec.tv_sec + timespec.tv_nsec / 1000000000)
  end

  function timing.sleep(time_to_sleep)
    ffi.C.usleep(time_to_sleep * 1000000);
  end

--- desktop
--- ---------------------------------------------------------------------------

else -- assume desktop otherwise

  local gl = require 'gl'
  local glfw = require 'bindings.glfw'

  function timing.init()
    assert(glfw.glfwInit() == gl.GL_TRUE, 'glfwInit failed')
  end

  function timing.get_time()
    return glfw.glfwGetTime()
  end

  function timing.sleep(time_to_sleep)
    glfw.glfwSleep(time_to_sleep)
  end

end

return timing
