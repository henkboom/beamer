--- android
--- =======
---
--- FFI bindings to the native Android API (-landroid).

local ffi = require 'ffi'
require 'bindings.jni'

local android = ffi.load('android')

-- from sys/types.h and arm/posix_types.h
ffi.cdef [[
typedef long off_t;
typedef long int  ssize_t;
]]

--- android/bitmap.h
--- ---------------------------------------------------------------------------

-- TODO

--- android/asset_manager.h
--- ---------------------------------------------------------------------------

ffi.cdef [[
/*
 * Copyright (C) 2010 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

struct AAssetManager;
typedef struct AAssetManager AAssetManager;

struct AAssetDir;
typedef struct AAssetDir AAssetDir;

struct AAsset;
typedef struct AAsset AAsset;

/* Available modes for opening assets */
enum {
    AASSET_MODE_UNKNOWN      = 0,
    AASSET_MODE_RANDOM       = 1,
    AASSET_MODE_STREAMING    = 2,
    AASSET_MODE_BUFFER       = 3
};


/**
 * Open the named directory within the asset hierarchy.  The directory can then
 * be inspected with the AAssetDir functions.  To open the top-level directory,
 * pass in "" as the dirName.
 *
 * The object returned here should be freed by calling AAssetDir_close().
 */
AAssetDir* AAssetManager_openDir(AAssetManager* mgr, const char* dirName);

/**
 * Open an asset.
 *
 * The object returned here should be freed by calling AAsset_close().
 */
AAsset* AAssetManager_open(AAssetManager* mgr, const char* filename, int mode);

/**
 * Iterate over the files in an asset directory.  A NULL string is returned
 * when all the file names have been returned.
 *
 * The returned file name is suitable for passing to AAssetManager_open().
 *
 * The string returned here is owned by the AssetDir implementation and is not
 * guaranteed to remain valid if any other calls are made on this AAssetDir
 * instance.
 */
const char* AAssetDir_getNextFileName(AAssetDir* assetDir);

/**
 * Reset the iteration state of AAssetDir_getNextFileName() to the beginning.
 */
void AAssetDir_rewind(AAssetDir* assetDir);

/**
 * Close an opened AAssetDir, freeing any related resources.
 */
void AAssetDir_close(AAssetDir* assetDir);

/**
 * Attempt to read 'count' bytes of data from the current offset.
 *
 * Returns the number of bytes read, zero on EOF, or < 0 on error.
 */
int AAsset_read(AAsset* asset, void* buf, size_t count);

/**
 * Seek to the specified offset within the asset data.  'whence' uses the
 * same constants as lseek()/fseek().
 *
 * Returns the new position on success, or (off_t) -1 on error.
 */
off_t AAsset_seek(AAsset* asset, off_t offset, int whence);

/**
 * Close the asset, freeing all associated resources.
 */
void AAsset_close(AAsset* asset);

/**
 * Get a pointer to a buffer holding the entire contents of the assset.
 *
 * Returns NULL on failure.
 */
const void* AAsset_getBuffer(AAsset* asset);

/**
 * Report the total size of the asset data.
 */
off_t AAsset_getLength(AAsset* asset);

/**
 * Report the total amount of asset data that can be read from the current position.
 */
off_t AAsset_getRemainingLength(AAsset* asset);

/**
 * Open a new file descriptor that can be used to read the asset data.
 *
 * Returns < 0 if direct fd access is not possible (for example, if the asset is
 * compressed).
 */
int AAsset_openFileDescriptor(AAsset* asset, off_t* outStart, off_t* outLength);

/**
 * Returns whether this asset's internal buffer is allocated in ordinary RAM (i.e. not
 * mmapped).
 */
int AAsset_isAllocated(AAsset* asset);
]]

--- android/keycodes.h
--- ---------------------------------------------------------------------------

ffi.cdef [[
/*
 * Copyright (C) 2010 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/*
 * Key codes.
 */
enum {
    AKEYCODE_UNKNOWN         = 0,
    AKEYCODE_SOFT_LEFT       = 1,
    AKEYCODE_SOFT_RIGHT      = 2,
    AKEYCODE_HOME            = 3,
    AKEYCODE_BACK            = 4,
    AKEYCODE_CALL            = 5,
    AKEYCODE_ENDCALL         = 6,
    AKEYCODE_0               = 7,
    AKEYCODE_1               = 8,
    AKEYCODE_2               = 9,
    AKEYCODE_3               = 10,
    AKEYCODE_4               = 11,
    AKEYCODE_5               = 12,
    AKEYCODE_6               = 13,
    AKEYCODE_7               = 14,
    AKEYCODE_8               = 15,
    AKEYCODE_9               = 16,
    AKEYCODE_STAR            = 17,
    AKEYCODE_POUND           = 18,
    AKEYCODE_DPAD_UP         = 19,
    AKEYCODE_DPAD_DOWN       = 20,
    AKEYCODE_DPAD_LEFT       = 21,
    AKEYCODE_DPAD_RIGHT      = 22,
    AKEYCODE_DPAD_CENTER     = 23,
    AKEYCODE_VOLUME_UP       = 24,
    AKEYCODE_VOLUME_DOWN     = 25,
    AKEYCODE_POWER           = 26,
    AKEYCODE_CAMERA          = 27,
    AKEYCODE_CLEAR           = 28,
    AKEYCODE_A               = 29,
    AKEYCODE_B               = 30,
    AKEYCODE_C               = 31,
    AKEYCODE_D               = 32,
    AKEYCODE_E               = 33,
    AKEYCODE_F               = 34,
    AKEYCODE_G               = 35,
    AKEYCODE_H               = 36,
    AKEYCODE_I               = 37,
    AKEYCODE_J               = 38,
    AKEYCODE_K               = 39,
    AKEYCODE_L               = 40,
    AKEYCODE_M               = 41,
    AKEYCODE_N               = 42,
    AKEYCODE_O               = 43,
    AKEYCODE_P               = 44,
    AKEYCODE_Q               = 45,
    AKEYCODE_R               = 46,
    AKEYCODE_S               = 47,
    AKEYCODE_T               = 48,
    AKEYCODE_U               = 49,
    AKEYCODE_V               = 50,
    AKEYCODE_W               = 51,
    AKEYCODE_X               = 52,
    AKEYCODE_Y               = 53,
    AKEYCODE_Z               = 54,
    AKEYCODE_COMMA           = 55,
    AKEYCODE_PERIOD          = 56,
    AKEYCODE_ALT_LEFT        = 57,
    AKEYCODE_ALT_RIGHT       = 58,
    AKEYCODE_SHIFT_LEFT      = 59,
    AKEYCODE_SHIFT_RIGHT     = 60,
    AKEYCODE_TAB             = 61,
    AKEYCODE_SPACE           = 62,
    AKEYCODE_SYM             = 63,
    AKEYCODE_EXPLORER        = 64,
    AKEYCODE_ENVELOPE        = 65,
    AKEYCODE_ENTER           = 66,
    AKEYCODE_DEL             = 67,
    AKEYCODE_GRAVE           = 68,
    AKEYCODE_MINUS           = 69,
    AKEYCODE_EQUALS          = 70,
    AKEYCODE_LEFT_BRACKET    = 71,
    AKEYCODE_RIGHT_BRACKET   = 72,
    AKEYCODE_BACKSLASH       = 73,
    AKEYCODE_SEMICOLON       = 74,
    AKEYCODE_APOSTROPHE      = 75,
    AKEYCODE_SLASH           = 76,
    AKEYCODE_AT              = 77,
    AKEYCODE_NUM             = 78,
    AKEYCODE_HEADSETHOOK     = 79,
    AKEYCODE_FOCUS           = 80,   // *Camera* focus
    AKEYCODE_PLUS            = 81,
    AKEYCODE_MENU            = 82,
    AKEYCODE_NOTIFICATION    = 83,
    AKEYCODE_SEARCH          = 84,
    AKEYCODE_MEDIA_PLAY_PAUSE= 85,
    AKEYCODE_MEDIA_STOP      = 86,
    AKEYCODE_MEDIA_NEXT      = 87,
    AKEYCODE_MEDIA_PREVIOUS  = 88,
    AKEYCODE_MEDIA_REWIND    = 89,
    AKEYCODE_MEDIA_FAST_FORWARD = 90,
    AKEYCODE_MUTE            = 91,
    AKEYCODE_PAGE_UP         = 92,
    AKEYCODE_PAGE_DOWN       = 93,
    AKEYCODE_PICTSYMBOLS     = 94,
    AKEYCODE_SWITCH_CHARSET  = 95,
    AKEYCODE_BUTTON_A        = 96,
    AKEYCODE_BUTTON_B        = 97,
    AKEYCODE_BUTTON_C        = 98,
    AKEYCODE_BUTTON_X        = 99,
    AKEYCODE_BUTTON_Y        = 100,
    AKEYCODE_BUTTON_Z        = 101,
    AKEYCODE_BUTTON_L1       = 102,
    AKEYCODE_BUTTON_R1       = 103,
    AKEYCODE_BUTTON_L2       = 104,
    AKEYCODE_BUTTON_R2       = 105,
    AKEYCODE_BUTTON_THUMBL   = 106,
    AKEYCODE_BUTTON_THUMBR   = 107,
    AKEYCODE_BUTTON_START    = 108,
    AKEYCODE_BUTTON_SELECT   = 109,
    AKEYCODE_BUTTON_MODE     = 110,

    // NOTE: If you add a new keycode here you must also add it to several other files.
    //       Refer to frameworks/base/core/java/android/view/KeyEvent.java for the full list.
};
]]

--- android/looper.h
--- ---------------------------------------------------------------------------

