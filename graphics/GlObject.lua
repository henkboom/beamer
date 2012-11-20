--- graphics.GlObject
--- =================
---
--- Generic object creation/deletion.

local class = require 'class'
local ffi = require 'ffi'
local gl = require 'gl'

local gl_name = ffi.typeof('struct { GLuint name; }')

local GlObject = class('GlObject')

local _object = {'object'}
local _delete = {'delete'}
local _bind = {'bind'}
local _target = {'target'}

--- ### `GlObject(gen, delete, bind, target)`
--- Creates a new GlObject object with its own OpenGL handle, using the given
--- generation, deletion, and bind functions.
---
--- Generally this object shouldn't be created directly, but through one of the
--- specific subclasses.
---
--- The handle will be released when this object is garbage collected, but
--- `GlObject:delete()` can be called to delete it immediately.
function GlObject:_init(gen, delete, bind, target)
  assert(type(gen) == 'function', 'invalid gen function for GlObject')
  assert(type(delete) == 'function', 'invalid delete function for GlObject')
  assert(type(bind) == 'function', 'invalid bind function for GlObject')
  assert(type(target) == 'number', 'invalid target for GlObject')

  self[_object] = gl_name()

  self[_delete] = delete
  self[_bind] = bind
  self[_target] = target

  local name = ffi.new('GLuint[1]')
  gen(1, name)
  self[_object].name = name[0]
  ffi.gc(self[_object], function () self:delete() end)
end

--- ### `GlObject:delete()`
--- Releases the GlObject's resources immediately. This object shouldn't be
--- used after this call.
---
--- Calling this method is optional, but will release graphics resources
--- sooner.
function GlObject:delete()
  if self[_object] then
    local name = ffi.new('GLuint[1]')
    name[0] = self[_object].name
    self[_delete](1, name)
    self[_object] = false
  end
end

--- ### `gl_object.name`
--- The native OpenGL handle, or `false` if this object has been deleted.
function GlObject:get_name()
  return self[_object] and self[_object].name
end

--- ### `gl_object.target`
--- The target given to GlObject().
function GlObject:get_target()
  return self[_target]
end

--- ### `gl_object:bind()`
--- Binds this object on its target.
function GlObject:bind()
  assert(self[_object], 'gl_object:bind() called on a deleted object')
  self[_bind](self.target, self.name)
end

--- ### `gl_object:unbind()`
--- Unbinds any bound objects from this object's target.
function GlObject:unbind()
  self[_bind](self.target, 0)
end

return GlObject
