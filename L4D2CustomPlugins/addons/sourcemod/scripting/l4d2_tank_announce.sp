/*
	SourcePawn is Copyright (C) 2006-2015 AlliedModders LLC.  All rights reserved.
	SourceMod is Copyright (C) 2006-2015 AlliedModders LLC.  All rights reserved.
	Pawn and SMALL are Copyright (C) 1997-2015 ITB CompuPhase.
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
#include <colors>

new bool:g_bIsTankAlive;
new bool:g_bIsWitchAlive;

public Plugin:myinfo = 
{
	name = "L4D2 Tank and Witch Announcer",
	author = "Visor. Modify by B[R]UTUS",
	description = "Announce in chat and via a sound when a Tank and Witch has spawned",
	version = "1.5",
	url = "https://github.com/Attano"
};

public OnMapStart()
{
	PrecacheSound("ui/pickup_secret01.wav");
	PrecacheSound("ui/survival_teamrec.wav");
	PrecacheSound("ui/critical_event_1.wav");
	PrecacheSound("ui/survival_playerrec.wav");
}

public OnPluginStart()
{
	HookEvent("tank_spawn", EventHook:OnTankSpawn, EventHookMode_PostNoCopy);
	HookEvent("tank_killed", EventHook:OnTankKilled, EventHookMode_PostNoCopy);
	HookEvent("round_start", EventHook:OnRoundStart, EventHookMode_PostNoCopy);
	HookEvent("witch_spawn", EventHook:OnWitchSpawn);
	HookEvent("witch_killed", EventHook:OnWitchKilled, EventHookMode_PostNoCopy);
}

public OnRoundStart()
{
	g_bIsTankAlive = false;
}

public OnTankSpawn()
{
	if (!g_bIsTankAlive)
	{
		g_bIsTankAlive = true;
		//CPrintToChatAll("Внимание! Появился {red}Танк{default}!");
		EmitSoundToAll("ui/pickup_secret01.wav");
	}
}

public OnTankKilled()
{
	g_bIsTankAlive = false;
	//CPrintToChatAll("{red}Танк {default}убит!");
	EmitSoundToAll("ui/survival_teamrec.wav");
}

public OnWitchSpawn()
{
	if (!g_bIsWitchAlive)
	{
		g_bIsWitchAlive = true;
		//CPrintToChatAll("Внимание! Появилась {red}Ведьма{default}!");
		EmitSoundToAll("ui/critical_event_1.wav");
	}
}

public OnWitchKilled()
{
	g_bIsWitchAlive = false;
	//CPrintToChatAll("{red}Ведьма {default}убита!");
	EmitSoundToAll("ui/survival_playerrec.wav");
}