ffi.cdef [[
/*
 * Copyright (C) 2010 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/**
 * ALooper
 *
 * A looper is the state tracking an event loop for a thread.
 * Loopers do not define event structures or other such things; rather
 * they are a lower-level facility to attach one or more discrete objects
 * listening for an event.  An "event" here is simply data available on
 * a file descriptor: each attached object has an associated file descriptor,
 * and waiting for "events" means (internally) polling on all of these file
 * descriptors until one or more of them have data available.
 *
 * A thread can have only one ALooper associated with it.
 */
struct ALooper;
typedef struct ALooper ALooper;

/**
 * Returns the looper associated with the calling thread, or NULL if
 * there is not one.
 */
ALooper* ALooper_forThread();

enum {
    /**
     * Option for ALooper_prepare: this looper will accept calls to
     * ALooper_addFd() that do not have a callback (that is provide NULL
     * for the callback).  In this case the caller of ALooper_pollOnce()
     * or ALooper_pollAll() MUST check the return from these functions to
     * discover when data is available on such fds and process it.
     */
    ALOOPER_PREPARE_ALLOW_NON_CALLBACKS = 1<<0
};

/**
 * Prepares a looper associated with the calling thread, and returns it.
 * If the thread already has a looper, it is returned.  Otherwise, a new
 * one is created, associated with the thread, and returned.
 *
 * The opts may be ALOOPER_PREPARE_ALLOW_NON_CALLBACKS or 0.
 */
ALooper* ALooper_prepare(int opts);

enum {
    /**
     * Result from ALooper_pollOnce() and ALooper_pollAll():
     * The poll was awoken using wake() before the timeout expired
     * and no callbacks were executed and no other file descriptors were ready.
     */
    ALOOPER_POLL_WAKE = -1,

    /**
     * Result from ALooper_pollOnce() and ALooper_pollAll():
     * One or more callbacks were executed.
     */
    ALOOPER_POLL_CALLBACK = -2,

    /**
     * Result from ALooper_pollOnce() and ALooper_pollAll():
     * The timeout expired.
     */
    ALOOPER_POLL_TIMEOUT = -3,

    /**
     * Result from ALooper_pollOnce() and ALooper_pollAll():
     * An error occurred.
     */
    ALOOPER_POLL_ERROR = -4,
};

/**
 * Acquire a reference on the given ALooper object.  This prevents the object
 * from being deleted until the reference is removed.  This is only needed
 * to safely hand an ALooper from one thread to another.
 */
void ALooper_acquire(ALooper* looper);

/**
 * Remove a reference that was previously acquired with ALooper_acquire().
 */
void ALooper_release(ALooper* looper);

/**
 * Flags for file descriptor events that a looper can monitor.
 *
 * These flag bits can be combined to monitor multiple events at once.
 */
enum {
    /**
     * The file descriptor is available for read operations.
     */
    ALOOPER_EVENT_INPUT = 1 << 0,

    /**
     * The file descriptor is available for write operations.
     */
    ALOOPER_EVENT_OUTPUT = 1 << 1,

    /**
     * The file descriptor has encountered an error condition.
     *
     * The looper always sends notifications about errors; it is not necessary
     * to specify this event flag in the requested event set.
     */
    ALOOPER_EVENT_ERROR = 1 << 2,

    /**
     * The file descriptor was hung up.
     * For example, indicates that the remote end of a pipe or socket was closed.
     *
     * The looper always sends notifications about hangups; it is not necessary
     * to specify this event flag in the requested event set.
     */
    ALOOPER_EVENT_HANGUP = 1 << 3,

    /**
     * The file descriptor is invalid.
     * For example, the file descriptor was closed prematurely.
     *
     * The looper always sends notifications about invalid file descriptors; it is not necessary
     * to specify this event flag in the requested event set.
     */
    ALOOPER_EVENT_INVALID = 1 << 4,
};

/**
 * For callback-based event loops, this is the prototype of the function
 * that is called.  It is given the file descriptor it is associated with,
 * a bitmask of the poll events that were triggered (typically ALOOPER_EVENT_INPUT),
 * and the data pointer that was originally supplied.
 *
 * Implementations should return 1 to continue receiving callbacks, or 0
 * to have this file descriptor and callback unregistered from the looper.
 */
typedef int (*ALooper_callbackFunc)(int fd, int events, void* data);

/**
 * Waits for events to be available, with optional timeout in milliseconds.
 * Invokes callbacks for all file descriptors on which an event occurred.
 *
 * If the timeout is zero, returns immediately without blocking.
 * If the timeout is negative, waits indefinitely until an event appears.
 *
 * Returns ALOOPER_POLL_WAKE if the poll was awoken using wake() before
 * the timeout expired and no callbacks were invoked and no other file
 * descriptors were ready.
 *
 * Returns ALOOPER_POLL_CALLBACK if one or more callbacks were invoked.
 *
 * Returns ALOOPER_POLL_TIMEOUT if there was no data before the given
 * timeout expired.
 *
 * Returns ALOOPER_POLL_ERROR if an error occurred.
 *
 * Returns a value >= 0 containing an identifier if its file descriptor has data
 * and it has no callback function (requiring the caller here to handle it).
 * In this (and only this) case outFd, outEvents and outData will contain the poll
 * events and data associated with the fd, otherwise they will be set to NULL.
 *
 * This method does not return until it has finished invoking the appropriate callbacks
 * for all file descriptors that were signalled.
 */
int ALooper_pollOnce(int timeoutMillis, int* outFd, int* outEvents, void** outData);

/**
 * Like ALooper_pollOnce(), but performs all pending callbacks until all
 * data has been consumed or a file descriptor is available with no callback.
 * This function will never return ALOOPER_POLL_CALLBACK.
 */
int ALooper_pollAll(int timeoutMillis, int* outFd, int* outEvents, void** outData);

/**
 * Wakes the poll asynchronously.
 *
 * This method can be called on any thread.
 * This method returns immediately.
 */
void ALooper_wake(ALooper* looper);

/**
 * Adds a new file descriptor to be polled by the looper.
 * If the same file descriptor was previously added, it is replaced.
 *
 * "fd" is the file descriptor to be added.
 * "ident" is an identifier for this event, which is returned from ALooper_pollOnce().
 * The identifier must be >= 0, or ALOOPER_POLL_CALLBACK if providing a non-NULL callback.
 * "events" are the poll events to wake up on.  Typically this is ALOOPER_EVENT_INPUT.
 * "callback" is the function to call when there is an event on the file descriptor.
 * "data" is a private data pointer to supply to the callback.
 *
 * There are two main uses of this function:
 *
 * (1) If "callback" is non-NULL, then this function will be called when there is
 * data on the file descriptor.  It should execute any events it has pending,
 * appropriately reading from the file descriptor.  The 'ident' is ignored in this case.
 *
 * (2) If "callback" is NULL, the 'ident' will be returned by ALooper_pollOnce
 * when its file descriptor has data available, requiring the caller to take
 * care of processing it.
 *
 * Returns 1 if the file descriptor was added or -1 if an error occurred.
 *
 * This method can be called on any thread.
 * This method may block briefly if it needs to wake the poll.
 */
int ALooper_addFd(ALooper* looper, int fd, int ident, int events,
        ALooper_callbackFunc callback, void* data);

/**
 * Removes a previously added file descriptor from the looper.
 *
 * When this method returns, it is safe to close the file descriptor since the looper
 * will no longer have a reference to it.  However, it is possible for the callback to
 * already be running or for it to run one last time if the file descriptor was already
 * signalled.  Calling code is responsible for ensuring that this case is safely handled.
 * For example, if the callback takes care of removing itself during its own execution either
 * by returning 0 or by calling this method, then it can be guaranteed to not be invoked
 * again at any later time unless registered anew.
 *
 * Returns 1 if the file descriptor was removed, 0 if none was previously registered
 * or -1 if an error occurred.
 *
 * This method can be called on any thread.
 * This method may block briefly if it needs to wake the poll.
 */
int ALooper_removeFd(ALooper* looper, int fd);
]]

--- android/input.h
--- ---------------------------------------------------------------------------

