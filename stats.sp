/*
	Stats for l4d2
	Copyright (C) 2015-2018 Alejandro Suárez (Aleexxx)

	This program is free software; you can redistribute it and/or
	modify it under the terms of the GNU General Public License
	as published by the Free Software Foundation; either version 2
	of the License, or (at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, write to the

	Free Software Foundation, Inc.
	51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
*/

#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <colors>
#include <data/zombieClass>
#include <data/teams>
#include <coop/skillsConstants>

#define DEBUG true

#if SOURCEMOD_V_MINOR < 7
 #error Old version sourcemod!
#endif

#define _FCVAR_PLUGIN_ 0

#define DAY "10/06/2018"
#define VERSION "5.0.0" 

#define WEBSITE_STATS "http://americasectorcoop.org/stats" 

#define ON_BAN_TIME 300 // Time on minutes
#define ON_BAN_REASON "Friendly Fire"
#define ON_BAN_MESSAGE "You has been bannned by \"Friendly fire\".\nIf you think was an error please talk with us via discord."

#define DB_CONF_NAME "stats"

#define TROPHY false

#define MAX_LINE_WIDTH 30
#define PROFILE_ID_SIZE 18

// Numero de zombies asesinados para premiar dar puntos
#define KILL_COUNT_INFECTED 15
// Numero de puntos a necesitar antes de lanzar una granada
#define POINTS_TO_LAUNCH_GRENADE 5000
// Numero de fraggers por imprimir
#define MAX_FRAGGERS 3
// Numero de puntos negativos para patear a un jugador 
#define POINTS_NEGATIVE_FOR_KICK_PLAYERS -2000

#define VOMIT_TK_BLOCK_MIN 70
#define VOMIT_TK_BLOCK_MAX 240

// #define SOUND_MAPTIME_START "level/countdown.wav"
#define SOUND_MAPTIME_FINISH "level/bell_normal.wav"
#define SOUND_JOIN "ui/beepclear.wav" 




int g_iPlayerCounters[MAXPLAYERS + 1][MAX_LENGTH_SKILLS];
float g_playerAssistanceFactor[MAXPLAYERS + 1];
char g_playerSteamId[MAXPLAYERS + 1][MAX_LINE_WIDTH];


int g_iTankDamage[MAXPLAYERS + 1][MAXPLAYERS + 1];
int g_iTankHealth[MAXPLAYERS + 1];
char g_sTankName[MAXPLAYERS + 1][MAX_LINE_WIDTH];

bool g_bPlayerIgnore[MAXPLAYERS+1][MAXPLAYERS+1];

// int g_roundsMap = 1;
int g_iPillsGiven[4096];
int g_iAdrenalineGiven[4096];
int g_iStatsBalans = 0;
// int bonus = 0;

// Numero de jugadores registrados
int g_iRegisteredPlayers = 0;
int g_iFailedAttempts = 0;
int g_iTkBlockMin = 70;
int g_iTkBlockMax = 240;

float g_fRankSum = 0.0;
float g_fMapTimingStartTime = -1.0;

Database g_dbConnection = null;
Handle g_hJoinTimer[MAXPLAYERS+1];

bool g_pointsEnabled = true;
bool g_isPrint = false;
bool g_isRoundStarted = false;

ConVar hm_count_fails;
ConVar l4d2_rankmod_mode;
ConVar l4d2_rankmod_min;
ConVar l4d2_rankmod_max;
ConVar l4d2_rankmod_logarithm;
ConVar cvar_Hunter;
ConVar cvar_Smoker;
ConVar cvar_Boomer;
ConVar cvar_Spitter;
ConVar cvar_Jockey;
ConVar cvar_Charger;
ConVar cvar_Witch;
ConVar cvar_Tank;
ConVar SDifficultyMultiplier;
ConVar l4d2_difficulty_multiplier;

DBResultSet playerData;

#include <coop/stock>
#include <coop/autodifficulty>
#include <coop/damage>

public Plugin myinfo = {
	name = "Stats with autodifficulty for AMERICA SECTOR COOP",
	author = "Alejandro Suárez",
	description = "Rank System with autodifficulty for ASC",
	version = VERSION,
	url = "https://www.americasectorcoop.org"
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) {
	CreateNative("TYSTATS_GetPoints", Native_TYSTATS_GetPoints);
	CreateNative("TYSTATS_GetRank", Native_TYSTATS_GetRank);
	CreateNative("TYSTATS_GetPlayTime", Native_TYSTATS_GetPlayTime);
	return APLRes_Success;
}

public int Native_TYSTATS_GetPoints(Handle plugin, int numParams) {
	return g_iPlayerCounters[GetNativeCell(1)][PLAYER_POINTS];
}

public int Native_TYSTATS_GetRank(Handle plugin, int numParams) {
	return g_iPlayerCounters[GetNativeCell(1)][PLAYER_RANK];
}

public int Native_TYSTATS_GetPlayTime(Handle plugin, int numParams) {
	return g_iPlayerCounters[GetNativeCell(1)][PLAYER_PLAYTIME];
}

public void OnPluginStart() {
	LoadTranslations("common.phrases");
	LoadTranslations("tystats.phrases");

	vConnectDatabase();

	CoopAutoDiffOnPluginStart();
	DamageOnPluginStart();

	RegConsoleCmd("callvote", onVote);

	RegConsoleCmd("mut", cmdMute);
	RegConsoleCmd("sm_ignore_voice", cmdMute);
	RegConsoleCmd("sm_ignore", cmdMute);
	RegConsoleCmd("sm_iv", cmdMute);
	RegConsoleCmd("sm_mut", cmdMute);

	cvar_Hunter = CreateConVar("l4d2_tystats_hunter", "4", "Base score for killing a Hunter");
	cvar_Smoker = CreateConVar("l4d2_tystats_smoker", "4", "Base score for killing a Smoker");
	cvar_Boomer = CreateConVar("l4d2_tystats_boomer", "3", "Base score for killing a Boomer");
	cvar_Spitter = CreateConVar("l4d2_tystats_spitter", "5", "Base score for killing a Spitter");
	cvar_Jockey = CreateConVar("l4d2_tystats_jockey", "4", "Base score for killing a Jockey");
	cvar_Charger = CreateConVar("l4d2_tystats_charger", "6", "Base score for killing a Charger");
	cvar_Witch = CreateConVar("l4d2_tystats_witch", "7", "Base score for killing a Witch");
	cvar_Tank = CreateConVar("l4d2_tystats_tank", "10", "Base score for killing a Tank");

	// HookEvent("player_changename", EVENT_PLAYER_CHANGE_NAME);
	HookEvent("player_spawn", eventPlayerSpawn);
	HookEvent("witch_killed", eventWitchKilled);
	HookEvent("witch_harasser_set", eventWitchDisturb);

	HookEvent("player_death", eventPlayerDeath);
	HookEvent("player_incapacitated", eventPlayerIncap);
	HookEvent("player_hurt", eventPlayerHurt);
	HookEvent("round_start", eventRoundStart);
	HookEvent("heal_success", eventHealPlayer);
	HookEvent("defibrillator_used", eventDefigPlayer);
	HookEvent("revive_success", eventReviveSuccess);
	HookEvent("player_now_it", eventPlayerNowIt);
	HookEvent("survivor_rescued", eventSurvivorRescued);
	HookEvent("award_earned", eventAward);
	HookEvent("player_team", eventPlayerTeamPost, EventHookMode_Post);
	HookEvent("map_transition", eventMapTransition);
	HookEvent("finale_win", eventFinalWin);
	HookEvent("player_left_start_area", eventStartAreaPost, EventHookMode_Post);
	HookEvent("player_left_checkpoint", eventStartAreaPost, EventHookMode_Post);
	HookEvent("round_end", eventRoundEnd);
	HookEvent("molotov_thrown", eventMolotovThrown);
	HookEvent("melee_kill", eventMeleeKill);
	HookEvent("tank_spawn", eventTankSpawn);
	HookEvent("tank_killed", eventTankKilled);


	AddCommandListener(Command_Setinfo, "setinfo");

	RegConsoleCmd("sm_rank", cmdRank, "sm_rank <target>");
	RegConsoleCmd("sm_assist", cmdFactorTop, "sm_assist");
	RegConsoleCmd("sm_factortop", cmdFactorTop, "sm_factortop");
	RegConsoleCmd("sm_top", cmdTop);
	RegConsoleCmd("sm_nextrank", cmdNextRank);
	RegConsoleCmd("sm_points", cmdPoints);
	RegConsoleCmd("sm_playtime", cmdPlaytime);
	RegConsoleCmd("sm_vkick", cmdVoteKick);

	RegConsoleCmd("sm_factor", cmdFactor);
	RegConsoleCmd("sm_colors", cmdColors);
	RegConsoleCmd("sm_maptop", cmdMapTop);
	RegConsoleCmd("sm_ranksum", cmdRankSum);
	RegConsoleCmd("sm_frags", cmdFrags);

	RegConsoleCmd("say", onMessage);
	RegConsoleCmd("say_team", onMessage);

	RegAdminCmd("sm_updateplayers", cmdUpdatePlayers, ADMFLAG_ROOT, "Envia los puntos al servidor");
	RegAdminCmd("sm_points_on", cmdPointsOn, ADMFLAG_GENERIC, "Activa los puntos de la partida");
	RegAdminCmd("sm_points_off", cmdPointsOff, ADMFLAG_GENERIC, "Desactiva los puntos de la partida");

	RegAdminCmd("sm_givepoints", cmdGivePoints, ADMFLAG_ROOT, "sm_givepoints <target> [Score]");

	hm_count_fails = CreateConVar("hm_count_fails", "1", "");

	l4d2_rankmod_mode = CreateConVar("l4d2_rankmod_mode", "0", "");
	l4d2_rankmod_min = CreateConVar("l4d2_rankmod_min", "0.5", "");
	l4d2_rankmod_max = CreateConVar("l4d2_rankmod_max", "1.0", "");
	l4d2_rankmod_logarithm = CreateConVar("l4d2_rankmod_logarithm", "0.008", "");

	SDifficultyMultiplier = CreateConVar("l4d2_difficulty_stats", "1.0", "");
	l4d2_difficulty_multiplier = CreateConVar("l4d2_difficulty_multiplier", "1.2", "");

	// WE FORCE TO RUNNING MAP START EVENT WHEN PLUGIN IS LOADED/RELOADED
	CreateTimer(1.0, MapStart);
}

public Action cmdFrags(int client, int args) {
	printTotalFrags(client);
}

/**
 * Function for mute player
 * @param  client
 * @param  args 	: name of client
 * @return Plugin_Handled
 */
public Action cmdMute(int client, int args) {
	// Verificando que el cliente sea valido
	if (client != 0) {
		// Verificando si el cliente no inserto ningun argumento
		if (args == 0) {
			// Mostrando listas por defecto
			ShowPlayerListMute(client);
		} else {
			// Inicializando variables
			char arg[65];
			GetCmdArg(1, arg, sizeof(arg));
			char target_name[MAX_TARGET_LENGTH];
			int target_list[MAXPLAYERS], targets, target;
			bool tn_is_ml;
			
			if ((targets = ProcessTargetString(arg, client, target_list, MAXPLAYERS, 0, target_name, sizeof(target_name), tn_is_ml)) <= 0) {
				// Enviando error al cliente
				ReplyToTargetError(client, targets);
			} else {
				// Recorriendo targets
				for (int i = 0; i < targets; i++) {
					target = target_list[i];
					ToggleIgnoreStatus(client, target);
				}
			}
		}

	}
	return Plugin_Handled;
}

public void GetRankTotal(Handle owner, Handle hndl, const char[] error, any data) {
	if (hndl != null) {
		if(StrEqual(error, "")) {
			while (SQL_FetchRow(hndl)) {
				g_iRegisteredPlayers = SQL_FetchInt(hndl, 0);
			}
		} else {
			LogError("(GetRankTotal)-> SQL Error: %s >>> %s", error, data);
		}
	}
}

public void OnClientDisconnect(int client) {

	if(IsRealClient(client)) {
	
		updatePlayer(client);

		DMOnClientDisconnect(client);

		if (g_hJoinTimer[client] != null) {
			KillTimer(g_hJoinTimer[client]);
			g_hJoinTimer[client] = null;
		}

		resetVariables(client);
		
		g_iTankDamage[client][0] = 0;
		
		for(int i = 1;i <= MaxClients; i++) {
			g_iTankDamage[client][i] = 0;
			g_bPlayerIgnore[client][i] = false;
		}
	}
}

public int ShowPlayerListMute(int client) {
	char str_userid[12];
	char str_name[128];
	Menu menu = CreateMenu(MenuHandler_PlayerList);
	menu.SetTitle("Ignore voice");
	menu.ExitButton = true;
	str_userid[0] = 0;
	for(int i = 1; i <= MaxClients; i++) {
		if (i != client) {
			if(IsClientInGame(i)) {
				if(!IsFakeClient(i)) {
					IntToString(GetClientUserId(i), str_userid, sizeof(str_userid));
					if (g_bPlayerIgnore[client][i]) {
						Format(str_name, sizeof(str_name), "%N [Listening]", i);
					} else {
						Format(str_name, sizeof(str_name), "%N [Silenced]", i);
					}
					menu.AddItem(str_userid, str_name);
				}
			}
		}
	}
	if(str_userid[0] == 0) {
		menu.AddItem("", "No available players", ITEMDRAW_DISABLED);
	}
	menu.Display(client, MENU_TIME_FOREVER);
}

public int MenuHandler_PlayerList(Menu menu, MenuAction action, int client, int Item) {
	switch(action) {
		case MenuAction_End: delete menu;
		case MenuAction_Select: {
			char sUserID[12];
			int target;
			menu.GetItem(Item, sUserID, sizeof(sUserID));
			target = GetClientOfUserId(StringToInt(sUserID));
			if (target) {
				g_bPlayerIgnore[client][target] = !g_bPlayerIgnore[client][target];
				if (g_bPlayerIgnore[client][target]) {
					SetListenOverride(client, target, Listen_No);
					CPrintToChat(client, "The player {blue}%N \x01turned {blue}off\x01 the microphone.", target);
				} else {
					if (GetClientTeam(client) == GetClientTeam(target)) {
						SetListenOverride(client, target, Listen_Yes);
					}
					CPrintToChat(client, "The player {blue}%N \x01turned {blue}on\x01 the microphone.", target);
				}
			} else {
				CPrintToChat(client, "The player is no longer available!");
			}
			ShowPlayerListMute(client);
		}
	}
}

