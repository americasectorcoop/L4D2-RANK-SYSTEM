#define DMGCLAW true

ConVar MeleeDmg[10];
ConVar MeleeHeadshotDmg[9];

float DamageBody[10];
float DamageHeadshot[9];

ConVar hm_damage;
ConVar hm_damage_friendly;
ConVar hm_damage_showvalue;

#if DMGCLAW
ConVar hm_damage_hunter;
ConVar hm_damage_smoker;
ConVar hm_damage_boomer;
ConVar hm_damage_spitter;
ConVar hm_damage_jockey;
ConVar hm_damage_charger;
#endif
ConVar hm_damage_spit;
ConVar hm_damage_tank;
ConVar hm_damage_tankrock;
ConVar hm_damage_common;

ConVar hm_damage_type;
ConVar hm_damage_ak47;
ConVar hm_damage2_ak47;
ConVar hm_damage_awp;
ConVar hm_damage2_awp;
ConVar hm_damage_scout;
ConVar hm_damage2_scout;
ConVar hm_damage_m60;
ConVar hm_damage2_m60;
ConVar hm_damage_pipebomb;
ConVar hm_damage_spas;
ConVar hm_damage2_spas;
ConVar hm_damage_sg552;
ConVar hm_damage2_sg552;
ConVar hm_damage_smg;
ConVar hm_damage_smg_silenced;
ConVar hm_damage_m16;
ConVar hm_damage_pumpshotgun;
ConVar hm_damage_autoshotgun;
ConVar hm_damage_hunting_rifle;
ConVar hm_damage_rifle_desert;
ConVar hm_damage_shotgun_chrome;
ConVar hm_damage_smg_mp5;
ConVar hm_damage_sniper_military;
ConVar hm_damage2_sniper_military;
ConVar hm_damage_pistol;
ConVar hm_damage_pistol_magnum;