ffi.cdef [[
/*
 * Copyright (C) 2010 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/*
 * Key states (may be returned by queries about the current state of a
 * particular key code, scan code or switch).
 */
enum {
    /* The key state is unknown or the requested key itself is not supported. */
    AKEY_STATE_UNKNOWN = -1,

    /* The key is up. */
    AKEY_STATE_UP = 0,

    /* The key is down. */
    AKEY_STATE_DOWN = 1,

    /* The key is down but is a virtual key press that is being emulated by the system. */
    AKEY_STATE_VIRTUAL = 2
};

/*
 * Meta key / modifer state.
 */
enum {
    /* No meta keys are pressed. */
    AMETA_NONE = 0,

    /* This mask is used to check whether one of the ALT meta keys is pressed. */
    AMETA_ALT_ON = 0x02,

    /* This mask is used to check whether the left ALT meta key is pressed. */
    AMETA_ALT_LEFT_ON = 0x10,

    /* This mask is used to check whether the right ALT meta key is pressed. */
    AMETA_ALT_RIGHT_ON = 0x20,

    /* This mask is used to check whether one of the SHIFT meta keys is pressed. */
    AMETA_SHIFT_ON = 0x01,

    /* This mask is used to check whether the left SHIFT meta key is pressed. */
    AMETA_SHIFT_LEFT_ON = 0x40,

    /* This mask is used to check whether the right SHIFT meta key is pressed. */
    AMETA_SHIFT_RIGHT_ON = 0x80,

    /* This mask is used to check whether the SYM meta key is pressed. */
    AMETA_SYM_ON = 0x04
};

/*
 * Input events.
 *
 * Input events are opaque structures.  Use the provided accessors functions to
 * read their properties.
 */
struct AInputEvent;
typedef struct AInputEvent AInputEvent;

/*
 * Input event types.
 */
enum {
    /* Indicates that the input event is a key event. */
    AINPUT_EVENT_TYPE_KEY = 1,

    /* Indicates that the input event is a motion event. */
    AINPUT_EVENT_TYPE_MOTION = 2
};

/*
 * Key event actions.
 */
enum {
    /* The key has been pressed down. */
    AKEY_EVENT_ACTION_DOWN = 0,

    /* The key has been released. */
    AKEY_EVENT_ACTION_UP = 1,

    /* Multiple duplicate key events have occurred in a row, or a complex string is
     * being delivered.  The repeat_count property of the key event contains the number
     * of times the given key code should be executed.
     */
    AKEY_EVENT_ACTION_MULTIPLE = 2
};

/*
 * Key event flags.
 */
enum {
    /* This mask is set if the device woke because of this key event. */
    AKEY_EVENT_FLAG_WOKE_HERE = 0x1,

    /* This mask is set if the key event was generated by a software keyboard. */
    AKEY_EVENT_FLAG_SOFT_KEYBOARD = 0x2,

    /* This mask is set if we don't want the key event to cause us to leave touch mode. */
    AKEY_EVENT_FLAG_KEEP_TOUCH_MODE = 0x4,

    /* This mask is set if an event was known to come from a trusted part
     * of the system.  That is, the event is known to come from the user,
     * and could not have been spoofed by a third party component. */
    AKEY_EVENT_FLAG_FROM_SYSTEM = 0x8,

    /* This mask is used for compatibility, to identify enter keys that are
     * coming from an IME whose enter key has been auto-labelled "next" or
     * "done".  This allows TextView to dispatch these as normal enter keys
     * for old applications, but still do the appropriate action when
     * receiving them. */
    AKEY_EVENT_FLAG_EDITOR_ACTION = 0x10,

    /* When associated with up key events, this indicates that the key press
     * has been canceled.  Typically this is used with virtual touch screen
     * keys, where the user can slide from the virtual key area on to the
     * display: in that case, the application will receive a canceled up
     * event and should not perform the action normally associated with the
     * key.  Note that for this to work, the application can not perform an
     * action for a key until it receives an up or the long press timeout has
     * expired. */
    AKEY_EVENT_FLAG_CANCELED = 0x20,

    /* This key event was generated by a virtual (on-screen) hard key area.
     * Typically this is an area of the touchscreen, outside of the regular
     * display, dedicated to "hardware" buttons. */
    AKEY_EVENT_FLAG_VIRTUAL_HARD_KEY = 0x40,

    /* This flag is set for the first key repeat that occurs after the
     * long press timeout. */
    AKEY_EVENT_FLAG_LONG_PRESS = 0x80,

    /* Set when a key event has AKEY_EVENT_FLAG_CANCELED set because a long
     * press action was executed while it was down. */
    AKEY_EVENT_FLAG_CANCELED_LONG_PRESS = 0x100,

    /* Set for AKEY_EVENT_ACTION_UP when this event's key code is still being
     * tracked from its initial down.  That is, somebody requested that tracking
     * started on the key down and a long press has not caused
     * the tracking to be canceled. */
    AKEY_EVENT_FLAG_TRACKING = 0x200
};

/*
 * Motion event actions.
 */

/* Bit shift for the action bits holding the pointer index as
 * defined by AMOTION_EVENT_ACTION_POINTER_INDEX_MASK.
 */
static const int AMOTION_EVENT_ACTION_POINTER_INDEX_SHIFT = 8;

enum {
    /* Bit mask of the parts of the action code that are the action itself.
     */
    AMOTION_EVENT_ACTION_MASK = 0xff,

    /* Bits in the action code that represent a pointer index, used with
     * AMOTION_EVENT_ACTION_POINTER_DOWN and AMOTION_EVENT_ACTION_POINTER_UP.  Shifting
     * down by AMOTION_EVENT_ACTION_POINTER_INDEX_SHIFT provides the actual pointer
     * index where the data for the pointer going up or down can be found.
     */
    AMOTION_EVENT_ACTION_POINTER_INDEX_MASK  = 0xff00,

    /* A pressed gesture has started, the motion contains the initial starting location.
     */
    AMOTION_EVENT_ACTION_DOWN = 0,

    /* A pressed gesture has finished, the motion contains the final release location
     * as well as any intermediate points since the last down or move event.
     */
    AMOTION_EVENT_ACTION_UP = 1,

    /* A change has happened during a press gesture (between AMOTION_EVENT_ACTION_DOWN and
     * AMOTION_EVENT_ACTION_UP).  The motion contains the most recent point, as well as
     * any intermediate points since the last down or move event.
     */
    AMOTION_EVENT_ACTION_MOVE = 2,

    /* The current gesture has been aborted.
     * You will not receive any more points in it.  You should treat this as
     * an up event, but not perform any action that you normally would.
     */
    AMOTION_EVENT_ACTION_CANCEL = 3,

    /* A movement has happened outside of the normal bounds of the UI element.
     * This does not provide a full gesture, but only the initial location of the movement/touch.
     */
    AMOTION_EVENT_ACTION_OUTSIDE = 4,

    /* A non-primary pointer has gone down.
     * The bits in AMOTION_EVENT_ACTION_POINTER_INDEX_MASK indicate which pointer changed.
     */
    AMOTION_EVENT_ACTION_POINTER_DOWN = 5,

    /* A non-primary pointer has gone up.
     * The bits in AMOTION_EVENT_ACTION_POINTER_INDEX_MASK indicate which pointer changed.
     */
    AMOTION_EVENT_ACTION_POINTER_UP = 6
};

/*
 * Motion event flags.
 */
enum {
    /* This flag indicates that the window that received this motion event is partly
     * or wholly obscured by another visible window above it.  This flag is set to true
     * even if the event did not directly pass through the obscured area.
     * A security sensitive application can check this flag to identify situations in which
     * a malicious application may have covered up part of its content for the purpose
     * of misleading the user or hijacking touches.  An appropriate response might be
     * to drop the suspect touches or to take additional precautions to confirm the user's
     * actual intent.
     */
    AMOTION_EVENT_FLAG_WINDOW_IS_OBSCURED = 0x1,
};

/*
 * Motion event edge touch flags.
 */
enum {
    /* No edges intersected */
    AMOTION_EVENT_EDGE_FLAG_NONE = 0,

    /* Flag indicating the motion event intersected the top edge of the screen. */
    AMOTION_EVENT_EDGE_FLAG_TOP = 0x01,

    /* Flag indicating the motion event intersected the bottom edge of the screen. */
    AMOTION_EVENT_EDGE_FLAG_BOTTOM = 0x02,

    /* Flag indicating the motion event intersected the left edge of the screen. */
    AMOTION_EVENT_EDGE_FLAG_LEFT = 0x04,

    /* Flag indicating the motion event intersected the right edge of the screen. */
    AMOTION_EVENT_EDGE_FLAG_RIGHT = 0x08
};

/*
 * Input sources.
 *
 * Refer to the documentation on android.view.InputDevice for more details about input sources
 * and their correct interpretation.
 */
enum {
    AINPUT_SOURCE_CLASS_MASK = 0x000000ff,

    AINPUT_SOURCE_CLASS_BUTTON = 0x00000001,
    AINPUT_SOURCE_CLASS_POINTER = 0x00000002,
    AINPUT_SOURCE_CLASS_NAVIGATION = 0x00000004,
    AINPUT_SOURCE_CLASS_POSITION = 0x00000008,
};

enum {
    AINPUT_SOURCE_UNKNOWN = 0x00000000,

    AINPUT_SOURCE_KEYBOARD = 0x00000100 | AINPUT_SOURCE_CLASS_BUTTON,
    AINPUT_SOURCE_DPAD = 0x00000200 | AINPUT_SOURCE_CLASS_BUTTON,
    AINPUT_SOURCE_TOUCHSCREEN = 0x00001000 | AINPUT_SOURCE_CLASS_POINTER,
    AINPUT_SOURCE_MOUSE = 0x00002000 | AINPUT_SOURCE_CLASS_POINTER,
    AINPUT_SOURCE_TRACKBALL = 0x00010000 | AINPUT_SOURCE_CLASS_NAVIGATION,
    AINPUT_SOURCE_TOUCHPAD = 0x00100000 | AINPUT_SOURCE_CLASS_POSITION,

    AINPUT_SOURCE_ANY = 0xffffff00,
};

/*
 * Keyboard types.
 *
 * Refer to the documentation on android.view.InputDevice for more details.
 */
enum {
    AINPUT_KEYBOARD_TYPE_NONE = 0,
    AINPUT_KEYBOARD_TYPE_NON_ALPHABETIC = 1,
    AINPUT_KEYBOARD_TYPE_ALPHABETIC = 2,
};

/*
 * Constants used to retrieve information about the range of motion for a particular
 * coordinate of a motion event.
 *
 * Refer to the documentation on android.view.InputDevice for more details about input sources
 * and their correct interpretation.
 */
enum {
    AINPUT_MOTION_RANGE_X = 0,
    AINPUT_MOTION_RANGE_Y = 1,
    AINPUT_MOTION_RANGE_PRESSURE = 2,
    AINPUT_MOTION_RANGE_SIZE = 3,
    AINPUT_MOTION_RANGE_TOUCH_MAJOR = 4,
    AINPUT_MOTION_RANGE_TOUCH_MINOR = 5,
    AINPUT_MOTION_RANGE_TOOL_MAJOR = 6,
    AINPUT_MOTION_RANGE_TOOL_MINOR = 7,
    AINPUT_MOTION_RANGE_ORIENTATION = 8,
};


/*
 * Input event accessors.
 *
 * Note that most functions can only be used on input events that are of a given type.
 * Calling these functions on input events of other types will yield undefined behavior.
 */

/*** Accessors for all input events. ***/

/* Get the input event type. */
int32_t AInputEvent_getType(const AInputEvent* event);

/* Get the id for the device that an input event came from.
 *
 * Input events can be generated by multiple different input devices.
 * Use the input device id to obtain information about the input
 * device that was responsible for generating a particular event.
 *
 * An input device id of 0 indicates that the event didn't come from a physical device;
 * other numbers are arbitrary and you shouldn't depend on the values.
 * Use the provided input device query API to obtain information about input devices.
 */
int32_t AInputEvent_getDeviceId(const AInputEvent* event);

/* Get the input event source. */
int32_t AInputEvent_getSource(const AInputEvent* event);

/*** Accessors for key events only. ***/

/* Get the key event action. */
int32_t AKeyEvent_getAction(const AInputEvent* key_event);

/* Get the key event flags. */
int32_t AKeyEvent_getFlags(const AInputEvent* key_event);

/* Get the key code of the key event.
 * This is the physical key that was pressed, not the Unicode character. */
int32_t AKeyEvent_getKeyCode(const AInputEvent* key_event);

/* Get the hardware key id of this key event.
 * These values are not reliable and vary from device to device. */
int32_t AKeyEvent_getScanCode(const AInputEvent* key_event);

/* Get the meta key state. */
int32_t AKeyEvent_getMetaState(const AInputEvent* key_event);

/* Get the repeat count of the event.
 * For both key up an key down events, this is the number of times the key has
 * repeated with the first down starting at 0 and counting up from there.  For
 * multiple key events, this is the number of down/up pairs that have occurred. */
int32_t AKeyEvent_getRepeatCount(const AInputEvent* key_event);

/* Get the time of the most recent key down event, in the
 * java.lang.System.nanoTime() time base.  If this is a down event,
 * this will be the same as eventTime.
 * Note that when chording keys, this value is the down time of the most recently
 * pressed key, which may not be the same physical key of this event. */
int64_t AKeyEvent_getDownTime(const AInputEvent* key_event);

/* Get the time this event occurred, in the
 * java.lang.System.nanoTime() time base. */
int64_t AKeyEvent_getEventTime(const AInputEvent* key_event);

/*** Accessors for motion events only. ***/

/* Get the combined motion event action code and pointer index. */
int32_t AMotionEvent_getAction(const AInputEvent* motion_event);

/* Get the motion event flags. */
int32_t AMotionEvent_getFlags(const AInputEvent* motion_event);

/* Get the state of any meta / modifier keys that were in effect when the
 * event was generated. */
int32_t AMotionEvent_getMetaState(const AInputEvent* motion_event);

/* Get a bitfield indicating which edges, if any, were touched by this motion event.
 * For touch events, clients can use this to determine if the user's finger was
 * touching the edge of the display. */
int32_t AMotionEvent_getEdgeFlags(const AInputEvent* motion_event);

/* Get the time when the user originally pressed down to start a stream of
 * position events, in the java.lang.System.nanoTime() time base. */
int64_t AMotionEvent_getDownTime(const AInputEvent* motion_event);

/* Get the time when this specific event was generated,
 * in the java.lang.System.nanoTime() time base. */
int64_t AMotionEvent_getEventTime(const AInputEvent* motion_event);

/* Get the X coordinate offset.
 * For touch events on the screen, this is the delta that was added to the raw
 * screen coordinates to adjust for the absolute position of the containing windows
 * and views. */
float AMotionEvent_getXOffset(const AInputEvent* motion_event);

/* Get the precision of the Y coordinates being reported.
 * For touch events on the screen, this is the delta that was added to the raw
 * screen coordinates to adjust for the absolute position of the containing windows
 * and views. */
float AMotionEvent_getYOffset(const AInputEvent* motion_event);

/* Get the precision of the X coordinates being reported.
 * You can multiply this number with an X coordinate sample to find the
 * actual hardware value of the X coordinate. */
float AMotionEvent_getXPrecision(const AInputEvent* motion_event);

/* Get the precision of the Y coordinates being reported.
 * You can multiply this number with a Y coordinate sample to find the
 * actual hardware value of the Y coordinate. */
float AMotionEvent_getYPrecision(const AInputEvent* motion_event);

/* Get the number of pointers of data contained in this event.
 * Always >= 1. */
size_t AMotionEvent_getPointerCount(const AInputEvent* motion_event);

/* Get the pointer identifier associated with a particular pointer
 * data index is this event.  The identifier tells you the actual pointer
 * number associated with the data, accounting for individual pointers
 * going up and down since the start of the current gesture. */
int32_t AMotionEvent_getPointerId(const AInputEvent* motion_event, size_t pointer_index);

/* Get the original raw X coordinate of this event.
 * For touch events on the screen, this is the original location of the event
 * on the screen, before it had been adjusted for the containing window
 * and views. */
float AMotionEvent_getRawX(const AInputEvent* motion_event, size_t pointer_index);

/* Get the original raw X coordinate of this event.
 * For touch events on the screen, this is the original location of the event
 * on the screen, before it had been adjusted for the containing window
 * and views. */
float AMotionEvent_getRawY(const AInputEvent* motion_event, size_t pointer_index);

/* Get the current X coordinate of this event for the given pointer index.
 * Whole numbers are pixels; the value may have a fraction for input devices
 * that are sub-pixel precise. */
float AMotionEvent_getX(const AInputEvent* motion_event, size_t pointer_index);

/* Get the current Y coordinate of this event for the given pointer index.
 * Whole numbers are pixels; the value may have a fraction for input devices
 * that are sub-pixel precise. */
float AMotionEvent_getY(const AInputEvent* motion_event, size_t pointer_index);

/* Get the current pressure of this event for the given pointer index.
 * The pressure generally ranges from 0 (no pressure at all) to 1 (normal pressure),
 * although values higher than 1 may be generated depending on the calibration of
 * the input device. */
float AMotionEvent_getPressure(const AInputEvent* motion_event, size_t pointer_index);

/* Get the current scaled value of the approximate size for the given pointer index.
 * This represents some approximation of the area of the screen being
 * pressed; the actual value in pixels corresponding to the
 * touch is normalized with the device specific range of values
 * and scaled to a value between 0 and 1.  The value of size can be used to
 * determine fat touch events. */
float AMotionEvent_getSize(const AInputEvent* motion_event, size_t pointer_index);

/* Get the current length of the major axis of an ellipse that describes the touch area
 * at the point of contact for the given pointer index. */
float AMotionEvent_getTouchMajor(const AInputEvent* motion_event, size_t pointer_index);

/* Get the current length of the minor axis of an ellipse that describes the touch area
 * at the point of contact for the given pointer index. */
float AMotionEvent_getTouchMinor(const AInputEvent* motion_event, size_t pointer_index);

/* Get the current length of the major axis of an ellipse that describes the size
 * of the approaching tool for the given pointer index.
 * The tool area represents the estimated size of the finger or pen that is
 * touching the device independent of its actual touch area at the point of contact. */
float AMotionEvent_getToolMajor(const AInputEvent* motion_event, size_t pointer_index);

/* Get the current length of the minor axis of an ellipse that describes the size
 * of the approaching tool for the given pointer index.
 * The tool area represents the estimated size of the finger or pen that is
 * touching the device independent of its actual touch area at the point of contact. */
float AMotionEvent_getToolMinor(const AInputEvent* motion_event, size_t pointer_index);

/* Get the current orientation of the touch area and tool area in radians clockwise from
 * vertical for the given pointer index.
 * An angle of 0 degrees indicates that the major axis of contact is oriented
 * upwards, is perfectly circular or is of unknown orientation.  A positive angle
 * indicates that the major axis of contact is oriented to the right.  A negative angle
 * indicates that the major axis of contact is oriented to the left.
 * The full range is from -PI/2 radians (finger pointing fully left) to PI/2 radians
 * (finger pointing fully right). */
float AMotionEvent_getOrientation(const AInputEvent* motion_event, size_t pointer_index);

/* Get the number of historical points in this event.  These are movements that
 * have occurred between this event and the previous event.  This only applies
 * to AMOTION_EVENT_ACTION_MOVE events -- all other actions will have a size of 0.
 * Historical samples are indexed from oldest to newest. */
size_t AMotionEvent_getHistorySize(const AInputEvent* motion_event);

/* Get the time that a historical movement occurred between this event and
 * the previous event, in the java.lang.System.nanoTime() time base. */
int64_t AMotionEvent_getHistoricalEventTime(AInputEvent* motion_event,
        size_t history_index);

/* Get the historical raw X coordinate of this event for the given pointer index that
 * occurred between this event and the previous motion event.
 * For touch events on the screen, this is the original location of the event
 * on the screen, before it had been adjusted for the containing window
 * and views.
 * Whole numbers are pixels; the value may have a fraction for input devices
 * that are sub-pixel precise. */
float AMotionEvent_getHistoricalRawX(const AInputEvent* motion_event, size_t pointer_index,
        size_t history_index);

/* Get the historical raw Y coordinate of this event for the given pointer index that
 * occurred between this event and the previous motion event.
 * For touch events on the screen, this is the original location of the event
 * on the screen, before it had been adjusted for the containing window
 * and views.
 * Whole numbers are pixels; the value may have a fraction for input devices
 * that are sub-pixel precise. */
float AMotionEvent_getHistoricalRawY(const AInputEvent* motion_event, size_t pointer_index,
        size_t history_index);

/* Get the historical X coordinate of this event for the given pointer index that
 * occurred between this event and the previous motion event.
 * Whole numbers are pixels; the value may have a fraction for input devices
 * that are sub-pixel precise. */
float AMotionEvent_getHistoricalX(AInputEvent* motion_event, size_t pointer_index,
        size_t history_index);

/* Get the historical Y coordinate of this event for the given pointer index that
 * occurred between this event and the previous motion event.
 * Whole numbers are pixels; the value may have a fraction for input devices
 * that are sub-pixel precise. */
float AMotionEvent_getHistoricalY(AInputEvent* motion_event, size_t pointer_index,
        size_t history_index);

/* Get the historical pressure of this event for the given pointer index that
 * occurred between this event and the previous motion event.
 * The pressure generally ranges from 0 (no pressure at all) to 1 (normal pressure),
 * although values higher than 1 may be generated depending on the calibration of
 * the input device. */
float AMotionEvent_getHistoricalPressure(AInputEvent* motion_event, size_t pointer_index,
        size_t history_index);

/* Get the current scaled value of the approximate size for the given pointer index that
 * occurred between this event and the previous motion event.
 * This represents some approximation of the area of the screen being
 * pressed; the actual value in pixels corresponding to the
 * touch is normalized with the device specific range of values
 * and scaled to a value between 0 and 1.  The value of size can be used to
 * determine fat touch events. */
float AMotionEvent_getHistoricalSize(AInputEvent* motion_event, size_t pointer_index,
        size_t history_index);

/* Get the historical length of the major axis of an ellipse that describes the touch area
 * at the point of contact for the given pointer index that
 * occurred between this event and the previous motion event. */
float AMotionEvent_getHistoricalTouchMajor(const AInputEvent* motion_event, size_t pointer_index,
        size_t history_index);

/* Get the historical length of the minor axis of an ellipse that describes the touch area
 * at the point of contact for the given pointer index that
 * occurred between this event and the previous motion event. */
float AMotionEvent_getHistoricalTouchMinor(const AInputEvent* motion_event, size_t pointer_index,
        size_t history_index);

/* Get the historical length of the major axis of an ellipse that describes the size
 * of the approaching tool for the given pointer index that
 * occurred between this event and the previous motion event.
 * The tool area represents the estimated size of the finger or pen that is
 * touching the device independent of its actual touch area at the point of contact. */
float AMotionEvent_getHistoricalToolMajor(const AInputEvent* motion_event, size_t pointer_index,
        size_t history_index);

/* Get the historical length of the minor axis of an ellipse that describes the size
 * of the approaching tool for the given pointer index that
 * occurred between this event and the previous motion event.
 * The tool area represents the estimated size of the finger or pen that is
 * touching the device independent of its actual touch area at the point of contact. */
float AMotionEvent_getHistoricalToolMinor(const AInputEvent* motion_event, size_t pointer_index,
        size_t history_index);

/* Get the historical orientation of the touch area and tool area in radians clockwise from
 * vertical for the given pointer index that
 * occurred between this event and the previous motion event.
 * An angle of 0 degrees indicates that the major axis of contact is oriented
 * upwards, is perfectly circular or is of unknown orientation.  A positive angle
 * indicates that the major axis of contact is oriented to the right.  A negative angle
 * indicates that the major axis of contact is oriented to the left.
 * The full range is from -PI/2 radians (finger pointing fully left) to PI/2 radians
 * (finger pointing fully right). */
float AMotionEvent_getHistoricalOrientation(const AInputEvent* motion_event, size_t pointer_index,
        size_t history_index);


/*
 * Input queue
 *
 * An input queue is the facility through which you retrieve input
 * events.
 */
struct AInputQueue;
typedef struct AInputQueue AInputQueue;

/*
 * Add this input queue to a looper for processing.  See
 * ALooper_addFd() for information on the ident, callback, and data params.
 */
void AInputQueue_attachLooper(AInputQueue* queue, ALooper* looper,
        int ident, ALooper_callbackFunc callback, void* data);

/*
 * Remove the input queue from the looper it is currently attached to.
 */
void AInputQueue_detachLooper(AInputQueue* queue);

/*
 * Returns true if there are one or more events available in the
 * input queue.  Returns 1 if the queue has events; 0 if
 * it does not have events; and a negative value if there is an error.
 */
int32_t AInputQueue_hasEvents(AInputQueue* queue);

/*
 * Returns the next available event from the queue.  Returns a negative
 * value if no events are available or an error has occurred.
 */
int32_t AInputQueue_getEvent(AInputQueue* queue, AInputEvent** outEvent);

/*
 * Sends the key for standard pre-dispatching -- that is, possibly deliver
 * it to the current IME to be consumed before the app.  Returns 0 if it
 * was not pre-dispatched, meaning you can process it right now.  If non-zero
 * is returned, you must abandon the current event processing and allow the
 * event to appear again in the event queue (if it does not get consumed during
 * pre-dispatching).
 */
int32_t AInputQueue_preDispatchEvent(AInputQueue* queue, AInputEvent* event);

/*
 * Report that dispatching has finished with the given event.
 * This must be called after receiving an event with AInputQueue_get_event().
 */
void AInputQueue_finishEvent(AInputQueue* queue, AInputEvent* event, int handled);
]]

