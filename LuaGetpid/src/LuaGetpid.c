#include "lua.h"
#include "lauxlib.h"

#if defined(_WIN32)
#include <windows.h>
#define LUA_EXPORT __attribute__((dllexport))

#define WIN32_LEAN_AND_MEAN
BOOL APIENTRY DllMain(HANDLE module, DWORD reason, LPVOID reserved) { return TRUE; }
#else
#include <unistd.h>
#define LUA_EXPORT extern
#endif

/*exports*/
static int l_getpid(lua_State * L)
{
    #if defined(_WIN32)
        lua_pushnumber(L, GetCurrentProcessId());
    #else
        lua_pushnumber(L, getpid());
    #endif
    return 1;
}

LUA_EXPORT int luaopen_LuaGetpid(lua_State * L)
{
    lua_pushcfunction(L, l_getpid);
    lua_setfield(L, LUA_GLOBALSINDEX, "getpid");
    return 1;
}
