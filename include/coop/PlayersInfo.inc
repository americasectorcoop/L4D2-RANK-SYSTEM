enum struct PlayerDamage {
  int counter;
  bool voted;

  void add(int counter = 1) {
    if(counter > 0) {
      this.counter += counter;
    }
  }

  void subtract(int counter = 1) {
    if(this.counter < 0) {
      this.counter -= counter;
    }
  }

  bool reset() {
    this.counter = 0;
    this.voted = false;
  }

  bool requirePunishment(int max_damage) {
    if(this.voted && this.counter >= max_damage) {
      this.voted = false;
      return true;
    }
    return false;
  }

  bool requireVoted(int min_damage, int max_damage) {
    if(this.counter > min_damage && this.counter < max_damage && !this.voted) {
      this.voted = true;
      return true;
    }
    return false;
  }
}

enum struct PlayersInfo {
  int id;
  char name[MAX_NAME_LENGTH];
  char authid[32];
  char ipv4[16];
  float factor;
  int bonus_points;
  int boxes_open;
  int boxes_specials_open;
  int counter_bh;
  int counter_commands;
  int counter_lvp;
  int counter_messages;
  int counter_mvp;
  int counter_suicide;
  int counter_witch_disturb;
  int frags;
  int friends_above;
  int friends_adrenaline_given;
  int friends_cured;
  int friends_damage;
  int friends_incapped;
  int friends_killed;
  int friends_pills_given;
  int friends_protected;
  int friends_rescued;
  int friends_revived;
  int gift_taken;
  int headshots;
  int infected_let_in_safehouse;
  int kill_boomers;
  int kill_bosses;
  int kill_chargers;
  int kill_hunters;
  int kill_jockeys;
  int kill_smookers;
  int kill_spitters;
  int kill_tanks;
  int kill_tanks_without_deaths;
  int kill_witches;
  int kill_zombies;
  int killed_by_boomer;
  int killed_by_charger;
  int killed_by_hunter;
  int killed_by_jockey;
  int killed_by_smooker;
  int killed_by_spitter;
  int killed_by_tank;
  int killed_by_witch;
  int last_vote_bantime;
  int left4dead;
  int melee_kills;
  int new_points;
  int new_points_gift;
  int playtime;
  int points;
  int points_for_next_rank;
  int points_gift;
  int points_lost;
  int points_vip;
  int rank;
  int rounds;
  int rounds_all_survive;
  int rounds_failed;
  int rounds_successful;
  int self_adrenaline;
  int self_cured;
  int self_pills;
  int server_join;
  int server_left;
  int spokentime;
  int start_time;
  // numero de kicks en la ronda...
  int vote_kick;

  PlayerDamage team_killer;
  PlayerDamage team_vomit;

  void store(int client) {
    this.id = client;
    this.start_time = GetTime();
    GetClientName(client, this.name, MAX_NAME_LENGTH);
    GetClientAuthId(client, AuthId_Steam2, this.authid, 32);
    GetClientIP(client, this.ipv4, 16);
  }

  int getTimeInMatch() {
    return GetTime() - this.start_time;
  }