--- android/rect.h
--- ---------------------------------------------------------------------------

ffi.cdef [[
/*
 * Copyright (C) 2010 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

typedef struct ARect {
    int32_t left;
    int32_t top;
    int32_t right;
    int32_t bottom;
} ARect;
]]

--- android/native_window.h
--- ---------------------------------------------------------------------------

ffi.cdef [[
/*
 * Copyright (C) 2010 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/*
 * Pixel formats that a window can use.
 */
enum {
    WINDOW_FORMAT_RGBA_8888          = 1,
    WINDOW_FORMAT_RGBX_8888          = 2,
    WINDOW_FORMAT_RGB_565            = 4,
};

struct ANativeWindow;
typedef struct ANativeWindow ANativeWindow;

typedef struct ANativeWindow_Buffer {
    // The number of pixels that are show horizontally.
    int32_t width;

    // The number of pixels that are shown vertically.
    int32_t height;

    // The number of *pixels* that a line in the buffer takes in
    // memory.  This may be >= width.
    int32_t stride;

    // The format of the buffer.  One of WINDOW_FORMAT_*
    int32_t format;

    // The actual bits.
    void* bits;
    
    // Do not touch.
    uint32_t reserved[6];
} ANativeWindow_Buffer;

/**
 * Acquire a reference on the given ANativeWindow object.  This prevents the object
 * from being deleted until the reference is removed.
 */
void ANativeWindow_acquire(ANativeWindow* window);

/**
 * Remove a reference that was previously acquired with ANativeWindow_acquire().
 */
void ANativeWindow_release(ANativeWindow* window);

/*
 * Return the current width in pixels of the window surface.  Returns a
 * negative value on error.
 */
int32_t ANativeWindow_getWidth(ANativeWindow* window);

/*
 * Return the current height in pixels of the window surface.  Returns a
 * negative value on error.
 */
int32_t ANativeWindow_getHeight(ANativeWindow* window);

/*
 * Return the current pixel format of the window surface.  Returns a
 * negative value on error.
 */
int32_t ANativeWindow_getFormat(ANativeWindow* window);

/*
 * Change the format and size of the window buffers.
 *
 * The width and height control the number of pixels in the buffers, not the
 * dimensions of the window on screen.  If these are different than the
 * window's physical size, then it buffer will be scaled to match that size
 * when compositing it to the screen.
 *
 * For all of these parameters, if 0 is supplied then the window's base
 * value will come back in force.
 */
int32_t ANativeWindow_setBuffersGeometry(ANativeWindow* window, int32_t width, int32_t height, int32_t format);

/**
 * Lock the window's next drawing surface for writing.
 */
int32_t ANativeWindow_lock(ANativeWindow* window, ANativeWindow_Buffer* outBuffer,
        ARect* inOutDirtyBounds);

/**
 * Unlock the window's drawing surface after previously locking it,
 * posting the new buffer to the display.
 */
int32_t ANativeWindow_unlockAndPost(ANativeWindow* window);
]]

