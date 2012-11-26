--- bindings.luajit
--- ===============
---
--- FFI bindings to the LuaJIT API.

local ffi = require 'ffi'

-- the lua api is already loaded
local lua = ffi.C

--- luaconf.h
--- ---------------------------------------------------------------------------

-- this is mostly preprocessor, so let's just put in the important things
ffi.cdef [[
typedef double LUA_NUMBER;
typedef ptrdiff_t LUA_INTEGER;
static const int LUA_IDSIZE = 60;
]]

--- lua.h
--- ---------------------------------------------------------------------------

ffi.cdef [[
/*
** $Id: lua.h,v 1.218.1.5 2008/08/06 13:30:12 roberto Exp $
** Lua - An Extensible Extension Language
** Lua.org, PUC-Rio, Brazil (http://www.lua.org)
** See Copyright Notice at the end of this file
*/


//#ifndef lua_h
//#define lua_h

//#include <stdarg.h>
//#include <stddef.h>


//#include "luaconf.h"


//#define LUA_VERSION	"Lua 5.1"
//#define LUA_RELEASE	"Lua 5.1.4"
static const int LUA_VERSION_NUM	= 501;
//#define LUA_COPYRIGHT	"Copyright (C) 1994-2008 Lua.org, PUC-Rio"
//#define LUA_AUTHORS	"R. Ierusalimschy, L. H. de Figueiredo & W. Celes"


/* mark for precompiled code (`<esc>Lua') */
//#define	LUA_SIGNATURE	"\033Lua"

/* option for multiple returns in `lua_pcall' and `lua_call' */
static const int LUA_MULTRET	= (-1);


/*
** pseudo-indices
*/
static const int LUA_REGISTRYINDEX	= (-10000);
static const int LUA_ENVIRONINDEX	= (-10001);
static const int LUA_GLOBALSINDEX	= (-10002);
//#define lua_upvalueindex(i)	(LUA_GLOBALSINDEX-(i))


/* thread status; 0 is OK */
static const int LUA_YIELD	= 1;
static const int LUA_ERRRUN	= 2;
static const int LUA_ERRSYNTAX	= 3;
static const int LUA_ERRMEM	= 4;
static const int LUA_ERRERR	= 5;


typedef struct lua_State lua_State;

typedef int (*lua_CFunction) (lua_State *L);


/*
** functions that read/write blocks when loading/dumping Lua chunks
*/
typedef const char * (*lua_Reader) (lua_State *L, void *ud, size_t *sz);

typedef int (*lua_Writer) (lua_State *L, const void* p, size_t sz, void* ud);


/*
** prototype for memory-allocation functions
*/
typedef void * (*lua_Alloc) (void *ud, void *ptr, size_t osize, size_t nsize);


/*
** basic types
*/
static const int LUA_TNONE		= (-1);

static const int LUA_TNIL		= 0;
static const int LUA_TBOOLEAN		= 1;
static const int LUA_TLIGHTUSERDATA	= 2;
static const int LUA_TNUMBER		= 3;
static const int LUA_TSTRING		= 4;
static const int LUA_TTABLE		= 5;
static const int LUA_TFUNCTION		= 6;
static const int LUA_TUSERDATA		= 7;
static const int LUA_TTHREAD		= 8;



/* minimum Lua stack available to a C function */
static const int LUA_MINSTACK	= 20;


/*
** generic extra include file
*/
//#if defined(LUA_USER_H)
//#include LUA_USER_H
//#endif


/* type of numbers in Lua */
typedef LUA_NUMBER lua_Number;


/* type for integer functions */
typedef LUA_INTEGER lua_Integer;



/*
** state manipulation
*/
lua_State *(lua_newstate) (lua_Alloc f, void *ud);
void       (lua_close) (lua_State *L);
lua_State *(lua_newthread) (lua_State *L);

lua_CFunction (lua_atpanic) (lua_State *L, lua_CFunction panicf);


/*
** basic stack manipulation
*/
int   (lua_gettop) (lua_State *L);
void  (lua_settop) (lua_State *L, int idx);
void  (lua_pushvalue) (lua_State *L, int idx);
void  (lua_remove) (lua_State *L, int idx);
void  (lua_insert) (lua_State *L, int idx);
void  (lua_replace) (lua_State *L, int idx);
int   (lua_checkstack) (lua_State *L, int sz);

void  (lua_xmove) (lua_State *from, lua_State *to, int n);


/*
** access functions (stack -> C)
*/

int             (lua_isnumber) (lua_State *L, int idx);
int             (lua_isstring) (lua_State *L, int idx);
int             (lua_iscfunction) (lua_State *L, int idx);
int             (lua_isuserdata) (lua_State *L, int idx);
int             (lua_type) (lua_State *L, int idx);
const char     *(lua_typename) (lua_State *L, int tp);

int            (lua_equal) (lua_State *L, int idx1, int idx2);
int            (lua_rawequal) (lua_State *L, int idx1, int idx2);
int            (lua_lessthan) (lua_State *L, int idx1, int idx2);

lua_Number      (lua_tonumber) (lua_State *L, int idx);
lua_Integer     (lua_tointeger) (lua_State *L, int idx);
int             (lua_toboolean) (lua_State *L, int idx);
const char     *(lua_tolstring) (lua_State *L, int idx, size_t *len);
size_t          (lua_objlen) (lua_State *L, int idx);
lua_CFunction   (lua_tocfunction) (lua_State *L, int idx);
void	       *(lua_touserdata) (lua_State *L, int idx);
lua_State      *(lua_tothread) (lua_State *L, int idx);
const void     *(lua_topointer) (lua_State *L, int idx);


/*
** push functions (C -> stack)
*/
void  (lua_pushnil) (lua_State *L);
void  (lua_pushnumber) (lua_State *L, lua_Number n);
void  (lua_pushinteger) (lua_State *L, lua_Integer n);
void  (lua_pushlstring) (lua_State *L, const char *s, size_t l);
void  (lua_pushstring) (lua_State *L, const char *s);
const char *(lua_pushvfstring) (lua_State *L, const char *fmt,
                                                      va_list argp);
const char *(lua_pushfstring) (lua_State *L, const char *fmt, ...);
void  (lua_pushcclosure) (lua_State *L, lua_CFunction fn, int n);
void  (lua_pushboolean) (lua_State *L, int b);
void  (lua_pushlightuserdata) (lua_State *L, void *p);
int   (lua_pushthread) (lua_State *L);


/*
** get functions (Lua -> stack)
*/
void  (lua_gettable) (lua_State *L, int idx);
void  (lua_getfield) (lua_State *L, int idx, const char *k);
void  (lua_rawget) (lua_State *L, int idx);
void  (lua_rawgeti) (lua_State *L, int idx, int n);
void  (lua_createtable) (lua_State *L, int narr, int nrec);
void *(lua_newuserdata) (lua_State *L, size_t sz);
int   (lua_getmetatable) (lua_State *L, int objindex);
void  (lua_getfenv) (lua_State *L, int idx);


/*
** set functions (stack -> Lua)
*/
void  (lua_settable) (lua_State *L, int idx);
void  (lua_setfield) (lua_State *L, int idx, const char *k);
void  (lua_rawset) (lua_State *L, int idx);
void  (lua_rawseti) (lua_State *L, int idx, int n);
int   (lua_setmetatable) (lua_State *L, int objindex);
int   (lua_setfenv) (lua_State *L, int idx);


/*
** `load' and `call' functions (load and run Lua code)
*/
void  (lua_call) (lua_State *L, int nargs, int nresults);
int   (lua_pcall) (lua_State *L, int nargs, int nresults, int errfunc);
int   (lua_cpcall) (lua_State *L, lua_CFunction func, void *ud);
int   (lua_load) (lua_State *L, lua_Reader reader, void *dt,
                                        const char *chunkname);

int (lua_dump) (lua_State *L, lua_Writer writer, void *data);


/*
** coroutine functions
*/
int  (lua_yield) (lua_State *L, int nresults);
int  (lua_resume) (lua_State *L, int narg);
int  (lua_status) (lua_State *L);

/*
** garbage-collection function and options
*/

static const int LUA_GCSTOP		= 0;
static const int LUA_GCRESTART		= 1;
static const int LUA_GCCOLLECT		= 2;
static const int LUA_GCCOUNT		= 3;
static const int LUA_GCCOUNTB		= 4;
static const int LUA_GCSTEP		= 5;
static const int LUA_GCSETPAUSE		= 6;
static const int LUA_GCSETSTEPMUL	= 7;

int (lua_gc) (lua_State *L, int what, int data);


/*
** miscellaneous functions
*/

int   (lua_error) (lua_State *L);

int   (lua_next) (lua_State *L, int idx);

void  (lua_concat) (lua_State *L, int n);

lua_Alloc (lua_getallocf) (lua_State *L, void **ud);
void lua_setallocf (lua_State *L, lua_Alloc f, void *ud);



/*
** ===============================================================
** some useful macros
** ===============================================================
*/

//#define lua_pop(L,n)		lua_settop(L, -(n)-1)

//#define lua_newtable(L)		lua_createtable(L, 0, 0)

//#define lua_register(L,n,f) (lua_pushcfunction(L, (f)), lua_setglobal(L, (n)))

//#define lua_pushcfunction(L,f)	lua_pushcclosure(L, (f), 0)

//#define lua_strlen(L,i)		lua_objlen(L, (i))

//#define lua_isfunction(L,n)	(lua_type(L, (n)) == LUA_TFUNCTION)
//#define lua_istable(L,n)	(lua_type(L, (n)) == LUA_TTABLE)
//#define lua_islightuserdata(L,n)	(lua_type(L, (n)) == LUA_TLIGHTUSERDATA)
//#define lua_isnil(L,n)		(lua_type(L, (n)) == LUA_TNIL)
//#define lua_isboolean(L,n)	(lua_type(L, (n)) == LUA_TBOOLEAN)
//#define lua_isthread(L,n)	(lua_type(L, (n)) == LUA_TTHREAD)
//#define lua_isnone(L,n)		(lua_type(L, (n)) == LUA_TNONE)
//#define lua_isnoneornil(L, n)	(lua_type(L, (n)) <= 0)

//#define lua_pushliteral(L, s)	\
//	lua_pushlstring(L, "" s, (sizeof(s)/sizeof(char))-1)

//#define lua_setglobal(L,s)	lua_setfield(L, LUA_GLOBALSINDEX, (s))
//#define lua_getglobal(L,s)	lua_getfield(L, LUA_GLOBALSINDEX, (s))

//#define lua_tostring(L,i)	lua_tolstring(L, (i), NULL)



/*
** compatibility macros and functions
*/

//#define lua_open()	luaL_newstate()

//#define lua_getregistry(L)	lua_pushvalue(L, LUA_REGISTRYINDEX)

//#define lua_getgccount(L)	lua_gc(L, LUA_GCCOUNT, 0)

//#define lua_Chunkreader		lua_Reader
//#define lua_Chunkwriter		lua_Writer


/* hack */
void lua_setlevel	(lua_State *from, lua_State *to);


/*
** {======================================================================
** Debug API
** =======================================================================
*/


/*
** Event codes
*/
static const int LUA_HOOKCALL	= 0;
static const int LUA_HOOKRET	= 1;
static const int LUA_HOOKLINE	= 2;
static const int LUA_HOOKCOUNT	= 3;
static const int LUA_HOOKTAILRET = 4;


/*
** Event masks
*/
static const int LUA_MASKCALL	= (1 << LUA_HOOKCALL);
static const int LUA_MASKRET	= (1 << LUA_HOOKRET);
static const int LUA_MASKLINE	= (1 << LUA_HOOKLINE);
static const int LUA_MASKCOUNT	= (1 << LUA_HOOKCOUNT);

typedef struct lua_Debug lua_Debug;  /* activation record */


/* Functions to be called by the debuger in specific events */
typedef void (*lua_Hook) (lua_State *L, lua_Debug *ar);


int lua_getstack (lua_State *L, int level, lua_Debug *ar);
int lua_getinfo (lua_State *L, const char *what, lua_Debug *ar);
const char *lua_getlocal (lua_State *L, const lua_Debug *ar, int n);
const char *lua_setlocal (lua_State *L, const lua_Debug *ar, int n);
const char *lua_getupvalue (lua_State *L, int funcindex, int n);
const char *lua_setupvalue (lua_State *L, int funcindex, int n);
int lua_sethook (lua_State *L, lua_Hook func, int mask, int count);
lua_Hook lua_gethook (lua_State *L);
int lua_gethookmask (lua_State *L);
int lua_gethookcount (lua_State *L);

/* From Lua 5.2. */
void *lua_upvalueid (lua_State *L, int idx, int n);
void lua_upvaluejoin (lua_State *L, int idx1, int n1, int idx2, int n2);
int lua_loadx (lua_State *L, lua_Reader reader, void *dt,
		       const char *chunkname, const char *mode);


struct lua_Debug {
  int event;
  const char *name;	/* (n) */
  const char *namewhat;	/* (n) `global', `local', `field', `method' */
  const char *what;	/* (S) `Lua', `C', `main', `tail' */
  const char *source;	/* (S) */
  int currentline;	/* (l) */
  int nups;		/* (u) number of upvalues */
  int linedefined;	/* (S) */
  int lastlinedefined;	/* (S) */
  char short_src[LUA_IDSIZE]; /* (S) */
  /* private part */
  int i_ci;  /* active function */
};

/* }====================================================================== */


/******************************************************************************
* Copyright (C) 1994-2008 Lua.org, PUC-Rio.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining
* a copy of this software and associated documentation files (the
* "Software"), to deal in the Software without restriction, including
* without limitation the rights to use, copy, modify, merge, publish,
* distribute, sublicense, and/or sell copies of the Software, and to
* permit persons to whom the Software is furnished to do so, subject to
* the following conditions:
*
* The above copyright notice and this permission notice shall be
* included in all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
* EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
* MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
* IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
* CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
* TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
* SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
******************************************************************************/


//#endif
]]

