--- bindings.pthread
--- ================
---
--- FFI bindings to pthread.

local ffi = require 'ffi'
local system = require 'system'

local pthread = ffi.C

---- android ------------------------------------------------------------------

if system.platform == 'android' then

  ffi.cdef [[
    typedef struct
    {
        uint32_t flags;
        void * stack_base;
        size_t stack_size;
        size_t guard_size;
        int32_t sched_policy;
        int32_t sched_priority;
    } pthread_attr_t;
    typedef struct
    {
        int volatile value;
    } pthread_cond_t;
    typedef long pthread_condattr_t;
    typedef int pthread_key_t;
    typedef struct
    {
        int volatile value;
    } pthread_mutex_t;
    typedef long pthread_mutexattr_t;
    typedef volatile int  pthread_once_t;
    typedef struct {
        pthread_mutex_t  lock;
        pthread_cond_t   cond;
        int              numLocks;
        int              writerThreadId;
        int              pendingReaders;
        int              pendingWriters;
        void*            reserved[4];  /* for future extensibility */
    } pthread_rwlock_t;
    typedef int pthread_rwlockattr_t;
    typedef long pthread_t;
  ]]

---- linux --------------------------------------------------------------------
elseif system.platform == 'linux' then

  if ffi.sizeof('void*') == 8 then
    ffi.cdef [[
      static const int __SIZEOF_PTHREAD_ATTR_T = 56;
      static const int __SIZEOF_PTHREAD_MUTEX_T = 40;
      static const int __SIZEOF_PTHREAD_MUTEXATTR_T = 4;
      static const int __SIZEOF_PTHREAD_COND_T = 48;
      static const int __SIZEOF_PTHREAD_CONDATTR_T = 4;
      static const int __SIZEOF_PTHREAD_RWLOCK_T = 56;
      static const int __SIZEOF_PTHREAD_RWLOCKATTR_T = 8;
      static const int __SIZEOF_PTHREAD_BARRIER_T = 32;
      static const int __SIZEOF_PTHREAD_BARRIERATTR_T = 4;
    ]]
  elseif ffi.sizeof('void*') == 4 then
    ffi.cdef [[
      static const int __SIZEOF_PTHREAD_ATTR_T = 36;
      static const int __SIZEOF_PTHREAD_MUTEX_T = 24;
      static const int __SIZEOF_PTHREAD_MUTEXATTR_T = 4;
      static const int __SIZEOF_PTHREAD_COND_T = 48;
      static const int __SIZEOF_PTHREAD_CONDATTR_T = 4;
      static const int __SIZEOF_PTHREAD_RWLOCK_T = 32;
      static const int __SIZEOF_PTHREAD_RWLOCKATTR_T = 8;
      static const int __SIZEOF_PTHREAD_BARRIER_T = 20;
      static const int __SIZEOF_PTHREAD_BARRIERATTR_T = 4;
    ]]
  else
    error('unsupported word size')
  end
  
  ffi.cdef [[
    typedef struct { char __size[__SIZEOF_PTHREAD_ATTR_T]; }       pthread_attr_t;
    typedef struct { char __size[__SIZEOF_PTHREAD_COND_T]; }       pthread_cond_t;
    typedef struct { char __size[__SIZEOF_PTHREAD_CONDATTR_T]; }   pthread_condattr_t;
    typedef unsigned int pthread_key_t;
    typedef struct { char __size[__SIZEOF_PTHREAD_MUTEX_T]; }      pthread_mutex_t;
    typedef struct { char __size[__SIZEOF_PTHREAD_MUTEXATTR_T]; }  pthread_mutexattr_t;
    typedef int pthread_once_t;
    typedef struct { char __size[__SIZEOF_PTHREAD_RWLOCK_T]; }     pthread_rwlock_t;
    typedef struct { char __size[__SIZEOF_PTHREAD_RWLOCKATTR_T]; } pthread_rwlockattr_t;
    typedef unsigned long int pthread_t;
  ]]

---- common -------------------------------------------------------------------
else
  error('unsupported platform')
end