--- android/native_activity.h
--- ---------------------------------------------------------------------------

ffi.cdef [[
/*
 * Copyright (C) 2010 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

struct ANativeActivityCallbacks;

/**
 * This structure defines the native side of an android.app.NativeActivity.
 * It is created by the framework, and handed to the application's native
 * code as it is being launched.
 */
typedef struct ANativeActivity {
    /**
     * Pointer to the callback function table of the native application.
     * You can set the functions here to your own callbacks.  The callbacks
     * pointer itself here should not be changed; it is allocated and managed
     * for you by the framework.
     */
    struct ANativeActivityCallbacks* callbacks;

    /**
     * The global handle on the process's Java VM.
     */
    JavaVM* vm;

    /**
     * JNI context for the main thread of the app.  Note that this field
     * can ONLY be used from the main thread of the process; that is, the
     * thread that calls into the ANativeActivityCallbacks.
     */
    JNIEnv* env;

    /**
     * The NativeActivity object handle.
     *
     * IMPORTANT NOTE: This member is mis-named. It should really be named
     * 'activity' instead of 'clazz', since it's a reference to the
     * NativeActivity instance created by the system for you.
     *
     * We unfortunately cannot change this without breaking NDK
     * source-compatibility.
     */
    jobject clazz;

    /**
     * Path to this application's internal data directory.
     */
    const char* internalDataPath;
    
    /**
     * Path to this application's external (removable/mountable) data directory.
     */
    const char* externalDataPath;
    
    /**
     * The platform's SDK version code.
     */
    int32_t sdkVersion;
    
    /**
     * This is the native instance of the application.  It is not used by
     * the framework, but can be set by the application to its own instance
     * state.
     */
    void* instance;

    /**
     * Pointer to the Asset Manager instance for the application.  The application
     * uses this to access binary assets bundled inside its own .apk file.
     */
    AAssetManager* assetManager;
} ANativeActivity;

/**
 * These are the callbacks the framework makes into a native application.
 * All of these callbacks happen on the main thread of the application.
 * By default, all callbacks are NULL; set to a pointer to your own function
 * to have it called.
 */
typedef struct ANativeActivityCallbacks {
    /**
     * NativeActivity has started.  See Java documentation for Activity.onStart()
     * for more information.
     */
    void (*onStart)(ANativeActivity* activity);
    
    /**
     * NativeActivity has resumed.  See Java documentation for Activity.onResume()
     * for more information.
     */
    void (*onResume)(ANativeActivity* activity);
    
    /**
     * Framework is asking NativeActivity to save its current instance state.
     * See Java documentation for Activity.onSaveInstanceState() for more
     * information.  The returned pointer needs to be created with malloc();
     * the framework will call free() on it for you.  You also must fill in
     * outSize with the number of bytes in the allocation.  Note that the
     * saved state will be persisted, so it can not contain any active
     * entities (pointers to memory, file descriptors, etc).
     */
    void* (*onSaveInstanceState)(ANativeActivity* activity, size_t* outSize);
    
    /**
     * NativeActivity has paused.  See Java documentation for Activity.onPause()
     * for more information.
     */
    void (*onPause)(ANativeActivity* activity);
    
    /**
     * NativeActivity has stopped.  See Java documentation for Activity.onStop()
     * for more information.
     */
    void (*onStop)(ANativeActivity* activity);
    
    /**
     * NativeActivity is being destroyed.  See Java documentation for Activity.onDestroy()
     * for more information.
     */
    void (*onDestroy)(ANativeActivity* activity);

    /**
     * Focus has changed in this NativeActivity's window.  This is often used,
     * for example, to pause a game when it loses input focus.
     */
    void (*onWindowFocusChanged)(ANativeActivity* activity, int hasFocus);
    
    /**
     * The drawing window for this native activity has been created.  You
     * can use the given native window object to start drawing.
     */
    void (*onNativeWindowCreated)(ANativeActivity* activity, ANativeWindow* window);

    /**
     * The drawing window for this native activity has been resized.  You should
     * retrieve the new size from the window and ensure that your rendering in
     * it now matches.
     */
    void (*onNativeWindowResized)(ANativeActivity* activity, ANativeWindow* window);

    /**
     * The drawing window for this native activity needs to be redrawn.  To avoid
     * transient artifacts during screen changes (such resizing after rotation),
     * applications should not return from this function until they have finished
     * drawing their window in its current state.
     */
    void (*onNativeWindowRedrawNeeded)(ANativeActivity* activity, ANativeWindow* window);

    /**
     * The drawing window for this native activity is going to be destroyed.
     * You MUST ensure that you do not touch the window object after returning
     * from this function: in the common case of drawing to the window from
     * another thread, that means the implementation of this callback must
     * properly synchronize with the other thread to stop its drawing before
     * returning from here.
     */
    void (*onNativeWindowDestroyed)(ANativeActivity* activity, ANativeWindow* window);
    
    /**
     * The input queue for this native activity's window has been created.
     * You can use the given input queue to start retrieving input events.
     */
    void (*onInputQueueCreated)(ANativeActivity* activity, AInputQueue* queue);
    
    /**
     * The input queue for this native activity's window is being destroyed.
     * You should no longer try to reference this object upon returning from this
     * function.
     */
    void (*onInputQueueDestroyed)(ANativeActivity* activity, AInputQueue* queue);

    /**
     * The rectangle in the window in which content should be placed has changed.
     */
    void (*onContentRectChanged)(ANativeActivity* activity, const ARect* rect);

    /**
     * The current device AConfiguration has changed.  The new configuration can
     * be retrieved from assetManager.
     */
    void (*onConfigurationChanged)(ANativeActivity* activity);

    /**
     * The system is running low on memory.  Use this callback to release
     * resources you do not need, to help the system avoid killing more
     * important processes.
     */
    void (*onLowMemory)(ANativeActivity* activity);
} ANativeActivityCallbacks;

/**
 * This is the function that must be in the native code to instantiate the
 * application's native activity.  It is called with the activity instance (see
 * above); if the code is being instantiated from a previously saved instance,
 * the savedState will be non-NULL and point to the saved data.  You must make
 * any copy of this data you need -- it will be released after you return from
 * this function.
 */
typedef void ANativeActivity_createFunc(ANativeActivity* activity,
        void* savedState, size_t savedStateSize);

/**
 * The name of the function that NativeInstance looks for when launching its
 * native code.  This is the default function that is used, you can specify
 * "android.app.func_name" string meta-data in your manifest to use a different
 * function.
 */
extern ANativeActivity_createFunc ANativeActivity_onCreate;

/**
 * Finish the given activity.  Its finish() method will be called, causing it
 * to be stopped and destroyed.  Note that this method can be called from
 * *any* thread; it will send a message to the main thread of the process
 * where the Java finish call will take place.
 */
void ANativeActivity_finish(ANativeActivity* activity);

/**
 * Change the window format of the given activity.  Calls getWindow().setFormat()
 * of the given activity.  Note that this method can be called from
 * *any* thread; it will send a message to the main thread of the process
 * where the Java finish call will take place.
 */
void ANativeActivity_setWindowFormat(ANativeActivity* activity, int32_t format);

/**
 * Change the window flags of the given activity.  Calls getWindow().setFlags()
 * of the given activity.  Note that this method can be called from
 * *any* thread; it will send a message to the main thread of the process
 * where the Java finish call will take place.  See window.h for flag constants.
 */
void ANativeActivity_setWindowFlags(ANativeActivity* activity,
        uint32_t addFlags, uint32_t removeFlags);

/**
 * Flags for ANativeActivity_showSoftInput; see the Java InputMethodManager
 * API for documentation.
 */
enum {
    ANATIVEACTIVITY_SHOW_SOFT_INPUT_IMPLICIT = 0x0001,
    ANATIVEACTIVITY_SHOW_SOFT_INPUT_FORCED = 0x0002,
};

/**
 * Show the IME while in the given activity.  Calls InputMethodManager.showSoftInput()
 * for the given activity.  Note that this method can be called from
 * *any* thread; it will send a message to the main thread of the process
 * where the Java finish call will take place.
 */
void ANativeActivity_showSoftInput(ANativeActivity* activity, uint32_t flags);

/**
 * Flags for ANativeActivity_hideSoftInput; see the Java InputMethodManager
 * API for documentation.
 */
enum {
    ANATIVEACTIVITY_HIDE_SOFT_INPUT_IMPLICIT_ONLY = 0x0001,
    ANATIVEACTIVITY_HIDE_SOFT_INPUT_NOT_ALWAYS = 0x0002,
};

/**
 * Hide the IME while in the given activity.  Calls InputMethodManager.hideSoftInput()
 * for the given activity.  Note that this method can be called from
 * *any* thread; it will send a message to the main thread of the process
 * where the Java finish call will take place.
 */
void ANativeActivity_hideSoftInput(ANativeActivity* activity, uint32_t flags);
]]