--- lualib.h
--- ---------------------------------------------------------------------------

ffi.cdef [[
/*
** Standard library header.
** Copyright (C) 2005-2012 Mike Pall. See Copyright Notice in luajit.h
*/

//#ifndef _LUALIB_H
//#define _LUALIB_H

//#include "lua.h"

//#define LUA_FILEHANDLE	"FILE*"

//#define LUA_COLIBNAME	"coroutine"
//#define LUA_MATHLIBNAME	"math"
//#define LUA_STRLIBNAME	"string"
//#define LUA_TABLIBNAME	"table"
//#define LUA_IOLIBNAME	"io"
//#define LUA_OSLIBNAME	"os"
//#define LUA_LOADLIBNAME	"package"
//#define LUA_DBLIBNAME	"debug"
//#define LUA_BITLIBNAME	"bit"
//#define LUA_JITLIBNAME	"jit"
//#define LUA_FFILIBNAME	"ffi"

int luaopen_base(lua_State *L);
int luaopen_math(lua_State *L);
int luaopen_string(lua_State *L);
int luaopen_table(lua_State *L);
int luaopen_io(lua_State *L);
int luaopen_os(lua_State *L);
int luaopen_package(lua_State *L);
int luaopen_debug(lua_State *L);
int luaopen_bit(lua_State *L);
int luaopen_jit(lua_State *L);
int luaopen_ffi(lua_State *L);

void luaL_openlibs(lua_State *L);

//#ifndef lua_assert
//#define lua_assert(x)	((void)0)
//#endif

//#endif
]]