public int ToggleIgnoreStatus(int client, int target) {	
	g_bPlayerIgnore[client][target] = !g_bPlayerIgnore[client][target];
	if (g_bPlayerIgnore[client][target]) {
		SetListenOverride(client, target, Listen_No);
		CPrintToChat(client, "The player {blue}%N \x01turned {blue}off\x01 the microphone.", target);
	} else {
		SetListenOverride(client, target, Listen_Yes);
		CPrintToChat(client, "The player {blue}%N \x01turned {blue}on\x01 the microphone.", target);
	}
}

public void UpdatePlayersStats() {
	// Instanciando metodo de trasaction
	Transaction transaction = new Transaction();
	// Inicializando variables para guardar el query y el steam id
	for (int i = 1; i <= MaxClients; i++) {
		// Verificando que cliente sea real
		if(IsRealClient(i)) {
			char sqlcode[2048];
			Format(sqlcode, 2048, buildQueryPlayerUpdate(i));
			resetVariables(i);
			transaction.AddQuery(sqlcode);
		}
	}
	g_dbConnection.Execute(transaction, onPlayerUpdated, OnUpdatePlayersStatsFailure, _, DBPrio_High);
}

public void updatePlayer(int client) {
	if(IsRealClient(client)) {
		// Instanciando metodo de trasaction
		Transaction transaction = new Transaction();
		char sqlcode[2048];
		Format(sqlcode, 2048, buildQueryPlayerUpdate(client));
		resetVariables(client);
		transaction.AddQuery(sqlcode);
		g_dbConnection.Execute(transaction, onPlayerUpdated, threadFailure, client, DBPrio_High);
	}
}

public void onPlayerUpdated(Database db, int client, int numQueries, DBResultSet[] results, any[] queryData) {
	
}

char buildQueryPlayerUpdate(int client) {
	// Variable para tiempo de juego
	int iClientPlaytime = GetTime() - g_iPlayerCounters[client][PLAYER_START_TIME];
	// Inicializando variables para guardar el query y el steam id
	char sqlcode[2048], SteamID[MAX_LINE_WIDTH];
	// Obteniendo el steam id
	GetClientAuthId(client, AuthId_Steam2, SteamID, sizeof(SteamID));
	// Formateando query
	Format(sqlcode, 2048, "CALL PLAYER_UPDATE ('%s', %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d);",
		SteamID, // Steam id del jugador
		g_iPlayerCounters[client][PLAYER_BOXES_OPEN],
		g_iPlayerCounters[client][PLAYER_BOXES_SPECIALS_OPEN],
		g_iPlayerCounters[client][PLAYER_COUNTER_BH],
		g_iPlayerCounters[client][PLAYER_COUNTER_COMMANDS],
		g_iPlayerCounters[client][PLAYER_COUNTER_LVP],
		g_iPlayerCounters[client][PLAYER_COUNTER_MESSAGES],
		g_iPlayerCounters[client][PLAYER_COUNTER_MVP],
		g_iPlayerCounters[client][PLAYER_COUNTER_SUICIDE],
		g_iPlayerCounters[client][PLAYER_COUNTER_WITCH_DISTURB],
		g_iPlayerCounters[client][PLAYER_FRIENDS_ABOVE],
		g_iPlayerCounters[client][PLAYER_FRIENDS_ADRENALINE_GIVEN],
		g_iPlayerCounters[client][PLAYER_FRIENDS_CURED],
		g_iPlayerCounters[client][PLAYER_FRIENDS_DAMAGE],
		g_iPlayerCounters[client][PLAYER_FRIENDS_INCAPPED],
		g_iPlayerCounters[client][PLAYER_FRIENDS_KILLED],
		g_iPlayerCounters[client][PLAYER_FRIENDS_PILLS_GIVEN],
		g_iPlayerCounters[client][PLAYER_FRIENDS_PROTECTED],
		g_iPlayerCounters[client][PLAYER_FRIENDS_RESCUED],
		g_iPlayerCounters[client][PLAYER_FRIENDS_REVIVED],
		g_iPlayerCounters[client][PLAYER_GIFT_TAKEN],
		g_iPlayerCounters[client][PLAYER_HEADSHOTS],
		g_iPlayerCounters[client][PLAYER_INFECTED_LET_IN_SAFEHOUSE],
		g_iPlayerCounters[client][PLAYER_KILL_BOOMERS],
		g_iPlayerCounters[client][PLAYER_KILL_BOSSES],
		g_iPlayerCounters[client][PLAYER_KILL_CHARGERS],
		g_iPlayerCounters[client][PLAYER_KILL_HUNTERS],
		g_iPlayerCounters[client][PLAYER_KILL_JOCKEYS],
		g_iPlayerCounters[client][PLAYER_KILL_SMOOKERS],
		g_iPlayerCounters[client][PLAYER_KILL_SPITTERS],
		g_iPlayerCounters[client][PLAYER_KILL_TANKS],
		g_iPlayerCounters[client][PLAYER_KILL_TANKS_WITHOUT_DEATHS],
		g_iPlayerCounters[client][PLAYER_KILL_WITCHES],
		g_iPlayerCounters[client][PLAYER_KILL_ZOMBIES],
		g_iPlayerCounters[client][PLAYER_KILLED_BY_BOOMER],
		g_iPlayerCounters[client][PLAYER_KILLED_BY_CHARGER],
		g_iPlayerCounters[client][PLAYER_KILLED_BY_HUNTER],
		g_iPlayerCounters[client][PLAYER_KILLED_BY_JOCKEY],
		g_iPlayerCounters[client][PLAYER_KILLED_BY_SMOOKER],
		g_iPlayerCounters[client][PLAYER_KILLED_BY_SPITTER],
		g_iPlayerCounters[client][PLAYER_KILLED_BY_TANK],
		g_iPlayerCounters[client][PLAYER_KILLED_BY_WITCH],
		g_iPlayerCounters[client][PLAYER_LEFT4DEAD],
		g_iPlayerCounters[client][PLAYER_MELEE_KILLS],
		iClientPlaytime, // tiempo nuevo del jugador
		g_iPlayerCounters[client][PLAYER_NEW_POINTS], // puntos nuevos del jugador
		g_iPlayerCounters[client][PLAYER_POINTS_GIFT], // puntos nuevos regalados para el jugador
		g_iPlayerCounters[client][PLAYER_POINTS_LOST], // puntos nuevos perdidos del jugador
		g_iPlayerCounters[client][PLAYER_POINTS_VIP], // puntos nuevos obtenidos por vip
		g_iPlayerCounters[client][PLAYER_ROUNDS],
		g_iPlayerCounters[client][PLAYER_ROUNDS_ALL_SURVIVE],
		g_iPlayerCounters[client][PLAYER_ROUNDS_FAILED],
		g_iPlayerCounters[client][PLAYER_ROUNDS_SUCCESSFUL],
		g_iPlayerCounters[client][PLAYER_SELF_ADRENALINE],
		g_iPlayerCounters[client][PLAYER_SELF_CURED],
		g_iPlayerCounters[client][PLAYER_SELF_PILLS],
		g_iPlayerCounters[client][PLAYER_SERVER_JOIN],
		g_iPlayerCounters[client][PLAYER_SERVER_LEFT],
		g_iPlayerCounters[client][PLAYER_SPOKENTIME]
	);
	return sqlcode;
}

public void OnUpdatePlayersStatsFailure(Database db, any data, int numQueries, const char[] error, int failIndex, any[] queryData) {
	LogError("(UpdatePlayersStats) Error in Database Execution: %s", error);
}

public void threadFailure(Database db, any data, int numQueries, const char[] error, int failIndex, any[] queryData) {
	LogError("(updatePlayer) Error in Database Execution: %s", error);
}


public void updateptystatslayers() {
	int players = GetTeamClientCount(TEAM_SURVIVORS);
	if (players >= 8) {
		g_iStatsBalans = (players / 4);
	}
}

public Action MapStart(Handle timer) {
	OnMapStart();
}

public void OnMapStart() {
	// g_roundsMap = 1;
	ADOnMapStart();
	PrecacheSound(SOUND_JOIN, true);
	// PrecacheSound(SOUND_MAPTIME_START, true);
	PrecacheSound(SOUND_MAPTIME_FINISH, true);
	g_iFailedAttempts = 0;
	char query[256];
	Format(query, sizeof(query), "CALL PLAYER_COUNT();");
	SQL_TQuery(g_dbConnection, GetRankTotal, query, _, DBPrio_High);
}

public Action eventTankSpawn(Event event, const char[] name, bool dontBroadcast) {
	int tank = GetClientOfUserId(event.GetInt("userid"));
	g_iTankHealth[tank] = GetClientHealth(tank);
	GetClientName(tank, g_sTankName[tank], MAX_LINE_WIDTH);
}

public Action eventTankKilled(Event event, const char[] name, bool dontBroadcast) {
	int tank = GetClientOfUserId(event.GetInt("userid"));
	GetClientName(tank, g_sTankName[tank], MAX_LINE_WIDTH);
	printTotalDamageTank(tank);
}

public Action eventMeleeKill(Event event, const char[] name, bool dontBroadcast) {
	int client = GetClientOfUserId(event.GetInt("userid"));
	g_iPlayerCounters[client][PLAYER_MELEE_KILLS]++; 
}

public Action eventMolotovThrown(Event event, const char[] name, bool dontBroadcast) {
	int client = GetClientOfUserId(event.GetInt("userid"));
	CPrintToChatAll("{blue}%N \x01thrown a {blue}molotov", client);
}

public Action eventRoundStart(Event event, const char[] name, bool dontBroadcast) {
	ADRoundStart();
	g_pointsEnabled = true;
	g_isRoundStarted = true;
	g_iStatsBalans = 0;
	// bonus = 0;
	g_fMapTimingStartTime = 0.0;

	for (int i = 1; i <= MaxClients; i++) {
		g_iPlayerCounters[i][PLAYER_ROUNDS]++;
	}
	return Plugin_Continue;
}

public Action eventRoundEnd(Event event, const char[] name, bool dontBroadcast) {
	if (!g_isRoundStarted) {
		return;
	}
	for (int i = 1; i <= MaxClients; i++) {
		g_iPlayerCounters[i][PLAYER_ROUNDS]++;
	}
	g_iFailedAttempts++;
}

/**
 * Al ingresar el cliente
 * @param client
 */
public void OnClientPostAdminCheck(int client) {
	// Verificando que sea una entidad valida
	if (IsValidEntity(client)) {
		// Verificando que el jugador sea real
		if(!IsFakeClient(client)) {
			// Definiendo contador a 0
			resetVariables(client);
			// Obteniendo informacion en la base de datos
			getPlayer(client);
		}
	}
}

/**
 * Funcion para establecer los valores en 0 de un cliente
 * @param client
 */
void resetVariables(int client) {
	g_playerSteamId[client] = "";
	g_playerAssistanceFactor[client] = 0.0;
	for(int i = 0; i < MAX_LENGTH_SKILLS; i++) {
		if(i == PLAYER_START_TIME) {
			g_iPlayerCounters[client][i] = GetTime();
		} else {
			g_iPlayerCounters[client][i] = 0;
		}
	}
}

/**
 * Funcion for connect to Database
 */
public void vConnectDatabase() {
	// Verificando si existe la configuracion
	if (SQL_CheckConfig(DB_CONF_NAME)) {
		char Error[80];
		// Instanciando conexion en g_dbConnection
		g_dbConnection = SQL_Connect(DB_CONF_NAME, true, Error, sizeof(Error));
		// Verificando si g_dbConnection fue exitosa
		if(g_dbConnection == null) {
			LogError("Failed to connect to database: %s", Error);
			SetFailState("Failed to connect to database: %s", Error);
		}
		g_dbConnection.SetCharset("utf8");
	} else {
		LogError("database.cfg missing '%s' entry!", DB_CONF_NAME);
		SetFailState("database.cfg missing '%s' entry!", DB_CONF_NAME);
	}
}

// Funcion para cuando un jugador se conecta al servidor...
public void getPlayer(int client) {
	// Verificando si el cliente es valido
	if (client) {
		// Verificando si el jugador esta en linea
		if (IsClientInGame(client)) {
			// Verificando que el cliente no sea falso
			if (!IsFakeClient(client)) {
				// Creando variables necesarias
				char clientName[MAX_NAME_LENGTH],
					clientIp[16], 
					sqlCommand[512]; // SteamID[MAX_LINE_WIDTH],
				GetClientName(client, clientName, MAX_NAME_LENGTH);
				// Obteniendo el steam id del jugador
				GetClientAuthId(client, AuthId_Steam2, g_playerSteamId[client], MAX_LINE_WIDTH);
				// Asignando valor a la ip
				GetClientIP(client, clientIp, sizeof(clientIp));
				// Formateando datos de actualizacion
				Format(sqlCommand, sizeof(sqlCommand), "CALL PLAYER_JOINED('%s', '%s', '%s');", g_playerSteamId[client], clientIp, clientName);
				// Verficando que se haya enviado correctamente
				if((playerData = g_dbConnection.Query(g_dbConnection, sqlCommand)) != null) {
					// Extrayendo datos
					if(playerData.FetchRow()) {
						// Asignando valores
						g_iPlayerCounters[client][PLAYER_KILL_BOSSES] = playerData.FetchInt(0);
						g_playerAssistanceFactor[client] = playerData.FetchFloat(1);
						g_iPlayerCounters[client][PLAYER_POINTS] = playerData.FetchInt(2);
						g_iPlayerCounters[client][PLAYER_PLAYTIME] = playerData.FetchInt(3);
						g_iPlayerCounters[client][PLAYER_RANK] = playerData.FetchInt(4);
						g_iPlayerCounters[client][PLAYER_POINTS_FOR_NEXT_RANK] = playerData.FetchInt(5);
						int ban_expired = playerData.FetchInt(6);
						if(ban_expired > GetTime()) {
							KickClient(client, "You're banned.\nTry to contact with us via Discord [http://discord.l4d.io]");
							return;
						}
						playerData.FetchMoreResults();
						// Verificando si el jugador tiene puntos mayor igual a 10k
						if (g_iPlayerCounters[client][PLAYER_POINTS] >= 10000) {
							// Verificando que tenga al menos un dia de juego
							if(g_iPlayerCounters[client][PLAYER_PLAYTIME] >= 86400) {
								// Viendo si el factor es mayor a 0.5
								if(g_playerAssistanceFactor[client] >= 1) {
									int clientBonusPoints = RoundToFloor(g_playerAssistanceFactor[client]);
									clientBonusPoints = (clientBonusPoints > 10) ? 10 : clientBonusPoints;
									// Giving points
									g_iPlayerCounters[client][PLAYER_BONUS_POINTS] = clientBonusPoints;
								}
							}
						} else if(g_iPlayerCounters[client][PLAYER_POINTS] <= POINTS_NEGATIVE_FOR_KICK_PLAYERS) {
							KickClient(client, "Sorry you have alot of negative points [%d].\nPlease contact to us via Discord [http://discord.l4d.io] for resolve your problem.", g_iPlayerCounters[client][PLAYER_POINTS]);
							return;
						}

						if(CheckCommandAccess(client, "sm_fk", ADMFLAG_KICK, true)) {
							CPrintToChatAll("\x05+\x04 Admin {blue}%N \x05has joined", client);
						} else if(CheckCommandAccess(client, "sm_fk", ADMFLAG_GENERIC, true)) {
							CPrintToChatAll("\x05+\x04 Moderator {blue}%N \x05has joined", client);
						} else if(CheckCommandAccess(client, "sm_fk", ADMFLAG_RESERVATION, true)) {
							CPrintToChatAll("\x05+\x04 VIP {blue}%N \x01(\x05RANK: \x04%d, \x05POINTS: \x04%d\x01)", client, g_iPlayerCounters[client][PLAYER_RANK],g_iPlayerCounters[client][PLAYER_POINTS]);
						} else {
							CPrintToChatAll("\x05+ Player {blue}%N \x01(\x05RANK: \x04%d, \x05POINTS: \x04%d\x01)", client, g_iPlayerCounters[client][PLAYER_RANK],g_iPlayerCounters[client][PLAYER_POINTS]);
						}
						EmitSoundToAll(SOUND_JOIN);
					}
				} else {
					char error[255];
					SQL_GetError(g_dbConnection, error, sizeof(error));
					PrintToServer("Failed to query (error: %s)", error);
					LogError("Failed to query (error: %s)", error);
				}
			}
		}
	}
}

