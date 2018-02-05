#pragma semicolon 1 
#include <sourcemod> 
#include <sdktools>
#include <colors>
#include <l4d2_direct>

#define PLUGIN_VERSION "1.0" 

#define CVAR_FLAGS FCVAR_PLUGIN|FCVAR_SPONLY

#define advertising IsClientInGame(client) && GetConVarInt(cvar_meleeannounce)

#define MODEL_BASEBALLBAT_W "models/weapons/melee/w_bat.mdl"
#define MODEL_BASEBALLBAT_V "models/weapons/melee/v_bat.mdl"
#define MODEL_CRICKETBAT_W "models/weapons/melee/w_cricket_bat.mdl"
#define MODEL_CRICKETBAT_V "models/weapons/melee/v_cricket_bat.mdl"
#define MODEL_CROWBAR_W "models/weapons/melee/w_crowbar.mdl"
#define MODEL_CROWBAR_V "models/weapons/melee/v_crowbar.mdl"
#define MODEL_ELECTRICGUITAR_W "models/weapons/melee/w_electric_guitar.mdl"
#define MODEL_ELECTRICGUITAR_V "models/weapons/melee/v_electric_guitar.mdl"
#define MODEL_FIREAXE_W "models/weapons/melee/w_fireaxe.mdl"
#define MODEL_FIREAXE_V "models/weapons/melee/v_fireaxe.mdl"
#define MODEL_FRYINGPAN_W "models/weapons/melee/w_frying_pan.mdl"
#define MODEL_FRYINGPAN_V "models/weapons/melee/v_frying_pan.mdl"
#define MODEL_GOLFCLUB_W "models/weapons/melee/w_golfclub.mdl"
#define MODEL_GOLFCLUB_V "models/weapons/melee/v_golfclub.mdl"
#define MODEL_KATANA_W "models/weapons/melee/w_katana.mdl"
#define MODEL_KATANA_V "models/weapons/melee/v_katana.mdl"
#define MODEL_KNIFE_W "models/w_models/weapons/w_knife_t.mdl"
#define MODEL_KNIFE_V "models/v_models/v_knife_t.mdl"
#define MODEL_MACHETE_W "models/weapons/melee/w_machete.mdl"
#define MODEL_MACHETE_V "models/weapons/melee/v_machete.mdl"
#define MODEL_TONFA_W "models/weapons/melee/w_tonfa.mdl"
#define MODEL_TONFA_V "models/weapons/melee/v_tonfa.mdl"
#define MODEL_RIOTSHIELD_W "models/weapons/melee/w_riotshield.mdl"
#define MODEL_RIOTSHIELD_V "models/weapons/melee/v_riotshield.mdl"

#define MAX(%0,%1) (((%0) > (%1)) ? (%0) : (%1))

new Handle:cvar_maxweaponstotal = INVALID_HANDLE; 
new Handle:cvar_maxweaponsclient = INVALID_HANDLE;
new Handle:cvar_maxt1total = INVALID_HANDLE; 
new Handle:cvar_maxt1client = INVALID_HANDLE; 
new Handle:cvar_meleeannounce = INVALID_HANDLE;
//new Handle:cvar_maxdistance = INVALID_HANDLE;
new numweaponstotal; 
new numweaponsclient[MAXPLAYERS + 1];
new numt1total; 
new numt1client[MAXPLAYERS + 1]; 
new bool:startstatus;

public Plugin:myinfo =  
{ 
	name = "[L4D2]MeleeAndT1WeaponsMenu", 
	author = "dani1341, Modify by B[R]UTUS", 
	description = "Allows Clients To Get Melee and T1 Weapons From The Weapon Menu", 
	version = PLUGIN_VERSION, 
	url = "" 
}