public void DamageOnPluginStart()
{
	hm_damage = CreateConVar("hm_damage", "1", "Enable/Disable damage", _FCVAR_PLUGIN_);
	hm_damage_friendly = CreateConVar("hm_damage_friendly", "0.3", "Enable/Disable ff damage", _FCVAR_PLUGIN_);
	hm_damage_showvalue = CreateConVar("hm_damage_showvalue", "0", "Enable/Disable show damage", _FCVAR_PLUGIN_);

#if DMGCLAW
	hm_damage_hunter = CreateConVar("hm_damage_hunter", "1.0", "Hunter additional damage", _FCVAR_PLUGIN_);
	hm_damage_smoker = CreateConVar("hm_damage_smoker", "1.2", "Smoker additional damage", _FCVAR_PLUGIN_);
	hm_damage_boomer = CreateConVar("hm_damage_boomer", "1.2", "Boomer additional damage", _FCVAR_PLUGIN_);
	hm_damage_spitter = CreateConVar("hm_damage_spitter", "1.2", "Spitter additional damage", _FCVAR_PLUGIN_);
	hm_damage_jockey = CreateConVar("hm_damage_jockey", "1.2", "Jockey additional damage", _FCVAR_PLUGIN_);
	hm_damage_charger = CreateConVar("hm_damage_charger", "1.2", "Charger additional damage", _FCVAR_PLUGIN_);
#endif
	hm_damage_spit = CreateConVar("hm_damage_spit", "7", "Spitter additional damage (spit)", _FCVAR_PLUGIN_);
	hm_damage_tank = CreateConVar("hm_damage_tank", "1.0", "Tank additional damage", _FCVAR_PLUGIN_);
	hm_damage_tankrock = CreateConVar("hm_damage_tankrock", "1.0", "Tank additional damage", _FCVAR_PLUGIN_);
	hm_damage_common = CreateConVar("hm_damage_common", "0", "Common additional damage", _FCVAR_PLUGIN_);
	
	hm_damage_type = CreateConVar("hm_damage_type", "2", "damage type", _FCVAR_PLUGIN_);
	hm_damage_ak47 = CreateConVar("hm_damage_ak47", "2523", "AK47 additional damage", _FCVAR_PLUGIN_);
	hm_damage2_ak47 = CreateConVar("hm_damage2_ak47", "140", "AK47 damage", _FCVAR_PLUGIN_);
	hm_damage_awp = CreateConVar("hm_damage_awp", "9486", "AWP additional damage", _FCVAR_PLUGIN_);
	hm_damage2_awp = CreateConVar("hm_damage2_awp", "700", "AWP damage", _FCVAR_PLUGIN_);
	hm_damage_scout = CreateConVar("hm_damage_scout", "4667", "Scout additional damage", _FCVAR_PLUGIN_);
	hm_damage2_scout = CreateConVar("hm_damage2_scout", "420", "Scout damage", _FCVAR_PLUGIN_);
	hm_damage_m60 = CreateConVar("hm_damage_m60", "1652", "M60 additional damage", _FCVAR_PLUGIN_);
	hm_damage2_m60 = CreateConVar("hm_damage2_m60", "85", "M60 damage", _FCVAR_PLUGIN_);
	hm_damage_spas = CreateConVar("hm_damage_spas", "3000", "SPAS additional damage", _FCVAR_PLUGIN_);
	hm_damage2_spas = CreateConVar("hm_damage2_spas", "60", "SPAS damage", _FCVAR_PLUGIN_);
	hm_damage_sg552 = CreateConVar("hm_damage_sg552", "1111", "SG552 additional damage", _FCVAR_PLUGIN_);
	hm_damage2_sg552 = CreateConVar("hm_damage2_sg552", "70", "SG552 damage", _FCVAR_PLUGIN_);
	hm_damage_smg = CreateConVar("hm_damage_smg", "0.6", "SMG additional damage", _FCVAR_PLUGIN_);
	hm_damage_smg_silenced = CreateConVar("hm_damage_smg_silenced", "0.6", "SMG_SILENCED additional damage", _FCVAR_PLUGIN_);
	hm_damage_m16 = CreateConVar("hm_damage_m16", "0.6", "M16 additional damage", _FCVAR_PLUGIN_);
	hm_damage_pumpshotgun = CreateConVar("hm_damage_pumpshotgun", "0.6", "PUMPSHOTGUN additional damage", _FCVAR_PLUGIN_);
	hm_damage_autoshotgun = CreateConVar("hm_damage_autoshotgun", "0.6", "AUTOSHOTGUN additional damage", _FCVAR_PLUGIN_);
	hm_damage_hunting_rifle = CreateConVar("hm_damage_hunting_rifle", "0.6", "HUNTING_RIFLE additional damage", _FCVAR_PLUGIN_);
	hm_damage_rifle_desert = CreateConVar("hm_damage_rifle_desert", "0.6", "RIFLE_DESERT additional damage", _FCVAR_PLUGIN_);
	hm_damage_shotgun_chrome = CreateConVar("hm_damage_shotgun_chrome", "0.6", "SHOTGUN_CHROME additional damage", _FCVAR_PLUGIN_);
	hm_damage_smg_mp5 = CreateConVar("hm_damage_smg_mp5", "0.6", "MP5 additional damage", _FCVAR_PLUGIN_);
	hm_damage_sniper_military = CreateConVar("hm_damage_sniper_military", "1055", "sniper military additional damage", _FCVAR_PLUGIN_);
	hm_damage2_sniper_military = CreateConVar("hm_damage2_sniper_military", "50", "sniper military damage", _FCVAR_PLUGIN_);
	hm_damage_pistol = CreateConVar("hm_damage_pistol", "0.6", "pistol additional damage", _FCVAR_PLUGIN_);
	hm_damage_pistol_magnum = CreateConVar("hm_damage_pistol_magnum", "1.0", "pistol magnum additional damage", _FCVAR_PLUGIN_);
	hm_damage_pipebomb = CreateConVar("hm_damage_pipebomb", "90", "Pipe bomb additional damage", _FCVAR_PLUGIN_);
	
	MeleeDmg[ZC_SMOKER] = CreateConVar("hm_meleefix_smoker", "1000.0", "Melee damage Smoker", _FCVAR_PLUGIN_);
	MeleeDmg[ZC_BOOMER] = CreateConVar("hm_meleefix_boomer", "1000.0", "Melee damage Boomer", _FCVAR_PLUGIN_);
	MeleeDmg[ZC_HUNTER] = CreateConVar("hm_meleefix_hunter", "1000.0", "Melee damage Hunter", _FCVAR_PLUGIN_);
	MeleeDmg[ZC_JOCKEY] = CreateConVar("hm_meleefix_jockey", "1000.0", "Melee damage Jockey", _FCVAR_PLUGIN_);
	MeleeDmg[ZC_SPITTER] = CreateConVar("hm_meleefix_spitter", "1000.0", "Melee damage Spitter", _FCVAR_PLUGIN_);
	MeleeDmg[ZC_CHARGER] = CreateConVar("hm_meleefix_charger", "1000.0", "Melee damage Charger", _FCVAR_PLUGIN_);
	MeleeDmg[ZC_WITCH] = CreateConVar("hm_meleefix_witch", "400.0", "Melee damage Witch", _FCVAR_PLUGIN_);
	MeleeDmg[ZC_TANK] = CreateConVar("hm_meleefix_tank", "1000.0", "Melee damage Tank", _FCVAR_PLUGIN_);
	
	MeleeHeadshotDmg[ZC_SMOKER] = CreateConVar("hm_meleefix_smoker_headshot", "2000.0", "Headshot Melee damage Smoker", _FCVAR_PLUGIN_);
	MeleeHeadshotDmg[ZC_BOOMER] = CreateConVar("hm_meleefix_boomer_headshot", "2000.0", "Headshot Melee damage Boomer", _FCVAR_PLUGIN_);
	MeleeHeadshotDmg[ZC_HUNTER] = CreateConVar("hm_meleefix_hunter_headshot", "2000.0", "Headshot Melee damage Hunter", _FCVAR_PLUGIN_);
	MeleeHeadshotDmg[ZC_JOCKEY] = CreateConVar("hm_meleefix_jockey_headshot", "2000.0", "Headshot Melee damage Jockey", _FCVAR_PLUGIN_);
	MeleeHeadshotDmg[ZC_SPITTER] = CreateConVar("hm_meleefix_spitter_headshot", "2000.0", "Headshot Melee damage Spitter", _FCVAR_PLUGIN_);
	MeleeHeadshotDmg[ZC_CHARGER] = CreateConVar("hm_meleefix_charger_headshot", "2000.0", "Headshot Melee damage Charger", _FCVAR_PLUGIN_);
	MeleeHeadshotDmg[ZC_TANK] = CreateConVar("hm_meleefix_tank_headshot", "1000.0", "Headshot Melee damage Tank", _FCVAR_PLUGIN_);
	
	HookConVarChange(MeleeDmg[ZC_SMOKER], ConVarChanged);
	HookConVarChange(MeleeDmg[ZC_BOOMER], ConVarChanged);
	HookConVarChange(MeleeDmg[ZC_HUNTER], ConVarChanged);
	HookConVarChange(MeleeDmg[ZC_JOCKEY], ConVarChanged);
	HookConVarChange(MeleeDmg[ZC_SPITTER], ConVarChanged);
	HookConVarChange(MeleeDmg[ZC_CHARGER], ConVarChanged);
	HookConVarChange(MeleeDmg[ZC_WITCH], ConVarChanged);
	HookConVarChange(MeleeDmg[ZC_TANK], ConVarChanged);
	HookConVarChange(MeleeHeadshotDmg[ZC_SMOKER], ConVarChanged);
	HookConVarChange(MeleeHeadshotDmg[ZC_BOOMER], ConVarChanged);
	HookConVarChange(MeleeHeadshotDmg[ZC_HUNTER], ConVarChanged);
	HookConVarChange(MeleeHeadshotDmg[ZC_JOCKEY], ConVarChanged);
	HookConVarChange(MeleeHeadshotDmg[ZC_SPITTER], ConVarChanged);
	HookConVarChange(MeleeHeadshotDmg[ZC_CHARGER], ConVarChanged);
	HookConVarChange(MeleeHeadshotDmg[ZC_TANK], ConVarChanged);
	
	HookEvent("player_hurt", Event_DPlayerHurt, EventHookMode_Pre);
	
	HookEvent("witch_spawn", OnWitchSpawn_Event);
	HookEvent("witch_killed", OnWitchKilled_Event);
	
	ConVarsInit();
	
	for (int x = 1; x <= MaxClients ; x++)
	{
		if (ValidClient(x)) SDKHook(x, SDKHook_OnTakeDamage, OnTakeDamage);
	}
}

