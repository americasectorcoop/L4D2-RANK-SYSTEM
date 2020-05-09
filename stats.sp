#include <sourcemod>
#pragma semicolon 1
#pragma newdecls required
#include <sdktools>
#include <sdkhooks>
#include <colors>
#include <data/zombieClass>
#include <data/teams>
#include <stats/database>

#define DEBUG true

#if SOURCEMOD_V_MINOR < 7
 #error Old version sourcemod!
#endif

#define _FCVAR_PLUGIN_ 0

#define VERSION "5.0.0"

#define WEBSITE_STATS "http://l4d.dev/stats"
#define BANS_URL "l4d.dev/bans"

#define TROPHY false

#define MAX_LINE_WIDTH 30
#define PROFILE_ID_SIZE 18

// Numero de zombies asesinados para premiar dar puntos
#define KILL_COUNT_INFECTED 15
// Numero de puntos a necesitar antes de lanzar una granada
#define POINTS_TO_LAUNCH_GRENADE 5000
// Numero de puntos negativos para patear a un jugador 
#define POINTS_NEGATIVE_FOR_KICK_PLAYERS -2000

#define SOUND_MAPTIME_START "level/countdown.wav"
#define SOUND_MAPTIME_FINISH "level/bell_normal.wav"
#define SOUND_JOIN "ui/beepclear.wav"

int g_iPillsGiven[4096];
int g_iAdrenalineGiven[4096];
int g_iStatsBalans = 0;

// Numero de jugadores registrados
int g_iRegisteredPlayers = 0;
int g_iFailedAttempts = 0;

float g_fRankSum = 0.0;
float g_fMapTimingStartTime = -1.0;

bool g_pointsEnabled = true;

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

#include <coop/stock>
#include <coop/PlayersInfo>
#include <coop/MapPlayerTop>
#include <coop/PlayerPunishments>
#include <coop/PlayerFrags>
#include <coop/autodifficulty>
#include <coop/damage>
#include <coop/votes/mute>
#include <coop/votes/kick>

public Plugin myinfo = {
  name = "Rank System",
  author = "Aleexxx",
  description = "Player ranks with autodifficulty",
  version = VERSION,
  url = "https://l4d.dev/about/rank-system"
}

public void OnPluginStart() {
  LoadTranslations("common.phrases");
  LoadTranslations("tystats.phrases");

  vStartSQL();

  CoopAutoDiffOnPluginStart();
  DamageOnPluginStart();

  RegConsoleCmd("callvote", OnAnyVote);

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
  HookEvent("player_spawn", OnPlayerSpawn);
  HookEvent("witch_killed", OnEventWitchKilled);
  HookEvent("witch_harasser_set", OnWitchDisturb);

  HookEvent("upgrade_pack_added", OnUpgradePackAdded);
  HookEvent("pills_used", OnPlayerPillsUsed);
  HookEvent("adrenaline_used", OnPlayerAdrenalineUsed);
  HookEvent("player_disconnect", OnPlayerDisconnect);
  HookEvent("player_death", OnPlayerDeath);
  HookEvent("player_incapacitated", OnPlayerIncap);
  HookEvent("player_hurt", OnPlayerHurt);
  HookEvent("round_start", OnRoundStart);
  HookEvent("heal_success", OnPlayerHelp);
  HookEvent("defibrillator_used", OnPlayerDefig);
  HookEvent("revive_success", OnReviveSuccess);
  HookEvent("player_now_it", OnPlayerNowIt);
  HookEvent("survivor_rescued", OnPlayerRescued);
  HookEvent("award_earned", OnAward);
  HookEvent("player_team", OnPlayerTeamPost, EventHookMode_Post);
  HookEvent("map_transition", OnMapTransition);
  HookEvent("finale_win", OnFinalWin);
  HookEvent("player_left_start_area", OnStartAreaPost, EventHookMode_Post);
  HookEvent("player_left_checkpoint", OnStartAreaPost, EventHookMode_Post);
  HookEvent("molotov_thrown", OnMolotovThrown);
  HookEvent("melee_kill", OnMeleeKill);
  HookEvent("tank_spawn", OnTankSpawn); 
  HookEvent("tank_killed", OnTankKilled);


  AddCommandListener(Command_Setinfo, "setinfo");

  RegConsoleCmd("sm_chat_colors", cmdChatColors);
  RegConsoleCmd("sm_rank", cmdRank, "sm_rank <target>");
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

  RegConsoleCmd("say", OnMessage);
  RegConsoleCmd("say_team", OnMessage);

  RegAdminCmd("sm_points_on", cmdPointsOn, ADMFLAG_GENERIC, "Activa los puntos de la partida");
  RegAdminCmd("sm_points_off", cmdPointsOff, ADMFLAG_GENERIC, "Desactiva los puntos de la partida");

  RegAdminCmd("sm_givepoints", cmdGivePoints, ADMFLAG_ROOT, "sm_givepoints <target> [Score]");

  l4d2_rankmod_mode = CreateConVar("l4d2_rankmod_mode", "0", "");
  l4d2_rankmod_min = CreateConVar("l4d2_rankmod_min", "0.5", "");
  l4d2_rankmod_max = CreateConVar("l4d2_rankmod_max", "1.0", "");
  l4d2_rankmod_logarithm = CreateConVar("l4d2_rankmod_logarithm", "0.008", "");

  SDifficultyMultiplier = CreateConVar("l4d2_difficulty_stats", "1.0", "");
  l4d2_difficulty_multiplier = CreateConVar("l4d2_difficulty_multiplier", "1.2", "");

  // WE FORCE TO RUNNING MAP START EVENT WHEN PLUGIN IS LOADED/RELOADED
  CreateTimer(1.0, MapStart);
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) {
  CreateNative("TYSTATS_GetPoints", Native_TYSTATS_GetPoints);
  CreateNative("TYSTATS_GetRank", Native_TYSTATS_GetRank);
  CreateNative("TYSTATS_GetPlayTime", Native_TYSTATS_GetPlayTime);
  CreateNative("TYSTATS_IncrementGiftTaken", Native_IncrementGiftTaken);
  CreateNative("TYSTATS_IncrementBoxSpecials", Native_IncrementBoxSpecials);
  MarkNativeAsOptional("KarmaBan");
  return APLRes_Success;
}