--- android/sensor.h
--- ---------------------------------------------------------------------------

ffi.cdef [[
/*
 * Copyright (C) 2010 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/*
 * Sensor types
 * (keep in sync with hardware/sensor.h)
 */

enum {
    ASENSOR_TYPE_ACCELEROMETER      = 1,
    ASENSOR_TYPE_MAGNETIC_FIELD     = 2,
    ASENSOR_TYPE_GYROSCOPE          = 4,
    ASENSOR_TYPE_LIGHT              = 5,
    ASENSOR_TYPE_PROXIMITY          = 8
};

/*
 * Sensor accuracy measure
 */
enum {
    ASENSOR_STATUS_UNRELIABLE       = 0,
    ASENSOR_STATUS_ACCURACY_LOW     = 1,
    ASENSOR_STATUS_ACCURACY_MEDIUM  = 2,
    ASENSOR_STATUS_ACCURACY_HIGH    = 3
};

/*
 * A few useful constants
 */

/* Earth's gravity in m/s^2 */
//#define ASENSOR_STANDARD_GRAVITY            (9.80665f)
/* Maximum magnetic field on Earth's surface in uT */
//#define ASENSOR_MAGNETIC_FIELD_EARTH_MAX    (60.0f)
/* Minimum magnetic field on Earth's surface in uT*/
//#define ASENSOR_MAGNETIC_FIELD_EARTH_MIN    (30.0f)

/*
 * A sensor event.
 */

/* NOTE: Must match hardware/sensors.h */
typedef struct ASensorVector {
    union {
        float v[3];
        struct {
            float x;
            float y;
            float z;
        };
        struct {
            float azimuth;
            float pitch;
            float roll;
        };
    };
    int8_t status;
    uint8_t reserved[3];
} ASensorVector;

/* NOTE: Must match hardware/sensors.h */
typedef struct ASensorEvent {
    int32_t version; /* sizeof(struct ASensorEvent) */
    int32_t sensor;
    int32_t type;
    int32_t reserved0;
    int64_t timestamp;
    union {
        float           data[16];
        ASensorVector   vector;
        ASensorVector   acceleration;
        ASensorVector   magnetic;
        float           temperature;
        float           distance;
        float           light;
        float           pressure;
    };
    int32_t reserved1[4];
} ASensorEvent;


struct ASensorManager;
typedef struct ASensorManager ASensorManager;

struct ASensorEventQueue;
typedef struct ASensorEventQueue ASensorEventQueue;

struct ASensor;
typedef struct ASensor ASensor;
typedef ASensor const* ASensorRef;
typedef ASensorRef const* ASensorList;

/*****************************************************************************/

/*
 * Get a reference to the sensor manager. ASensorManager is a singleton.
 *
 * Example:
 *
 *     ASensorManager* sensorManager = ASensorManager_getInstance();
 *
 */
ASensorManager* ASensorManager_getInstance();


/*
 * Returns the list of available sensors.
 */
int ASensorManager_getSensorList(ASensorManager* manager, ASensorList* list);

/*
 * Returns the default sensor for the given type, or NULL if no sensor
 * of that type exist.
 */
ASensor const* ASensorManager_getDefaultSensor(ASensorManager* manager, int type);

/*
 * Creates a new sensor event queue and associate it with a looper.
 */
ASensorEventQueue* ASensorManager_createEventQueue(ASensorManager* manager,
        ALooper* looper, int ident, ALooper_callbackFunc callback, void* data);

/*
 * Destroys the event queue and free all resources associated to it.
 */
int ASensorManager_destroyEventQueue(ASensorManager* manager, ASensorEventQueue* queue);


/*****************************************************************************/

/*
 * Enable the selected sensor. Returns a negative error code on failure.
 */
int ASensorEventQueue_enableSensor(ASensorEventQueue* queue, ASensor const* sensor);

/*
 * Disable the selected sensor. Returns a negative error code on failure.
 */
int ASensorEventQueue_disableSensor(ASensorEventQueue* queue, ASensor const* sensor);

/*
 * Sets the delivery rate of events in microseconds for the given sensor.
 * Note that this is a hint only, generally event will arrive at a higher
 * rate. It is an error to set a rate inferior to the value returned by
 * ASensor_getMinDelay().
 * Returns a negative error code on failure.
 */
int ASensorEventQueue_setEventRate(ASensorEventQueue* queue, ASensor const* sensor, int32_t usec);

/*
 * Returns true if there are one or more events available in the
 * sensor queue.  Returns 1 if the queue has events; 0 if
 * it does not have events; and a negative value if there is an error.
 */
int ASensorEventQueue_hasEvents(ASensorEventQueue* queue);

/*
 * Returns the next available events from the queue.  Returns a negative
 * value if no events are available or an error has occurred, otherwise
 * the number of events returned.
 *
 * Examples:
 *   ASensorEvent event;
 *   ssize_t numEvent = ASensorEventQueue_getEvents(queue, &event, 1);
 *
 *   ASensorEvent eventBuffer[8];
 *   ssize_t numEvent = ASensorEventQueue_getEvents(queue, eventBuffer, 8);
 *
 */
ssize_t ASensorEventQueue_getEvents(ASensorEventQueue* queue,
                ASensorEvent* events, size_t count);


/*****************************************************************************/

/*
 * Returns this sensor's name (non localized)
 */
const char* ASensor_getName(ASensor const* sensor);

/*
 * Returns this sensor's vendor's name (non localized)
 */
const char* ASensor_getVendor(ASensor const* sensor);

/*
 * Return this sensor's type
 */
int ASensor_getType(ASensor const* sensor);

/*
 * Returns this sensors's resolution
 */
float ASensor_getResolution(ASensor const* sensor);

/*
 * Returns the minimum delay allowed between events in microseconds.
 * A value of zero means that this sensor doesn't report events at a
 * constant rate, but rather only when a new data is available.
 */
int ASensor_getMinDelay(ASensor const* sensor);
]]