public void OnPluginEnd() // updated, thx Sheepdude
{
	for (int x = 1; x <= MaxClients ; x++)
	{
		if (ValidClient(x)) SDKUnhook(x, SDKHook_OnTakeDamage, OnTakeDamage);
	}
}

bool ValidClient(int ok)
{
	if(0 < ok <= MaxClients && IsClientConnected(ok) && IsClientInGame(ok)) return true;
	else return false;
}

public void ConVarChanged(Handle hVariable, const char[] strOldValue, const char[] strNewValue)
{
	ConVarsInit();
}

public void ConVarsInit()
{
	DamageBody[ZC_SMOKER] = MeleeDmg[ZC_SMOKER].FloatValue;
	DamageBody[ZC_BOOMER] = MeleeDmg[ZC_BOOMER].FloatValue;
	DamageBody[ZC_HUNTER] = MeleeDmg[ZC_HUNTER].FloatValue;
	DamageBody[ZC_JOCKEY] = MeleeDmg[ZC_JOCKEY].FloatValue;
	DamageBody[ZC_SPITTER] = MeleeDmg[ZC_SPITTER].FloatValue;
	DamageBody[ZC_CHARGER] = MeleeDmg[ZC_CHARGER].FloatValue;
	DamageBody[ZC_WITCH] = MeleeDmg[ZC_WITCH].FloatValue;
	DamageBody[ZC_TANK] = MeleeDmg[ZC_TANK].FloatValue;
	
	DamageHeadshot[ZC_SMOKER] = MeleeHeadshotDmg[ZC_SMOKER].FloatValue;
	DamageHeadshot[ZC_BOOMER] = MeleeHeadshotDmg[ZC_BOOMER].FloatValue;
	DamageHeadshot[ZC_HUNTER] = MeleeHeadshotDmg[ZC_HUNTER].FloatValue;
	DamageHeadshot[ZC_JOCKEY] = MeleeHeadshotDmg[ZC_JOCKEY].FloatValue;
	DamageHeadshot[ZC_SPITTER] = MeleeHeadshotDmg[ZC_SPITTER].FloatValue;
	DamageHeadshot[ZC_CHARGER] = MeleeHeadshotDmg[ZC_CHARGER].FloatValue;
	DamageHeadshot[ZC_TANK] = MeleeHeadshotDmg[ZC_TANK].FloatValue;
}