public Action eventWitchDisturb(Event event, const char[] name, bool dontBroadcast) {
	int client = GetClientOfUserId(event.GetInt("userid"));
	if(client) {
		if(IsValidEntity(client)) {
			if(!IsFakeClient(client)) {
				g_iPlayerCounters[client][PLAYER_COUNTER_WITCH_DISTURB] += 1;
			}
		}
	}
	return Plugin_Continue;
}

public Action eventWitchKilled(Event event, const char[] name, bool dontBroadcast) {
	int client = GetClientOfUserId(event.GetInt("userid"));
	if(client) {
		if(IsValidEntity(client)) {
			if(!IsFakeClient(client)) {
				int Score = cvar_Witch.IntValue + g_iStatsBalans + g_iPlayerCounters[client][PLAYER_BONUS_POINTS];
				g_iPlayerCounters[client][PLAYER_KILL_WITCHES] += 1;
				CPrintToChatAll("{blue}%N {green}killed {blue}Witch",client);
				AddScore(client, Score);
			}
		}
	}
	return Plugin_Continue;
}

/**
*	Event when a player death
*/
public Action eventPlayerDeath(Event event, const char[] name, bool dontBroadcast) {
	// Obteniendo el id del jugador
	int attacker = GetClientOfUserId(event.GetInt("attacker"));
	// Verificando si fue un headshot
	int headshot = event.GetBool("headshot") ? 1 : 0;
	// Verificando si es una entidad valida
	if (IsValidEntity(attacker)) {
		// Verificando si es un atacante valid
		if (attacker) { 
			// Obteniendo el userid del jugador
			int victim = GetClientOfUserId(event.GetInt("userid"));
			// Verificando que el atacante no sea un bot
			if (!IsFakeClient(attacker)) {
				// Verificando que el atacante sea diferente de la victima
				if (attacker != victim) {
					int Score = 0;
					// Verificando si el atacante es valido
					if (victim > 0) {
						// Guardando el grupo de la victima
						int victim_team = GetClientTeam(victim);
						// Verificando si la vctima es del grupo se los sobrevivintes
						if(victim_team == TEAM_SURVIVORS) {
							// verificando que no sea un jugador falso
							if(!IsFakeClient(victim)) {
								// Verificando que pertenezca al equipo de sobrevivientes
								if(GetClientTeam(attacker) == TEAM_SURVIVORS) {
									Score = -50;
									g_iPlayerCounters[attacker][PLAYER_TK_BLOCK_DAMAGE] += 30;
									pusnishTeamKiller(attacker);
									CPrintToChatAll("{blue}%N {default}killed {blue}%N", attacker, victim);
									g_iPlayerCounters[attacker][PLAYER_FRIENDS_KILLED] += 1;
								}
							}
						} else if(victim_team == TEAM_INFECTED) {
							int special_infected = GetEntProp(victim, Prop_Send, "m_zombieClass");
							int bonus_points = g_iPlayerCounters[attacker][PLAYER_BONUS_POINTS] + g_iStatsBalans;
							if(special_infected == ZC_SMOKER) {
								Score = cvar_Smoker.IntValue + bonus_points;
								g_iPlayerCounters[attacker][PLAYER_KILL_SMOOKERS] += 1;
							} else if(special_infected == ZC_BOOMER) {
								Score = cvar_Boomer.IntValue + bonus_points;
								g_iPlayerCounters[attacker][PLAYER_KILL_BOOMERS] += 1;
							} else if(special_infected == ZC_HUNTER) {
								Score = cvar_Hunter.IntValue + bonus_points;
								g_iPlayerCounters[attacker][PLAYER_KILL_HUNTERS] += 1;
							} else if(special_infected == ZC_SPITTER) {
								Score = cvar_Spitter.IntValue + bonus_points;
								g_iPlayerCounters[attacker][PLAYER_KILL_SPITTERS] += 1;
							} else if(special_infected == ZC_JOCKEY) {
								Score = cvar_Jockey.IntValue + bonus_points;
								g_iPlayerCounters[attacker][PLAYER_KILL_JOCKEYS] += 1;
							} else if(special_infected == ZC_CHARGER) {
								Score = cvar_Charger.IntValue + bonus_points;
								g_iPlayerCounters[attacker][PLAYER_KILL_CHARGERS] += 1;
							} else if(special_infected == ZC_WITCH) {
								CPrintToChatAll("Si jala el evento que pedo :v");
							} else if(special_infected == ZC_TANK) {
								Score = cvar_Tank.IntValue + bonus_points;
								g_iPlayerCounters[attacker][PLAYER_KILL_TANKS] += 1;
							}
							g_iPlayerCounters[attacker][PLAYER_FRAGS]++;
							g_iPlayerCounters[attacker][PLAYER_KILL_BOSSES]++;
							g_iPlayerCounters[attacker][PLAYER_HEADSHOTS] += headshot;
							AddScore(attacker, Score);
						}
					} else {
						char VictimName[MAX_LINE_WIDTH];
						event.GetString("victimname", VictimName, sizeof(VictimName));
						if (StrEqual(VictimName, "Infected", false)) {
							g_iPlayerCounters[attacker][PLAYER_KILL_ZOMBIES]++;
							g_iPlayerCounters[attacker][PLAYER_HEADSHOTS] += headshot;
							if ((g_iPlayerCounters[attacker][PLAYER_KILL_ZOMBIES] % KILL_COUNT_INFECTED) == 0) {
								AddScore(attacker, 5);
								PrintCenterText(attacker, "Infected killed: %d", g_iPlayerCounters[attacker][PLAYER_KILL_ZOMBIES]);
							}
						} else if(DEBUG) {
							PrintToChatAll("[stats] Asesinato de %s", VictimName);
						}
					}
				} else {
					CPrintToChatAll("%N se ha suicidado :O", attacker);
				}
			} else {
				// al ser asesinado un jugador por un enemigo xD
				if(victim > 0) {
					// Guardando el grupo de la victima
					if(GetClientTeam(attacker) == TEAM_INFECTED) {
						int special_infected = GetEntProp(attacker, Prop_Send, "m_zombieClass");
						CPrintToChatAll("Zombie Class: %d", special_infected);
					}
				} else {
					char VictimName[MAX_LINE_WIDTH];
					event.GetString("victimname", VictimName, sizeof(VictimName));
					PrintToChatAll("%s", VictimName);
				}
			}
		}
	}
	return Plugin_Continue;
}

public Action eventPlayerIncap(Event event, const char[] name, bool dontBroadcast) {
	int attacker = GetClientOfUserId(event.GetInt("attacker"));
	int victim = GetClientOfUserId(event.GetInt("userid"));
	if (attacker) {
		if (!IsFakeClient(attacker)) {
			if(!IsFakeClient(victim)) {
				if (attacker != victim) {
					if (GetClientTeam(attacker) == TEAM_SURVIVORS) {
						if (GetClientTeam(victim) == TEAM_SURVIVORS) {
							g_iPlayerCounters[attacker][PLAYER_TK_BLOCK_DAMAGE] += 25;
							CPrintToChat(victim, "{blue}%N \x05incapacitated {blue}you", attacker);
							CPrintToChat(attacker, "{blue}You \x05incapacitated {blue}%N \x04[\x05%i TK\x04]", victim, g_iPlayerCounters[attacker][PLAYER_TK_BLOCK_DAMAGE]);
							pusnishTeamKiller(attacker);
							// if(DEBUG) {
								// CPrintToChatAll("se suma aqui la variable de: PLAYER_FRIENDS_INCAPPED");
							// }
							g_iPlayerCounters[attacker][PLAYER_FRIENDS_INCAPPED] += 1;
							if(g_iPlayerCounters[attacker][PLAYER_BONUS_POINTS] > 0) {
								g_iPlayerCounters[attacker][PLAYER_BONUS_POINTS]--;
							}
							AddScore(attacker, -10);
						}
					}
				}
			}
		}
	}
	return Plugin_Continue;
}

// Fix para gente que se mete al fuego xD
// char weapon[128]; 
// event.GetString("weapon", weapon, sizeof(weapon));

// if(StrEqual(weapon, "inferno", true))
// {
// 	if(g_iPlayerCounters[target][PLAYER_POINTS] < 0)
// 	{
// 		CPrintToChat(target, "{blue}%N \x05get out of there...", Attacker);
// 		return Plugin_Handled;
// 	}
// 	else if(ClientPoints[Attacker] > 160000)
// 	{
// 		CPrintToChat(target, "{blue}%N \x05attacked {blue}you", Attacker);
// 		CPrintToChat(Attacker, "{blue}You \x05attacked {blue}%N", target);
		
// 		if(LastTimeAttackFire[Attacker] == 0)
// 		{
// 			LastTimeAttackFire[Attacker] = GetTime();	
// 		}

// 		if(LastTimeAttackFire[Attacker] + 10 >= GetTime())
// 		{
// 			AddScore(Attacker, -1);
// 			LastTimeAttackFire[Attacker] = 0;
// 			return Plugin_Handled;
// 		}

// 		return Plugin_Continue;
// 	}
// }
// else
// {
// }
public Action eventPlayerHurt(Event event, const char[] name, bool dontBroadcast) {
	int attacker = GetClientOfUserId(event.GetInt("attacker"));
	if (attacker) {
		int damage = event.GetInt("dmg_health");
		// Damage es mayor a 0
		if (damage > 0) {
			int target = GetClientOfUserId(event.GetInt("userid"));
			// Verificando que atacante sea diferente del objetivo
			if (attacker != target) {
				// Verificando que el atacante sea real
				if (!IsFakeClient(attacker)) {
				// Verificando si el atacante es del equivo de sobrevivientes
					int team_target = GetClientTeam(target);
					// Verificando si el objetico es del equivo de sobrevivientes
					if(team_target == TEAM_SURVIVORS) {
						// Verificando que el target sea real
						if(!IsFakeClient(target)) {
							int Score = 1;
							Score = (g_iPlayerCounters[attacker][PLAYER_BONUS_POINTS] > 0) ? ((Score * -damage) / 2) : ((Score * -damage));
							Score = (Score == 0) ? -1 : Score;
							g_iPlayerCounters[attacker][PLAYER_TK_BLOCK_DAMAGE] += (-1*Score);
							CPrintToChat(target, "{blue}%N \x05attacked {blue}you \x04[\x05%i TK\x04]", attacker, g_iPlayerCounters[attacker][PLAYER_TK_BLOCK_DAMAGE]);
							CPrintToChat(attacker, "{blue}You \x05attacked {blue}%N \x04[\x05%d TK\x04]", target, g_iPlayerCounters[attacker][PLAYER_TK_BLOCK_DAMAGE]);
							AddScore(attacker, Score);
							pusnishTeamKiller(attacker);
						}
					// Verificando si es del equipo de infectados
					} else if(team_target == TEAM_INFECTED) {
						int special_infected = GetEntProp(target, Prop_Send, "m_zombieClass");
						if(special_infected == ZC_TANK) {
							int health = GetClientHealth(target);
							if(!bIsPlayerIncapped(target) && health > 0) {
								if(damage > health) {
									damage = health;
								}
								g_iTankDamage[target][attacker] += damage;
							}
						}
					}
				}
			}
		}
	}
	return Plugin_Continue;
}

public Action eventHealPlayer(Event event, const char[] name, bool dontBroadcast) {
	int client = GetClientOfUserId(event.GetInt("userid"));	
	int target = GetClientOfUserId(event.GetInt("subject"));
	if(!IsFakeClient(target)) {
		if(!IsFakeClient(client)) {
			if (target != client) {
				g_iPlayerCounters[client][PLAYER_TK_BLOCK_DAMAGE] = g_iPlayerCounters[client][PLAYER_TK_BLOCK_DAMAGE] - 16;
				if (g_iPlayerCounters[client][PLAYER_TK_BLOCK_DAMAGE] <= 0) {
					g_iPlayerCounters[client][PLAYER_TK_BLOCK_DAMAGE] = 0;
				}
				int Score = 0;
				int restored = event.GetInt("health_restored");
				g_iPlayerCounters[client][PLAYER_FRIENDS_CURED] += 1;
				if (restored > 49) {
					Score = 4;
					g_iPlayerCounters[client][PLAYER_BONUS_POINTS] += 1;
				} else {
					Score = 1;
				}
				AddScore(client, Score);
			} else {
				g_iPlayerCounters[client][PLAYER_SELF_CURED] += 1;
			}
		}
	}
	return Plugin_Continue;
}

public Action eventDefigPlayer(Event event, const char[] name, bool dontBroadcast){
	int Recipient = GetClientOfUserId(event.GetInt("subject"));
	int Giver = GetClientOfUserId(event.GetInt("userid"));
	if (!IsFakeClient(Recipient)) {
		if(!IsFakeClient(Giver)) {
			if (Recipient != Giver) {
				g_iPlayerCounters[Giver][PLAYER_BONUS_POINTS] += 1;
				g_iPlayerCounters[Giver][PLAYER_FRIENDS_REVIVED] += 1;
				AddScore(Giver, 3);
			}
		}
	}
	return Plugin_Continue;
}

