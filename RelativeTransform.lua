--- RelativeTransform
--- =================
---
--- Implements a read-only but otherwise Transform-compatible interface,
--- actually representing the composition of two Transforms.

local class = require 'class'
local Event = require 'Event'
local Transform = require 'Transform'

local RelativeTransform = class('RelativeTransform')

function RelativeTransform:_init(parent_transform, local_transform)
  self.changed = Event()

  -- making this method a closure lets us use it as an event handler
  -- TODO: this should unsubscribe from parents
  function self._invalidate()
    self._position = false
    self._orientation = false
    self.changed(self)
  end

  self._parent_transform = false
  self._local_transform = false

  self.parent_transform = parent_transform or Transform()
  self.local_transform = local_transform or Transform()

  self.changed(self)
end

-- relative_transform.parent_transform
function RelativeTransform:get_parent_transform()
  return self._parent_transform
end
function RelativeTransform:set_parent_transform(parent_transform)
  if self._parent_transform ~= parent_transform then
    if self._parent_transform then
      self._parent_transform.changed:remove_handler(self._invalidate)
    end
    self._parent_transform = parent_transform;
    if self._parent_transform then
      self._parent_transform.changed:add_handler(self._invalidate)
    end
    self:_invalidate()
  end
end

-- relative_transform.local_transform
function RelativeTransform:get_local_transform()
  return self._local_transform
end
function RelativeTransform:set_local_transform(local_transform)
  if self._local_transform ~= local_transform then
    if self._local_transform then
      self._local_transform.changed:remove_handler(self._invalidate)
    end
    self._local_transform = local_transform;
    if self._local_transform then
      self._local_transform.changed:add_handler(self._invalidate)
    end
    self:_invalidate()
  end
end

-- relative_transform.position (read only, computed lazily)
function RelativeTransform:get_position()
  if not self._position then
    self._position = self._parent_transform.position +
      self._parent_transform.orientation:rotate_vector(
        self.local_transform.position)
  end
  return self._position
end

function RelativeTransform:set_position()
  error('position is read-only on RelativeTransform')
end

-- relative_transform.orientation (read only, computed lazily)
function RelativeTransform:get_orientation()
  if not self._orientation then
    self._orientation =
      self.parent_transform.orientation * self.local_transform.orientation
  end
  return self._orientation
end

function RelativeTransform:set_orientation()
  error('orientation is read-only on RelativeTransform')
end

-- TODO remove all this copy-paste
function RelativeTransform:transform_point(point)
  return self.orientation:rotate_vector(point) + self.position
end

function RelativeTransform:inverse_transform_point(point)
  return self.orientation:conjugate():rotate_vector(point - self.position)
end

function RelativeTransform:transform_direction(direction)
  return self.orientation:rotate_vector(direction)
end

function RelativeTransform:inverse_transform_direction(direction)
  return self.orientation:conjugate():rotate_vector(direction)
end

return RelativeTransform