public void OnAllPluginsLoaded() {
  DamageOnAllPluginsLoaded();
  PunishmentsOnAllPluginsLoaded();
}

void OnDatabaseConnected() {
  PrintToServer("Conexión a base de datos exitosa");
  GetTotalPlayers();
}

public Action OnUpgradePackAdded(Event event, const char[] name, bool dontBroadcast) {
  int client = GetClientOfUserId(event.GetInt("userid"));
  if(IsRealClient(client)) {
    Players[client].boxes_open++;
  }
  return Plugin_Continue;
}

public Action OnPlayerPillsUsed(Event event, const char[] name, bool dontBroadcast) {
  int client = GetClientOfUserId(event.GetInt("userid"));
  if(IsRealClient(client)) {
    Players[client].self_pills++;
  }
  return Plugin_Continue;
}

public Action OnPlayerAdrenalineUsed(Event event, const char[] name, bool dontBroadcast) {
  int client = GetClientOfUserId(event.GetInt("userid"));
  if(IsRealClient(client)) {
    Players[client].self_adrenaline++;
  }
  return Plugin_Continue;
}

public Action OnPlayerDisconnect(Event event, const char[] name, bool dontBroadcast) {
  int client = GetClientOfUserId(event.GetInt("userid"));
  if(IsRealClient(client)) {
    char reason[32];
    event.GetString("reason", reason, 32);
    if(StrContains(reason, "Disconnect by user") != -1) {
      Players[client].server_left++;
    }
  }
  return Plugin_Continue;
}

public Action cmdFrags(int client, int args) {
  RenderPlayerFrags(client);
}

public void OnFetchTotalPlayers(Database db, DBResultSet results, const char[] error, any data) {
  if (db == null || results == null) {
    LogError("Query failed! %s", error);
    SetFailState("(OnPlayerFetch) Something is wrong: %s", error);
  } else {
    while (results.FetchRow()) {
      g_iRegisteredPlayers = results.FetchInt(0);
    }
  }
  while (results.FetchMoreResults()) {}
}

public void OnClientDisconnect(int client) {
  if(!IsRealClient(client)) return;
  UpdatePlayer(client);
  DMOnClientDisconnect(client);
  PlayerReset(client);
  for(int i = 1;i <= MaxClients; i++) {
    g_bPlayerIgnore[client][i] = false;
  }
}

public void UpdatePlayersStats(bool final) {
  PrintToServer("ENVIANDO ESTADISTICAS AL SERVIDOR");
  // Instanciando metodo de trasaction
  Transaction transaction = new Transaction();
  bool all_players_alive = final ? AllPlayersAlive() : false;
  // Inicializando variables para guardar el query y el steam id
  for (int i = 1; i <= MaxClients; i++) {
    // Verificando que cliente sea real
    if(IsRealClient(i)) {
      if(final) {
        Players[i].rounds_all_survive = all_players_alive ? 1 : 0;
        Players[i].rounds_successful = 1;
      }
      transaction.AddQuery(Players[i].getQuery());
      PlayerReset(i);
    }
  }
  g_database.Execute(transaction, onPlayerUpdated, OnUpdatePlayersStatsFailure, _, DBPrio_High);
}

public void UpdatePlayer(int client) {
  if(IsRealClient(client)) {
    // Instanciando metodo de trasaction
    Transaction transaction = new Transaction();
    transaction.AddQuery(Players[client].getQuery());
    PlayerReset(client);
    g_database.Execute(transaction, onPlayerUpdated, threadFailure, client, DBPrio_High);
  }
}

public void onPlayerUpdated(Database db, int client, int numQueries, DBResultSet[] results, any[] queryData) {
  
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
  ADOnMapStart();
  PrecacheSound(SOUND_JOIN, true);
  PrecacheSound(SOUND_MAPTIME_START, true);
  PrecacheSound(SOUND_MAPTIME_FINISH, true);
  g_iFailedAttempts = 0;
  if(g_database != null) {
    GetTotalPlayers();
  }
}