public void OnAllPluginsLoaded()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if(IsValidEntity(i))
		{
			SDKHook(i, SDKHook_TraceAttack, OnTraceAttack);
		}
	}
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_TraceAttack, OnTraceAttack);
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

void DMOnClientDisconnect(int client) {
	SDKUnhook(client, SDKHook_TraceAttack, OnTraceAttack);
	SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public Action OnWitchSpawn_Event(Event event, const char[] name, bool dontBroadcast)
{
	if (DamageBody[ZC_WITCH] == 0.0) return;

	int witch = event.GetInt("witchid");
	if (witch < 1 || !IsValidEntity(witch)){
		return;
	}

	SDKHook(witch, SDKHook_OnTakeDamage, OnWitchTakeDamage);
}

public Action OnWitchKilled_Event(Event event, const char[] name, bool dontBroadcast)
{
	if (DamageBody[ZC_WITCH] == 0.0) return;

	int witch = event.GetInt("witchid");
	if (witch < 1 || !IsValidEntity(witch)) return;

	SDKUnhook(witch, SDKHook_OnTakeDamage, OnWitchTakeDamage);
}

public Action OnWitchTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (!(damage > 0.0) || attacker < 1 || attacker > MaxClients || !IsClientInGame(attacker) || GetClientTeam(attacker) != TEAM_SURVIVORS) return Plugin_Continue;

	char clsname[64];
	GetEdictClassname(inflictor, clsname, 64);
	
	if (!StrEqual(clsname, "weapon_melee")) return Plugin_Continue;
	damage = DamageBody[ZC_WITCH];
	
	return Plugin_Changed;
}

