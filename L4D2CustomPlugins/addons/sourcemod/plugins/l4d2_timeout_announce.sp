#pragma semicolon 1
#include <sourcemod>
#include <colors>
#define	PLUGIN_VERSION		"1.0"

new playerDC[MAXPLAYERS+1];

public Plugin:myinfo = 
{
	name			=	"[L4D2] Timeout Announce",
	author			=	"B[R]UTUS",
	description		=	"Informs other players when a client will lose connection with server.",
	version			=	PLUGIN_VERSION,
	url				=	"https://github.com/BRU7U5"
}

public OnPluginStart() 
{
    LoadTranslations("l4d2_timeout_announce.phrases.txt");
    CreateTimer(1.0, CheckIsTimingOut, _, TIMER_REPEAT);
    CreateTimer(1.0, CheckForRestored, _, TIMER_REPEAT);
}

public Action:CheckIsTimingOut(Handle:timer) 
{
    for (new i = 1; i <= MaxClients; i++)
        if (IsClientInGame(i) && !IsFakeClient(i) && IsClientTimingOut(i) && !playerDC[i])
        {
            CPrintToChatAll("%t", "Lost Connection Announce", i);
            playerDC[i] = true;
        }
}

public Action:CheckForRestored(Handle:timer)
{
    for (new i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i) && !IsFakeClient(i) && !IsClientTimingOut(i) && playerDC[i])
        {
            CPrintToChatAll("%t", "Restored Connection Announce", i);
            playerDC[i] = false;
        }    
    }
}