void GetTotalPlayers() {
  char query[256];
  Format(query, sizeof(query), "CALL PLAYER_COUNT();");
  g_database.Query(OnFetchTotalPlayers, query, _, DBPrio_High);
}

public Action OnTankSpawn(Event event, const char[] name, bool dontBroadcast) {
  int tank = GetClientOfUserId(event.GetInt("userid"));
  Tanks[tank].health = GetClientHealth(tank);
  return Plugin_Continue;
}

public Action OnTankKilled(Event event, const char[] name, bool dontBroadcast) {
  int tank = GetClientOfUserId(event.GetInt("userid"));
  GetClientName(tank, Tanks[tank].name, MAX_LINE_WIDTH);
  Tanks[tank].renderPlayersDamage();
  TanksInfo t;
  Tanks[tank] = t;
  return Plugin_Continue;
}

public Action OnMeleeKill(Event event, const char[] name, bool dontBroadcast) {
  int client = GetClientOfUserId(event.GetInt("userid"));
  Players[client].melee_kills++; 
}

public Action OnMolotovThrown(Event event, const char[] name, bool dontBroadcast) {
  int client = GetClientOfUserId(event.GetInt("userid"));
  CPrintToChatAll("{blue}%N \x01thrown a {blue}molotov", client);
}

public Action OnRoundStart(Event event, const char[] name, bool dontBroadcast) {
  ADRoundStart();
  g_pointsEnabled = true;
  g_iStatsBalans = 0;
  // bonus = 0;
  g_fMapTimingStartTime = 0.0;

  for (int i = 1; i <= MaxClients; i++) {
    Players[i].rounds++;
  }
  return Plugin_Continue;
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
      PlayerReset(client);
      // Obteniendo informacion en la base de datos
      PlayerFetch(client);
    }
  }
}

public Action OnWitchDisturb(Event event, const char[] name, bool dontBroadcast) {
  int client = GetClientOfUserId(event.GetInt("userid"));
  if (IsRealClient(client) && GetClientTeam(client) == TEAM_SURVIVORS) {
    Players[client].counter_witch_disturb += 1;
  }
  return Plugin_Continue;
}

public Action OnEventWitchKilled(Event event, const char[] name, bool dontBroadcast) {
  int client = GetClientOfUserId(event.GetInt("userid"));
  if(!IsRealClient(client)) return Plugin_Continue;
  int score = cvar_Witch.IntValue + g_iStatsBalans + Players[client].bonus_points;
  Players[client].kill_witches += 1;
  Players[client].addPoints(score);
  return Plugin_Continue;
}

/**
*	Event when a player death
*/
public Action OnPlayerDeath(Event event, const char[] name, bool dontBroadcast) {
  // Obteniendo el id del jugador
  int attacker = GetClientOfUserId(event.GetInt("attacker"));
  // Verificando si fue un headshot
  int headshot = event.GetBool("headshot") ? 1 : 0;
  // Obteniendo el userid del jugador
  int victim = GetClientOfUserId(event.GetInt("userid"));
  // Verificando que el atacante no sea un bot
  if (IsRealClient(attacker)) {
    // Verificando que el atacante sea diferente de la victima
    if (attacker != victim) {
      int score = 0;
      int bonus_points = Players[attacker].bonus_points + g_iStatsBalans;
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
              score = -50;
              PunishTeamKiller(attacker, 30);
              CPrintToChatAll("{blue}%N {default}killed {blue}%N", attacker, victim);
              Players[attacker].friends_killed += 1;
            }
          }
        } else if(victim_team == TEAM_INFECTED) {
          int special_infected = iGetZombieClass(victim);
          if(special_infected == ZC_SMOKER) {
            score = cvar_Smoker.IntValue + bonus_points;
            Players[attacker].kill_smookers += 1;
          } else if(special_infected == ZC_BOOMER) {
            score = cvar_Boomer.IntValue + bonus_points;
            Players[attacker].kill_boomers += 1;
          } else if(special_infected == ZC_HUNTER) {
            score = cvar_Hunter.IntValue + bonus_points;
            Players[attacker].kill_hunters += 1;
          } else if(special_infected == ZC_SPITTER) {
            score = cvar_Spitter.IntValue + bonus_points;
            Players[attacker].kill_spitters += 1;
          } else if(special_infected == ZC_JOCKEY) {
            score = cvar_Jockey.IntValue + bonus_points;
            Players[attacker].kill_jockeys += 1;
          } else if(special_infected == ZC_CHARGER) {
            score = cvar_Charger.IntValue + bonus_points;
            Players[attacker].kill_chargers += 1;
          } else if(special_infected == ZC_TANK) {
            score = cvar_Tank.IntValue + bonus_points;
            Players[attacker].kill_tanks += 1;
          }
          Players[attacker].frags += 1;
          Players[attacker].kill_bosses += 1;
          Players[attacker].headshots += headshot;
        }
      } else {
        char victim_name[MAX_LINE_WIDTH];
        event.GetString("victimname", victim_name, sizeof(victim_name));
        if (StrEqual(victim_name, "Infected", false)) {
          Players[attacker].kill_zombies++;
          Players[attacker].headshots += headshot;
          if ((Players[attacker].kill_zombies % KILL_COUNT_INFECTED) == 0) {
            score = 5 + bonus_points;
            PrintCenterText(attacker, "Infected killed: %d", Players[attacker].kill_zombies);
          }
        }
      }
      Players[attacker].addPoints(score);
    } else {
      Players[victim].counter_suicide += 1;
    }
  // esto para saber quien es el principal nemesis de cada jugador
  // al ser asesinado un jugador por un enemigo xD
  } else if(IsRealClient(victim) && GetClientTeam(victim) == TEAM_SURVIVORS) {
    // Guardando el grupo de la victima
    if(IsValidClient(attacker) && GetClientTeam(attacker) == TEAM_INFECTED) {
      int special_infected = iGetZombieClass(attacker);
      if(special_infected == ZC_SMOKER) {
        Players[victim].killed_by_smooker += 1;
      } else if(special_infected == ZC_BOOMER) {
        Players[victim].killed_by_boomer += 1;
      } else if(special_infected == ZC_HUNTER) {
        Players[victim].killed_by_hunter += 1;
      } else if(special_infected == ZC_SPITTER) {
        Players[victim].killed_by_spitter += 1;
      } else if(special_infected == ZC_JOCKEY) {
        Players[victim].killed_by_jockey += 1;
      } else if(special_infected == ZC_CHARGER) {
        Players[victim].killed_by_charger += 1;
      } else if(special_infected == ZC_TANK) {
        Players[victim].killed_by_tank += 1;
      }
    } else {
      char attacker_name[MAX_LINE_WIDTH];
      event.GetString("attackername", attacker_name, sizeof(attacker_name));
      if(StrEqual(attacker_name, "Witch", false)) {
        Players[victim].killed_by_witch += 1;
      } else if(StrEqual(attacker_name, "Infected", false)) {
        Players[victim].killed_by_mob += 1;
      }
    }
  }
  return Plugin_Continue;
}