ffi.cdef [[
static const int PTHREAD_INHERIT_SCHED = 0;
static const int PTHREAD_EXPLICIT_SCHED = 1;

static const int PTHREAD_PROCESS_PRIVATE = 0;
static const int PTHREAD_PROCESS_SHARED = 1;

static const int PTHREAD_CREATE_JOINABLE = 0;
static const int PTHREAD_CREATE_DETACHED = 1;

static const int PTHREAD_CANCEL_ENABLE = 0;
static const int PTHREAD_CANCEL_DISABLE = 1;

static const int PTHREAD_CANCEL_DEFERRED = 0;
static const int PTHREAD_CANCEL_ASYNCHRONOUS = 1;

static const int PTHREAD_CANCELED = -1;

static const int PTHREAD_ONCE_INIT = 0;

int   pthread_atfork(void (*)(void), void (*)(void), void(*)(void));
int   pthread_attr_destroy(pthread_attr_t *);
int   pthread_attr_getdetachstate(const pthread_attr_t *, int *);
int   pthread_attr_getschedparam(const pthread_attr_t *restrict,
          struct sched_param *restrict);
int   pthread_attr_init(pthread_attr_t *);
int   pthread_attr_setdetachstate(pthread_attr_t *, int);
int   pthread_attr_setschedparam(pthread_attr_t *restrict,
          const struct sched_param *restrict);
int   pthread_cancel(pthread_t);
void  pthread_cleanup_push(void (*)(void *), void *);
void  pthread_cleanup_pop(int);
int   pthread_cond_broadcast(pthread_cond_t *);
int   pthread_cond_destroy(pthread_cond_t *);
int   pthread_cond_init(pthread_cond_t *restrict,
          const pthread_condattr_t *restrict);
int   pthread_cond_signal(pthread_cond_t *);
int   pthread_cond_timedwait(pthread_cond_t *restrict,
          pthread_mutex_t *restrict, const struct timespec *restrict);
int   pthread_cond_wait(pthread_cond_t *restrict,
          pthread_mutex_t *restrict);
int   pthread_condattr_destroy(pthread_condattr_t *);
int   pthread_condattr_init(pthread_condattr_t *);
int   pthread_create(pthread_t *restrict, const pthread_attr_t *restrict,
          void *(*)(void *), void *restrict);
int   pthread_detach(pthread_t);
int   pthread_equal(pthread_t, pthread_t);
void  pthread_exit(void *);
void *pthread_getspecific(pthread_key_t);
int   pthread_join(pthread_t, void **);
int   pthread_key_create(pthread_key_t *, void (*)(void *));
int   pthread_key_delete(pthread_key_t);
int   pthread_mutex_destroy(pthread_mutex_t *);
int   pthread_mutex_init(pthread_mutex_t *restrict,
          const pthread_mutexattr_t *restrict);
int   pthread_mutex_lock(pthread_mutex_t *);
int   pthread_mutex_trylock(pthread_mutex_t *);
int   pthread_mutex_unlock(pthread_mutex_t *);
int   pthread_mutexattr_destroy(pthread_mutexattr_t *);
int   pthread_once(pthread_once_t *, void (*)(void));
int   pthread_rwlock_destroy(pthread_rwlock_t *);
int   pthread_rwlock_init(pthread_rwlock_t *restrict,
          const pthread_rwlockattr_t *restrict);
int   pthread_rwlock_rdlock(pthread_rwlock_t *);
int   pthread_rwlock_tryrdlock(pthread_rwlock_t *);
int   pthread_rwlock_trywrlock(pthread_rwlock_t *);
int   pthread_rwlock_unlock(pthread_rwlock_t *);
int   pthread_rwlock_wrlock(pthread_rwlock_t *);
int   pthread_rwlockattr_destroy(pthread_rwlockattr_t *);
int   pthread_rwlockattr_init(pthread_rwlockattr_t *);
pthread_t
      pthread_self(void);
int   pthread_setcancelstate(int, int *);
int   pthread_setcanceltype(int, int *);
int   pthread_setspecific(pthread_key_t, const void *);
void  pthread_testcancel(void);
]]


return pthread