public Action OnTraceAttack(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &ammotype, int hitbox, int hitgroup)
{
	if (damage == 0.0 || victim < 1 || victim > MaxClients || !IsClientInGame(victim) || GetClientTeam(victim) != TEAM_INFECTED || attacker < 1 || 
		attacker > MaxClients || !IsClientInGame(attacker) || GetClientTeam(attacker) != TEAM_SURVIVORS)
		return Plugin_Continue;

	char clsname[64];
	GetEdictClassname(inflictor, clsname, 64);
	
	if (!StrEqual(clsname, "weapon_melee")) return Plugin_Continue;

	int zClass = GetEntProp(victim, Prop_Send, "m_zombieClass");
	
	if (((zClass > 0) && (zClass < 7)) || (zClass == 8))
	{
		if (DamageBody[zClass] == 0.0) return Plugin_Continue;
		
		if (hitgroup == 1)
		{
			if (DamageHeadshot[zClass] == 0.0) return Plugin_Continue;
			
			damage = DamageHeadshot[zClass];
			return Plugin_Changed;
		}
		damage = DamageBody[zClass];
		
		return Plugin_Changed;
	}

	return Plugin_Continue;
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (hm_damage.IntValue != 1 || !victim) return Plugin_Continue;
	if (inflictor > MaxClients || attacker > MaxClients || !attacker || damage == 0.0) return Plugin_Continue;
	char Weapon[32];
	GetClientWeapon(attacker, Weapon, sizeof(Weapon));
	float original_damage = damage;
	if (damagetype == 128)
	{
	#if DMGCLAW
		if (StrEqual(Weapon, "weapon_boomer_claw")) damage *= hm_damage_boomer.FloatValue;
		else if (StrEqual(Weapon, "weapon_charger_claw")) damage *= hm_damage_charger.FloatValue;
		else if (StrEqual(Weapon, "weapon_hunter_claw")) damage *= hm_damage_hunter.FloatValue;
		else if (StrEqual(Weapon, "weapon_smoker_claw")) damage *= hm_damage_smoker.FloatValue;
		else if (StrEqual(Weapon, "weapon_spitter_claw")) damage *= hm_damage_spitter.FloatValue;
		else if (StrEqual(Weapon, "weapon_jockey_claw")) damage *= hm_damage_jockey.FloatValue;
		else if (StrEqual(Weapon, "weapon_tank_claw")) damage *= hm_damage_tank.FloatValue;
		else if (StrEqual(Weapon, "weapon_tank_rock")) damage *= hm_damage_tankrock.FloatValue;
	#else
		if (StrEqual(Weapon, "weapon_tank_claw")) damage *= hm_damage_tank.FloatValue;
		else if (StrEqual(Weapon, "weapon_tank_rock")) damage *= hm_damage_tankrock.FloatValue;
	#endif
	}
	else
	{
		if (hm_damage_type.IntValue == 1)
		{
			if (StrEqual(Weapon, "weapon_rifle_ak47")) damage *= (hm_damage_ak47.FloatValue / 1000);
			else if (StrEqual(Weapon, "weapon_sniper_awp")) damage *= (hm_damage_awp.FloatValue / 1000);
			else if (StrEqual(Weapon, "weapon_sniper_scout")) damage *= (hm_damage_scout.FloatValue / 1000);
			else if (StrEqual(Weapon, "weapon_rifle_m60")) damage *= (hm_damage_m60.FloatValue / 1000);
			else if (StrEqual(Weapon, "weapon_shotgun_spas")) damage *= (hm_damage_spas.FloatValue / 1000);
			else if (StrEqual(Weapon, "weapon_rifle_sg552")) damage *= (hm_damage_sg552.FloatValue / 1000);
			else if (StrEqual(Weapon, "weapon_smg")) damage *= hm_damage_smg.FloatValue;
			else if (StrEqual(Weapon, "weapon_smg_silenced")) damage *= hm_damage_smg_silenced.FloatValue;
			else if (StrEqual(Weapon, "weapon_rifle")) damage *= hm_damage_m16.FloatValue;
			else if (StrEqual(Weapon, "weapon_pumpshotgun")) damage *= hm_damage_pumpshotgun.FloatValue;
			else if (StrEqual(Weapon, "weapon_autoshotgun")) damage *= hm_damage_autoshotgun.FloatValue;
			else if (StrEqual(Weapon, "weapon_hunting_rifle")) damage *= hm_damage_hunting_rifle.FloatValue;
			else if (StrEqual(Weapon, "weapon_rifle_desert")) damage *= hm_damage_rifle_desert.FloatValue;
			else if (StrEqual(Weapon, "weapon_shotgun_chrome")) damage *= hm_damage_shotgun_chrome.FloatValue;
			else if (StrEqual(Weapon, "weapon_smg_mp5")) damage *= hm_damage_smg_mp5.FloatValue;
			else if (StrEqual(Weapon, "weapon_sniper_military")) damage *= (hm_damage_sniper_military.FloatValue / 1000);
			else if (StrEqual(Weapon, "weapon_pistol")) damage *= hm_damage_pistol.FloatValue;
			else if (StrEqual(Weapon, "weapon_pistol_magnum")) damage *= hm_damage_pistol_magnum.FloatValue;
		}
		else if (hm_damage_type.IntValue == 2)
		{
			if (StrEqual(Weapon, "weapon_rifle_ak47")) 
			{
				damage = hm_damage2_ak47.FloatValue;
			}
			else if (StrEqual(Weapon, "weapon_sniper_awp"))
			{
				damage = hm_damage2_awp.FloatValue;
			}
			else if (StrEqual(Weapon, "weapon_sniper_scout"))
			{
				damage = hm_damage2_scout.FloatValue;
			}
			else if (StrEqual(Weapon, "weapon_rifle_m60"))
			{
				damage = hm_damage2_m60.FloatValue;
			}
			else if (StrEqual(Weapon, "weapon_shotgun_spas"))
			{
				damage = hm_damage2_spas.FloatValue;
			}
			else if (StrEqual(Weapon, "weapon_rifle_sg552"))
			{
				damage = hm_damage2_sg552.FloatValue;
			}
			else if (StrEqual(Weapon, "weapon_smg"))
			{
				damage *= hm_damage_smg.FloatValue;
			}
			else if (StrEqual(Weapon, "weapon_smg_silenced"))
			{
				damage *= hm_damage_smg_silenced.FloatValue;
			}
			else if (StrEqual(Weapon, "weapon_rifle"))
			{
				damage *= hm_damage_m16.FloatValue;
			}
			else if (StrEqual(Weapon, "weapon_pumpshotgun"))
			{
				damage *= hm_damage_pumpshotgun.FloatValue;
			}
			else if (StrEqual(Weapon, "weapon_autoshotgun"))
			{
				damage *= hm_damage_autoshotgun.FloatValue;
			}
			else if (StrEqual(Weapon, "weapon_hunting_rifle"))
			{
				damage *= hm_damage_hunting_rifle.FloatValue;
			}
			else if (StrEqual(Weapon, "weapon_rifle_desert"))
			{
				damage *= hm_damage_rifle_desert.FloatValue;
			}
			else if (StrEqual(Weapon, "weapon_shotgun_chrome"))
			{
				damage *= hm_damage_shotgun_chrome.FloatValue;
			}
			else if (StrEqual(Weapon, "weapon_smg_mp5"))
			{
				damage *= hm_damage_smg_mp5.FloatValue;
			}
			else if (StrEqual(Weapon, "weapon_sniper_military"))
			{
				damage = hm_damage2_sniper_military.FloatValue;
			}
			else if (StrEqual(Weapon, "weapon_pistol"))
			{
				damage *= hm_damage_pistol.FloatValue;
			}
			else if (StrEqual(Weapon, "weapon_pistol_magnum"))
			{
				damage *= hm_damage_pistol_magnum.FloatValue;
			}
		}
	}
	if (original_damage != damage) {
		if (GetClientTeam(victim) == TEAM_SURVIVORS && GetClientTeam(attacker) == TEAM_SURVIVORS) {
			if (Players[attacker].playtime < 43200) {
				damage = 2.0;
			} else {
				if(!bIsPlayerIncapped(victim)) {
					damage *= hm_damage_friendly.FloatValue;
					int health = GetHealth(victim);
					if (health > 1) {
						if (damage >= health * 1.0)
						{
							damage = (health * 1.0 - 1);
						}
					}
				}
				else
				{
					damage *= (hm_damage_friendly.FloatValue * 0.5);
				}	
			}
		}
		return Plugin_Changed;
	}
	return Plugin_Continue;
}