public Action OnPlayerIncap(Event event, const char[] name, bool dontBroadcast) {
  int attacker = GetClientOfUserId(event.GetInt("attacker"));
  int victim = GetClientOfUserId(event.GetInt("userid"));
  if(!IsRealClient(attacker) || !IsRealClient(victim)) return Plugin_Continue;
  if (attacker == victim) return Plugin_Continue;
  if (GetClientTeam(attacker) != TEAM_SURVIVORS || GetClientTeam(victim) != TEAM_SURVIVORS) return Plugin_Continue;
  CPrintToChat(victim, "{blue}%N \x05incapacitated {blue}you", attacker);
  CPrintToChat(attacker, "{blue}You \x05incapacitated {blue}%N", victim);
  PunishTeamKiller(attacker, 25);
  Players[attacker].friends_incapped += 1;
  Players[attacker].addPoints(-10);
  return Plugin_Continue;
}

// Fix para gente que se mete al fuego xD
// char weapon[128]; 
// event.GetString("weapon", weapon, sizeof(weapon));

// if(StrEqual(weapon, "inferno", true))
// {
// 	if(Players[target].points < 0)
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
public Action OnPlayerHurt(Event event, const char[] name, bool dontBroadcast) {
  int attacker = GetClientOfUserId(event.GetInt("attacker"));
  int target = GetClientOfUserId(event.GetInt("userid"));
  int damage = event.GetInt("dmg_health");
  if(!IsRealClient(attacker) || damage == 0) return Plugin_Continue;
  if (attacker == target) return Plugin_Continue;
  // Verificando si el atacante es del equivo de sobrevivientes
  int team_target = GetClientTeam(target);
  // Verificando si el objetico es del equivo de sobrevivientes
  if(team_target == TEAM_SURVIVORS && !IsFakeClient(target)) {
    int points = (damage > 25 ? 25 : (damage < 1 ? 1 : damage)) * -1;
    Players[attacker].addPoints(points);
    PunishTeamKiller(attacker, damage);
    CPrintToChat(target, "{blue}%N \x05attacked {blue}you \x04[\x05%i TK\x04]", attacker, Players[attacker].team_killer.counter);
    CPrintToChat(attacker, "{blue}You \x05attacked {blue}%N \x04[\x05%d TK\x04]", target, Players[attacker].team_killer.counter);
    Players[attacker].friends_damage += damage;
  } else if(team_target == TEAM_INFECTED) {
    int special_infected = GetEntProp(target, Prop_Send, "m_zombieClass");
    if(special_infected == ZC_TANK) {
      int health = GetClientHealth(target);
      if(!bIsPlayerIncapped(target) && health > 0) {
        if(damage > health) {
          damage = health;
        }
        Tanks[target].damage[attacker] += damage;
      }
    }
  }
  return Plugin_Continue;
}