public Action eventReviveSuccess(Event event, const char[] name, bool dontBroadcast) {
	int target = GetClientOfUserId(event.GetInt("subject"));
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (!IsFakeClient(target)) {
		if(!IsFakeClient(client)) {
			if (target != client) {
				g_iPlayerCounters[client][PLAYER_TK_BLOCK_DAMAGE] = g_iPlayerCounters[client][PLAYER_TK_BLOCK_DAMAGE] - 8;
				if (g_iPlayerCounters[client][PLAYER_TK_BLOCK_DAMAGE] <= 0) {
					g_iPlayerCounters[client][PLAYER_TK_BLOCK_DAMAGE] = 0;
				}
				g_iPlayerCounters[client][PLAYER_FRIENDS_ABOVE] += 1;
				if(!event.GetBool("ledge_hang")) {
					g_iPlayerCounters[client][PLAYER_BONUS_POINTS] += 1;
				}
				AddScore(client, 2);
				GrantPlayerColor(target);
			}
		}
	}
	return Plugin_Continue;
}


public Action eventPlayerNowIt(Event event, const char[] name, bool dontBroadcast) {
	int attacker = GetClientOfUserId(event.GetInt("attacker"));
	int victim = GetClientOfUserId(event.GetInt("userid"));
	bool by_boomer = GetEventBool(event, "by_boomer");
	if(!by_boomer) {
		if (attacker > 0) {
			// Verificando que el atacante este en juego
			if(IsClientInGame(attacker)) {
				// Verificando que sea un atacante real
				if(!IsFakeClient(attacker)) {
					// verificando que victima este en juego
					if(IsClientInGame(victim)) {
						// verificando que sea diferente el atacante y de la victima
						if(attacker != victim) {
							int team_victim = GetClientTeam(victim);
							int Score = 0;
							// Verificando grupo de la victima
							switch(team_victim) {
								case TEAM_INFECTED: {
									int zombieClass = iGetZombieClass(victim);
									// Verificando clase del vomiton
									switch(zombieClass) {
										case ZC_WITCH: {
											CPrintToChatAll("{blue}%N {default}vomit {blue}witch", attacker);
											Score = 10;
										}
										case ZC_TANK: {
											CPrintToChatAll("{blue}%N {default}vomit {blue}Tank", attacker);
											Score = 8;
										}
									}
									AddScore(attacker, Score);
									return Plugin_Continue;
								}
								case TEAM_SURVIVORS: {
									if (!IsFakeClient(victim)) {
										Score = 5;
										// Verificando si el tank esta vivo
										if (IsTankAlive()) {
											// Verificando si el jugador esta incapacitado o colgado
											if(IsIncapacitated(victim) || bIsPlayerGrapEdge(victim)) {
												Score *= 3;
											} else {
												Score *= 2;
											}
										} else {
											// Verificando si el jugador esta incapacitado o colgado
											if(IsIncapacitated(victim) || bIsPlayerGrapEdge(victim)) {
												Score *= 2;
											}
										}
										g_iPlayerCounters[attacker][PLAYER_VOMIT_TK_BLOCK_DAMAGE] += Score;
										AddScore(attacker, (Score * -1));
										punishTeamVomiter(attacker);
										CPrintToChat(victim, "{blue}%N {default}vomited you! \x04[\x05%i vomitTK\x04]", attacker, g_iPlayerCounters[attacker][PLAYER_VOMIT_TK_BLOCK_DAMAGE]);
										CPrintToChat(attacker, "{blue}You {default}vomited {blue}%N ! \x04[\x05%i vomitTK\x04]", victim, g_iPlayerCounters[attacker][PLAYER_VOMIT_TK_BLOCK_DAMAGE]);
										return Plugin_Continue;
									}
								}
							}
						}
					}
				}
			}
		}
	}
	return Plugin_Continue;
}

/**
 * Metodo para castigar a un vomiton
 * @param {integer} client
 * @return {void}
 */
void punishTeamVomiter(int client) { 

	// Verificando si el cliente ya supero el vomito
	if ( g_iPlayerCounters[client][PLAYER_VOMIT_TK_BLOCK_DAMAGE] > VOMIT_TK_BLOCK_MIN ) {

		if ( g_iPlayerCounters[client][PLAYER_VOMIT_TK_BLOCK_DAMAGE] > VOMIT_TK_BLOCK_MAX ) {

			if ( g_iPlayerCounters[client][PLAYER_VOMIT_TK_BLOCK_PUNISHMENT] < VOMIT_TK_BLOCK_MAX ) {
				
				if (IsValidEntity(client) && IsClientInGame(client) && IsClientConnected(client) && !IsFakeClient(client) && IsPlayerAlive(client)) {
					CPrintToChatAll("{blue}%N {default}has been slayed \x04[\x05%i vomitTK\x05]", client, g_iPlayerCounters[client][PLAYER_VOMIT_TK_BLOCK_DAMAGE]);
					g_iPlayerCounters[client][PLAYER_VOMIT_TK_BLOCK_PUNISHMENT] = g_iPlayerCounters[client][PLAYER_VOMIT_TK_BLOCK_DAMAGE];
					ServerCommand("sm_cancelvote");
					ServerCommand("sm_slay #%d", GetClientUserId(client));
					g_iPlayerCounters[client][PLAYER_VOMIT_TK_BLOCK_DAMAGE] = 0;
				}
			}
		} else if ((g_iPlayerCounters[client][PLAYER_VOMIT_TK_BLOCK_DAMAGE] - g_iPlayerCounters[client][PLAYER_VOMIT_TK_BLOCK_PUNISHMENT]) > VOMIT_TK_BLOCK_MIN) {
			if (IsValidEntity(client) && IsClientInGame(client) && IsClientConnected(client) && !IsFakeClient(client) && IsPlayerAlive(client)) {
				g_iPlayerCounters[client][PLAYER_VOMIT_TK_BLOCK_PUNISHMENT] = g_iPlayerCounters[client][PLAYER_VOMIT_TK_BLOCK_DAMAGE];
				CPrintToChatAll("Auto {blue}voteslay against {blue}%N [%i vomitTK]", client, g_iPlayerCounters[client][PLAYER_VOMIT_TK_BLOCK_DAMAGE]);
				ServerCommand("sm_voteslay #%d", GetClientUserId(client));
			}
		}
	}
}

public Action eventSurvivorRescued(Event event, const char[] name, bool dontBroadcast) {
	int client = GetClientOfUserId(event.GetInt("rescuer"));
	int target = GetClientOfUserId(event.GetInt("victim"));
	if (IsValidClient(client)) {
		if(!IsFakeClient(client)) {
			if(IsValidClient(target)) {
				if(!IsFakeClient(target)) {
					g_iPlayerCounters[client][PLAYER_FRIENDS_RESCUED] += 1;
					AddScore(client, 2);
				}
			}
		}
	}
	return Plugin_Continue;
}

/**
 * El evento se dispara al obtener un logro
 * @param Event event
 * @param string name
 * @param bool  dontBroadcast
 */
public Action eventAward(Event event, const char[] name, bool dontBroadcast) {
	// Obteniendo el id del cliente
	int client = GetClientOfUserId(event.GetInt("userid"));
	// Verificando que el cliente no sea falso
	if (!IsFakeClient(client)) {
		// Obteniendo el del logro
		int adward_id = event.GetInt("award");
		int target = event.GetInt("subjectentid");
		// Creando switch para id del logro
		switch(adward_id) {
			// Protect friendly
			case 67: {
				// Verificando que el objetivo sea valido
				if(target) {
					g_iPlayerCounters[client][PLAYER_FRIENDS_PROTECTED] += 1;
				}
				return Plugin_Continue;
			}
			// Pills given
			case 68: {
				// Verificando que el objetivo sea valido
				if (target) {
					// Dando pildoras 
					givePills(client, GetClientOfUserId(GetClientUserId(target)));
				}
				return Plugin_Continue;
			}
			// Adrenaline given
			case 69: {
				// Verificando que el objetivo sea valido
				if (target) {
					// Dando adrenalina
					giveAdrenaline(client, GetClientOfUserId(GetClientUserId(target)));
				}
				return Plugin_Continue;
			}
			// Kill Tank with no deaths
			case 81: {
				// Sumando al cliente un asesinato de tank sin morir
				g_iPlayerCounters[client][PLAYER_KILL_TANKS_WITHOUT_DEATHS] += 1;
				return Plugin_Continue;
			}
			// Incap friendly
			case 85: {
				// Verificando que el objetivo sea valido
				if (target) {
					// Obteniendo el id del objetivo
					target = GetClientOfUserId(GetClientUserId(target));
					// Verificando que cliente y el objetivo sean del equipo de sobrevivientes
					if ( GetClientTeam(client) == TEAM_SURVIVORS && GetClientTeam(target) == TEAM_SURVIVORS) {
						// Sumando al cliente una incapacitacion
						g_iPlayerCounters[client][PLAYER_FRIENDS_INCAPPED] += 1;
						// if(DEBUG) {
						// 	PrintToChatAll("se suma aqui la variable de: PLAYER_FRIENDS_INCAPPED");
						// }
					}
				}
				return Plugin_Continue;
			}
			// Left friendly for dead
			case 86: {
				// Sumando al jugador una muerte culposa
				g_iPlayerCounters[client][PLAYER_LEFT4DEAD] += 1;
				return Plugin_Continue;
			}
			// Let infected in safe room
			case 95: {
				// if(DEBUG) {
				// 	PrintToChatAll("Se dejo en el saferoom infectados especiales");
				// }
				g_iPlayerCounters[client][PLAYER_INFECTED_LET_IN_SAFEHOUSE] += 1;
				return Plugin_Continue;
			}
		}
	}
	return Plugin_Continue;
}

void givePills(int giver, int recipient){
	int pills_id = GetPlayerWeaponSlot(recipient, 4);
	if (pills_id > 0) {
		if(g_iPillsGiven[pills_id] != 1) {
			g_iPillsGiven[pills_id] = 1;
			if (!IsFakeClient(giver)) {
				g_iPlayerCounters[giver][PLAYER_FRIENDS_PILLS_GIVEN] += 1;
			}
		}
	}
}

void giveAdrenaline(int giver, int recipient) {
	int adrenalineId = GetPlayerWeaponSlot(recipient, 4);
	if (adrenalineId > 0) {
		if(g_iAdrenalineGiven[adrenalineId] != 1) {
			g_iAdrenalineGiven[adrenalineId] = 1;
			if (!IsFakeClient(giver)) {
				g_iPlayerCounters[giver][PLAYER_FRIENDS_ADRENALINE_GIVEN] += 1;
			}
		}
	}
}

/**
* Metodo para castigar a un jugador
* @param {int} client
*/
public void pusnishTeamKiller(int client) {
	// Verificando que sea un cliente valido
	if (IsValidEntity(client)) {
		// Verificando que el cliente este en juego
		if(IsClientInGame(client)) {
			// Verificando que el cliente este conectado
			if(IsClientConnected(client)) {
				// Verificando que el cliente no sea falso
				if(!IsFakeClient(client)) { 
					// Verificando si el cliente tiene puntos a menos 500
					if(g_iPlayerCounters[client][PLAYER_POINTS] >= -1000) {
						// Verificando si el cliente ya supero el limite TK
						if (g_iPlayerCounters[client][PLAYER_TK_BLOCK_DAMAGE] > g_iTkBlockMin) {
							if (g_iPlayerCounters[client][PLAYER_TK_BLOCK_DAMAGE] > g_iTkBlockMax) {
								if (g_iPlayerCounters[client][PLAYER_TK_BLOCK_PUNISHMENT] < g_iTkBlockMax) {
									// Cancenlando voto si existe alguno
									CancelVote();
									// Verificando si el cliente contiene flags
									if(CheckCommandAccess(client, "sm_fk", ADMFLAG_GENERIC, true)) {
										// Verificando si el ultimo voto fue reciente
										if (g_iPlayerCounters[client][PLAYER_LAST_VOTE_BANTIME] + 7 >= GetTime()) {
											// Creando switch para opcion random
											switch(GetRandomInt(0, 2)) {
												case 0: {
													// Baneando al jugado
													ServerCommand("sm_ban \"#%d\" \"%i\" \"%s\"", GetClientUserId(client), GetRandomInt(30, 60), "Team killer");
													// Imprimiendo que el jugador se ha vuelto loco
													CPrintToChatAll("{blue}%N {default}went crazy and {blue}banned{default} by the {blue}server! \x04[\x05{green}%i TK\x04]", client, g_iPlayerCounters[client][PLAYER_TK_BLOCK_DAMAGE]);
												}
												default: {
													// Expulsando al jugador
													KickClient(client, "Don't abuse about your power !! ;)");
													// Imprimiendo que el jugador se ha vuelto loco
													CPrintToChatAll("{blue}%N {default}went crazy and {blue}kicked{default} by the {blue}server! \x04[\x05{green}%i TK\x04]", client, g_iPlayerCounters[client][PLAYER_TK_BLOCK_DAMAGE]);
												}
											}
										} else {
											// Asesinando al jugador
											ServerCommand("sm_slay \"#%d\"", GetClientUserId(client));
											// Imprimiendo mensaje
											CPrintToChatAll("{blue}%N \x05went crazy \x04[\x05{green}%i TK\x04]", client, g_iPlayerCounters[client][PLAYER_TK_BLOCK_DAMAGE]);
										}
									} else {
										// Igualando el castigo con el block damage
										g_iPlayerCounters[client][PLAYER_TK_BLOCK_PUNISHMENT] = g_iPlayerCounters[client][PLAYER_TK_BLOCK_DAMAGE];
										bool isBanned = false;
										// Verificando si cliente tiene puntos menores a -300
										if (g_iPlayerCounters[client][PLAYER_POINTS] < -300) {
											// Verificando si el ultimo tiempo de voto fue reciente para banear dependiendo sus puntos * 2
											if (g_iPlayerCounters[client][PLAYER_LAST_VOTE_BANTIME] + 7 >= GetTime()) {
												// isBanned = BanClient(client, (-2 * g_iPlayerCounters[client][PLAYER_POINTS]), AuthId_Steam2, ON_BAN_REASON, ON_BAN_MESSAGE);
											} else {
												// isBanned = BanClient(client, (-1 * g_iPlayerCounters[client][PLAYER_POINTS]), AuthId_Steam2, ON_BAN_REASON, ON_BAN_MESSAGE);
											}
										} else {
											// En caso de que sus puntos sean mayores a -300 entonces se banea 5 horas
											// isBanned = BanClient(client, ON_BAN_TIME, AuthId_Steam2, ON_BAN_REASON, ON_BAN_MESSAGE);
										}
										if(isBanned) {
											// Imprimiendo que l jugado va hacer baneado
											CPrintToChatAll("{blue}%N \x04(\x05%s\x4)\x05 has been banned \x04[\x05%i TK\x04]", client, g_playerSteamId[client], g_iPlayerCounters[client][PLAYER_TK_BLOCK_DAMAGE]);				
										}
										#if DEBUG 
										else {
											CPrintToChatAll("Failed to banned");
										}
										#endif
									}
								
								} else if ((g_iPlayerCounters[client][PLAYER_TK_BLOCK_DAMAGE] - g_iPlayerCounters[client][PLAYER_TK_BLOCK_PUNISHMENT]) > g_iTkBlockMin) {			
									// Tk de castigo 
									g_iPlayerCounters[client][PLAYER_TK_BLOCK_PUNISHMENT] = g_iPlayerCounters[client][PLAYER_TK_BLOCK_DAMAGE];
									// Obteniendo el tiempo
									g_iPlayerCounters[client][PLAYER_LAST_VOTE_BANTIME] = GetTime();
									// Verificando si tiene acceso de admin mod vip
									if(CheckCommandAccess(client, "sm_fk", ADMFLAG_GENERIC, true)) {
										// Iniciando auto voteslay
										ServerCommand("sm_voteslay \"#%d\"", GetClientUserId(client));
										// Imprimiendo mensaje de autovote slay
										CPrintToChatAll("{blue}Autovoteslay {default}against {blue}%N {default}because {green}team killing \x04[\x05{green}%i TK\x04]", client, g_iPlayerCounters[client][PLAYER_TK_BLOCK_DAMAGE]);
									} else {
										// Iniciando voto de vote ban
										ServerCommand("sm_voteban #%d \"Team killer\"", GetClientUserId(client));
										// Imprimiendo mensaje 
										CPrintToChatAll("{blue}Autovoteban {default}against {blue}%N \x04[\x05%iTK\x04] \x04({blue}Rank: \x05{green}%d {blue}Points: \x05%d\x04)", client, g_iPlayerCounters[client][PLAYER_TK_BLOCK_DAMAGE], g_iPlayerCounters[client][PLAYER_RANK], g_iPlayerCounters[client][PLAYER_POINTS]);
									}
									return;
								}
							}
						}
					} else {
						KickClient(client, "Fucking noob");
					}
				}
			}
		}
	}
}