--- android/window.h
--- ---------------------------------------------------------------------------

ffi.cdef [[
/*
 * Copyright (C) 2010 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/**
 * Window flags, as per the Java API at android.view.WindowManager.LayoutParams.
 */
enum {
    AWINDOW_FLAG_ALLOW_LOCK_WHILE_SCREEN_ON = 0x00000001,
    AWINDOW_FLAG_DIM_BEHIND                 = 0x00000002,
    AWINDOW_FLAG_BLUR_BEHIND                = 0x00000004,
    AWINDOW_FLAG_NOT_FOCUSABLE              = 0x00000008,
    AWINDOW_FLAG_NOT_TOUCHABLE              = 0x00000010,
    AWINDOW_FLAG_NOT_TOUCH_MODAL            = 0x00000020,
    AWINDOW_FLAG_TOUCHABLE_WHEN_WAKING      = 0x00000040,
    AWINDOW_FLAG_KEEP_SCREEN_ON             = 0x00000080,
    AWINDOW_FLAG_LAYOUT_IN_SCREEN           = 0x00000100,
    AWINDOW_FLAG_LAYOUT_NO_LIMITS           = 0x00000200,
    AWINDOW_FLAG_FULLSCREEN                 = 0x00000400,
    AWINDOW_FLAG_FORCE_NOT_FULLSCREEN       = 0x00000800,
    AWINDOW_FLAG_DITHER                     = 0x00001000,
    AWINDOW_FLAG_SECURE                     = 0x00002000,
    AWINDOW_FLAG_SCALED                     = 0x00004000,
    AWINDOW_FLAG_IGNORE_CHEEK_PRESSES       = 0x00008000,
    AWINDOW_FLAG_LAYOUT_INSET_DECOR         = 0x00010000,
    AWINDOW_FLAG_ALT_FOCUSABLE_IM           = 0x00020000,
    AWINDOW_FLAG_WATCH_OUTSIDE_TOUCH        = 0x00040000,
    AWINDOW_FLAG_SHOW_WHEN_LOCKED           = 0x00080000,
    AWINDOW_FLAG_SHOW_WALLPAPER             = 0x00100000,
    AWINDOW_FLAG_TURN_SCREEN_ON             = 0x00200000,
    AWINDOW_FLAG_DISMISS_KEYGUARD           = 0x00400000,
};
]]

--- android/configuration.h
--- ---------------------------------------------------------------------------