--- lauxlib.h
--- ---------------------------------------------------------------------------

ffi.cdef [[
/*
** $Id: lauxlib.h,v 1.88.1.1 2007/12/27 13:02:25 roberto Exp $
** Auxiliary functions for building Lua libraries
** See Copyright Notice in lua.h
*/


//#ifndef lauxlib_h
//#define lauxlib_h


//#include <stddef.h>
//#include <stdio.h>

//#include "lua.h"


//#define luaL_getn(L,i)          ((int)lua_objlen(L, i))
//#define luaL_setn(L,i,j)        ((void)0)  /* no op! */

/* extra error code for `luaL_load' */
static const int LUA_ERRFILE     = (LUA_ERRERR+1);

typedef struct luaL_Reg {
  const char *name;
  lua_CFunction func;
} luaL_Reg;

void (luaL_openlib) (lua_State *L, const char *libname,
                     const luaL_Reg *l, int nup);
void (luaL_register) (lua_State *L, const char *libname,
                     const luaL_Reg *l);
int (luaL_getmetafield) (lua_State *L, int obj, const char *e);
int (luaL_callmeta) (lua_State *L, int obj, const char *e);
int (luaL_typerror) (lua_State *L, int narg, const char *tname);
int (luaL_argerror) (lua_State *L, int numarg, const char *extramsg);
const char *(luaL_checklstring) (lua_State *L, int numArg,
                                               size_t *l);
const char *(luaL_optlstring) (lua_State *L, int numArg,
                               const char *def, size_t *l);
lua_Number (luaL_checknumber) (lua_State *L, int numArg);
lua_Number (luaL_optnumber) (lua_State *L, int nArg, lua_Number def);

lua_Integer (luaL_checkinteger) (lua_State *L, int numArg);
lua_Integer (luaL_optinteger) (lua_State *L, int nArg,
                               lua_Integer def);

void (luaL_checkstack) (lua_State *L, int sz, const char *msg);
void (luaL_checktype) (lua_State *L, int narg, int t);
void (luaL_checkany) (lua_State *L, int narg);

int   (luaL_newmetatable) (lua_State *L, const char *tname);
void *(luaL_checkudata) (lua_State *L, int ud, const char *tname);

void (luaL_where) (lua_State *L, int lvl);
int (luaL_error) (lua_State *L, const char *fmt, ...);

int (luaL_checkoption) (lua_State *L, int narg, const char *def,
                        const char *const lst[]);

int (luaL_ref) (lua_State *L, int t);
void (luaL_unref) (lua_State *L, int t, int ref);

int (luaL_loadfile) (lua_State *L, const char *filename);
int (luaL_loadbuffer) (lua_State *L, const char *buff, size_t sz,
                       const char *name);
int (luaL_loadstring) (lua_State *L, const char *s);

lua_State *(luaL_newstate) (void);


const char *(luaL_gsub) (lua_State *L, const char *s, const char *p,
                                       const char *r);

const char *(luaL_findtable) (lua_State *L, int idx,
                                         const char *fname, int szhint);

/* From Lua 5.2. */
int luaL_fileresult(lua_State *L, int stat, const char *fname);
int luaL_execresult(lua_State *L, int stat);
int (luaL_loadfilex) (lua_State *L, const char *filename,
                      const char *mode);
int (luaL_loadbufferx) (lua_State *L, const char *buff, size_t sz,
                        const char *name, const char *mode);


/*
** ===============================================================
** some useful macros
** ===============================================================
*/

//#define luaL_argcheck(L, cond,numarg,extramsg)	\
//		((void)((cond) || luaL_argerror(L, (numarg), (extramsg))))
//#define luaL_checkstring(L,n)	(luaL_checklstring(L, (n), NULL))
//#define luaL_optstring(L,n,d)	(luaL_optlstring(L, (n), (d), NULL))
//#define luaL_checkint(L,n)	((int)luaL_checkinteger(L, (n)))
//#define luaL_optint(L,n,d)	((int)luaL_optinteger(L, (n), (d)))
//#define luaL_checklong(L,n)	((long)luaL_checkinteger(L, (n)))
//#define luaL_optlong(L,n,d)	((long)luaL_optinteger(L, (n), (d)))
//
//#define luaL_typename(L,i)	lua_typename(L, lua_type(L,(i)))
//
//#define luaL_dofile(L, fn) \
//	(luaL_loadfile(L, fn) || lua_pcall(L, 0, LUA_MULTRET, 0))
//
//#define luaL_dostring(L, s) \
//	(luaL_loadstring(L, s) || lua_pcall(L, 0, LUA_MULTRET, 0))
//
//#define luaL_getmetatable(L,n)	(lua_getfield(L, LUA_REGISTRYINDEX, (n)))
//
//#define luaL_opt(L,f,n,d)	(lua_isnoneornil(L,(n)) ? (d) : f(L,(n)))

/*
** {======================================================
** Generic Buffer manipulation
** =======================================================
*/



//typedef struct luaL_Buffer {
//  char *p;			/* current position in buffer */
//  int lvl;  /* number of strings in the stack (level) */
//  lua_State *L;
//  char buffer[LUAL_BUFFERSIZE];
//} luaL_Buffer;

//#define luaL_addchar(B,c) \
//  ((void)((B)->p < ((B)->buffer+LUAL_BUFFERSIZE) || luaL_prepbuffer(B)), \
//   (*(B)->p++ = (char)(c)))

/* compatibility only */
//#define luaL_putchar(B,c)	luaL_addchar(B,c)

//#define luaL_addsize(B,n)	((B)->p += (n))

//LUALIB_API void (luaL_buffinit) (lua_State *L, luaL_Buffer *B);
//LUALIB_API char *(luaL_prepbuffer) (luaL_Buffer *B);
//LUALIB_API void (luaL_addlstring) (luaL_Buffer *B, const char *s, size_t l);
//LUALIB_API void (luaL_addstring) (luaL_Buffer *B, const char *s);
//LUALIB_API void (luaL_addvalue) (luaL_Buffer *B);
//LUALIB_API void (luaL_pushresult) (luaL_Buffer *B);


/* }====================================================== */


/* compatibility with ref system */

/* pre-defined references */
static const int LUA_NOREF = -2;
static const int LUA_REFNIL = -1;

//#define lua_ref(L,lock) ((lock) ? luaL_ref(L, LUA_REGISTRYINDEX) : \
//      (lua_pushstring(L, "unlocked references are obsolete"), lua_error(L), 0))

//#define lua_unref(L,ref)        luaL_unref(L, LUA_REGISTRYINDEX, (ref))

//#define lua_getref(L,ref)       lua_rawgeti(L, LUA_REGISTRYINDEX, (ref))


//#define luaL_reg	luaL_Reg

//#endif
]]

return lua
