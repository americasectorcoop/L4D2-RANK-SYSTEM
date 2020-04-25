enum struct MapPlayerTop {
  int id;
  char name[MAX_NAME_LENGTH];
  int rank;
  int points;
  int counter;
}

void RenderMatchInfo(int client, bool for_final) {
  MapPlayerTop player_pro;
  MapPlayerTop player_noob;
  MapPlayerTop player_helper;

  int total_points = 0;

  // Loop client
  for (int i = 1; i <= MaxClients; i++) {
    // Check if is real client
    if (IsRealClient(i) && !IsFromStaff(i)) {
      // Get Client name
      char player_name[MAX_NAME_LENGTH];
      GetClientName(i, player_name, MAX_NAME_LENGTH);
      // Check if Points in map of player is > N>>J
      if (Players[i].new_points > player_pro.points) {
        player_pro.id = i;
        player_pro.name = player_name;
        player_pro.points = Players[i].new_points;
        player_pro.rank = Players[i].rank;
      // Check if Points in map of player is < N>>J
      } else if (Players[i].new_points < player_noob.points) {
        player_noob.id = i;
        player_noob.name = player_name;
        player_noob.points = Players[i].new_points;
        player_noob.rank = Players[i].rank;
      }
      // Best team helper on map
      int helpt_at_map = Players[i].friends_above + Players[i].friends_cured + Players[i].friends_revived + Players[i].friends_rescued;
      // Check if is the best helper on map
      if(helpt_at_map > player_helper.counter) {
        player_helper.id = i;
        player_helper.name = player_name;
        player_helper.counter = helpt_at_map;
        player_helper.points = Players[i].new_points;
        player_helper.rank = Players[i].rank;
      }
      total_points += Players[i].new_points; // sum of total points of all players in map
    }
  }
  if(for_final) {
    // se añaden al contador las veces que X jugador fue:
    // mejor pro, mejor ayudante, mejor noob
    if(player_pro.points > 0) Players[player_pro.id].counter_mvp = 1;
    if(player_helper.counter > 0) Players[player_helper.id].counter_bh = 1;
    if (player_noob.points < 0) Players[player_noob.id].counter_lvp = 1;
    if (g_iFailedAttempts == 0) {
      // Check is not print before to print
      PrintToChat(client, "\x05The map was passed on the first try!");
      PrintToChat(client, "\x05All players will receive \x04100%%\x05 of their points earned");
    } else {
      // Check is not print before to print
      int percentage = 100 - g_iFailedAttempts * 10;
      PrintToChat(client, "\x05It took \x04%d\x05 attempts to finish this map!", g_iFailedAttempts);
      PrintToChat(client, "\x05All players will receive \x04%d%%\x05 of their points earned", percentage);
    }
  }
  if(player_pro.points > 0) RenderPlayerTop(client, "MVP", player_pro);
  if(player_helper.counter > 0) RenderPlayerTop(client, "LIFEGUARD", player_helper);
  if (player_noob.points < 0) RenderPlayerTop(client, "NOOB", player_noob);
  if (g_iFailedAttempts == 0) {
    PrintToChat(client, "\x05Map total points: \x04%d \x03| \x05Your map points: \x04%d", total_points, Players[client].new_points);
  } else {
    PrintToChat(
      client,
      "\x05Map total points: \x04%d \x01(\x04%d\x01) \x03| \x05Your map points: \x04%d \x01(\x04%d\x01)",
      total_points, calculatePoints(total_points),
      Players[client].new_points, calculatePoints(Players[client].new_points)
    );
  }
}

/**
* Se imprime al cliente el mejor para ser Pro, Noob, Ayudante de la partida
*/
void RenderPlayerTop(int client, char[] title, MapPlayerTop player) {
  int points_to_get = calculatePoints(player.points);
  if(points_to_get == player.points) {
    CPrintToChat(
      client,
      "\x04[\x05%s\x04] {blue}%s\x01 (\x05rank\x01: {blue}%d\x01; \x05points\x01: {blue}%d\x01)",
      title,
      player.name,
      player.rank,
      player.points
    );
  } else {
    CPrintToChat(
      client,
      "\x04[\x05%s\x04] {blue}%s\x01 (\x05rank\x01: {blue}%d\x01; \x05points\x01: {blue}%d \x04[{blue}%d\x04]\x01)",
      title,
      player.name,
      player.rank,
      player.points,
      points_to_get
    );
  }
}