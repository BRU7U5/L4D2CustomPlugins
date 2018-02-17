#pragma semicolon 1
#include <sourcemod>
#include <colors>
#define	PLUGIN_VERSION		"1.0"

new bool:playerW[MAXPLAYERS+1];

public Plugin:myinfo = 
{
	name = "[L4D2] Welcome Message",
	author = "B[R]UTUS",
	description	= "Prints the welcome message to new connected player.",
	version	= PLUGIN_VERSION,
	url	= "https://github.com/BRU7U5"
}

public void OnPluginStart()
{
    for (new i = 1; i <= MAXPLAYERS; i++)
    {
        playerW[i] = false;    
    }    
}

public void OnClientPutInServer(int client) //public void OnClientConnected(int client)
{
    if (IsClientInGame(client) && !IsFakeClient(client) && !playerW[client])
        {
            CPrintToChat(client, "{green}-----------------------------------------------------------------------{default}");
            CPrintToChat(client, "Добро пожаловать на сервер {olive}[T100] SkyLine Versus #1 |t2{default}");
            CPrintToChat(client, "{green}-----------------------------------------------------------------------{default}");
            CPrintToChat(client, "Список основных команд сервера: {olive}!commands{default}");
            CPrintToChat(client, "Узнать правила сервера: {olive}!rules{default}");
            CPrintToChat(client, "{green}-----------------------------------------------------------------------{default}");
            playerW[client] = true;
        }
}

public void OnClientDisconnect_Post(int client)
{
    playerW[client] = false;
}