  char getQuery() {
    char sqlcode[2048];
    Format(sqlcode, 2048, "CALL PLAYER_UPDATE ('%s', %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d);",
      this.authid, // Steam id del jugador
      this.boxes_open, // *
      this.boxes_specials_open,
      this.counter_bh,
      this.counter_commands,
      this.counter_lvp,
      this.counter_messages,
      this.counter_mvp,
      this.counter_suicide,
      this.counter_witch_disturb,
      this.friends_above,
      this.friends_adrenaline_given,
      this.friends_cured,
      this.friends_damage,
      this.friends_incapped,
      this.friends_killed,
      this.friends_pills_given,
      this.friends_protected,
      this.friends_rescued,
      this.friends_revived,
      this.gift_taken,
      this.headshots,
      this.infected_let_in_safehouse,
      this.kill_boomers,
      this.kill_bosses,
      this.kill_chargers,
      this.kill_hunters,
      this.kill_jockeys,
      this.kill_smookers,
      this.kill_spitters,
      this.kill_tanks,
      this.kill_tanks_without_deaths,
      this.kill_witches,
      this.kill_zombies,
      this.killed_by_boomer,
      this.killed_by_charger,
      this.killed_by_hunter,
      this.killed_by_jockey,
      this.killed_by_smooker,
      this.killed_by_spitter,
      this.killed_by_tank,
      this.killed_by_witch,
      this.left4dead,
      this.melee_kills,
      this.getTimeInMatch(), // tiempo nuevo del jugador
      this.new_points, // puntos nuevos del jugador
      this.points_gift, // puntos nuevos regalados para el jugador
      this.points_lost, // puntos nuevos perdidos del jugador
      this.points_vip, // puntos nuevos obtenidos por vip
      this.rounds,
      this.rounds_all_survive,
      this.rounds_failed,
      this.rounds_successful,
      this.self_adrenaline,
      this.self_cured,
      this.self_pills,
      this.server_join,
      this.server_left,
      this.spokentime
    );
    return sqlcode;
  }

  void assignFlags(char[] flags, int immunity) {
    AdminId admin_id;
    char authtype[6] = "steam";
    if ((admin_id = FindAdminByIdentity(authtype, this.authid)) != INVALID_ADMIN_ID) {
      RemoveAdmin(admin_id);
    }
    admin_id = CreateAdmin(this.name);
    if (!admin_id.BindIdentity(authtype, this.authid)) {
      LogError("Could not bind prefetched SQL admin (authtype \"%s\") (identity \"%s\")", authtype, this.authid);
      return;
    }
    admin_id.ImmunityLevel = immunity;
    int len = strlen(flags);
    AdminFlag flag;
    for (int i = 0; i < len; i++) {
      if (!FindFlagByChar(flags[i], flag)) {
        continue;
      }
      admin_id.SetFlag(flag, true);
    }
    RunAdminCacheChecks(this.id);
  }

  void announce() {
    if(CheckCommandAccess(this.id, "sm_fk", ADMFLAG_KICK, true)) {
      CPrintToChatAll("\x05+\x04 Admin {blue}%N \x05has joined", this.id);
    } else if(CheckCommandAccess(this.id, "sm_fk", ADMFLAG_GENERIC, true)) {
      CPrintToChatAll("\x05+\x04 Moderator {blue}%N \x05has joined", this.id);
    } else if(CheckCommandAccess(this.id, "sm_fk", ADMFLAG_RESERVATION, true)) {
      CPrintToChatAll("\x05+\x04 VIP {blue}%N \x01(\x05RANK: \x04%d, \x05POINTS: \x04%d\x01)", this.id, this.rank,this.points);
    } else {
      CPrintToChatAll("\x05+ Player {blue}%N \x01(\x05RANK: \x04%d, \x05POINTS: \x04%d\x01)", this.id, this.rank,this.points);
    }
    EmitSoundToAll(SOUND_JOIN);
  }

  void renderColor() {
    if(!IsRealClient(this.id) || GetClientTeam(this.id) != TEAM_SURVIVORS || !IsPlayerAlive(this.id)) return;
    if(CheckCommandAccess(this.id, "sm_fk", ADMFLAG_ROOT, true)) {
      SetEntityRenderColor(this.id, 0, 0, 0, 255); // Negro para administrador
    } else if(CheckCommandAccess(this.id, "sm_fk", ADMFLAG_GENERIC, true)) {
      SetEntityRenderColor(this.id, 0, 176, 246, 255); // Cyan
    } else if (this.points > 1280000) {
      SetEntityRenderColor(this.id, 102, 51, 0, 255); // Cafe
    } else if (this.points > 640000) {
      SetEntityRenderColor(this.id, 255, 97, 3, 255); // Orange color
    } else if (this.points > 320000) {
      SetEntityRenderColor(this.id, 255, 0, 0, 255); // Red color
    } else if (this.points > 160000) {
      SetEntityRenderColor(this.id, 255, 104, 240, 255); // pink color FF68F0
    } else if (this.points > 80000) {
      SetEntityRenderColor(this.id, 102, 25, 140, 255); // purple 66198C
    } else if (this.points > 40000) {
      SetEntityRenderColor(this.id, 0, 139, 0, 255); // green color
    } else if (this.points > 20000) {
      SetEntityRenderColor(this.id, 0, 0, 255, 255); // Blue colour
    } else if (this.points > 10000) {
      SetEntityRenderColor(this.id, 255, 255, 0, 255); // yellow
    } else if (this.points > 5000) {
      SetEntityRenderColor(this.id, 173, 255, 47, 255); // light green color
    }
  }