ffi.cdef [[
/*
 * Copyright (C) 2010 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

struct AConfiguration;
typedef struct AConfiguration AConfiguration;

enum {
    ACONFIGURATION_ORIENTATION_ANY  = 0x0000,
    ACONFIGURATION_ORIENTATION_PORT = 0x0001,
    ACONFIGURATION_ORIENTATION_LAND = 0x0002,
    ACONFIGURATION_ORIENTATION_SQUARE = 0x0003,

    ACONFIGURATION_TOUCHSCREEN_ANY  = 0x0000,
    ACONFIGURATION_TOUCHSCREEN_NOTOUCH  = 0x0001,
    ACONFIGURATION_TOUCHSCREEN_STYLUS  = 0x0002,
    ACONFIGURATION_TOUCHSCREEN_FINGER  = 0x0003,

    ACONFIGURATION_DENSITY_DEFAULT = 0,
    ACONFIGURATION_DENSITY_LOW = 120,
    ACONFIGURATION_DENSITY_MEDIUM = 160,
    ACONFIGURATION_DENSITY_HIGH = 240,
    ACONFIGURATION_DENSITY_NONE = 0xffff,

    ACONFIGURATION_KEYBOARD_ANY  = 0x0000,
    ACONFIGURATION_KEYBOARD_NOKEYS  = 0x0001,
    ACONFIGURATION_KEYBOARD_QWERTY  = 0x0002,
    ACONFIGURATION_KEYBOARD_12KEY  = 0x0003,

    ACONFIGURATION_NAVIGATION_ANY  = 0x0000,
    ACONFIGURATION_NAVIGATION_NONAV  = 0x0001,
    ACONFIGURATION_NAVIGATION_DPAD  = 0x0002,
    ACONFIGURATION_NAVIGATION_TRACKBALL  = 0x0003,
    ACONFIGURATION_NAVIGATION_WHEEL  = 0x0004,

    ACONFIGURATION_KEYSHIDDEN_ANY = 0x0000,
    ACONFIGURATION_KEYSHIDDEN_NO = 0x0001,
    ACONFIGURATION_KEYSHIDDEN_YES = 0x0002,
    ACONFIGURATION_KEYSHIDDEN_SOFT = 0x0003,

    ACONFIGURATION_NAVHIDDEN_ANY = 0x0000,
    ACONFIGURATION_NAVHIDDEN_NO = 0x0001,
    ACONFIGURATION_NAVHIDDEN_YES = 0x0002,

    ACONFIGURATION_SCREENSIZE_ANY  = 0x00,
    ACONFIGURATION_SCREENSIZE_SMALL = 0x01,
    ACONFIGURATION_SCREENSIZE_NORMAL = 0x02,
    ACONFIGURATION_SCREENSIZE_LARGE = 0x03,
    ACONFIGURATION_SCREENSIZE_XLARGE = 0x04,

    ACONFIGURATION_SCREENLONG_ANY = 0x00,
    ACONFIGURATION_SCREENLONG_NO = 0x1,
    ACONFIGURATION_SCREENLONG_YES = 0x2,

    ACONFIGURATION_UI_MODE_TYPE_ANY = 0x00,
    ACONFIGURATION_UI_MODE_TYPE_NORMAL = 0x01,
    ACONFIGURATION_UI_MODE_TYPE_DESK = 0x02,
    ACONFIGURATION_UI_MODE_TYPE_CAR = 0x03,

    ACONFIGURATION_UI_MODE_NIGHT_ANY = 0x00,
    ACONFIGURATION_UI_MODE_NIGHT_NO = 0x1,
    ACONFIGURATION_UI_MODE_NIGHT_YES = 0x2,

    ACONFIGURATION_MCC = 0x0001,
    ACONFIGURATION_MNC = 0x0002,
    ACONFIGURATION_LOCALE = 0x0004,
    ACONFIGURATION_TOUCHSCREEN = 0x0008,
    ACONFIGURATION_KEYBOARD = 0x0010,
    ACONFIGURATION_KEYBOARD_HIDDEN = 0x0020,
    ACONFIGURATION_NAVIGATION = 0x0040,
    ACONFIGURATION_ORIENTATION = 0x0080,
    ACONFIGURATION_DENSITY = 0x0100,
    ACONFIGURATION_SCREEN_SIZE = 0x0200,
    ACONFIGURATION_VERSION = 0x0400,
    ACONFIGURATION_SCREEN_LAYOUT = 0x0800,
    ACONFIGURATION_UI_MODE = 0x1000,
};

/**
 * Create a new AConfiguration, initialized with no values set.
 */
AConfiguration* AConfiguration_new();

/**
 * Free an AConfiguration that was previously created with
 * AConfiguration_new().
 */
void AConfiguration_delete(AConfiguration* config);

/**
 * Create and return a new AConfiguration based on the current configuration in
 * use in the given AssetManager.
 */
void AConfiguration_fromAssetManager(AConfiguration* out, AAssetManager* am);

/**
 * Copy the contents of 'src' to 'dest'.
 */
void AConfiguration_copy(AConfiguration* dest, AConfiguration* src);

/**
 * Return the current MCC set in the configuration.  0 if not set.
 */
int32_t AConfiguration_getMcc(AConfiguration* config);

/**
 * Set the current MCC in the configuration.  0 to clear.
 */
void AConfiguration_setMcc(AConfiguration* config, int32_t mcc);

/**
 * Return the current MNC set in the configuration.  0 if not set.
 */
int32_t AConfiguration_getMnc(AConfiguration* config);

/**
 * Set the current MNC in the configuration.  0 to clear.
 */
void AConfiguration_setMnc(AConfiguration* config, int32_t mnc);

/**
 * Return the current language code set in the configuration.  The output will
 * be filled with an array of two characters.  They are not 0-terminated.  If
 * a language is not set, they will be 0.
 */
void AConfiguration_getLanguage(AConfiguration* config, char* outLanguage);

/**
 * Set the current language code in the configuration, from the first two
 * characters in the string.
 */
void AConfiguration_setLanguage(AConfiguration* config, const char* language);

/**
 * Return the current country code set in the configuration.  The output will
 * be filled with an array of two characters.  They are not 0-terminated.  If
 * a country is not set, they will be 0.
 */
void AConfiguration_getCountry(AConfiguration* config, char* outCountry);

/**
 * Set the current country code in the configuration, from the first two
 * characters in the string.
 */
void AConfiguration_setCountry(AConfiguration* config, const char* country);

/**
 * Return the current ACONFIGURATION_ORIENTATION_* set in the configuration.
 */
int32_t AConfiguration_getOrientation(AConfiguration* config);

/**
 * Set the current orientation in the configuration.
 */
void AConfiguration_setOrientation(AConfiguration* config, int32_t orientation);

/**
 * Return the current ACONFIGURATION_TOUCHSCREEN_* set in the configuration.
 */
int32_t AConfiguration_getTouchscreen(AConfiguration* config);

/**
 * Set the current touchscreen in the configuration.
 */
void AConfiguration_setTouchscreen(AConfiguration* config, int32_t touchscreen);

/**
 * Return the current ACONFIGURATION_DENSITY_* set in the configuration.
 */
int32_t AConfiguration_getDensity(AConfiguration* config);

/**
 * Set the current density in the configuration.
 */
void AConfiguration_setDensity(AConfiguration* config, int32_t density);

/**
 * Return the current ACONFIGURATION_KEYBOARD_* set in the configuration.
 */
int32_t AConfiguration_getKeyboard(AConfiguration* config);

/**
 * Set the current keyboard in the configuration.
 */
void AConfiguration_setKeyboard(AConfiguration* config, int32_t keyboard);

/**
 * Return the current ACONFIGURATION_NAVIGATION_* set in the configuration.
 */
int32_t AConfiguration_getNavigation(AConfiguration* config);

/**
 * Set the current navigation in the configuration.
 */
void AConfiguration_setNavigation(AConfiguration* config, int32_t navigation);

/**
 * Return the current ACONFIGURATION_KEYSHIDDEN_* set in the configuration.
 */
int32_t AConfiguration_getKeysHidden(AConfiguration* config);

/**
 * Set the current keys hidden in the configuration.
 */
void AConfiguration_setKeysHidden(AConfiguration* config, int32_t keysHidden);

/**
 * Return the current ACONFIGURATION_NAVHIDDEN_* set in the configuration.
 */
int32_t AConfiguration_getNavHidden(AConfiguration* config);

/**
 * Set the current nav hidden in the configuration.
 */
void AConfiguration_setNavHidden(AConfiguration* config, int32_t navHidden);

/**
 * Return the current SDK (API) version set in the configuration.
 */
int32_t AConfiguration_getSdkVersion(AConfiguration* config);

/**
 * Set the current SDK version in the configuration.
 */
void AConfiguration_setSdkVersion(AConfiguration* config, int32_t sdkVersion);

/**
 * Return the current ACONFIGURATION_SCREENSIZE_* set in the configuration.
 */
int32_t AConfiguration_getScreenSize(AConfiguration* config);

/**
 * Set the current screen size in the configuration.
 */
void AConfiguration_setScreenSize(AConfiguration* config, int32_t screenSize);

/**
 * Return the current ACONFIGURATION_SCREENLONG_* set in the configuration.
 */
int32_t AConfiguration_getScreenLong(AConfiguration* config);

/**
 * Set the current screen long in the configuration.
 */
void AConfiguration_setScreenLong(AConfiguration* config, int32_t screenLong);

/**
 * Return the current ACONFIGURATION_UI_MODE_TYPE_* set in the configuration.
 */
int32_t AConfiguration_getUiModeType(AConfiguration* config);

/**
 * Set the current UI mode type in the configuration.
 */
void AConfiguration_setUiModeType(AConfiguration* config, int32_t uiModeType);

/**
 * Return the current ACONFIGURATION_UI_MODE_NIGHT_* set in the configuration.
 */
int32_t AConfiguration_getUiModeNight(AConfiguration* config);

/**
 * Set the current UI mode night in the configuration.
 */
void AConfiguration_setUiModeNight(AConfiguration* config, int32_t uiModeNight);

/**
 * Perform a diff between two configurations.  Returns a bit mask of
 * ACONFIGURATION_* constants, each bit set meaning that configuration element
 * is different between them.
 */
int32_t AConfiguration_diff(AConfiguration* config1, AConfiguration* config2);

/**
 * Determine whether 'base' is a valid configuration for use within the
 * environment 'requested'.  Returns 0 if there are any values in 'base'
 * that conflict with 'requested'.  Returns 1 if it does not conflict.
 */
int32_t AConfiguration_match(AConfiguration* base, AConfiguration* requested);

/**
 * Determine whether the configuration in 'test' is better than the existing
 * configuration in 'base'.  If 'requested' is non-NULL, this decision is based
 * on the overall configuration given there.  If it is NULL, this decision is
 * simply based on which configuration is more specific.  Returns non-0 if
 * 'test' is better than 'base'.
 *
 * This assumes you have already filtered the configurations with
 * AConfiguration_match().
 */
int32_t AConfiguration_isBetterThan(AConfiguration* base, AConfiguration* test,
        AConfiguration* requested);
]]

--- android/storage_manager.h
--- ---------------------------------------------------------------------------

ffi.cdef [[
/*
 * Copyright (C) 2010 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

struct AStorageManager;
typedef struct AStorageManager AStorageManager;

enum {
    /*
     * The OBB container is now mounted and ready for use. Can be returned
     * as the status for callbacks made during asynchronous OBB actions.
     */
    AOBB_STATE_MOUNTED = 1,

    /*
     * The OBB container is now unmounted and not usable. Can be returned
     * as the status for callbacks made during asynchronous OBB actions.
     */
    AOBB_STATE_UNMOUNTED = 2,

    /*
     * There was an internal system error encountered while trying to
     * mount the OBB. Can be returned as the status for callbacks made
     * during asynchronous OBB actions.
     */
    AOBB_STATE_ERROR_INTERNAL = 20,

    /*
     * The OBB could not be mounted by the system. Can be returned as the
     * status for callbacks made during asynchronous OBB actions.
     */
    AOBB_STATE_ERROR_COULD_NOT_MOUNT = 21,

    /*
     * The OBB could not be unmounted. This most likely indicates that a
     * file is in use on the OBB. Can be returned as the status for
     * callbacks made during asynchronous OBB actions.
     */
    AOBB_STATE_ERROR_COULD_NOT_UNMOUNT = 22,

    /*
     * A call was made to unmount the OBB when it was not mounted. Can be
     * returned as the status for callbacks made during asynchronous OBB
     * actions.
     */
    AOBB_STATE_ERROR_NOT_MOUNTED = 23,

    /*
     * The OBB has already been mounted. Can be returned as the status for
     * callbacks made during asynchronous OBB actions.
     */
    AOBB_STATE_ERROR_ALREADY_MOUNTED = 24,

    /*
     * The current application does not have permission to use this OBB.
     * This could be because the OBB indicates it's owned by a different
     * package. Can be returned as the status for callbacks made during
     * asynchronous OBB actions.
     */
    AOBB_STATE_ERROR_PERMISSION_DENIED = 25,
};

/**
 * Obtains a new instance of AStorageManager.
 */
AStorageManager* AStorageManager_new();

/**
 * Release AStorageManager instance.
 */
void AStorageManager_delete(AStorageManager* mgr);

/**
 * Callback function for asynchronous calls made on OBB files.
 */
typedef void (*AStorageManager_obbCallbackFunc)(const char* filename, const int32_t state, void* data);

/**
 * Attempts to mount an OBB file. This is an asynchronous operation.
 */
void AStorageManager_mountObb(AStorageManager* mgr, const char* filename, const char* key,
        AStorageManager_obbCallbackFunc cb, void* data);

/**
 * Attempts to unmount an OBB file. This is an asynchronous operation.
 */
void AStorageManager_unmountObb(AStorageManager* mgr, const char* filename, const int force,
        AStorageManager_obbCallbackFunc cb, void* data);

/**
 * Check whether an OBB is mounted.
 */
int AStorageManager_isObbMounted(AStorageManager* mgr, const char* filename);

/**
 * Get the mounted path for an OBB.
 */
const char* AStorageManager_getMountedObbPath(AStorageManager* mgr, const char* filename);
]]

--- android/obb.h
--- ---------------------------------------------------------------------------

ffi.cdef [[
/*
 * Copyright (C) 2010 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

struct AObbInfo;
typedef struct AObbInfo AObbInfo;

enum {
    AOBBINFO_OVERLAY = 0x0001,
};

/**
 * Scan an OBB and get information about it.
 */
AObbInfo* AObbScanner_getObbInfo(const char* filename);

/**
 * Destroy the AObbInfo object. You must call this when finished with the object.
 */
void AObbInfo_delete(AObbInfo* obbInfo);

/**
 * Get the package name for the OBB.
 */
const char* AObbInfo_getPackageName(AObbInfo* obbInfo);

/**
 * Get the version of an OBB file.
 */
int32_t AObbInfo_getVersion(AObbInfo* obbInfo);

/**
 * Get the flags of an OBB file.
 */
int32_t AObbInfo_getFlags(AObbInfo* obbInfo);
]]

return android