public OnPluginStart() 
{ 
	LoadTranslations("l4d2_MeleeAndT1WeaponsMenu.phrases.txt");

	//melee weapons menu cvar 
	RegConsoleCmd("sm_melee", MeleeMenu); 
	RegConsoleCmd("sm_w", WeaponsMenu);
	RegConsoleCmd("sm_chrome", GChrome);
	RegConsoleCmd("sm_pump", GPump);
	RegConsoleCmd("sm_uzi", GUZI);
	RegConsoleCmd("sm_smg", GSMG);
	RegConsoleCmd("sm_axe", GAxe);
	RegConsoleCmd("sm_machete", GMachete);
	RegConsoleCmd("sm_katana", GKatana);
	//plugin version 
	CreateConVar("melee_version", PLUGIN_VERSION, "L4D2 Melee and T1 Weapons Menu version", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY); 

	cvar_maxweaponstotal = CreateConVar("melee_max", "16", "How much times all players can get melee weapons per map", FCVAR_PLUGIN|FCVAR_NOTIFY);
	cvar_maxt1total = CreateConVar("t1_max", "16", "How much times all players can get melee weapons per map", FCVAR_PLUGIN|FCVAR_NOTIFY);
	cvar_maxt1client = CreateConVar("t1_playermax", "4", "How much times one player can get melee weapons", FCVAR_PLUGIN|FCVAR_NOTIFY);   
	cvar_maxweaponsclient = CreateConVar("melee_playermax", "4", "How much times one player can get melee weapons", FCVAR_PLUGIN|FCVAR_NOTIFY);
	//cvar_maxdistance = CreateConVar("weapon_maxdistance", "15", "How many distance in percents do you have to get a weapons", FCVAR_PLUGIN|FCVAR_NOTIFY); 

	// Announce cvar
	cvar_meleeannounce = CreateConVar("melee_announce", "1", "Should the plugin advertise itself? 1 chat box message, 2 hint text message, 3 both, 0 for none.",CVAR_FLAGS,true,0.0,true,3.0);

	HookEvent("round_start", EventHook:OnRoundStart, EventHookMode_PostNoCopy);
	HookEvent("round_end", Event_RoundEnd);
	HookEvent("player_left_start_area", EventHook:OnLeftStartArea, EventHookMode_PostNoCopy);
	HookEvent("player_entered_start_area", EventHook:OnSpawnInStartArea, EventHookMode_PostNoCopy);  
	//autoexec 
	AutoExecConfig(true, "l4d2_melee"); 
} 

public OnMapStart() 
{ 
	PrecacheModel(MODEL_BASEBALLBAT_W, true);
	PrecacheModel(MODEL_BASEBALLBAT_V, true);
	PrecacheModel(MODEL_CRICKETBAT_W, true);
	PrecacheModel(MODEL_CRICKETBAT_V, true);
	PrecacheModel(MODEL_CROWBAR_W, true);
	PrecacheModel(MODEL_CROWBAR_V, true);
	PrecacheModel(MODEL_ELECTRICGUITAR_W, true);
	PrecacheModel(MODEL_ELECTRICGUITAR_V, true);
	PrecacheModel(MODEL_FIREAXE_W, true);
	PrecacheModel(MODEL_FIREAXE_V, true);
	PrecacheModel(MODEL_FRYINGPAN_W, true);
	PrecacheModel(MODEL_FRYINGPAN_V, true);
	PrecacheModel(MODEL_GOLFCLUB_W, true);
	PrecacheModel(MODEL_GOLFCLUB_V, true);
	PrecacheModel(MODEL_KATANA_W, true);
	PrecacheModel(MODEL_KATANA_V, true);
	PrecacheModel(MODEL_GOLFCLUB_W, true);
	PrecacheModel(MODEL_GOLFCLUB_V, true);
	PrecacheModel(MODEL_KNIFE_W, true);
	PrecacheModel(MODEL_KNIFE_V, true);
	PrecacheModel(MODEL_MACHETE_W, true);
	PrecacheModel(MODEL_MACHETE_V, true);
	PrecacheModel(MODEL_TONFA_W, true);
	PrecacheModel(MODEL_TONFA_V, true);
	PrecacheModel(MODEL_RIOTSHIELD_W, true);
	PrecacheModel(MODEL_RIOTSHIELD_V, true);
		
	numweaponstotal = 0;
	numt1total = 0;
	startstatus = false;
	for(new i = 1; i <= MAXPLAYERS; i++) {
		numweaponsclient[i] = 0;
		numt1client[i] = 0;
	} 
}

public OnRoundStart()
{
	if (InSecondHalfOfRound())
	{
		startstatus = false;
	}
}

public OnLeftStartArea()
{
	startstatus = true;
}

public OnSpawnInStartArea()
{
	startstatus = false;
}

InSecondHalfOfRound()
{
	return GameRules_GetProp("m_bInSecondHalfOfRound");
}

