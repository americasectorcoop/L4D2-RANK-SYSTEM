
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
            Players[i].addPoints(attackers[attacker_counter][2]);
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
    if (Players[i].frags > 0) {
      if(IsClientInGame(i)) {
        if(!IsFakeClient(i)) {
          if(GetClientTeam(i) == TEAM_SURVIVORS) {
            fraggers[frag_counter][0] = i;
            fraggers[frag_counter][1] = Players[i].frags;
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