public Action OnPlayerHelp(Event event, const char[] name, bool dontBroadcast) {
  int client = GetClientOfUserId(event.GetInt("userid"));	
  int target = GetClientOfUserId(event.GetInt("subject"));
  if(!IsRealClient(client) || !IsRealClient(target)) return Plugin_Continue;
  if (target != client) {
    Players[client].team_killer.subtract(16);
    int restored = event.GetInt("health_restored");
    Players[client].friends_cured += 1;
    if (restored > 49) {
      Players[client].addPoints(4);
      Players[client].addBonusPoints();
    } else {
      Players[client].addPoints(1);
    }
  } else {
    Players[client].self_cured += 1;
  }
  return Plugin_Continue;
}

public Action OnPlayerDefig(Event event, const char[] name, bool dontBroadcast){
  int subject = GetClientOfUserId(event.GetInt("subject"));
  int savior = GetClientOfUserId(event.GetInt("userid"));
  if(!bRealClients(savior, subject)) return Plugin_Continue;
  Players[savior].addBonusPoints();
  Players[savior].friends_revived += 1;
  Players[savior].addPoints(3);
  return Plugin_Continue;
}

public Action OnReviveSuccess(Event event, const char[] name, bool dontBroadcast) {
  int target = GetClientOfUserId(event.GetInt("subject"));
  int client = GetClientOfUserId(event.GetInt("userid"));
  if(!bRealClients(target, client)) return Plugin_Continue;
  Players[client].friends_above += 1;
  Players[client].team_killer.subtract(8);
  if(!event.GetBool("ledge_hang")) {
    Players[client].addBonusPoints();
  }
  Players[client].addPoints(2);
  Players[target].renderColor();
  return Plugin_Continue;
}

public Action OnPlayerNowIt(Event event, const char[] name, bool dontBroadcast) {
  if(GetEventBool(event, "by_boomer")) return Plugin_Continue;
  int attacker = GetClientOfUserId(event.GetInt("attacker"));
  int victim = GetClientOfUserId(event.GetInt("userid"));
    // Verificando que el atacante este en juego
  if(IsRealClient(attacker) && IsClientInGame(victim) && attacker != victim) {
    int score = 0;
    int team_victim = GetClientTeam(victim);
    // Verificando grupo de la victima
    if(team_victim == TEAM_INFECTED) {
      int zombie_class = iGetZombieClass(victim);
      if(zombie_class == ZC_WITCH) {
        CPrintToChatAll("{blue}%N {default}was brave enough to vomit the {blue}witch", attacker);
        score = 10;
      } else if(zombie_class == ZC_TANK) {
        CPrintToChatAll("{blue}%N {default}vomit {blue}Tank", attacker);
        score = 8;
      }
    } else if(team_victim == TEAM_SURVIVORS && !IsFakeClient(victim)) {
      score = -5;
      if (IsTankAlive()) {
        if(bPlayerInDistress(victim)) score *= 4;
        else score *= 3;
      } else if(bPlayerInDistress(victim)) score *= 2;
      CPrintToChat(victim, "{blue}%N {default}vomited you! \x04[\x05%i vomitTK\x04]", attacker, Players[attacker].team_vomit.counter);
      CPrintToChat(attacker, "{blue}You {default}vomited {blue}%N ! \x04[\x05%i vomitTK\x04]", victim, Players[attacker].team_vomit.counter);
      PunishVomiter(attacker, (score * -1));
    }
    Players[attacker].addPoints(score);
  }
  return Plugin_Continue;
}

public Action OnPlayerRescued(Event event, const char[] name, bool dontBroadcast) {
  int client = GetClientOfUserId(event.GetInt("rescuer"));
  int target = GetClientOfUserId(event.GetInt("victim"));
  if(!IsRealClient(client) || !IsRealClient(target)) return Plugin_Continue;
  Players[client].friends_rescued += 1;
  Players[client].addPoints(2);
  return Plugin_Continue;
}

/**
 * El evento se dispara al obtener un logro
 * @param Event event
 * @param string name
 * @param bool  dontBroadcast
 */
public Action OnAward(Event event, const char[] name, bool dontBroadcast) {
// Obteniendo el id del cliente
  int client = GetClientOfUserId(event.GetInt("userid"));
  if(!IsRealClient(client)) return Plugin_Continue;
  int adward_id = event.GetInt("award");
  int target = event.GetInt("subjectentid");
  // Creando switch para id del logro
  switch(adward_id) {
    // Protect friendly
    case 67: {
      // Verificando que el objetivo sea valido
      if(target) {
        Players[client].friends_protected += 1;
        Players[client].addPoints(2);
      }
    }
    // Pills given
    case 68: {
      // Verificando que el objetivo sea valido
      if (target) {
        // Dando pildoras 
        givePills(client, GetClientOfUserId(GetClientUserId(target)));
      }
    }
    // Adrenaline given
    case 69: {
      // Verificando que el objetivo sea valido
      if (target) {
        // Dando adrenalina
        giveAdrenaline(client, GetClientOfUserId(GetClientUserId(target)));
      }
    }
    // Kill Tank with no deaths
    case 81: {
      // Sumando al cliente un asesinato de tank sin morir
      Players[client].kill_tanks_without_deaths += 1;
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
          Players[client].friends_incapped += 1;
        }
      }
    }
    // Left friendly for dead
    case 86: {
      // Sumando al jugador una muerte culposa
      Players[client].left4dead += 1;
    }
    // Let infected in safe room
    case 95: {
      Players[client].infected_let_in_safehouse += 1;
    }
    case 99: { // Round restart
      g_iFailedAttempts++;
      Players[client].rounds_failed += 1;
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
        Players[giver].friends_pills_given += 1;
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
        Players[giver].friends_adrenaline_given += 1;
      }
    }
  }
}