public Action:Event_RoundEnd(Handle:event, const String:name[], bool:dontBroadcast) 
{ 
	numweaponstotal = 0;
	numt1total = 0; 
	startstatus = false;
	for(new i = 1; i <= MAXPLAYERS; i++) { 
		numweaponsclient[i] = 0;
		numt1client[i] = 0;
	} 
} 

public OnClientPostAdminCheck(client) 
{ 
	for(new i = 1; i <= MAXPLAYERS; i++) {
		numweaponsclient[i] = 0;
		numt1client[i] = 0; 
	}
} 

public OnClientPutInServer(client)
{
	if (client)
	{
		if (GetConVarBool(cvar_meleeannounce))
			CreateTimer(60.0, AnnounceMelee, client);
	}
}

public Action:MeleeMenu(client,args) 
{ 
	if(!client || !IsClientInGame(client))  
		return Plugin_Handled; 

	if(GetClientTeam(client) != 2) 
	{ 
		CPrintToChat(client, "{olive}Меню рукопашного оружия {default}доступно только команде {blue}выживших{default}."); 
		return Plugin_Handled; 
	} 

	if(numweaponstotal >= GetConVarInt(cvar_maxweaponstotal))  
	{ 
		CPrintToChat(client, "Достигнут лимит из {olive}%i {default}ед. рукопашного оружия для этой карты!", GetConVarInt(cvar_maxweaponstotal)); 
		return Plugin_Handled; 
	} 

	if(numweaponsclient[client] >= GetConVarInt(cvar_maxweaponsclient))  
	{ 
		CPrintToChat(client, "Вы достигли своего лимита из {olive}%i {default}ед. для этой карты!", GetConVarInt(cvar_maxweaponsclient)); 
		return Plugin_Handled; 
	} 

	if(startstatus) 
	{
	  CPrintToChat(client, "%t", "Left a saferoom announce for melee"); 
	  return Plugin_Handled;  
	}

	Melee(client); 

	return Plugin_Handled; 
} 

public Action:WeaponsMenu(client,args) 
{ 
	if(!client || !IsClientInGame(client))  
		return Plugin_Handled; 

	if(GetClientTeam(client) != 2) 
	{ 
		CPrintToChat(client, "{olive}Меню t1 оружия {default}доступно только команде {blue}выживших{default}."); 
		return Plugin_Handled; 
	} 

	if(numt1total >= GetConVarInt(cvar_maxt1total))  
	{ 
		CPrintToChat(client, "Достигнут лимит из {olive}%i {default}ед. t1 оружия для этой карты!", GetConVarInt(cvar_maxt1total)); 
		return Plugin_Handled; 
	} 

	if(numt1client[client] >= GetConVarInt(cvar_maxt1client))  
	{ 
		CPrintToChat(client, "Вы достигли своего лимита из {olive}%i {default}ед. t1 оружия для этой карты!", GetConVarInt(cvar_maxt1client)); 
		return Plugin_Handled; 
	} 

	if(startstatus) 
	{
	  CPrintToChat(client, "%t", "Left a saferoom announce for gun"); 
	  return Plugin_Handled;  
	}

	Weapons(client); 

	return Plugin_Handled; 
} 


//----------------------------------------------GIVE CUSTOM WEAPONS-----------------------------------------------------------------------------
public Action:GChrome(client,args) 
{ 
	//new max_completion = GetMaxSurvivorCompletion(client);
	if(!client || !IsClientInGame(client))  
		return Plugin_Handled; 

	if(GetClientTeam(client) != 2) 
	{ 
		CPrintToChat(client, "{olive}Меню t1 оружия {default}доступно только команде {blue}выживших{default}."); 
		return Plugin_Handled; 
	} 

	if(numt1total >= GetConVarInt(cvar_maxt1total))  
	{ 
		CPrintToChat(client, "Достигнут лимит из {olive}%i {default}ед. t1 оружия для этой карты!", GetConVarInt(cvar_maxt1total)); 
		return Plugin_Handled; 
	} 

	if(numt1client[client] >= GetConVarInt(cvar_maxt1client))  
	{ 
		CPrintToChat(client, "Вы достигли своего лимита из {olive}%i {default}ед. t1 оружия для этой карты!", GetConVarInt(cvar_maxt1client)); 
		return Plugin_Handled; 
	}  

	if(startstatus) 
	{
	  CPrintToChat(client, "%t", "Left a saferoom announce for gun"); 
	  return Plugin_Handled;  
	}

	GiveChrome(client);

	return Plugin_Handled; 
}

