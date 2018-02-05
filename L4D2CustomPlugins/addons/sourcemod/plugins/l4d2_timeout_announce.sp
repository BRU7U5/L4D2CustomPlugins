#pragma semicolon 1
#include <sourcemod>
#include <colors>
#define	PLUGIN_VERSION		"0.7"

new playerDC[MAXPLAYERS+1];

public Plugin:myinfo = 
{
	name			=	"[L4D2] Timeout Announce",
	author			=	"B[R]UTUS",
	description		=	"Informs other players when a client will lose connection with server.",
	version			=	PLUGIN_VERSION,
	url				=	""
}

public OnPluginStart() 
{
   CreateTimer(1.0, CheckIsTimingOut, _, TIMER_REPEAT);
   CreateTimer(1.0, RestoreTimer, _, TIMER_REPEAT);
}

public Action:CheckIsTimingOut(Handle:timer) 
{
    for (new i = 1; i <= MaxClients; i++)
        if (IsClientInGame(i) && !IsFakeClient(i) && IsClientTimingOut(i) && !playerDC[i]) //IsClientConnected
        {
            CPrintToChatAll("{olive}%N{red} has lost connection with server.{default}", i);
            playerDC[i] = true;
        }
}

public Action:RestoreTimer(Handle:timer)
{
    for (new i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i) && !IsFakeClient(i) && !IsClientTimingOut(i) && playerDC[i])
        {
            CPrintToChatAll("{olive}%N{blue} has restored connection with server.{default}", i);
            playerDC[i] = false;
        }    
    }
}