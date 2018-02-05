/*
	SourcePawn is Copyright (C) 2006-2008 AlliedModders LLC.  All rights reserved.
	SourceMod is Copyright (C) 2006-2008 AlliedModders LLC.  All rights reserved.
	Pawn and SMALL are Copyright (C) 1997-2008 ITB CompuPhase.
	Source is Copyright (C) Valve Corporation.
	All trademarks are property of their respective owners.

	This program is free software: you can redistribute it and/or modify it
	under the terms of the GNU General Public License as published by the
	Free Software Foundation, either version 3 of the License, or (at your
	option) any later version.

	This program is distributed in the hope that it will be useful, but
	WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
	General Public License for more details.

	You should have received a copy of the GNU General Public License along
	with this program.  If not, see <http://www.gnu.org/licenses/>.
*/
#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <left4downtown>
#include <colors>

new iDistance;
new witchIndex;
new EscTankSpawnCnt;

new bool:bTankPointsFrozen;
new bool:bWitchPointsFrozen;
new bool:bEscapeEventStarted;

public Plugin:myinfo = 
{
	name = "L4D2 No Boss Rush",
	author = "Visor; originally by Jahze, vintik. Modified by B[R]UTUS",
	version = "2.2",
	description = "Stops distance points accumulating whilst the Tank or Witch are alive",
	url = "https://github.com/Attano/Equilibrium"
};

public OnPluginStart()
{
	LoadTranslations("l4d2_boss_rush.phrases.txt");
	HookEvent("round_start", EventHook:OnRoundStart, EventHookMode_PostNoCopy);
	HookEvent("tank_spawn", EventHook:OnTankSpawn, EventHookMode_PostNoCopy);
	HookEvent("player_death", OnPlayerDeath);
	HookEvent("witch_spawn", OnWitchSpawn);
	HookEvent("witch_killed", EventHook:OnWitchKilled, EventHookMode_PostNoCopy);
	HookEvent("finale_vehicle_ready", EventHook:OnEscapeVehicleReady, EventHookMode_PostNoCopy); // Перехватываем ивент готовности к погрузке в спасательный транспорт
}

public OnRoundStart()
{
	if (InSecondHalfOfRound())
	{
		UnFreezePoints();
		bEscapeEventStarted = false;
		EscTankSpawnCnt = 0;
	}

	bEscapeEventStarted = false;
	EscTankSpawnCnt = 0;
}

/* Tank */

public OnTankSpawn()
{
	if (!bTankPointsFrozen && !bWitchPointsFrozen)
	{
		CPrintToChatAll("%t", "Tank Spawn Announce");
		bTankPointsFrozen = true;
		FreezePoints();
	}

	else if (bEscapeEventStarted)
	{
		EscTankSpawnCnt++;
		
		if (EscTankSpawnCnt == 1)
		{
			CPrintToChatAll("%t", "Escape Event Tank Spawn Announce");
			bTankPointsFrozen = true;
		}

		if (EscTankSpawnCnt >= 1)
			bTankPointsFrozen = true;	
	}
}

public OnEscapeVehicleReady() // Когда спасательный транспорт готов к погрузке людей
{
	if (bTankPointsFrozen) // Если очки заморожены из-за танка
	{
		CPrintToChatAll("%t", "Escape Event Started Announce");
		bTankPointsFrozen = true; // Оставляем состояние замороженности в "истина", чтобы появление всех остальных танков не вызывало замораживание очков.
		UnFreezePoints(); // Размораживаем очки
		bEscapeEventStarted = true; 
	}
}

public Action:OnPlayerDeath(Handle:event, const String:name[], bool:dontBroadcast) 
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (IsTank(client))
	{
		CreateTimer(0.1, CheckForTanksDelay, TIMER_FLAG_NO_MAPCHANGE);
	}
}

public OnClientDisconnect(client) 
{
	if (IsTank(client))
	{
		CreateTimer(0.1, CheckForTanksDelay, TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Action:CheckForTanksDelay(Handle:timer) 
{
	if (FindTank() == -1)
	{
		if (bTankPointsFrozen) 
		{
			CPrintToChatAll("%t", "Tank Killed Announce");
			bTankPointsFrozen = false;
			UnFreezePoints();
		}
	}
}

/* Witch */

public Action:OnWitchSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!bTankPointsFrozen && !bWitchPointsFrozen)
	{
		witchIndex = GetEventInt(event, "witchid");
		CPrintToChatAll("%t", "Witch Spawn Announce");
		bWitchPointsFrozen = true;
		FreezePoints();
	}
}

public OnWitchKilled()
{
	if (bWitchPointsFrozen)
	{
		CPrintToChatAll("%t", "Witch Killed Announce");
		bWitchPointsFrozen = false;
		UnFreezePoints();
		witchIndex = -1;
	}
}

public OnEntityDestroyed(entity)
{
	if (entity == witchIndex)
	{
		OnWitchKilled();
	}
}

/* Shared */

FreezePoints() 
{
	iDistance = L4D_GetVersusMaxCompletionScore();
	L4D_SetVersusMaxCompletionScore(0);
}

UnFreezePoints() 
{
	L4D_SetVersusMaxCompletionScore(iDistance);
}

FindTank() 
{
	for (new i = 1; i <= MaxClients; i++) 
	{
		if (IsTank(i) && IsPlayerAlive(i)) 
		{
			return i;
		}
	}
	return -1;
}

bool:IsTank(client)
{
	if (client <= 0 || !IsClientInGame(client) || GetClientTeam(client) != 3)
		return false;

	if (GetEntProp(client, Prop_Send, "m_zombieClass") != 8)
		return false;

	return true;
}

InSecondHalfOfRound()
{
	return GameRules_GetProp("m_bInSecondHalfOfRound");
}