public Action:GPump(client,args) 
{ 
	if(!client || !IsClientInGame(client))  
		return Plugin_Handled; 

	if(GetClientTeam(client) != 2) 
	{ 
		CPrintToChat(client, "{olive}Меню t1 оружия {default}доступно только команде {blue}выживших{default}."); 
		return Plugin_Handled; 
	} 

	if(numt1total >= GetConVarInt(cvar_maxt1total))  
	{ 
		CPrintToChat(client, "Достигнут лимит из {olive}%i {default}ед. t1 оружия для этой карты!", GetConVarInt(cvar_maxt1total)); 
		return Plugin_Handled; 
	} 

	if(numt1client[client] >= GetConVarInt(cvar_maxt1client))  
	{ 
		CPrintToChat(client, "Вы достигли своего лимита из {olive}%i {default}ед. t1 оружия для этой карты!", GetConVarInt(cvar_maxt1client)); 
		return Plugin_Handled; 
	}

	if(startstatus) 
	{
	  CPrintToChat(client, "%t", "Left a saferoom announce for gun"); 
	  return Plugin_Handled;  
	}

	GivePump(client);

	return Plugin_Handled; 
} 

public Action:GUZI(client,args) 
{ 
	if(!client || !IsClientInGame(client))  
		return Plugin_Handled; 

	if(GetClientTeam(client) != 2) 
	{ 
		CPrintToChat(client, "{olive}Меню t1 оружия {default}доступно только команде {blue}выживших{default}."); 
		return Plugin_Handled; 
	} 

	if(numt1total >= GetConVarInt(cvar_maxt1total))  
	{ 
		CPrintToChat(client, "Достигнут лимит из {olive}%i {default}ед. t1 оружия для этой карты!", GetConVarInt(cvar_maxt1total)); 
		return Plugin_Handled; 
	} 

	if(numt1client[client] >= GetConVarInt(cvar_maxt1client))  
	{ 
		CPrintToChat(client, "Вы достигли своего лимита из {olive}%i {default}ед. t1 оружия для этой карты!", GetConVarInt(cvar_maxt1client)); 
		return Plugin_Handled; 
	} 

	if(startstatus) 
	{
	  CPrintToChat(client, "%t", "Left a saferoom announce for gun"); 
	  return Plugin_Handled;  
	}

	GiveUZI(client);

	return Plugin_Handled; 
} 

public Action:GSMG(client,args) 
{ 
	if(!client || !IsClientInGame(client))  
		return Plugin_Handled; 

	if(GetClientTeam(client) != 2) 
	{ 
		CPrintToChat(client, "{olive}Меню t1 оружия {default}доступно только команде {blue}выживших{default}."); 
		return Plugin_Handled; 
	} 

	if(numt1total >= GetConVarInt(cvar_maxt1total))  
	{ 
		CPrintToChat(client, "Достигнут лимит из {olive}%i {default}ед. t1 оружия для этой карты!", GetConVarInt(cvar_maxt1total)); 
		return Plugin_Handled; 
	} 

	if(numt1client[client] >= GetConVarInt(cvar_maxt1client))  
	{ 
		CPrintToChat(client, "Вы достигли своего лимита из {olive}%i {default}ед. t1 оружия для этой карты!", GetConVarInt(cvar_maxt1client)); 
		return Plugin_Handled; 
	}   

	if(startstatus) 
	{
	  CPrintToChat(client, "%t", "Left a saferoom announce for gun"); 
	  return Plugin_Handled;  
	}

	GiveSMG(client);

	return Plugin_Handled; 
} 

public Action:GAxe(client,args) 
{ 
	if(!client || !IsClientInGame(client))  
		return Plugin_Handled; 

	if(GetClientTeam(client) != 2) 
	{ 
		CPrintToChat(client, "{olive}Меню рукопашного оружия {default}доступно только команде {blue}выживших{default}."); 
		return Plugin_Handled; 
	} 

	if(numweaponstotal >= GetConVarInt(cvar_maxweaponstotal))  
	{ 
		CPrintToChat(client, "Достигнут лимит из {olive}%i {default}ед. рукопашного оружия для этой карты!", GetConVarInt(cvar_maxweaponstotal)); 
		return Plugin_Handled; 
	} 

	if(numweaponsclient[client] >= GetConVarInt(cvar_maxweaponsclient))  
	{ 
		CPrintToChat(client, "Вы достигли своего лимита из {olive}%i {default}ед. для этой карты!", GetConVarInt(cvar_maxweaponsclient)); 
		return Plugin_Handled; 
	}  

	if(startstatus) 
	{
	  CPrintToChat(client, "%t", "Left a saferoom announce for melee"); 
	  return Plugin_Handled;  
	}  

	GiveAxe(client);

	return Plugin_Handled; 
} 