public Action Event_DPlayerHurt(Event event, const char[] name, bool dontBroadcast)
{
	if (!hm_damage.BoolValue) return Plugin_Continue;
	
	int enemy = GetClientOfUserId(event.GetInt("attacker"));
	int target = GetClientOfUserId(event.GetInt("userid"));
	int dmg_health = event.GetInt("dmg_health");
	int damagetype = event.GetInt("type");
	
	if (hm_damage.IntValue < 2 && damagetype == 128 || target == 0 || !dmg_health) return Plugin_Continue;
	
	char weapon[16];
	event.GetString("weapon", weapon, sizeof(weapon));
	int hardmod_damage = 0;
	
	if (StrEqual(weapon, "insect_swarm", false)) hardmod_damage = hm_damage_spit.IntValue;
	else if (StrEqual(weapon, "pipe_bomb", false)) hardmod_damage = hm_damage_pipebomb.IntValue;
	else if (StrEqual(weapon, "", false)) hardmod_damage = hm_damage_common.IntValue;
	else if (hm_damage.IntValue > 1 && enemy)
	{
		if (damagetype == 128)
		{
		#if DMGCLAW
			if (StrEqual(weapon, "boomer_claw")) hardmod_damage = hm_damage_boomer.IntValue;
			else if (StrEqual(weapon, "charger_claw")) hardmod_damage = hm_damage_charger.IntValue;
			else if (StrEqual(weapon, "hunter_claw")) hardmod_damage = hm_damage_hunter.IntValue;
			else if (StrEqual(weapon, "smoker_claw")) hardmod_damage = hm_damage_smoker.IntValue;
			else if (StrEqual(weapon, "spitter_claw")) hardmod_damage = hm_damage_spitter.IntValue;
			else if (StrEqual(weapon, "jockey_claw")) hardmod_damage = hm_damage_jockey.IntValue;
			else if (StrEqual(weapon, "tank_claw")) hardmod_damage = hm_damage_tank.IntValue;
			else if (StrEqual(weapon, "tank_rock")) hardmod_damage = hm_damage_tankrock.IntValue;
		#else
			if (StrEqual(weapon, "tank_claw")) hardmod_damage = hm_damage_tank.IntValue;
			else if (StrEqual(weapon, "tank_rock")) hardmod_damage = hm_damage_tankrock.IntValue;
		#endif
		}
		else
		{
			if (StrEqual(weapon, "rifle_ak47")) hardmod_damage = hm_damage_ak47.IntValue;
			else if (StrEqual(weapon, "sniper_awp")) hardmod_damage = hm_damage_awp.IntValue;
			else if (StrEqual(weapon, "sniper_scout")) hardmod_damage = hm_damage_scout.IntValue;
			else if (StrEqual(weapon, "rifle_m60")) hardmod_damage = hm_damage_m60.IntValue;
			else if (StrEqual(weapon, "shotgun_spas")) hardmod_damage = hm_damage_spas.IntValue;
			else if (StrEqual(weapon, "rifle_sg552")) hardmod_damage = hm_damage_sg552.IntValue;
			else if (StrEqual(weapon, "smg")) hardmod_damage = hm_damage_smg.IntValue;
			else if (StrEqual(weapon, "smg_silenced")) hardmod_damage = hm_damage_smg_silenced.IntValue;
			else if (StrEqual(weapon, "rifle")) hardmod_damage = hm_damage_m16.IntValue;
			else if (StrEqual(weapon, "pumpshotgun")) hardmod_damage = hm_damage_pumpshotgun.IntValue;
			else if (StrEqual(weapon, "autoshotgun")) hardmod_damage = hm_damage_autoshotgun.IntValue;
			else if (StrEqual(weapon, "hunting_rifle")) hardmod_damage = hm_damage_hunting_rifle.IntValue;
			else if (StrEqual(weapon, "rifle_desert")) hardmod_damage = hm_damage_rifle_desert.IntValue;
			else if (StrEqual(weapon, "shotgun_chrome")) hardmod_damage = hm_damage_shotgun_chrome.IntValue;
			else if (StrEqual(weapon, "smg_mp5")) hardmod_damage = hm_damage_smg_mp5.IntValue;
			else if (StrEqual(weapon, "sniper_military")) hardmod_damage = hm_damage_sniper_military.IntValue;
			else if (StrEqual(weapon, "pistol")) hardmod_damage = hm_damage_pistol.IntValue;
			else if (StrEqual(weapon, "pistol_magnum")) hardmod_damage = hm_damage_pistol_magnum.IntValue;
		}
	}
	
	if (hardmod_damage > 0)
	{
		if (enemy && GetClientTeam(target) == TEAM_SURVIVORS && GetClientTeam(enemy) == TEAM_SURVIVORS)
		{
			hardmod_damage = RoundToNearest(hardmod_damage * hm_damage_friendly.FloatValue);
		}
		dmg_health += hardmod_damage;
		SetEventInt(event, "dmg_health", dmg_health);
		DamageTarget(target, hardmod_damage);
	}
	
	if (hm_damage_showvalue.IntValue > 0)
	{
		if (IsValidClient(enemy) && !IsFakeClient(enemy))
		{
			PrintHintText(enemy, "%d", dmg_health);
			PrintToChat(enemy, "\x05(Damage) \x04%d", dmg_health);
		}
		else if (IsValidClient(target) && !IsFakeClient(target))
		{
			PrintHintText(target, "-%d", dmg_health);
		}
	}
	return Plugin_Continue;	
}

