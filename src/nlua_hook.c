/*
 * See Licensing and Copyright notice in naev.h
 */

/**
 * @file nlua_hook.c
 *
 * @brief Lua hook module.
 */


#include "nlua_hook.h"

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

#include "lua.h"
#include "lauxlib.h"

#include "nlua.h"
#include "nluadef.h"
#include "nlua_pilot.h"
#include "hook.h"
#include "log.h"
#include "naev.h"
#include "mission.h"


/*
 * Needed.
 */
extern Mission *cur_mission;


/* hooks */
static int hook_land( lua_State *L );
static int hook_takeoff( lua_State *L );
static int hook_time( lua_State *L );
static int hook_enter( lua_State *L );
static int hook_pilot( lua_State *L );
static const luaL_reg hook_methods[] = {
   { "land", hook_land },
   { "takeoff", hook_takeoff },
   { "time", hook_time },
   { "enter", hook_enter },
   { "pilot", hook_pilot },
   {0,0}
}; /**< Hook Lua methods. */


/*
 * Prototypes.
 */
static unsigned int hook_generic( lua_State *L, char* stack, int pos );


/**
 * @brief Loads the hook lua library.
 *    @param L Lua state.
 *    @return 0 on success.
 */
int lua_loadHook( lua_State *L )
{
   luaL_register(L, "hook", hook_methods);
   return 0;
}


/**
 * @defgroup HOOK Hook Lua bindings
 *
 * @brief Lua bindings to manipulate hooks.
 *
 * Functions should be called like:
 *
 * @code
 * hook.function( parameters )
 * @endcode
 */
/**
 * @brief Creates a mission hook to a certain stack.
 *
 * Basically a generic approach to hooking.
 *
 *    @param L Lua state.
 *    @param stack Stack to put the hook in.
 *    @param pos Position in the stack of the function name.
 *    @return The hook ID or 0 on error.
 */
static unsigned int hook_generic( lua_State *L, char* stack, int pos )
{
   int i;
   char *func;

   NLUA_MIN_ARGS(1);

   /* Last parameter must be function to hook */
   if (lua_isstring(L,pos)) func = (char*)lua_tostring(L,pos);
   else NLUA_INVALID_PARAMETER();

   /* make sure mission is a player mission */
   for (i=0; i<MISSION_MAX; i++)
      if (player_missions[i].id == cur_mission->id)
         break;
   if (i>=MISSION_MAX) {
      WARN("Mission not in stack trying to hook");
      return 0;
   }

   return hook_add( cur_mission->id, func, stack );
}
/**
 * @ingroup HOOK
 *
 * @brief number land( string func )
 *
 * Hooks the function to the player landing.
 *
 *    @param func Function to run when hook is triggered.
 *    @return Hook identifier.
 */
static int hook_land( lua_State *L )
{
   hook_generic( L, "land", 1 );
   return 0;
}
/**
 * @ingroup HOOK
 *
 * @brief number takeoff( string func )
 *
 * Hooks the function to the player taking off
 *
 *    @param func Function to run when hook is triggered.
 *    @return Hook identifier.
 */
static int hook_takeoff( lua_State *L )
{
   hook_generic( L, "takeoff", 1 );
   return 0;
}
/**
 * @ingroup HOOK
 *
 * @brief number time( string func )
 *
 * Hooks the function to a time change.
 *
 *    @param func Function to run when hook is triggered.
 *    @return Hook identifier.
 */
static int hook_time( lua_State *L )
{
   hook_generic( L, "time", 1 );
   return 0;
}
/**
 * @ingroup HOOK
 *
 * @brief number enter( string func )
 *
 * Hooks the function to the player entering a system (triggers when taking
 *  off too).
 *
 *    @param func Function to run when hook is triggered.
 *    @return Hook identifier.
 */
static int hook_enter( lua_State *L )
{
   hook_generic( L, "enter", 1 );
   return 0;
}
/**
 * @ingroup HOOK
 *
 * @brief number pilot( Pilot pilot, string type, string func )
 *
 * Hooks the function to a specific pilot.
 *
 * You can hook to different actions.  Curently hook system only supports:
 *    - "death" :  triggered when pilot dies.
 *    - "board" :  triggered when pilot is boarded.
 *    - "disable" :  triggered when pilot is disabled.
 *    - "jump" : triggered when pilot jumps to hyperspace.
 *
 *    @param pilot Pilot identifier to hook.
 *    @param type One of the supported hook types.
 *    @param func Function to run when hook is triggered.
 *    @return Hook identifier.
 */
static int hook_pilot( lua_State *L )
{
   NLUA_MIN_ARGS(3);
   unsigned int h;
   LuaPilot *p;
   int type;
   char *hook_type;

   /* First parameter parameter - pilot to hook */
   if (lua_ispilot(L,1)) p = lua_topilot(L,1);
   else NLUA_INVALID_PARAMETER();

   /* Second parameter - hook name */
   if (lua_isstring(L,2)) hook_type = (char*) lua_tostring(L,2);
   else NLUA_INVALID_PARAMETER();

   /* Check to see if hook_type is valid */
   if (strcmp(hook_type,"death")==0) type = PILOT_HOOK_DEATH;
   else if (strcmp(hook_type,"board")==0) type = PILOT_HOOK_BOARD;
   else if (strcmp(hook_type,"disable")==0) type = PILOT_HOOK_DISABLE;
   else if (strcmp(hook_type,"jump")==0) type = PILOT_HOOK_JUMP;
   else { /* hook_type not valid */
      NLUA_DEBUG("Invalid pilot hook type: '%s'", hook_type);
      return 0;
   }

   /* actually add the hook */
   h = hook_generic( L, hook_type, 3 );
   pilot_addHook( pilot_get(p->pilot), type, h );

   return 0;
}