public Action:GKatana(client,args) 
{ 
	//new max_completion = GetMaxSurvivorCompletion(client);
	if(!client || !IsClientInGame(client))  
		return Plugin_Handled; 

	if(GetClientTeam(client) != 2) 
	{ 
		CPrintToChat(client, "{olive}Меню рукопашного оружия {default}доступно только команде {blue}выживших{default}."); 
		return Plugin_Handled; 
	} 

	if(numweaponstotal >= GetConVarInt(cvar_maxweaponstotal))  
	{ 
		CPrintToChat(client, "Достигнут лимит из {olive}%i {default}ед. рукопашного оружия для этой карты!", GetConVarInt(cvar_maxweaponstotal)); 
		return Plugin_Handled; 
	} 

	if(numweaponsclient[client] >= GetConVarInt(cvar_maxweaponsclient))  
	{ 
		CPrintToChat(client, "Вы достигли своего лимита из {olive}%i {default}ед. для этой карты!", GetConVarInt(cvar_maxweaponsclient)); 
		return Plugin_Handled; 
	}   

	if(startstatus) 
	{
	  CPrintToChat(client, "%t", "Left a saferoom announce for melee"); 
	  return Plugin_Handled;  
	}

	GiveKatana(client);

	return Plugin_Handled; 
} 

public Action:GMachete(client,args) 
{ 
	if(!client || !IsClientInGame(client))  
		return Plugin_Handled; 

	if(GetClientTeam(client) != 2) 
	{ 
		CPrintToChat(client, "{olive}Меню рукопашного оружия {default}доступно только команде {blue}выживших{default}."); 
		return Plugin_Handled; 
	} 

	if(numweaponstotal >= GetConVarInt(cvar_maxweaponstotal))  
	{ 
		CPrintToChat(client, "Достигнут лимит из {olive}%i {default}ед. рукопашного оружия для этой карты!", GetConVarInt(cvar_maxweaponstotal)); 
		return Plugin_Handled; 
	} 

	if(numweaponsclient[client] >= GetConVarInt(cvar_maxweaponsclient))  
	{ 
		CPrintToChat(client, "Вы достигли своего лимита из {olive}%i {default}ед. для этой карты!", GetConVarInt(cvar_maxweaponsclient)); 
		return Plugin_Handled; 
	}   

	if(startstatus) 
	{
	  CPrintToChat(client, "%t", "Left a saferoom announce for melee"); 
	  return Plugin_Handled;  
	}

	GiveMachete(client);

	return Plugin_Handled; 
} 
//----------------------------------------------GIVE CUSTOM WEAPONS-----------------------------------------------------------------------------

public Action:Melee(clientId) 
{ 
	new Handle:menu = CreateMenu(MeleeMenuHandler); 
	SetMenuTitle(menu, "Melee Weapons Menu"); 
	AddMenuItem(menu, "option1", "Бейсбольная бита"); 
	AddMenuItem(menu, "option2", "Монтировка"); 
	AddMenuItem(menu, "option3", "Бита для крикета"); 
	AddMenuItem(menu, "option4", "Электрогитара"); 
	AddMenuItem(menu, "option5", "Топор"); 
	AddMenuItem(menu, "option6", "Сковородка"); 
	AddMenuItem(menu, "option7", "Клюшка для гольфа"); 
	AddMenuItem(menu, "option8", "Катана"); 
	AddMenuItem(menu, "option9", "Мачете");
	AddMenuItem(menu, "option10", "Огнестрельное оружие");  
	SetMenuExitButton(menu, true); 
	DisplayMenu(menu, clientId, MENU_TIME_FOREVER); 

	return Plugin_Handled; 
} 