public void DamageTarget(int client, int damage)
{
	if (GetHealth(client) < 1) return;
	int HP = GetHealth(client);
	if (HP > damage) SetEntityHealth(client, HP - damage);
	else
	{
		if (HP > 1)
		{
			damage -= HP - 1;
			SetEntityHealth(client, 1);
		}
		
		int TempHP = GetClientTempHealth(client);
		
		if (TempHP >= damage) SetTempHealth(client, TempHP - damage);
		else
		{
			if (GetClientTeam(client) == TEAM_SURVIVORS && !IsGoingToDie(client)) IncapTarget(client);
			else
			{
				if (hm_damage.IntValue > 2) {
					DamageEffect(client, 5.0);
				} else {
					SetTempHealth(client, 0);
				}
			}
		}
	}
}

public void IncapTarget(int target)
{
	if(IsValidEntity(target))
	{
		int iDmgEntity = CreateEntityByName("point_hurt");
		SetEntityHealth(target, 1);
		DispatchKeyValue(target, "targetname", "bm_target");
		DispatchKeyValue(iDmgEntity, "DamageTarget", "bm_target");
		DispatchKeyValue(iDmgEntity, "Damage", "100");
		DispatchKeyValue(iDmgEntity, "DamageType", "0");
		DispatchSpawn(iDmgEntity);
		AcceptEntityInput(iDmgEntity, "Hurt", target);
		DispatchKeyValue(target, "targetname", "bm_targetoff");
		RemoveEdict(iDmgEntity);
	}
}