void ShowRank(int client, int target)
{
  if(client == 0 || !IsClientInGame(client) || IsFakeClient(client) || target == 0 || !IsClientInGame(target) || IsFakeClient(target)) {
    return;
  }
  Panel rank = new Panel();
  char Value[128];

  int theTime = Players[target].playtime;
  int days = theTime /60/60/24;
  int hours = theTime/60/60%24;
  int minutes = theTime/60%60;

  char playtime[128];

  if (hours == 0 && days == 0) {
    Format(playtime, sizeof(playtime), "%d min", minutes);
  } else if (days == 0) {
    Format(playtime, sizeof(playtime), "%d hour %d min", hours, minutes);
  } else {
    Format(playtime, sizeof(playtime), "%d day %d hour %d min", days, hours, minutes);
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

  Format(Value, sizeof(Value), "Ranking of %N", client, client);
  rank.DrawText(Value);

  Format(Value, sizeof(Value), "===========================");
  rank.DrawText(Value);

  Format(Value, sizeof(Value), "Rank: %d of %d", Players[target].rank, g_iRegisteredPlayers);
  rank.DrawText(Value);

  int current_points = calculatePoints(Players[target].new_points);
  char prefix[1];
  prefix = current_points > 0 ? "+" : "";
  Format(Value, sizeof(Value), "Points: %d %s%d", Players[target].points, prefix, calculatePoints(Players[target].new_points));
  rank.DrawText(Value);

  Format(Value, sizeof(Value), "Killed Bosses: %d", Players[target].kill_bosses);
  rank.DrawText(Value);

  Format(Value, sizeof(Value), "Connection Time: %s", contime);
  rank.DrawText(Value);

  Format(Value, sizeof(Value), "Playtime: %s", playtime);
  rank.DrawText(Value);
  
  Format(Value, sizeof(Value), "Bonus Points: %d", Players[target].bonus_points);
  rank.DrawText(Value);

  Format(Value, sizeof(Value), "For full stats visit:\n%s", WEBSITE_STATS);
  rank.DrawText(Value);

  Format(Value, sizeof(Value), "===========================");
  rank.DrawText(Value);

  Format(Value, sizeof(Value), "Show full stats");
  rank.DrawItem(Value);

  Format(Value, sizeof(Value), "Next rank");
  rank.DrawItem(Value);

  Format(Value, sizeof(Value), "Top players");
  rank.DrawItem(Value);

  Format(Value, sizeof(Value), "Show players");
  rank.DrawItem(Value);

  Format(Value, sizeof(Value), "Close");
  rank.DrawItem(Value);

  rank.Send(client, RankPanelHandlerOption, 20);
  delete rank;
}

public int RankPanelHandlerOption(Menu menu, MenuAction action, int client, int index)
{
  if (action == MenuAction_Select)
  {
    if (index == 1)
    {
      FakeClientCommand(client, "sm_browse l4d.dev/stats");
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
        Format(DisplayName, sizeof(DisplayName), "%s (%i points)", playername, Players[i].points);
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
      ShowRank(client, target);
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
  if (IsRealClient(client)) {
    char query[256];
    Format(query, sizeof(query), "CALL PLAYER_TOP(0, %d);", top);
    SQL_TQuery(g_database, DisplayTop, query, client, DBPrio_Low);
  } else {
    CPrintToChat(client, "\x04[\x05ASC\x04]\x01 Please set a valid player");
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
  if(!IsRealClient(client)) return Plugin_Handled;
  if(Players[client].rank > 0) {
    Panel next = new Panel();
    char buffer[128];
    if (Players[client].rank == 1) {
      next.SetTitle("You are 1st");
    } else {
      Format(buffer, sizeof(buffer), "Next Rank: %d", (Players[client].rank + 1));
      next.SetTitle(buffer);
      Format(buffer, sizeof(buffer), "Points required: %d", Players[client].points_for_next_rank);
      next.DrawText(buffer);
    }
    Format(buffer, sizeof(buffer), "More...");
    next.DrawItem(buffer);
    Format(buffer, sizeof(buffer), "Close");
    next.DrawItem(buffer);
    next.Send(client, NextRankPanelHandler, 20);
    delete next;
  } else if(IsFromStaff(client)) {
    CPrintToChat(client, "Sorry dude, you are part of the staff");
  } else {
    CPrintToChat(client, "We can't fetch your data");
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
      Format(query, sizeof(query), "CALL PLAYER_NEXT_RANK('%s', %i);", Players[client].authid, Players[client].points);
      SQL_TQuery(g_database, DisplayFullNextRank, query, client, DBPrio_Low);
    }
  }
  return 0;
}

public void ShowRankTarget(int sender, int target) {
  if(IsRealClient(target)) {
    CPrintToChat(sender, "Player: {blue}%N\x01 | Rank: {blue}%d\x01 | Points: {blue}%d\x01 Map points: {blue}%d", target, Players[target].rank, Players[target].points, Players[target].new_points);
  }
}

public Action cmdPoints(int client, int args) {
  if(CheckCommandAccess(client, "sm_fk", ADMFLAG_RESERVATION, true)) {
    PrintToChat(client, "Your points: %d , Your map points: %d, Your vip points: %d", Players[client].points, Players[client].new_points, calculatePointsForVip(client));
  } else {
    PrintToChat(client, "Your points: %d , Your map points: %d", Players[client].points, Players[client].new_points);
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
    PrintToChat(client, "Your playtime on this map: %d", Players[client].getTimeInMatch());
  }
}


public Action cmdFactor(int client, int args)
{
  if (client)
  {
    PrintToChat(client, "\x05Your assistance factor: \x04%.2f", Players[client].factor);
    PrintToChat(client, "\x05Your bonus points: \x04%d", Players[client].bonus_points);
  }
  return Plugin_Handled;
}

public Action cmdMapTop(int client, int args){
  RenderMatchInfo(client, false);
}

int calculatePoints(int points) {
  if(points > 0 && g_iFailedAttempts > 0) {
    float percent = (100.0 - g_iFailedAttempts * 10.0) / 100.0;
    return RoundToZero(points * percent);
  }
  return points;
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

public Action OnPlayerSpawn(Event event, const char[] name, bool dontBroadcast) {
  ADPlayerSpawn(event);
  int client = GetClientOfUserId(event.GetInt("userid"));
  CreateTimer(6.0, TimedGrantPlayerColor, client);
}

public Action TimedGrantPlayerColor(Handle timer, int client) {
  Players[client].renderColor();
}

bool IsRealClient(int client) {
  return IsValidClient(client) && IsClientInGame(client) && !IsFakeClient(client) && client > 0;
}

bool IsValidClient(int client) {
  return IsValidEntity(client) && client && client <= MaxClients;
}

public Action OnPlayerTeamPost(Event event, const char[] name, bool dontBroadcast) {
  int client = GetClientOfUserId(event.GetInt("userid"));
  if (!event.GetBool("disconnect") && IsRealClient(client)) {
    CreateTimer(0.1, Timer_ADPlayerTeam);
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
              current_player_rank = Players[i].rank * 1.0;
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
              if (Players[i].rank == 0) g_fRankSum += 0.0;
              else if (Players[i].rank <= 10) g_fRankSum += 5.0;
              else if (Players[i].rank <= 25) g_fRankSum += 4.4;
              else if (Players[i].rank <= 50) g_fRankSum += 3.8;
              else if (Players[i].rank <= 100) g_fRankSum += 3.2;
              else if (Players[i].rank <= 200) g_fRankSum += 2.6;
              else if (Players[i].rank <= 400) g_fRankSum += 2.0;
              else if (Players[i].rank <= 800) g_fRankSum += 1.4;
              else if (Players[i].rank <= 1600) g_fRankSum += 0.8;
              else if (Players[i].rank <= 3200) g_fRankSum += 0.2;
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

public Action OnMapTransition(Event event, const char[] name, bool dontBroadcast) {
  ADOnMapStart();
  StopMapTiming();
  PrintMapPoints();
}

public Action OnFinalWin(Event event, const char[] name, bool dontBroadcast){
  // StopMapTiming();
  // PrintMapPoints();
  UpdatePlayersStats(true);
}

void PrintMapPoints() {
  for (int i = 1; i <= MaxClients; i++) {
    if (IsRealClient(i)) {
      int bonus = calculatePointsForVip(i);
      Players[i].new_points += bonus;
      RenderMatchInfo(i, true);
    }
  }
}

int calculatePointsForVip(int client) {
  int bonus = 0;
  if(CheckCommandAccess(client, "sm_fk", ADMFLAG_RESERVATION, true) && !CheckCommandAccess(client, "sm_fk", ADMFLAG_GENERIC, true)) {
    int points = Players[client].new_points;
    if(points > 0) {
      bonus = RoundToNearest(points * 0.2);
      Players[client].points_vip += bonus;
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
        Players[player].points_gift += Score;
        Players[player].addPoints(Score);
      }
      return Plugin_Handled;
    }
  } else {
    ReplyToCommand(client, "sm_givepoints <#userid|name> [Score]");
    return Plugin_Handled;
  }
}

public Action cmdChatColors(int client, int args) {
  CPrintToChat(client, "{default}default\n{green}green\n{lightgreen}lightgreen\n{olive}olive");
}

public Action cmdRank(int client, int args) {
  if (args == 0) {
    int target = GetClientAimTarget(client, false);
    if (target > 0 && target <= MaxClients && !IsFakeClient(target)) {
      ShowRankTarget(client, target);
    }
    else {
      ShowRank(client, client);
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

        ShowRank(client, targetclient);
      }
    }
  }
  else
  {
    ReplyToCommand(client, "sm_rank <#userid|name>");
  }
  
  return Plugin_Handled;
}

public Action OnAnyVote(int client, int args) {
  CPrintToChat(client, "\x04Vote access {red}denied\x01!");
  return Plugin_Handled;
}

public Action OnStartAreaPost(Event event, const char[] name, bool dontBroadcast) {
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
    EmitSoundToAll(SOUND_MAPTIME_START);
  }
}

public void StopMapTiming(){
  if (g_fMapTimingStartTime > 0.0) {
    float TotalTime = GetEngineTime() - g_fMapTimingStartTime;
    g_fMapTimingStartTime = -1.0;
    char TimeLabel[32];
    vGetTimeLabel(TotalTime, TimeLabel, sizeof(TimeLabel));
    EmitSoundToAll(SOUND_MAPTIME_FINISH);
    CPrintToChatAll("It took \x04%s \x01to finish this map!", TimeLabel);
  }
}

/**
* Evento al correr cualquier cmd
*/
public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon) {
  if(!IsRealClient(client)) return Plugin_Continue;
  if(Players[client].points >= POINTS_TO_LAUNCH_GRENADE) return Plugin_Continue;

  int active_weapon = GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");
  if (active_weapon == -1) return Plugin_Continue;

  char weapon_name[32];
  GetEdictClassname(active_weapon, weapon_name, sizeof(weapon_name));

  if ( (buttons & IN_ATTACK) && (
      StrContains(weapon_name, "vomitjar") > -1 ||
      StrContains(weapon_name, "molotov") > -1 ||
      StrContains(weapon_name, "weapon_grenade_launcher") > -1 ||
      StrContains(weapon_name, "weapon_chainsaw") > -1
   ) ) {
    buttons &= ~IN_ATTACK;
    ReplaceString(weapon_name, 32, "weapon_", "");
    ReplaceString(weapon_name, 32, "_", " ");
    PrintHintText(
      client, 
      "Player with less than %d points\nare not allowed to use %s!",
      POINTS_TO_LAUNCH_GRENADE,
      weapon_name
    );
  }
  return Plugin_Continue;
}

/**
*	Handle when a user send a message then concatenate "tag + user : + message"
*/
public Action OnMessage(int client, int args) {
  // Verificando si es un trigger ! o /
  if(IsChatTrigger()) {
    Players[client].counter_commands++;
    // Deteniendo el evento
    return Plugin_Handled;
  }
  // Verificando que el jugador sea valido
  if(!IsValidClient(client)) return Plugin_Continue;
  if(client > 0) {
    Players[client].counter_messages++;
    // Verificando si el jugador es un vip/mod/admin
    if(CheckCommandAccess(client, "sm_fk", ADMFLAG_GENERIC, true) ||
      CheckCommandAccess(client, "sm_fk", ADMFLAG_RESERVATION, true) ||
      Players[client].rank > 0 && Players[client].rank < 40) {
      // Inicializando variable
      char message[256];
      GetCmdArgString(message, sizeof(message));
      StripQuotes(message);
      // Verificando si tiene permisos como root
      if(CheckCommandAccess(client, "sm_fk", ADMFLAG_ROOT, true)) {
        // Imprimiendo mensaje 
        CPrintToChatAll("\x03[\x04A\x03] {blue}%N: {default}%s", client, message);
      // Verificando si tiene permisos como moderador
      } else if(CheckCommandAccess(client, "sm_fk", ADMFLAG_GENERIC, true)) {
        // Imprimiendo mensaje como mod
        CPrintToChatAll("\03[\x04M\03] {blue}%N: {default}%s", client, message);
      // Verificando si tiene permisos como vip
      } else if(CheckCommandAccess(client, "sm_fk", ADMFLAG_RESERVATION, true)) {
        // Verificando si pertenece al top 40
        if(Players[client].rank > 0 && Players[client].rank <= 99) {
          // Imprimiendo mensaje
          CPrintToChatAll("\x03[\x04V\x03]\x04[\x05RANK-%d\x04] {blue}%N: {default}%s", Players[client].rank, client, message);
        } else {
          // Imprimiendo mensaje
          CPrintToChatAll("\x03[\x04V\x03]\x05 {blue}%N: {default}%s", client, message);
        }
      // Verificando si pertene al top 40
      } else if(Players[client].rank > 0 && Players[client].rank <= 99) {
        // Imprimiendo mensaje
        CPrintToChatAll("\x04[\x05RANK-%d\x04] {blue}%N: {default}%s", Players[client].rank, client, message);
      }
      return Plugin_Handled;
    }
  } else {
    char message[256];
    GetCmdArgString(message, sizeof(message));
    CPrintToChatAll("\x04[\x05GOD\x04] {default}%s", message);
    return Plugin_Handled;
  }
  return Plugin_Continue;
}