void ShowRank(int client)
{
	if(client)
	{
		if(IsClientInGame(client))
		{
			if(!IsFakeClient(client))
			{
				Panel rank = new Panel();
				char Value[128];

				int theTime = g_iPlayerCounters[client][PLAYER_PLAYTIME];
				int days = theTime /60/60/24;
				int hours = theTime/60/60%24;
				int minutes = theTime/60%60;

				char playtime[128];

				if (hours == 0 && days == 0)
				{
					Format(playtime, sizeof(playtime), "%d min", client, minutes);
				}
				else if (days == 0)
				{
					Format(playtime, sizeof(playtime), "%d hour %d min", client, hours, minutes);
				}
				else
				{
					Format(playtime, sizeof(playtime), "%d day %d hour %d min", client, days, hours, minutes);
				}

				int cTime = RoundToCeil(GetClientTime(client));
				int cDays = cTime / 86400;
				cTime %= 86400;
				int cHours = cTime / 3600;
				cTime %= 3600;
				int cMinutes = cTime / 60;
				cTime %= 60;
				int seconds = cTime;

				char contime[128];
				if (cMinutes < 1 && cHours < 1 && cDays < 1)
				{
					Format(contime, sizeof(contime), "%d sec", client, seconds);
				}
				else if (cHours < 1 && cDays < 1)
				{
					Format(contime, sizeof(contime), "%d min %d sec", client, cMinutes, seconds);
				}
				else if (cDays < 1)
				{
					Format(contime, sizeof(contime), "%d h %d min %d sec", client, cHours, cMinutes, seconds);
				}
				else
				{
					Format(contime, sizeof(contime), "%d d %d h %d min %d sec", client, cDays, cHours, cMinutes, seconds);
				}

				int BonusTK = 0;

				if (g_iPlayerCounters[client][PLAYER_RANK] > 1000 || g_iPlayerCounters[client][PLAYER_RANK] == 0)
				{
					BonusTK = -45;
				}
				else if (g_iPlayerCounters[client][PLAYER_RANK] > 100 && g_iPlayerCounters[client][PLAYER_RANK] < 1001)
				{
					BonusTK = 0;
				}
				else if (g_iPlayerCounters[client][PLAYER_RANK] > 0 && g_iPlayerCounters[client][PLAYER_RANK] < 101)
				{
					BonusTK = 30;
				}

				int g_iTkBlockMinReal = g_iTkBlockMin + BonusTK;
				int g_iTkBlockMaxReal = g_iTkBlockMax + BonusTK;

				Format(Value, sizeof(Value), "Ranking of %N", client, client);
				rank.DrawText(Value);

				Format(Value, sizeof(Value), "Rank: %i of %i", g_iPlayerCounters[client][PLAYER_RANK], g_iRegisteredPlayers);
				rank.DrawText(Value);

				if (g_iPlayerCounters[client][PLAYER_NEW_POINTS] != 0)
				{
					if (g_iPlayerCounters[client][PLAYER_NEW_POINTS] > 0)
					{
						if (hm_count_fails.IntValue > 0 && g_iFailedAttempts > 0)
						{
							Format(Value, sizeof(Value), "Points: %i + %i(%i)", client, g_iPlayerCounters[client][PLAYER_POINTS], g_iPlayerCounters[client][PLAYER_NEW_POINTS], calculatePoints(g_iPlayerCounters[client][PLAYER_NEW_POINTS]));
						}
						else
						{
							Format(Value, sizeof(Value), "Points: %i + %i", client, g_iPlayerCounters[client][PLAYER_POINTS], g_iPlayerCounters[client][PLAYER_NEW_POINTS]);
						}
					}
					else
					{
						Format(Value, sizeof(Value), "Points: %i %i", client, g_iPlayerCounters[client][PLAYER_POINTS], g_iPlayerCounters[client][PLAYER_NEW_POINTS]);
					}
				}
				else
				{
					Format(Value, sizeof(Value), "Points: %i", client, g_iPlayerCounters[client][PLAYER_POINTS]);
				}

				rank.DrawText(Value);

				Format(Value, sizeof(Value), "Killed Bosses: %i", client, g_iPlayerCounters[client][PLAYER_KILL_BOSSES]);
				rank.DrawText(Value);

				Format(Value, sizeof(Value), "Connection Time: %s", client, contime);
				rank.DrawText(Value);

				Format(Value, sizeof(Value), "Playtime: %s", client, playtime);
				rank.DrawText(Value);
				
				Format(Value, sizeof(Value), "Assistance Factor: %.2f", client, g_playerAssistanceFactor[client]);
				rank.DrawText(Value);

				Format(Value, sizeof(Value), "Bonus Points: %d", client, g_iPlayerCounters[client][PLAYER_BONUS_POINTS]);
				rank.DrawText(Value);

				Format(Value, sizeof(Value), "TK: %i", client, g_iPlayerCounters[client][PLAYER_TK_BLOCK_DAMAGE]);
				rank.DrawText(Value);

				Format(Value, sizeof(Value), "Voteban TK: %i", client, g_iTkBlockMinReal);
				rank.DrawText(Value);

				Format(Value, sizeof(Value), "Ban TK: %i", client, g_iTkBlockMaxReal);
				rank.DrawText(Value);


				Format(Value, sizeof(Value), "For full stats visit:\n%s", WEBSITE_STATS);
				rank.DrawText(Value);

				Format(Value, sizeof(Value), "Show full stats", client);
				rank.DrawItem(Value);

				Format(Value, sizeof(Value), "Next rank", client);
				rank.DrawItem(Value);

				Format(Value, sizeof(Value), "Top players", client);
				rank.DrawItem(Value);

				Format(Value, sizeof(Value), "Show players", client);
				rank.DrawItem(Value);

				Format(Value, sizeof(Value), "Close", client);
				rank.DrawItem(Value);

				rank.Send(client, RankPanelHandlerOption, 20);
				delete rank;
			}
		}
	}
	return;
}

public int RankPanelHandlerOption(Menu menu, MenuAction action, int client, int index)
{
	if (action == MenuAction_Select)
	{
		if (index == 1)
		{
			FakeClientCommand(client, "sm_browse www.americasectorcoop.org/stats");
		}
		else if (index == 2)
		{
			cmdNextRank(client, 0);
		}
		else if (index == 3)
		{
			cmdTop(client, 0);
		}
		else if (index == 4)
		{
			DisplayRankTargetMenu(client);
		}
	}
}

void DisplayRankTargetMenu(int client)
{
	Menu hMenu = new Menu(MenuHandler_Rank);

	char title[100];
	char playername[128];
	char identifier[64];
	char DisplayName[64];
	Format(title, sizeof(title), "%s", "Player Ranks:");
	hMenu.SetTitle(title);
	hMenu.ExitButton = true;

	for (int i = 1; i < MaxClients; i++)
	{
		if (IsClientInGame(i))
		{
			if(!IsFakeClient(i))
			{
				GetClientName(i, playername, sizeof(playername));
				Format(DisplayName, sizeof(DisplayName), "%s (%i points)", playername, g_iPlayerCounters[i][PLAYER_POINTS]);
				Format(identifier, sizeof(identifier), "%i", i);
				hMenu.AddItem(identifier, DisplayName);
			}
		}
	}

	hMenu.Display(client, MENU_TIME_FOREVER);
}

public int MenuHandler_Rank(Menu menu, MenuAction action, int client, int index)
{
	if (action == MenuAction_End)
	{
		delete menu;
	}
	else if (action == MenuAction_Select)
	{
		char info[32];
		char name[32];
		int target;

		menu.GetItem(index, info, sizeof(info), _, name, sizeof(name));
		target = StringToInt(info);

		if (target == 0)
		{
			CPrintToChat(client, "\x04[\x05ASC\x04] Player no longer available");
		}
		else
		{
			DisplayRank(target, client);
		}
	}
}

void DisplayRank(int target, int sender)
{
	Panel rank = new Panel();
	char Value[128];

	int theTime = g_iPlayerCounters[target][PLAYER_PLAYTIME];
	int days = theTime /60/60/24;
	int hours = theTime/60/60%24;
	int minutes = theTime/60%60;

	char playtime[128];
	if (hours == 0 && days == 0)
	{
		Format(playtime, sizeof(playtime), "%d min", sender, minutes);
	}
	else if (days == 0)
	{
		Format(playtime, sizeof(playtime), "%d hour %d min", sender, hours, minutes);
	}
	else
	{
		Format(playtime, sizeof(playtime), "%d day %d hour %d min", sender, days, hours, minutes);
	}

	int cTime = RoundToCeil(GetClientTime(target));

	int cDays = cTime / 86400;
	cTime %= 86400;
	int cHours = cTime / 3600;
	cTime %= 3600;
	int cMinutes = cTime / 60;
	cTime %= 60;
	int seconds = cTime;

	char contime[128];
	if (cMinutes < 1 && cHours < 1 && cDays < 1)
	{
		Format(contime, sizeof(contime), "%d sec", sender, seconds);
	}
	else if (cHours < 1 && cDays < 1)
	{
		Format(contime, sizeof(contime), "%d min %d sec", sender, cMinutes, seconds);
	}
	else if (cDays < 1)
	{
		Format(contime, sizeof(contime), "%d h %d min %d sec", sender, cHours, cMinutes, seconds);
	}
	else Format(contime, sizeof(contime), "%d d %d h %d min %d sec", sender, cDays, cHours, cMinutes, seconds);

	int BonusTK = 0;

	if (g_iPlayerCounters[target][PLAYER_RANK] > 1000 || g_iPlayerCounters[target][PLAYER_RANK] == 0)
	{
		BonusTK = -45;
	}
	else if (g_iPlayerCounters[target][PLAYER_RANK] > 100 && g_iPlayerCounters[target][PLAYER_RANK] < 1001)
	{
		BonusTK = 0;
	}
	else if (g_iPlayerCounters[target][PLAYER_RANK] > 0 && g_iPlayerCounters[target][PLAYER_RANK] < 101)
	{
		BonusTK = 30;
	}

	int g_iTkBlockMinReal = g_iTkBlockMin + BonusTK;
	int g_iTkBlockMaxReal = g_iTkBlockMax + BonusTK;

	Format(Value, sizeof(Value), "Ranking of %N", sender, target);

	rank.DrawText(Value);

	Format(Value, sizeof(Value), "===========================");
	rank.DrawText(Value);

	Format(Value, sizeof(Value), "Rank: %i of %i", sender, g_iPlayerCounters[target][PLAYER_RANK], g_iRegisteredPlayers);
	rank.DrawText(Value);

	if (g_iPlayerCounters[target][PLAYER_NEW_POINTS] != 0)
	{
		if (g_iPlayerCounters[target][PLAYER_NEW_POINTS] > 0)
		{
			if (hm_count_fails.IntValue > 0)
			{
				Format(Value, sizeof(Value), "Points: %i + %i(%i)", sender, g_iPlayerCounters[target][PLAYER_POINTS], g_iPlayerCounters[target][PLAYER_NEW_POINTS], calculatePoints(g_iPlayerCounters[target][PLAYER_NEW_POINTS]));
			}
			else
			{
				Format(Value, sizeof(Value), "Points: %i + %i", sender, g_iPlayerCounters[target][PLAYER_POINTS], g_iPlayerCounters[target][PLAYER_NEW_POINTS]);
			}
		}
		else
		{
			Format(Value, sizeof(Value), "Points: %i %i", sender, g_iPlayerCounters[target][PLAYER_POINTS], g_iPlayerCounters[target][PLAYER_NEW_POINTS]);
		}
	}
	else
	{
		Format(Value, sizeof(Value), "Points: %i", sender, g_iPlayerCounters[target][PLAYER_POINTS]);
	}
	rank.DrawText(Value);

	Format(Value, sizeof(Value), "Connection Time: %s", sender, contime);
	rank.DrawText(Value);

	Format(Value, sizeof(Value), "Killed Bosses: %i", sender, g_iPlayerCounters[target][PLAYER_KILL_BOSSES]);
	rank.DrawText(Value);

	Format(Value, sizeof(Value), "Playtime: %s", sender, playtime);
	rank.DrawText(Value);

	Format(Value, sizeof(Value), "Assistance Factor: %.2f", sender, g_playerAssistanceFactor[target]);
	rank.DrawText(Value);

	Format(Value, sizeof(Value), "Bonus Points: %d", sender, g_iPlayerCounters[target][PLAYER_BONUS_POINTS]);
	rank.DrawText(Value);

	Format(Value, sizeof(Value), "TK: %i", sender, g_iPlayerCounters[target][PLAYER_TK_BLOCK_DAMAGE]);
	rank.DrawText(Value);

	Format(Value, sizeof(Value), "Voteban TK: %i", sender, g_iTkBlockMinReal);
	rank.DrawText(Value);

	Format(Value, sizeof(Value), "Ban TK: %i", sender, g_iTkBlockMaxReal);
	rank.DrawText(Value);

	Format(Value, sizeof(Value), "For full stats visit:\n%s", WEBSITE_STATS);
	rank.DrawText(Value);

	Format(Value, sizeof(Value), "===========================");
	rank.DrawText(Value);

	Format(Value, sizeof(Value), "Show full stats", sender);
	rank.DrawItem(Value);


	Format(Value, sizeof(Value), "Next rank", sender);
	rank.DrawItem(Value);

	Format(Value, sizeof(Value), "Top players", sender);
	rank.DrawItem(Value);

	Format(Value, sizeof(Value), "Show players", sender);
	rank.DrawItem(Value);

	Format(Value, sizeof(Value), "Close", sender);
	rank.DrawItem(Value);

	rank.Send(sender, RankPanelHandlerOption, 20);
	delete rank;
}