public Action:Weapons(clientId) 
{ 
	new Handle:menu = CreateMenu(WeaponsMenuHandler); 
	SetMenuTitle(menu, "Weapons Menu"); 
	AddMenuItem(menu, "option1", "Помповый дробовик"); 
	AddMenuItem(menu, "option2", "Хромированный дробовик"); 
	AddMenuItem(menu, "option3", "УЗИ"); 
	AddMenuItem(menu, "option4", "УЗИ с глушителем");
	AddMenuItem(menu, "option5", "Рукопашное оружие"); 
	SetMenuExitButton(menu, true); 
	DisplayMenu(menu, clientId, MENU_TIME_FOREVER); 

	return Plugin_Handled; 
} 

public Action:AnnounceMelee(Handle:timer, any:client)
{
	if(advertising == 3)
	{
		//CPrintToChatAll("Если Вы хотите получить {olive}рукопашное оружие{default}, наберите в чат команду {olive}!melee{default} или {olive}/melee{default}");
		//PrintHintTextToAll("Если Вы хотите получить рукопашное оружие, наберите команду !melee или /melee в чат");
	}
	else if(advertising == 2)
	{
		//PrintHintTextToAll("Если Вы хотите получить рукопашное оружие, наберите команду !melee или /melee в чат");
	}
	else if(advertising == 1)
	{
		//CPrintToChatAll("Если Вы хотите получить {olive}рукопашное оружие{default}, наберите в чат команду {olive}!melee{default} или {olive}/melee{default}");
	}
}

public MeleeMenuHandler(Handle:menu, MenuAction:action, client, itemNum) 
{ 
	//Strip the CHEAT flag off of the "give" command 
	new flags = GetCommandFlags("give"); 
	SetCommandFlags("give", flags & ~FCVAR_CHEAT); 

	if ( action == MenuAction_Select ) { 

		switch (itemNum) 
		{ 
			case 0: //Baseball Bat 
			{ 
				//Give the player a Baseball Bat 
				FakeClientCommand(client, "give baseball_bat"); 
			} 
			case 1: //Crowbar 
			{ 
				//Give the player a Crowbar 
				FakeClientCommand(client, "give crowbar"); 
			} 
			case 2: //Cricket Bat 
			{ 
				//Give the player a Cricket Bat 
				FakeClientCommand(client, "give cricket_bat"); 
			} 
			case 3: //Electric Guitar 
			{ 
				//Give the player a Electric Guitar 
				FakeClientCommand(client, "give electric_guitar"); 
			} 
			case 4: //Fire Axe 
			{ 
				//Give the player a Fire Axe 
				FakeClientCommand(client, "give fireaxe"); 
			} 
			case 5: //Frying Pan 
			{ 
				//Give the player a Frying Pan 
				FakeClientCommand(client, "give frying_pan"); 
			} 
			case 6: //Golf Club 
			{ 
				//Give the player a Golf Club 
				FakeClientCommand(client, "give golfclub"); 
			} 
			case 7: //Katana 
			{ 
				//Give the player a Katana 
				FakeClientCommand(client, "give katana"); 
			} 
			case 8: //Machete 
			{ 
				//Give the player a Machete 
				FakeClientCommand(client, "give machete"); 
			} 
			case 9: //t1 Guns 
			{ 
				//Open a Weapons Menu
				Weapons(client); 
			} 
		} 
		numweaponstotal++; 
		numweaponsclient[client]++;
	}

	//Add the CHEAT flag back to "give" command 
	SetCommandFlags("give", flags|FCVAR_CHEAT);
}

public WeaponsMenuHandler(Handle:menu, MenuAction:action, client, itemNum) 
{ 
	//Strip the CHEAT flag off of the "give" command 
	new flags = GetCommandFlags("give"); 
	SetCommandFlags("give", flags & ~FCVAR_CHEAT); 

	if ( action == MenuAction_Select ) { 

		switch (itemNum) 
		{ 
			case 0: //Pump Shotgun 
			{ 
				//Give the player a pumpshotgun
				FakeClientCommand(client, "give pumpshotgun"); 
			} 
			case 1: //Chrome Shotgun
			{ 
				//Give the player a Chrome Shotgun 
				FakeClientCommand(client, "give shotgun_chrome"); 
			} 
			case 2: //UZI 
			{ 
				//Give the player a UZI 
				FakeClientCommand(client, "give smg"); 
			} 
			case 3: //Silenced SMG 
			{ 
				//Give the player a Silenced SMG
				FakeClientCommand(client, "give smg_silenced"); 
			} 
			case 4: //t1 Guns 
			{ 
				//Open a Melee Menu
				Melee(client); 
			} 
		} 
		numt1total++; 
		numt1client[client]++; 
	} 

	//Add the CHEAT flag back to "give" command 
	SetCommandFlags("give", flags|FCVAR_CHEAT); 
} 

