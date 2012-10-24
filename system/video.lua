--- system.video
--- ============
---
--- Platform-specific windowing and video initialization.

local gl = require 'gl'
local system = require 'system'
local logging = require 'system.logging'

local video = {}

--- android
--- ---------------------------------------------------------------------------

if system.platform == 'android' then

  local android = require 'bindings.android'
  local egl = require 'bindings.egl'
  local ffi = require 'ffi'

  local window
  local display
  local surface

  function video.android_set_window(w)
    window = w
  end

  function video.init()
    display = egl.eglGetDisplay(ffi.cast('EGLDisplay', egl.EGL_DEFAULT_DISPLAY))
    egl.eglInitialize(display, nil, nil)

    local attribs = ffi.new('EGLint[11]',
      egl.EGL_SURFACE_TYPE, egl.EGL_WINDOW_BIT,
      egl.EGL_BLUE_SIZE, 8,
      egl.EGL_GREEN_SIZE, 8,
      egl.EGL_RED_SIZE, 8,
      egl.EGL_RENDERABLE_TYPE, egl.EGL_OPENGL_ES2_BIT,
      egl.EGL_NONE)

    local ptr_config = ffi.new('EGLConfig[1]')
    local ptr_numconfigs = ffi.new('EGLint[1]')
    local ptr_format = ffi.new('EGLint[1]')

    egl.eglChooseConfig(display, attribs, ptr_config, 1, ptr_numconfigs)
    egl.eglGetConfigAttrib(display, ptr_config[0], egl.EGL_NATIVE_VISUAL_ID, ptr_format);
    android.ANativeWindow_setBuffersGeometry(window, 0, 0, ptr_format[0])
    surface = egl.eglCreateWindowSurface(display, ptr_config[0], window, nil);
    
    local ctx_attribs = ffi.new('EGLint[3]',
      egl.EGL_CONTEXT_CLIENT_VERSION, 2,
      egl.EGL_NONE)
    local context = egl.eglCreateContext(display, ptr_config[0], nil, ctx_attribs);

    assert(egl.eglMakeCurrent(display, surface, surface, context) == egl.EGL_TRUE,
      'unable to eglMakeCurrent');

    local ptr_width = ffi.new('EGLint[1]')
    local ptr_height = ffi.new('EGLint[1]')

    egl.eglQuerySurface(display, surface, egl.EGL_WIDTH, ptr_width);
    egl.eglQuerySurface(display, surface, egl.EGL_HEIGHT, ptr_height);

    logging.log('video initialized ' .. ptr_width[0] .. ' ' .. ptr_height[0])
  end

  function video.uninit()
    -- TODO
  end

  function video.swap_buffers()
    egl.eglSwapBuffers(display, surface)
  end

--- desktop
--- ---------------------------------------------------------------------------

else -- assume desktop otherwise

  local glfw = require 'bindings.glfw'

  local width, height = 800, 480

  local inited = false

  function video.init()
    assert(glfw.glfwInit() == gl.GL_TRUE, 'glfwInit failed')

    assert(
      glfw.glfwOpenWindow(width, height, 8, 8, 8, 8, 24, 0, glfw.GLFW_WINDOW)
        == gl.GL_TRUE, 'glfwOpenWindow failed')
  end

  function video.uninit()
    glfw.glfwCloseWindow()
  end

  function video.swap_buffers()
    glfw.glfwSwapBuffers()
  end

end

return video