public Action cmdFactorTop(int client, int args)
{
	if (client)
	{
		if(IsClientInGame(client))
		{
			if(!IsFakeClient(client))
			{
				char query[128];
				Format(query, sizeof(query), "CALL PLAYER_TOP(0,20);");
				SQL_TQuery(g_dbConnection, DisplayAfTop, query, client, DBPrio_Low);
			}
		}
	}
}

public void DisplayAfTop(Handle owner, Handle hndl, const char[] error, any client) {
	if (client) {
		if(hndl != null) {
			if(StrEqual("", error)) {
				char Name[32];
				Panel top = new Panel();
				char Value[64];
				float points = 0.0;
				int number = 0;
				Format(Value, sizeof(Value), "Top assistance factor", client);
				top.SetTitle(Value);
				while (SQL_FetchRow(hndl)) {
					SQL_FetchString(hndl, 0, Name, sizeof(Name));
					points = SQL_FetchFloat(hndl, 1);
					ReplaceString(Name, sizeof(Name), "&lt;", "<");
					ReplaceString(Name, sizeof(Name), "&gt;", ">");
					ReplaceString(Name, sizeof(Name), "&#37;", "%");
					ReplaceString(Name, sizeof(Name), "&#61;", "=");
					ReplaceString(Name, sizeof(Name), "&#42;", "*");
					number++;
					Format(Value, sizeof(Value), "%i %s (%.2f)" , number, Name, points);
					top.DrawText(Value);
				}
				Format(Value, sizeof(Value), "Close", client);
				top.DrawItem(Value);
				top.Send(client, RankPanelHandler, 20);
				delete top;
			} else {
				LogError("Query failed (DisplayAfTop): %s", error);
			}
		}
	}
}

public Action cmdTop(int client, int args)
{
	int top = 10;
	if (args >= 1) {
		char arg[2];
		GetCmdArg(1, arg, 2);
		top = StringToInt(arg);
		if(top == 0) {
			CPrintToChat(client, "\x04[\x05ASC\x04]\x01 You can set the first parameter as a number between 5 and 20, example: !top 15");
			top = 10;
		} else {
			top = top > 20 ? 20 : top;
			top = top < 5 ? 5 : top;
		}
	}
	if (client) {
		if (IsClientInGame(client)) {
			if (!IsFakeClient(client)) {
				char query[256];
				Format(query, sizeof(query), "CALL PLAYER_TOP(0, %d);", top);
				SQL_TQuery(g_dbConnection, DisplayTop, query, client, DBPrio_Low);
			}
		}
	}
	return Plugin_Handled;
}

public void DisplayTop(Handle owner, Handle hndl, const char[] error, any client) {
	if (client) {
		if(hndl != null) {
			if(StrEqual("", error)) {
				char Name[32];
				Panel top = new Panel();
				char Value[64];
				int points = 0;
				int number = 0;
				Format(Value, sizeof(Value), "Top players", client);
				top.SetTitle(Value);
				while (SQL_FetchRow(hndl)) {
					SQL_FetchString(hndl, 1, Name, sizeof(Name));
					points = SQL_FetchInt(hndl, 2);
					ReplaceString(Name, sizeof(Name), "&lt;", "<");
					ReplaceString(Name, sizeof(Name), "&gt;", ">");
					ReplaceString(Name, sizeof(Name), "&#37;", "%");
					ReplaceString(Name, sizeof(Name), "&#61;", "=");
					ReplaceString(Name, sizeof(Name), "&#42;", "*");
					number++;
					Format(Value, sizeof(Value), "%i %s (%i)" ,number, Name, points);
					top.DrawText(Value);
				}
				Format(Value, sizeof(Value), "Close", client);
				top.DrawItem(Value);
				top.Send(client, RankPanelHandler, 20);
				delete top;
			} else {
				LogError("Query failed (DisplayTop): %s", error);
			}
		}
	}
}

public Action cmdNextRank(int client, int args) {
	if (client) {
		if (IsClientInGame(client)) {
			if (!IsFakeClient(client)) {
				if(g_iPlayerCounters[client][PLAYER_RANK] > 0) {
					Panel next = new Panel();
					char buffer[128];
					if (g_iPlayerCounters[client][PLAYER_RANK] == 1) {
						Format(buffer, sizeof(buffer), "You are 1st", client);
						next.SetTitle(buffer);
					} else {
						Format(buffer, sizeof(buffer), "Next Rank: %d", client, (g_iPlayerCounters[client][PLAYER_RANK] - 1));
						next.SetTitle(buffer);
						Format(buffer, sizeof(buffer), "Points required: %d", client, g_iPlayerCounters[client][PLAYER_POINTS_FOR_NEXT_RANK]);
						next.DrawText(buffer);
					}
					Format(buffer, sizeof(buffer), "More...", client);
					next.DrawItem(buffer);
					Format(buffer, sizeof(buffer), "Close", client);
					next.DrawItem(buffer);
					next.Send(client, NextRankPanelHandler, 20);
					delete next;
				} else if(CheckCommandAccess(client, "sm_fk", ADMFLAG_GENERIC, true)) {
					CPrintToChat(client, "{green}Sorry dude, you are part of the {blue}staff");
				} else {
					CPrintToChat(client, "Something is wrong with your data");
				}
			}
		}
	}
	return Plugin_Handled;
}

public void DisplayFullNextRank(Handle owner, Handle hndl, const char[] error, any client) {
	if (client) {
		if(hndl != null) {
			if(StrEqual("", error)) {
				char Name[32];
				int Points = 0;
				Panel fnext = new Panel();
				char Value[128];
				Format(Value, sizeof(Value), "Next Rank List:", client);
				fnext.SetTitle(Value);
				while (SQL_FetchRow(hndl)) {
					SQL_FetchString(hndl, 0, Name, sizeof(Name));
					Points = SQL_FetchInt(hndl, 1);
					ReplaceString(Name, sizeof(Name), "&lt;", "<");
					ReplaceString(Name, sizeof(Name), "&gt;", ">");
					ReplaceString(Name, sizeof(Name), "&#37;", "%");
					ReplaceString(Name, sizeof(Name), "&#61;", "=");
					ReplaceString(Name, sizeof(Name), "&#42;", "*");
					Format(Value, sizeof(Value), "%d points: %s", client, Points, Name);
					fnext.DrawText(Value);
				}
				Format(Value, sizeof(Value), "Close", client);
				fnext.DrawItem(Value);
				fnext.Send(client, RankPanelHandler, 20);
				delete fnext;
			} else {
				LogError("Query failed (DisplayFullNextRank): %s", error);
			}
		}
	}
}

public int RankPanelHandler(Menu menu, MenuAction action, int param1, int param2)
{

}

public int NextRankPanelHandler(Menu panel, MenuAction action, int client, int option)
{
	if (action == MenuAction_Select)
	{
		if (option == 1)
		{
			char query[128];
			Format(query, sizeof(query), "CALL PLAYER_NEXT_RANK('%s', %i);", g_playerSteamId[client], g_iPlayerCounters[client][PLAYER_POINTS]);
			SQL_TQuery(g_dbConnection, DisplayFullNextRank, query, client, DBPrio_Low);
		}
	}
	return 0;
}

public void ShowRankTarget(int sender, int target) {
	if(IsRealClient(target)) {
		CPrintToChat(sender, "Player: {blue}%N\x01 | Rank: {blue}%d\x01 | Points: {blue}%d\x01 Map points: {blue}%d", target, g_iPlayerCounters[target][PLAYER_RANK], g_iPlayerCounters[target][PLAYER_POINTS], g_iPlayerCounters[target][PLAYER_NEW_POINTS]);
	}
}

public Action cmdPoints(int client, int args) {
	if(CheckCommandAccess(client, "sm_fk", ADMFLAG_RESERVATION, true)) {
		PrintToChat(client, "Your points: %d , Your map points: %d, Your vip points: %d", g_iPlayerCounters[client][PLAYER_POINTS], g_iPlayerCounters[client][PLAYER_NEW_POINTS], calculatePointsForVip(client));
	} else {
		PrintToChat(client, "Your points: %d , Your map points: %d", g_iPlayerCounters[client][PLAYER_POINTS], g_iPlayerCounters[client][PLAYER_NEW_POINTS]);
	}
	return Plugin_Handled;
}

public Action cmdColors(int client, int args)
{
	if(IsRealClient(client))
	{
		CPrintToChat(client, "\x05The skin\x04 colors\x05 depend on your\x04 points");
		CPrintToChat(client, "\x04Light green:\x05 5K points |\x04 Yellow:\x05 10K points |\x04 Blue:\x05 20K points");
		CPrintToChat(client, "\x04Green:\x05 40K points |\x04 Purple:\x05 80K points |\x04 Pink:\x05 160K points");
		CPrintToChat(client, "\x04Red:\x05 320K |\x04 Orange:\x05 640K points |\x04 Brown:\x05 1M");
		CPrintToChat(client, "\x04Black:\x05 10M");
	}
	return Plugin_Handled;
}

public Action cmdPlaytime(int client, int args) {
	if(client) {
		PrintToChat(client, "Your playtime on this map: %d", (GetTime() - g_iPlayerCounters[client][PLAYER_START_TIME])/60%60);
	}
}

public Action cmdVoteKick(int client, int args) {
	if(	CheckCommandAccess(client, "sm_fk", ADMFLAG_RESERVATION, true) || 
		CheckCommandAccess(client, "sm_fk", ADMFLAG_GENERIC, true) ||
		(g_iPlayerCounters[client][PLAYER_RANK] > 0 && g_iPlayerCounters[client][PLAYER_RANK] < 21)) {
		if(g_iPlayerCounters[client][PLAYER_VOTE_KICK] < 3) {
			ShowVoteKickList(client);
		} else {
			PrintToChat(client, "\x04[\x05ASC\x04]{default} You has try to kick more that {blue}3 times{default}, wait for the next map.");
		}
	} else {
		PrintToChat(client, "\x04[\x05ASC\x04]{default} You don't have access to this command.");
	}
}

public int ShowVoteKickList(int client) {
	Menu hMenu = CreateMenu(MenuHandler_VoteKick);
	char str_name[256], str_userid[11];	
	hMenu.SetTitle("Vote Kick");
	hMenu.ExitButton = true;
	int players = 0;
	for(int i = 1; i <= MaxClients; i++) {
		if(client != i) {
			if (IsClientInGame(i)) {
				if (!IsFakeClient(i)) {
					if(!CheckCommandAccess(i, "sm_fk", ADMFLAG_GENERIC, true)) {
						IntToString(i, str_userid, sizeof(str_userid));
						Format(str_name, sizeof(str_name), "%N [RANK: %d]", i, g_iPlayerCounters[i][PLAYER_RANK]);
						hMenu.AddItem(str_userid, str_name);
						players++;
					}
				}
			}
		}
	}
	if (players == 0) {
		hMenu.AddItem("", "No available players", ITEMDRAW_DISABLED);
	}
	hMenu.Display(client, MENU_TIME_FOREVER);
}


public int MenuHandler_VoteKick(Menu menu, MenuAction action, int client, int item) {
	switch(action) {
		case MenuAction_End: delete menu;
		case MenuAction_Select: {
			char char_user_id[12];
			menu.GetItem(item, char_user_id, sizeof(char_user_id));
			int target_user_id = StringToInt(char_user_id);
			if(target_user_id > 0) {
				g_iPlayerCounters[client][PLAYER_VOTE_KICK] += 1;
				ServerCommand("sm_votekick \"#%d\" \"%s %N\"", GetClientUserId(target_user_id), "Vote kick, started by ", client);
				CPrintToChatAll("\x04[\x05ASC\x04] %N\x01 start a vote kick for \x04%N", client, target_user_id);
			}
		}
	}
}

public Action cmdFactor(int client, int args)
{
	if (client)
	{
		PrintToChat(client, "\x05Your assistance factor: \x04%.2f", g_playerAssistanceFactor[client]);
		PrintToChat(client, "\x05Your bonus points: \x04%d", g_iPlayerCounters[client][PLAYER_BONUS_POINTS]);
	}
	return Plugin_Handled;
}

public Action cmdMapTop(int client, int args){
	tplMapTop(client);
}