void DamageEffect(int target, float damage) // (C) http://forums.alliedmods.net/showthread.php?p=1229450
{
	char tName[20];
	Format(tName, 20, "target%d", target);
	int pointHurt = CreateEntityByName("point_hurt");
	DispatchKeyValue(target, "targetname", tName);
	DispatchKeyValueFloat(pointHurt, "Damage", damage);
	DispatchKeyValue(pointHurt, "DamageTarget", tName);
	DispatchKeyValue(pointHurt, "DamageType", "65536");
	DispatchSpawn(pointHurt);
	AcceptEntityInput(pointHurt, "Hurt");
	AcceptEntityInput(pointHurt, "Kill");
}

public int GetHealth(int client)
{
	return GetEntProp(client, Prop_Send, "m_iHealth");
}

public int GetClientTempHealth(int client)
{
	if (!client || !IsValidEntity(client) || !IsClientInGame(client) || !IsPlayerAlive(client) || IsClientObserver(client) || GetClientTeam(client) != TEAM_SURVIVORS) return -1;
	
	float buffer = GetEntPropFloat(client, Prop_Send, "m_healthBuffer");
	float TempHealth;
	
	if (buffer <= 0.0)
	{
		TempHealth = 0.0;
	}
	else
	{
		float difference = GetGameTime() - GetEntPropFloat(client, Prop_Send, "m_healthBufferTime");
		float decay = FindConVar("pain_pills_decay_rate").FloatValue;
		float constant = 1.0/decay;
		TempHealth = buffer - (difference / constant);
	}
	
	if (TempHealth < 0.0)
	{
		TempHealth = 0.0;
	}
	
	return RoundToFloor(TempHealth);
}

public void SetTempHealth(int client, int hp)
{
	SetEntPropFloat(client, Prop_Send, "m_healthBufferTime", GetGameTime());
	float newOverheal = hp * 1.0;
	SetEntPropFloat(client, Prop_Send, "m_healthBuffer", newOverheal);
}


bool IsGoingToDie(int client)
{
	return (GetEntProp(client, Prop_Send, "m_currentReviveCount") == FindConVar("survivor_max_incapacitated_count").IntValue);
}