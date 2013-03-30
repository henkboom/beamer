--- system.input
--- ============
---
--- Platform-specific input handling.

local system = require 'system'
local logging = require 'system.logging'

local input = {}

local function wrap_errors(fn)
  return function (...)
    local success, val = pcall(fn, ...)
    if success then
      return val
    else
      print('ERROR: ' .. tostring(val))
    end
  end
end

--- general
--- ---------------------------------------------------------------------------

local function pointer_down(id, x, y)
  return {type = 'pointer_down', id = id, x=x, y=y}
end

local function pointer_motion(id, x, y, dx, dy)
  return {type = 'pointer_motion', id = id, x = x, y = y, dx = dx, dy = dy}
end

local function pointer_up(id, x, y)
  return {type = 'pointer_up', id = id, x = x, y = y}
end

local function pointer_cancel(id)
  return {type = 'pointer_cancel', id = id}
end

local function key_down(key)
  return {type = 'key_down', key = key}
end

local function key_up(key)
  return {type = 'key_up', key = key}
end

local function character_down(character)
  return {type = 'character_down', character = character}
end

local function character_up(key)
  return {type = 'character_up', character = character}
end

local function resize(x, y, w, h)
  return {type = 'resize', x = x, y = y, w = w, h = h}
end

local function quit()
  return {type = 'quit'}
end

local function kill()
  return {type = 'kill'}
end

local events = {}

function input.get_event()
  return table.remove(events, 1)
end

--- android
--- ---------------------------------------------------------------------------

if system.platform == 'android' then

  local ffi = require 'ffi'
  local android = require 'bindings.android'
  local glue = require 'bindings.android_native_app_glue'

  local running = false
  local paused = false

  -- track current positions of pointers
  local pointer_states = {}

  local function handle_command (_, cmd)
    -- ignored for now:
    -- APP_CMD_SAVE_STATE
    -- APP_CMD_INIT_WINDOW
    -- APP_CMD_GAINED_FOCUS
    -- APP_CMD_LOST_FOCUS (supposed to redraw here?)
    -- .. many others
    if cmd == glue.APP_CMD_TERM_WINDOW or
       cmd == glue.APP_CMD_DESTROY then
      logging.log("KILL")
      -- TODO clean this up a bit
      require('system.video').uninit()
      table.insert(events, kill())
      running = false
    elseif cmd == glue.APP_CMD_PAUSE then
      logging.log('pausing game')
      paused = true
    elseif cmd == glue.APP_CMD_RESUME then
      logging.log('unpausing game')
      paused = false
    elseif cmd == glue.APP_CMD_CONTENT_RECT_CHANGED then
      local rect = system.android.android_app.contentRect
      local w, h = rect.right-rect.left, rect.bottom-rect.top
      logging.log('resize', rect.left, rect.top, w, h)
      table.insert(events, resize(rect.left, rect.top, w, h))
    end
  end

  local function handle_input(_, event)
    -- event is an AInputEvent*
    local type = android.AInputEvent_getType(event)
    if type == android.AINPUT_EVENT_TYPE_MOTION then

      local raw_action = android.AMotionEvent_getAction(event)
      local action = bit.band(raw_action,
        android.AMOTION_EVENT_ACTION_MASK)
      local index = bit.rshift(raw_action,
        android.AMOTION_EVENT_ACTION_POINTER_INDEX_SHIFT)

      -- events
      if action == android.AMOTION_EVENT_ACTION_DOWN then
        local id = android.AMotionEvent_getPointerId(event, 0)
        local x = android.AMotionEvent_getX(event, 0)
        local y = android.AMotionEvent_getY(event, 0)
        pointer_states[id] = {x, y}
        table.insert(events, pointer_down(id, x, y))

      elseif action == android.AMOTION_EVENT_ACTION_UP then
        local id = android.AMotionEvent_getPointerId(event, 0)
        local x = android.AMotionEvent_getX(event, 0)
        local y = android.AMotionEvent_getY(event, 0)
        pointer_states[id] = nil
        table.insert(events, pointer_up(id, x, y))
        for id in pairs(pointer_states) do
          logging.log('WARNING: ACTION UP left pointer ' .. id .. 'down')
          table.insert(events,
            pointer_up(id, pointer_states[id].x, pointer_states[id].y))
          pointer_states[id] = nil
        end

      elseif action == android.AMOTION_EVENT_ACTION_CANCEL then
        for id in pairs(pointer_states) do
          table.insert(events,
            pointer_cancel(id, pointer_states[id].x, pointer_states[id].y))
          pointer_states[id] = nil
        end

      elseif action == android.AMOTION_EVENT_ACTION_POINTER_DOWN then
        local id = android.AMotionEvent_getPointerId(event, index)
        local x = android.AMotionEvent_getX(event, id)
        local y = android.AMotionEvent_getY(event, id)
        pointer_states[id] = {x, y}
        table.insert(events, pointer_down(id, x, y))

      elseif action == android.AMOTION_EVENT_ACTION_POINTER_UP then
        local id = android.AMotionEvent_getPointerId(event, index)
        local x = android.AMotionEvent_getX(event, id)
        local y = android.AMotionEvent_getY(event, id)
        pointer_states[id] = nil
        table.insert(events, pointer_up(id, x, y))
      end

      -- motion tracking
      local pointer_count = android.AMotionEvent_getPointerCount(event)
      for i = 0, pointer_count - 1 do
        local id = android.AMotionEvent_getPointerId(event, i)
        local x = android.AMotionEvent_getX(event, i)
        local y = android.AMotionEvent_getY(event, i)
        if pointer_states[id] and
           (x ~= pointer_states[id].x or y ~= pointer_states[id].y) then
          local dx = x - pointer_states[id][1]
          local dy = y - pointer_states[id][2]
          pointer_states[id] = {x, y}
          table.insert(events, pointer_motion(id, x, y, dx, dy))
        end
      end
      return 1
    end
    return 0
  end

  function input.init()
    running = true
    paused = false
    system.android.android_app.onAppCmd = handle_command
    system.android.android_app.onInputEvent = handle_input

    -- if the width and height are nonzero we're using a preexisting window and
    -- won't get a proper resize event, so synthesize one
    local rect = system.android.android_app.contentRect
    local w, h = rect.right-rect.left, rect.bottom-rect.top
    if w ~= 0 and h ~= 0 then
      logging.log('init resize', rect.left, rect.top, w, h)
      table.insert(events, resize(rect.left, rect.top, w, h))
    end
  end

  function input.poll_events()
    if not running then return end

    -- TODO why doesn't the jit.off(input.poll_events) work well enough?
    jit.off()
    --logging.log('poll_events')
    local poll_source = ffi.new('struct android_poll_source*[1]')
    local ret = android.ALooper_pollAll(
      paused and -1 or 0, nil, nil, ffi.cast('void**', poll_source))
    while ret >= 0 do
      if poll_source[0] ~= nil then
        poll_source[0].process(system.android.android_app, poll_source[0])
      end

      if not running then break end

      ret = android.ALooper_pollAll(
        paused and -1 or 0, nil, nil, ffi.cast('void**', poll_source))
    end
    --logging.log('poll_events done')
    jit.on()
  end
  -- turn off jit compilation because ALooper_poll* can call back into lua
  --jit.off(input.poll_events)