  void addPoints(int points) {
    this.new_points += points;
    if (points > 0 && g_pointsEnabled) {
      PrintToChat(this.id, "\x05+%i", points);
    } else if (points < 0) {
      PrintToChat(this.id, "\x04%i", points);
      this.points_lost += (-1 * points);
    }
  }

  void addBonusPoints(int points = 1) {
    if(points > 0) {
      this.bonus_points += points;
    }
  }

  void subtractBonusPoints(int points = 1) {
    this.bonus_points -= points;
    if(this.bonus_points < 0) {
      this.bonus_points = 0;
    }
  }
}

PlayersInfo Players[MAXPLAYERS + 1];

stock void PlayerFetch(int client) {
  char query[256];
  Players[client].store(client);
  Format(query, sizeof(query), "CALL PLAYER_JOINED('%s', '%s', '%s');", Players[client].authid, Players[client].ipv4, Players[client].name);
  g_database.Query(OnPlayerFetch, query, client, DBPrio_High);
}

public void OnPlayerFetch(Database db, DBResultSet results, const char[] error, int client) {
  if (db == null || results == null) {
    LogError("Query failed! %s", error);
  } else if (results.RowCount == 0) {
    LogError("(OnPlayerFetch) Something is wrong: %s");
  } else {
    while (results.FetchRow()) {
      // 0 is_banned
      // 1 ban_reason
      // 2 kill_bosses
      // 3 factor
      // 4 points
      // 5 playtime
      // 6 rank
      // 7 points_for_next_rank
      // 8 flags
      int is_banned = results.FetchInt(0);
      if(is_banned) {
        PlayerReset(client);
        char reason[255], hostname[96];
        results.FetchString(1, reason, 255);
        FindConVar("hostname").GetString(hostname, 96);
        KickClient(client, "%s\n\nYou have been banned because: %s,\n\n Please visit: %s", hostname, reason, BANS_URL);
        return;
      }
      Players[client].kill_bosses = results.FetchInt(2);
      Players[client].factor = results.FetchFloat(3);
      Players[client].points = results.FetchInt(4);
      Players[client].playtime = results.FetchInt(5);
      Players[client].rank = results.FetchInt(6);
      Players[client].points_for_next_rank = results.FetchInt(7);
      char flags[10];
      results.FetchString(8, flags, 10);
      int immunity = results.FetchInt(9);
      Players[client].assignFlags(flags, immunity);
      Players[client].announce();
      Players[client].renderColor();
    }
  }
  while (results.FetchMoreResults()) {}
}

stock void PlayerReset(int client) {
  PlayersInfo p;
  Players[client] = p;
}

stock void PlayerResetAll() {
  PlayersInfo p;
  for (int i = 1; i <= MaxClients; ++i) {
    Players[i] = p;
  }
}

public int Native_TYSTATS_GetPoints(Handle plugin, int numParams) {
  return Players[GetNativeCell(1)].points;
}

public int Native_TYSTATS_GetRank(Handle plugin, int numParams) {
  return Players[GetNativeCell(1)].rank;
}

public int Native_TYSTATS_GetPlayTime(Handle plugin, int numParams) {
  return Players[GetNativeCell(1)].playtime;
}