public GiveChrome(client) 
{ 
	//Strip the CHEAT flag off of the "give" command 
	new flags = GetCommandFlags("give"); 
	SetCommandFlags("give", flags & ~FCVAR_CHEAT); 

	//Give the player a Chrome Shotgun 
	FakeClientCommand(client, "give shotgun_chrome");
	numt1total++; 
	numt1client[client]++; 

	//Add the CHEAT flag back to "give" command 
	SetCommandFlags("give", flags|FCVAR_CHEAT); 
}  

public GivePump(client) 
{ 
	//Strip the CHEAT flag off of the "give" command 
	new flags = GetCommandFlags("give"); 
	SetCommandFlags("give", flags & ~FCVAR_CHEAT); 

	//Give the player a Chrome Shotgun 
	FakeClientCommand(client, "give pumpshotgun");
	numt1total++; 
	numt1client[client]++; 

	//Add the CHEAT flag back to "give" command 
	SetCommandFlags("give", flags|FCVAR_CHEAT); 
} 

public GiveUZI(client) 
{ 
	//Strip the CHEAT flag off of the "give" command 
	new flags = GetCommandFlags("give"); 
	SetCommandFlags("give", flags & ~FCVAR_CHEAT); 

	//Give the player a Chrome Shotgun 
	FakeClientCommand(client, "give smg");
	numt1total++; 
	numt1client[client]++; 

	//Add the CHEAT flag back to "give" command 
	SetCommandFlags("give", flags|FCVAR_CHEAT); 
} 

public GiveSMG(client) 
{ 
	//Strip the CHEAT flag off of the "give" command 
	new flags = GetCommandFlags("give"); 
	SetCommandFlags("give", flags & ~FCVAR_CHEAT); 

	//Give the player a Chrome Shotgun 
	FakeClientCommand(client, "give smg_silenced");
	numt1total++; 
	numt1client[client]++; 

	//Add the CHEAT flag back to "give" command 
	SetCommandFlags("give", flags|FCVAR_CHEAT); 
}

public GiveAxe(client) 
{ 
	//Strip the CHEAT flag off of the "give" command 
	new flags = GetCommandFlags("give"); 
	SetCommandFlags("give", flags & ~FCVAR_CHEAT); 

	//Give the player a Chrome Shotgun 
	FakeClientCommand(client, "give fireaxe");
	numweaponstotal++; 
	numweaponsclient[client]++; 

	//Add the CHEAT flag back to "give" command 
	SetCommandFlags("give", flags|FCVAR_CHEAT); 
}

public GiveKatana(client) 
{ 
	//Strip the CHEAT flag off of the "give" command 
	new flags = GetCommandFlags("give"); 
	SetCommandFlags("give", flags & ~FCVAR_CHEAT); 

	//Give the player a Chrome Shotgun 
	FakeClientCommand(client, "give katana");
	numweaponstotal++; 
	numweaponsclient[client]++; 

	//Add the CHEAT flag back to "give" command 
	SetCommandFlags("give", flags|FCVAR_CHEAT); 
}

public GiveMachete(client) 
{ 
	//Strip the CHEAT flag off of the "give" command 
	new flags = GetCommandFlags("give"); 
	SetCommandFlags("give", flags & ~FCVAR_CHEAT); 

	//Give the player a Chrome Shotgun 
	FakeClientCommand(client, "give machete");
	numweaponstotal++; 
	numweaponsclient[client]++; 

	//Add the CHEAT flag back to "give" command 
	SetCommandFlags("give", flags|FCVAR_CHEAT); 
}

stock GetMaxSurvivorCompletion(client)
{
	new Float:flow = 0.0;
	decl Float:tmp_flow;
	decl Float:origin[3];
	decl Address:pNavArea;
	
	GetClientAbsOrigin(client, origin);
	pNavArea = L4D2Direct_GetTerrorNavArea(origin);
	if (pNavArea != Address_Null)
		{
				tmp_flow = L4D2Direct_GetTerrorNavAreaFlow(pNavArea);
				flow = MAX(flow, tmp_flow);
		}
	return RoundToNearest(flow * 100 / L4D2Direct_GetMapMaxFlowDistance());
}