--- desktop
--- ---------------------------------------------------------------------------

else -- assume desktop otherwise

  local gl = require 'gl'
  local glfw = require 'bindings.glfw'

  local key_map = {
    [glfw.GLFW_KEY_SPACE]       = 'space',
    [glfw.GLFW_KEY_SPECIAL]     = 'special',
    [glfw.GLFW_KEY_ESC]         = 'esc',
    [glfw.GLFW_KEY_F1]          = 'f1',
    [glfw.GLFW_KEY_F2]          = 'f2',
    [glfw.GLFW_KEY_F3]          = 'f3',
    [glfw.GLFW_KEY_F4]          = 'f4',
    [glfw.GLFW_KEY_F5]          = 'f5',
    [glfw.GLFW_KEY_F6]          = 'f6',
    [glfw.GLFW_KEY_F7]          = 'f7',
    [glfw.GLFW_KEY_F8]          = 'f8',
    [glfw.GLFW_KEY_F9]          = 'f9',
    [glfw.GLFW_KEY_F10]         = 'f10',
    [glfw.GLFW_KEY_F11]         = 'f11',
    [glfw.GLFW_KEY_F12]         = 'f12',
    [glfw.GLFW_KEY_F13]         = 'f13',
    [glfw.GLFW_KEY_F14]         = 'f14',
    [glfw.GLFW_KEY_F15]         = 'f15',
    [glfw.GLFW_KEY_F16]         = 'f16',
    [glfw.GLFW_KEY_F17]         = 'f17',
    [glfw.GLFW_KEY_F18]         = 'f18',
    [glfw.GLFW_KEY_F19]         = 'f19',
    [glfw.GLFW_KEY_F20]         = 'f20',
    [glfw.GLFW_KEY_F21]         = 'f21',
    [glfw.GLFW_KEY_F22]         = 'f22',
    [glfw.GLFW_KEY_F23]         = 'f23',
    [glfw.GLFW_KEY_F24]         = 'f24',
    [glfw.GLFW_KEY_F25]         = 'f25',
    [glfw.GLFW_KEY_UP]          = 'up',
    [glfw.GLFW_KEY_DOWN]        = 'down',
    [glfw.GLFW_KEY_LEFT]        = 'left',
    [glfw.GLFW_KEY_RIGHT]       = 'right',
    [glfw.GLFW_KEY_LSHIFT]      = 'left_shift',
    [glfw.GLFW_KEY_RSHIFT]      = 'right_shift',
    [glfw.GLFW_KEY_LCTRL]       = 'left_ctrl',
    [glfw.GLFW_KEY_RCTRL]       = 'right_ctrl',
    [glfw.GLFW_KEY_LALT]        = 'left_alt',
    [glfw.GLFW_KEY_RALT]        = 'right_alt',
    [glfw.GLFW_KEY_TAB]         = 'tab',
    [glfw.GLFW_KEY_ENTER]       = 'enter',
    [glfw.GLFW_KEY_BACKSPACE]   = 'backspace',
    [glfw.GLFW_KEY_INSERT]      = 'insert',
    [glfw.GLFW_KEY_DEL]         = 'delete',
    [glfw.GLFW_KEY_PAGEUP]      = 'page_up',
    [glfw.GLFW_KEY_PAGEDOWN]    = 'page_down',
    [glfw.GLFW_KEY_HOME]        = 'home',
    [glfw.GLFW_KEY_END]         = 'end',
    [glfw.GLFW_KEY_KP_0]        = 'numpad_0',
    [glfw.GLFW_KEY_KP_1]        = 'numpad_1',
    [glfw.GLFW_KEY_KP_2]        = 'numpad_2',
    [glfw.GLFW_KEY_KP_3]        = 'numpad_3',
    [glfw.GLFW_KEY_KP_4]        = 'numpad_4',
    [glfw.GLFW_KEY_KP_5]        = 'numpad_5',
    [glfw.GLFW_KEY_KP_6]        = 'numpad_6',
    [glfw.GLFW_KEY_KP_7]        = 'numpad_7',
    [glfw.GLFW_KEY_KP_8]        = 'numpad_8',
    [glfw.GLFW_KEY_KP_9]        = 'numpad_9',
    [glfw.GLFW_KEY_KP_DIVIDE]   = 'numpad_divide',
    [glfw.GLFW_KEY_KP_MULTIPLY] = 'numpad_multiply',
    [glfw.GLFW_KEY_KP_SUBTRACT] = 'numpad_subtract',
    [glfw.GLFW_KEY_KP_ADD]      = 'numpad_add',
    [glfw.GLFW_KEY_KP_DECIMAL]  = 'numpad_decimal',
    [glfw.GLFW_KEY_KP_EQUAL]    = 'numpad_equal',
    [glfw.GLFW_KEY_KP_ENTER]    = 'numpad_enter',
    [glfw.GLFW_KEY_KP_NUM_LOCK] = 'numpad_num_lock',
    [glfw.GLFW_KEY_CAPS_LOCK]   = 'caps_lock',
    [glfw.GLFW_KEY_SCROLL_LOCK] = 'scroll_lock',
    [glfw.GLFW_KEY_PAUSE]       = 'pause',
    [glfw.GLFW_KEY_LSUPER]      = 'left_super',
    [glfw.GLFW_KEY_RSUPER]      = 'right_super',
    [glfw.GLFW_KEY_MENU]        = 'menu'
  }


  local position = {x = 0, y = 0}

  function input.init()
    assert(glfw.glfwInit() == gl.GL_TRUE, 'glfwInit failed')

    glfw.glfwDisable(glfw.GLFW_AUTO_POLL_EVENTS)

    glfw.glfwSetKeyCallback(wrap_errors(function (key, action)
      local mapped_key = key_map[key]
      if mapped_key == nil and key >= 0 and key < 256 then
        mapped_key = string.char(key)
      end

      if mapped_key then
        if(action == glfw.GLFW_PRESS) then
          table.insert(events, key_down(mapped_key))
        else
          table.insert(events, key_up(mapped_key))
        end
      end
    end))

    glfw.glfwSetCharCallback(wrap_errors(function (char, action)
      if char < 256 then
        if(action == glfw.GLFW_PRESS) then
          table.insert(events, character_down(string.char(char)))
        else
          table.insert(events, character_up(string.char(char)))
        end
      end
    end))

    glfw.glfwSetMousePosCallback(wrap_errors(function (x, y)
      local dx = x - position.x
      local dy = y - position.y
      position.x = x
      position.y = y
      table.insert(events, pointer_motion(0, x, y, dx, dy))
    end))

    glfw.glfwSetMouseButtonCallback(wrap_errors(function (button, action)
      if button == glfw.GLFW_MOUSE_BUTTON_1 then
        if action == glfw.GLFW_PRESS then
          table.insert(events, pointer_down(0, position.x, position.y))
        else
          table.insert(events, pointer_up(0, position.x, position.y))
        end
      end
    end))

    glfw.glfwSetWindowSizeCallback(wrap_errors(function (width, height)
      table.insert(events, resize(0, 0, width, height))
    end))

    glfw.glfwSetWindowCloseCallback(wrap_errors(function ()
      table.insert(events, quit())
      return gl.GL_FALSE
    end))

    return events
  end

  function input.poll_events()
    glfw.glfwPollEvents()
  end

  -- turn off jit compilation because glfwPollEvents can call back into lua
  jit.off(input.poll_events)

end

return input