void tplMapTop(int client) {

	// Inicializando variables
	char playerNameBestBuffer[MAX_NAME_LENGTH] = "", // save name of top map player
		playerNameWorstBuffer[MAX_NAME_LENGTH] = "", // save name of worse map player
		playerNameHelperBuffer[MAX_NAME_LENGTH] = ""; // save name of best helper in map

	int totalPoints = 0, // total points in map of all players
		rankBestPlayer = 0, // Save the rank of map top player
		rankWorstPlayer = 0, // Save the rank of worst map player
		rankHelper = 0, // know rank for best helper
		pointsLastPlayer = 0,
		pointsCurrentWorstPlayer = 0,
		pointsCurrentBestPlayer = 0,
		counterCurrentHelper = 0, // know map best help
		pointsCurrentHelper = 0; // Know points for best helper

	// Loop client
	for (int i = 1; i <= MaxClients; i++) {
		// Check if is real client
		if (IsRealClient(i)) {
			// Get Client name
			char clientName[MAX_NAME_LENGTH];
			GetClientName(i, clientName, sizeof(clientName));
			// Check if Points in map of player is > N>>J
			if (g_iPlayerCounters[i][PLAYER_NEW_POINTS] > pointsLastPlayer) {
				pointsCurrentBestPlayer = g_iPlayerCounters[i][PLAYER_NEW_POINTS];
				playerNameBestBuffer = clientName;
				rankBestPlayer = g_iPlayerCounters[i][PLAYER_RANK];
			// Check if Points in map of player is < N>>J
			} else if (g_iPlayerCounters[i][PLAYER_NEW_POINTS] < pointsLastPlayer) {
				pointsCurrentWorstPlayer = g_iPlayerCounters[i][PLAYER_NEW_POINTS];
				playerNameWorstBuffer = clientName;
				rankWorstPlayer = g_iPlayerCounters[i][PLAYER_RANK];
			}
			// Best team helper on map
			int myHelpAtMap = g_iPlayerCounters[i][PLAYER_FRIENDS_ABOVE] + g_iPlayerCounters[i][PLAYER_FRIENDS_CURED] + g_iPlayerCounters[i][PLAYER_FRIENDS_REVIVED] + g_iPlayerCounters[i][PLAYER_FRIENDS_RESCUED];
			// Check if is the best helper on map
			if(myHelpAtMap > counterCurrentHelper) {
				counterCurrentHelper = myHelpAtMap;
				playerNameHelperBuffer = clientName;
				rankHelper = g_iPlayerCounters[i][PLAYER_RANK];
				pointsCurrentHelper = g_iPlayerCounters[i][PLAYER_POINTS];
			}
			totalPoints += g_iPlayerCounters[i][PLAYER_NEW_POINTS]; // sum of total points of all players in map
			pointsLastPlayer = g_iPlayerCounters[i][PLAYER_NEW_POINTS];
		}
	}
	// Count tries of map
	if (hm_count_fails.IntValue > 0) { 
		// Calculate function is use to give a % of points according to tries
		CPrintToChat(client, "Map total points: %d (%d)", totalPoints, calculatePoints(totalPoints));
		// Print to chat Map best player
		CPrintToChat(client, "[MVP] {blue}%s (rank: %d; points: %d [%d])", playerNameBestBuffer, rankBestPlayer, pointsCurrentBestPlayer, calculatePoints(pointsCurrentBestPlayer));
		// Check if Helper name is not empty
		if(!StrEqual(playerNameHelperBuffer, "")) {
			// Print to Chat map best helper
			CPrintToChat(client, "[Lifeguard] {blue}%s (rank: %d; points: %d [%d])", playerNameHelperBuffer, rankHelper, pointsCurrentHelper, calculatePoints(pointsCurrentHelper));
		}
	} else {
		// if is first try and no need to calculate points
		// PrintToChat Total points of map
		PrintToChat(client, "Map total points: %d", totalPoints);
		// Print to chat Map best player
		CPrintToChat(client, "[MVP] {blue}%s (rank: %d; points: %d [%d])", playerNameBestBuffer, rankBestPlayer, pointsCurrentBestPlayer, calculatePoints(pointsCurrentBestPlayer));
		// Verificando si existe mejor ayudante
		if(!StrEqual(playerNameHelperBuffer, "")) {
			// Print to Chat map best helper
			CPrintToChat(client, "[Lifeguard] {blue}%s (rank: %d; points: %d [%d])", playerNameHelperBuffer, rankHelper, pointsCurrentHelper, calculatePoints(pointsCurrentHelper));
		}
	}
	// Check if pointsCurrentBestPlayer player have points < 0 to print if not no print
	if (pointsCurrentBestPlayer < 0) {
		CPrintToChat(client, "[Noob] {blue}%s (rank: %d; points: %d [%d])", playerNameWorstBuffer, rankWorstPlayer, pointsCurrentWorstPlayer, calculatePoints(pointsCurrentWorstPlayer));
	}
	// Check tries of map and if > 0
	if (hm_count_fails.IntValue > 0) {
		// doueble check of tries map?
		if (g_iFailedAttempts == 0) {
			// Check is not print before to print
			if (!g_isPrint) {

				g_isPrint = true;
				PrintToChatAll("The map was passed on the first try!");
				// PrintToChatAll("VIP will receive + 20%%%% bonus points in this map.");
				PrintToChatAll("All players will receive 100%%%% of their points earned for this map.");
			}
		}
		else
		{
			// Check is not print before to print
			if (!g_isPrint)
			{
				g_isPrint = true;
				int porcent = 100 - g_iFailedAttempts * 10;
				PrintToChatAll("It took %d attempts to finish this map!", g_iFailedAttempts);
				// PrintToChatAll("VIP will receive + 20%%%% bonus points in this map.");
				PrintToChatAll("All players will receive %d%%%% of their points earned for this map.", porcent);
			}
		}
		// Print my map points in map with calculate according to tries
		PrintToChat(client, "Your map points: %d (%d)", g_iPlayerCounters[client][PLAYER_NEW_POINTS], calculatePoints(g_iPlayerCounters[client][PLAYER_NEW_POINTS]));
	}
	else
	{
		// Print my map points in map
		PrintToChat(client, "Your map points: %d", g_iPlayerCounters[client][PLAYER_NEW_POINTS]);
	}
}

int calculatePoints(int points) {
	return (points > 0) ? (RoundToZero( (points * 1.0) * ( 100.0 - (g_iFailedAttempts * 10.0) ) / 100.0)) : points;
}

void GrantPlayerColor(int client) {
	if (IsValidClient(client)) {
		if (IsClientConnected(client)) {
			if(IsClientInGame(client)) {
				if(GetClientTeam(client) == TEAM_SURVIVORS) {
					if(IsPlayerAlive(client)) {
						if(CheckCommandAccess(client, "sm_fk", ADMFLAG_ROOT, true)) {
							SetEntityRenderColor(client, 0, 0, 0, 255); // Negro para administrador
						} else if(CheckCommandAccess(client, "sm_fk", ADMFLAG_GENERIC, true)) {
							SetEntityRenderColor(client, 0, 176, 246, 255); // Cyan
						} else if (g_iPlayerCounters[client][PLAYER_POINTS] > 1280000) {
							SetEntityRenderColor(client, 102, 51, 0, 255); // Cafe
						} else if (g_iPlayerCounters[client][PLAYER_POINTS] > 640000) {
							SetEntityRenderColor(client, 255, 97, 3, 255); // Orange color
						} else if (g_iPlayerCounters[client][PLAYER_POINTS] > 320000) {
							SetEntityRenderColor(client, 255, 0, 0, 255); // Red color
						} else if (g_iPlayerCounters[client][PLAYER_POINTS] > 160000) {
							SetEntityRenderColor(client, 255, 104, 240, 255); // pink color FF68F0
						} else if (g_iPlayerCounters[client][PLAYER_POINTS] > 80000) {
							SetEntityRenderColor(client, 102, 25, 140, 255); // purple 66198C
						} else if (g_iPlayerCounters[client][PLAYER_POINTS] > 40000) {
							SetEntityRenderColor(client, 0, 139, 0, 255); // green color
						} else if (g_iPlayerCounters[client][PLAYER_POINTS] > 20000) {
							SetEntityRenderColor(client, 0, 0, 255, 255); // Blue colour
						} else if (g_iPlayerCounters[client][PLAYER_POINTS] > 10000) {
							SetEntityRenderColor(client, 255, 255, 0, 255); // yellow
						} else if (g_iPlayerCounters[client][PLAYER_POINTS] > 5000) {
							SetEntityRenderColor(client, 173, 255, 47, 255); // light green color
						}
						ServerCommand("sm_rcon setaura #%d", GetClientUserId(client));
					}
				}
			}
		}
	}
}

public Action Command_Setinfo(int client, const char[] _command, int _argc)
{
	char _arg[32];
	GetCmdArg(1, _arg, sizeof(_argc));
	if (StrEqual(_arg, "name", false)) {
		return Plugin_Handled;
	}
	return Plugin_Continue;
} 

public Action eventPlayerSpawn(Event event, const char[] name, bool dontBroadcast) {
	ADPlayerSpawn(event);
	int client = GetClientOfUserId(event.GetInt("userid"));
	CreateTimer(6.0, TimedGrantPlayerColor, client);
}

public Action TimedGrantPlayerColor(Handle timer, any client) {
	GrantPlayerColor(client);
}

bool IsRealClient(int client)
{
	if(IsValidClient(client))
	{
		if(IsClientInGame(client))
		{
			if(!IsFakeClient(client))
			{
				return true;
			}
		}
	}
	return false;
}

bool IsValidClient(int client)
{
	if (IsValidEntity(client))
	{
		if(client)
		{
			if(client <= MaxClients)
			{
				return true;
			}
		}
	}
	return true;
}

public Action eventPlayerTeamPost(Event event, const char[] name, bool dontBroadcast) {
	if (!event.GetBool("disconnect")) {
		int client = GetClientOfUserId(event.GetInt("userid"));
		if(client) {
			if(IsClientInGame(client)) {
				if(!IsFakeClient(client)) {
					CreateTimer(0.1, Timer_ADPlayerTeam);
				}	
			}
		}
	}
	return Plugin_Continue;
}

public Action Timer_ADPlayerTeam(Handle timer)
{
	ADPlayerTeam();
}

void ADPlayerTeam()
{
	// ServerCommand("sm_autodifficulty_refresh");
	AutoDifficultyRefresh();
	updateptystatslayers();
}

float Calculate_Rank_Mod() {

	float local_result = 1.0;

	switch (l4d2_rankmod_mode.IntValue) {
		case 0, 1, 2: {
			if (g_iRegisteredPlayers < cvar_maxplayers) {
				return SDifficultyMultiplier.FloatValue;
			}

			float sum_low = 0.0;
			float sum_high = 0.0;

			for (int i = 1; i <= cvar_maxplayers; i++) {
				sum_low += Sum_Function(i * 1.0);
				sum_high += Sum_Function(g_iRegisteredPlayers * 1.0 + 1.0 - i * 1.0);
			}

			sum_low *= 1.0 / cvar_maxplayers * 1.0;
			sum_high *= 1.0 / cvar_maxplayers * 1.0;
			float sum_current = 0.0;
			float current_player_rank = 0.0;
			float current_players_count = 0.0;
			for (int i = 1; i <= MaxClients; i++) {
				if (IsClientInGame(i)) {
					if (!IsFakeClient(i)) {
						if (GetClientTeam(i) == TEAM_SURVIVORS) {
							current_players_count++;
							current_player_rank = g_iPlayerCounters[i][PLAYER_RANK] * 1.0;
							if (current_player_rank < 1.0) {
								// el jugador aún no está clasificado
								current_player_rank = g_iRegisteredPlayers * 0.5;
							}
							sum_current += Sum_Function(g_iRegisteredPlayers + 1.0 - current_player_rank);
						}
					}
				}
			}

			if (current_players_count < 1) {
				return local_result;
			}

			sum_current *= 1.0 / current_players_count * 1.0;
			float k = (l4d2_rankmod_max.FloatValue - l4d2_rankmod_min.FloatValue) / (sum_high - sum_low);
			float p = l4d2_rankmod_max.FloatValue - k * sum_high;
			local_result = k * sum_current + p;

			if (local_result < l4d2_rankmod_min.FloatValue)	{
				local_result = l4d2_rankmod_min.FloatValue;
			} else if (local_result > l4d2_rankmod_max.FloatValue) {
				local_result = l4d2_rankmod_max.FloatValue;
			}

			if (l4d2_rankmod_mode.IntValue == 1) {
				local_result += SDifficultyMultiplier.FloatValue;
			}

			if (l4d2_rankmod_mode.IntValue == 2) {
				local_result *= SDifficultyMultiplier.FloatValue;
			}

			l4d2_difficulty_multiplier.SetFloat(local_result, false, false);
			
			return local_result;
		}
		case 3, 4, 5: {
			if (g_iRegisteredPlayers < 3600) {
				return SDifficultyMultiplier.FloatValue;
			}
			
			g_fRankSum = 0.0;
			
			int players_count = 0;
			
			for (int i = 1; i <= MaxClients; i++) {
				if (IsClientInGame(i)) {
					if (!IsFakeClient(i)) {
						if (GetClientTeam(i) == TEAM_SURVIVORS) {
							if (g_iPlayerCounters[i][PLAYER_RANK] == 0) g_fRankSum += 0.0;
							else if (g_iPlayerCounters[i][PLAYER_RANK] <= 10) g_fRankSum += 5.0;
							else if (g_iPlayerCounters[i][PLAYER_RANK] <= 25) g_fRankSum += 4.4;
							else if (g_iPlayerCounters[i][PLAYER_RANK] <= 50) g_fRankSum += 3.8;
							else if (g_iPlayerCounters[i][PLAYER_RANK] <= 100) g_fRankSum += 3.2;
							else if (g_iPlayerCounters[i][PLAYER_RANK] <= 200) g_fRankSum += 2.6;
							else if (g_iPlayerCounters[i][PLAYER_RANK] <= 400) g_fRankSum += 2.0;
							else if (g_iPlayerCounters[i][PLAYER_RANK] <= 800) g_fRankSum += 1.4;
							else if (g_iPlayerCounters[i][PLAYER_RANK] <= 1600) g_fRankSum += 0.8;
							else if (g_iPlayerCounters[i][PLAYER_RANK] <= 3200) g_fRankSum += 0.2;
							players_count++;
						}
					}
				}
			}

			if (players_count < 1) {
				players_count = 1;
			}
			
			local_result = ((g_fRankSum * 1.0 - (players_count * 1.5)) / (players_count * 1.0)) / 6.0 + 0.75;

			if (local_result < l4d2_rankmod_min.FloatValue) {
				local_result = l4d2_rankmod_min.FloatValue;
			} else if (local_result > l4d2_rankmod_max.FloatValue) {
				local_result = l4d2_rankmod_max.FloatValue;
			}

			if (l4d2_rankmod_mode.IntValue == 4) {
				local_result += SDifficultyMultiplier.FloatValue;
			}
			
			if (l4d2_rankmod_mode.IntValue == 5) {
				local_result *= SDifficultyMultiplier.FloatValue;
			}
			
			return local_result;
		}
	}

	return SDifficultyMultiplier.FloatValue;
}

float Sum_Function(const float input_value) {

	if (input_value == 0.0) {
		return 0.0;
	}

	float cvar_rankmod_logarithm = l4d2_rankmod_logarithm.FloatValue;

	if (cvar_rankmod_logarithm >= 1.0) {
		return Logarithm(input_value, cvar_rankmod_logarithm);
	}

	if (cvar_rankmod_logarithm >= 0.0 && cvar_rankmod_logarithm < 1.0) {
		return input_value * cvar_rankmod_logarithm;
	}

	if (cvar_rankmod_logarithm == 0.0) {
		// una relación lineal simple
		// простая линейная зависимость
		return input_value; 
	}
	
	if (cvar_rankmod_logarithm == -1.0) {
		float x = Logarithm(input_value, 10.0);
		return x * x;
	}

	if (cvar_rankmod_logarithm == -2.0) {
		return (input_value * input_value / ((input_value + g_iRegisteredPlayers * 4) / (25.0 * g_iRegisteredPlayers))) / 10.0;
	}

	if (cvar_rankmod_logarithm == -3.0) {
		float x = Logarithm(input_value, 10.0);
		return x * x / (0.001 * x + 1.11);
	}

	return input_value;
}

public Action cmdRankSum(int client, int args) {
	if (client == 0) {
		PrintToServer("Rank Sum: %f", g_fRankSum);
	} else {
		PrintToChat(client, "\x05Rank Sum: \x04%f", g_fRankSum);
	}
}

public Action cmdPointsOn(int client, int args) {
	if (!g_pointsEnabled) {
		g_pointsEnabled = true;
	}
}

public Action cmdPointsOff(int client, int args) {
	if (g_pointsEnabled) {
		g_pointsEnabled = false;
	}
}

public Action eventMapTransition(Event event, const char[] name, bool dontBroadcast) {
	ADOnMapStart();
	PrintMapPoints();
	StopMapTiming();
}

public Action eventFinalWin(Event event, const char[] name, bool dontBroadcast){
	PrintMapPoints();
	StopMapTiming();
	UpdatePlayersStats();
}

void PrintMapPoints() {
	for (int i = 1; i <= MaxClients; i++) {
		if (IsRealClient(i)) {
			int bonus = calculatePointsForVip(i);
			g_iPlayerCounters[i][PLAYER_NEW_POINTS] += bonus;
			tplMapTop(i);
		}
	}
}

int calculatePointsForVip(int client) {
	int bonus = 0;
	if(CheckCommandAccess(client, "sm_fk", ADMFLAG_RESERVATION, true) && !CheckCommandAccess(client, "sm_fk", ADMFLAG_GENERIC, true)) {
		int points = g_iPlayerCounters[client][PLAYER_NEW_POINTS];
		if(points > 0) {
			bonus = RoundToNearest(points * 0.2);
			g_iPlayerCounters[client][PLAYER_POINTS_VIP] += bonus;
		}
	}
	return bonus;
}

public Action cmdGivePoints(int client, int args) {
	if (args == 2) {
		char arg[65];
		char arg2[32];
		GetCmdArg(1, arg, sizeof(arg));
		GetCmdArg(2, arg2, sizeof(arg2));

		char target_name[MAX_TARGET_LENGTH];
		int target_list[MAXPLAYERS];
		int target_count;
		bool tn_is_ml;

		int Score = StringToInt(arg2);
		if ((target_count = ProcessTargetString(arg, client, target_list, MAXPLAYERS, 0, target_name, sizeof(target_name), tn_is_ml)) <= 0) {
			ReplyToTargetError(client, target_count);
			return Plugin_Handled;
		}
		else {
			ReplyToCommand(client, "Point for player: %s set to: %d", target_name, Score);
			for (int i = 0; i < target_count; i++) {
				int player = target_list[i];
				g_iPlayerCounters[player][PLAYER_POINTS_GIFT] += Score;
				AddScore(player, Score);
			}
			return Plugin_Handled;
		}
	} else {
		ReplyToCommand(client, "sm_givepoints <#userid|name> [Score]");
		return Plugin_Handled;
	}
}

public void AddScore(int client, int Score) {
	if (Score > 0) {
		if(g_pointsEnabled) {
			PrintToChat(client, "\x05+%i", Score);
			g_iPlayerCounters[client][PLAYER_NEW_POINTS] += Score;
		}
	} else if (Score < 0) {
		PrintToChat(client, "\x04%i", Score);
		g_iPlayerCounters[client][PLAYER_NEW_POINTS] += Score;
		g_iPlayerCounters[client][PLAYER_POINTS_LOST] += (-1 * Score);
	}
}

public Action cmdRank(int client, int args) {
	if (args == 0) {
		int target = GetClientAimTarget(client, false);
		if (target > 0 && target <= MaxClients && !IsFakeClient(target)) {
			ShowRankTarget(client, target);
		}
		else {
			if(g_iPlayerCounters[client][PLAYER_RANK] == 0) {
				if(!CheckCommandAccess(client, "sm_fk", ADMFLAG_GENERIC, true)) {
					getPlayer(client);
				}
			}
			ShowRank(client);
		}
			
		return Plugin_Handled;
	}
	else if (args == 1)
	{
		char arg[65];
		GetCmdArg(1, arg, sizeof(arg));

		char target_name[MAX_TARGET_LENGTH];
		int target_list[MAXPLAYERS];
		int target_count;
		bool tn_is_ml;

		int targetclient;
		if ((target_count = ProcessTargetString(arg, client, target_list, MAXPLAYERS, 0, target_name, sizeof(target_name), tn_is_ml)) <= 0)
		{
			ReplyToTargetError(client, target_count);
			return Plugin_Handled;
		}
		else
		{
			CPrintToChat(client, "\x04[\x05RANK\x04] {default}You are viewing the player statistics of {blue}%s", target_name);

			for (int i = 0; i < target_count; i++)
			{
				targetclient = target_list[i];

				DisplayRank(targetclient, client);
			}
		}
	}
	else
	{
		ReplyToCommand(client, "sm_rank <#userid|name>");
	}
	
	return Plugin_Handled;
}

public Action cmdUpdatePlayers(int client, int args) {
	UpdatePlayersStats();
}

public Action onVote(int client, int args) {
	PrintToChat(client, "\x01Vote access denied!");
	return Plugin_Handled;
}

public Action eventStartAreaPost(Event event, const char[] name, bool dontBroadcast) {
	if (bIsFirstMapOfCampaign()) {
		StartMapTiming();
		return Plugin_Continue;
	}
	return Plugin_Continue;
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if (StrEqual(classname, "prop_door_rotating_checkpoint"))
	{
		if (GetEntProp(entity, Prop_Send, "m_eDoorState") == 0)
		{
			HookSingleEntityOutput(entity, "OnFullyOpen", OnStartSFDoorFullyOpened, true);
		}
	}
}

public int OnStartSFDoorFullyOpened(const char[] output, int caller, int activator, float delay) {
	StartMapTiming();
}

public void StartMapTiming() {
	if (g_fMapTimingStartTime == 0.0) {
		g_fMapTimingStartTime = GetEngineTime();
		// EmitSoundToAll(SOUND_MAPTIME_START);
	}
}

public void StopMapTiming(){
	if (g_fMapTimingStartTime > 0.0) {
		float TotalTime = GetEngineTime() - g_fMapTimingStartTime;
		g_fMapTimingStartTime = -1.0;
		char TimeLabel[32];
		vGetTimeLabel(TotalTime, TimeLabel, sizeof(TimeLabel));
		EmitSoundToAll(SOUND_MAPTIME_FINISH);
		CPrintToChatAll("It took %s to finish this map!", TimeLabel);
	}
}

/**
* Evento al correr cualquier cmd
*/
public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon) {
	if (!IsFakeClient(client)) {
		if(g_iPlayerCounters[client][PLAYER_POINTS] < POINTS_TO_LAUNCH_GRENADE) {
			int activeWeapon = GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");
			if (activeWeapon > -1) {
				char weponName[32];
				GetEdictClassname(activeWeapon, weponName, sizeof(weponName));
				if ( (buttons & IN_ATTACK) && ( StrContains(weponName, "vomitjar") > -1 || StrContains(weponName, "molotov") > -1 ) ) {
					buttons &= ~IN_ATTACK;
					PrintHintText(client, "It is forbidden to use grenades for players\nwith less than %d points!", POINTS_TO_LAUNCH_GRENADE);
				}
			}
		}
	}
	return Plugin_Continue;
}

/**
*	Handle when a user send a message then concatenate "tag + user : + message"
*/
public Action onMessage(int client, int args) {
	// Verificando si es un trigger ! o /
	if(IsChatTrigger()) {
		g_iPlayerCounters[client][PLAYER_COUNTER_COMMANDS]++;
		// Deteniendo el evento
		return Plugin_Handled;
	}
	// Verificando que el jugador sea valido
	if(IsValidClient(client)) {
		if(client > 0) {
			g_iPlayerCounters[client][PLAYER_COUNTER_MESSAGES]++;
			// Verificando si el jugador es un vip/mod/admin
			if(CheckCommandAccess(client, "sm_fk", ADMFLAG_GENERIC, true) ||
				CheckCommandAccess(client, "sm_fk", ADMFLAG_RESERVATION, true) ||
				g_iPlayerCounters[client][PLAYER_RANK] > 0 && g_iPlayerCounters[client][PLAYER_RANK] < 40) {
				// Inicializando variable
				char message[256];
				GetCmdArgString(message, sizeof(message));
				message[ strlen(message)-1 ] = '\0';
				// Verificando si tiene permisos como root
				if(CheckCommandAccess(client, "sm_fk", ADMFLAG_ROOT, true)) {
					// Imprimiendo mensaje 
					CPrintToChatAll("\x03[\x04A\x03] {blue}%N: {default}%s", client, message[1]);
				// Verificando si tiene permisos como moderador
				} else if(CheckCommandAccess(client, "sm_fk", ADMFLAG_GENERIC, true)) {
					// Imprimiendo mensaje como mod
					CPrintToChatAll("\03[\x04M\03] {blue}%N: {default}%s", client, message[1]);
				// Verificando si tiene permisos como vip
				} else if(CheckCommandAccess(client, "sm_fk", ADMFLAG_RESERVATION, true)) {
					// Verificando si pertenece al top 40
					if(g_iPlayerCounters[client][PLAYER_RANK] > 0 && g_iPlayerCounters[client][PLAYER_RANK] < 40) {
						// Imprimiendo mensaje
						CPrintToChatAll("\x03[\x04V\x03]\x04[\x05RANK-%d\x04] {blue}%N: {default}%s", g_iPlayerCounters[client][PLAYER_RANK], client, message[1]);
					} else {
						// Imprimiendo mensaje
						CPrintToChatAll("\x03[\x04V\x03]\x05 {blue}%N: {default}%s", client, message[1]);
					}
				// Verificando si pertene al top 40
				} else if(g_iPlayerCounters[client][PLAYER_RANK] > 0 && g_iPlayerCounters[client][PLAYER_RANK] < 25) {
					// Imprimiendo mensaje
					CPrintToChatAll("\x04[\x05RANK-%d\x04] {blue}%N: {default}%s", g_iPlayerCounters[client][PLAYER_RANK], client, message[1]);
				}
				return Plugin_Handled;
			}
		} else {
			// char message[256];
			// GetCmdArgString(message, sizeof(message));
			// CPrintToChatAll("\x04[\x05CONSOLE\x04] {default}%s ----", g_iPlayerCounters[client][PLAYER_RANK], client, message);
		}
		
	} else {
		CPrintToChatAll("asdñklfhjasdfkhasd");
	}
	return Plugin_Continue;
}

void printTotalDamageTank(int tank = 0) {
	int total_health = g_iTankHealth[tank];
	char Message[256];
	Format(Message, 256, "\x04[\x05FRAGS\x04]\x01 \x03%s \x04(\x05%d-HP\x04) \x01 was killed by: \n", g_sTankName[tank], total_health);
	printTotalDamage(tank, g_iTankDamage, Message, total_health);
}


void printTotalDamage(int victim, int[][] damageList, char[] Message, int total_health) {
	char TempMessage[64];
	int attackers[MAXPLAYERS+1][3];
	int attacker_counter = 0;
	for(int i = 1; i < MaxClients; i++) {
		int damage = damageList[victim][i];
		damageList[victim][i] = 0;
		if(damage > 0) {
			if(IsClientInGame(i)) {
				if(!IsFakeClient(i)) {
					if(GetClientTeam(i) == TEAM_SURVIVORS) {
						attackers[attacker_counter][0] = i;
						attackers[attacker_counter][1] = damage;
						attackers[attacker_counter][2] = iGetPercent(damage, total_health);
						AddScore(i, attackers[attacker_counter][2]);
						attacker_counter++;
					}
				}
			}
		}
	}
	if(attacker_counter > 0) {
		SortCustom2D(attackers, attacker_counter, iSortFunc);
		int length = (attacker_counter > MAX_FRAGGERS) ? MAX_FRAGGERS : attacker_counter;
		for (int i = 0; i < length; i++) {
			Format(TempMessage, sizeof(TempMessage), "{blue}%N: \x01%d\x05[\x04%d%%%%\x05]\n", attackers[i][0], attackers[i][1], attackers[i][2]);
			StrCat(Message, 256, TempMessage);
		}	
		CPrintToChatAll(Message);
	}
}

/**
* Metodo para imprimir los mejores jugadores en cuestion de frags
* @param int client
* @return void
*/
void printTotalFrags(int client = 0) {
	char Message[256];
	char TempMessage[64];
	Message = "\x04[\x05FRAGS\x04]\x01 ";
	int fraggers[MAXPLAYERS+1][2];
	int frag_counter = 0;
	for(int i = 1; i < MaxClients; i++) {
		if (g_iPlayerCounters[i][PLAYER_FRAGS] > 0) {
			if(IsClientInGame(i)) {
				if(!IsFakeClient(i)) {
					if(GetClientTeam(i) == TEAM_SURVIVORS) {
						fraggers[frag_counter][0] = i;
						fraggers[frag_counter][1] = g_iPlayerCounters[i][PLAYER_FRAGS];
						frag_counter++;
					}
				}
			}
		}
	}
	if(frag_counter > 0) {
		SortCustom2D(fraggers, frag_counter, iSortFunc);
		bool more_than_one = false;
		int length = (frag_counter > MAX_FRAGGERS) ? MAX_FRAGGERS : frag_counter;
		for (int i = 0; i < length; i++) {
			if (more_than_one) {
				Format(TempMessage, sizeof(TempMessage), "\x01, {blue}%N: \x01%d", fraggers[i][0], fraggers[i][0]);
			} else {
				Format(TempMessage, sizeof(TempMessage), "{blue}%N: \x01%d", fraggers[i][0], fraggers[i][1]);
				more_than_one = true;
			}
			StrCat(Message, sizeof(Message), TempMessage);
		}	
		if(client) {
			CPrintToChat(client, Message);
		} else {
			CPrintToChatAll(Message);
		}
	} else {
		CPrintToChatAll("\x04[\x05FRAGS\x04]\x01 Without frags");
	}
}