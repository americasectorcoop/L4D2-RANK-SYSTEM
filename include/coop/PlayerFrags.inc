#define MAX_FRAGGERS 3
#define MAXENTITIES 2048
#define FRAGS_PREFIX "\x04[\x05FRAGS\x04]"
#define SIZE_OF_PLAYER_DAMAGE 128

enum struct TanksInfo {
  char name[MAX_LINE_WIDTH];
  int health;
  int damage[MAXPLAYERS + 1];

  void renderPlayersDamage() {
    const int message_size_of = (SIZE_OF_PLAYER_DAMAGE * MAX_FRAGGERS + 64);
    char message[message_size_of];
    Format(message, message_size_of, "%s \x03%s \x04(\x05%d-HP\x04) \x01 was killed by: \n", FRAGS_PREFIX, this.name, this.health);
    if(CalculatePlayersDamage(this.damage, this.health, message, message_size_of)) {
      CPrintToChatAll(message);
    }
  }
}

enum struct WitchsInfo {
  int health;
  int damage[MAXPLAYERS + 1];

  void renderPlayersDamage() {
    const int message_size_of = (SIZE_OF_PLAYER_DAMAGE * MAX_FRAGGERS + 64);
    char message[message_size_of];
    Format(message, message_size_of, "%s \x03Witch \x04(\x05%d-HP\x04) \x01 was killed by: \n", FRAGS_PREFIX, this.health);
    if(CalculatePlayersDamage(this.damage, this.health, message, message_size_of)) {
      CPrintToChatAll(message);
    }
  }
}

TanksInfo Tanks[MAXPLAYERS + 1];
WitchsInfo Witchs[MAXENTITIES + 1];

int CalculatePlayersDamage(const int[] damage_players, const int health, char[] message, int msg_size_of) {
  int attackers[MAXPLAYERS+1][3]; 
  int attacker_counter = 0;
  for(int i = 1; i < MaxClients; i++) {
    int damage = damage_players[i];
    if(IsRealClient(i) && GetClientTeam(i) == TEAM_SURVIVORS && damage > 0) {
      int percentage = iGetPercentage(damage, health);
      if(!IsFromStaff(i)) {
        attackers[attacker_counter][0] = i;
        attackers[attacker_counter][1] = damage;
        attackers[attacker_counter][2] = percentage;
        attacker_counter++;
      }
      Players[i].addPoints(percentage);
    }
  }
  if(attacker_counter > 0) {
    SortCustom2D(attackers, attacker_counter, SortPlayerDamage);
    int length = (attacker_counter > MAX_FRAGGERS) ? MAX_FRAGGERS : attacker_counter;
    for (int i = 0; i < length; i++) {
      char buffer[SIZE_OF_PLAYER_DAMAGE];
      Format(buffer, SIZE_OF_PLAYER_DAMAGE, "{blue}%N: \x01%d\x05[\x04%d%%%%\x05]\n", attackers[i][0], attackers[i][1], attackers[i][2]);
      StrCat(message, msg_size_of, buffer);
    }
  }
  return attacker_counter;
}

void RenderPlayerFrags(int client = 0) {
  char message[256];
  char buffer[64];
  message = "\x04[\x05FRAGS\x04]\x01 ";
  int fraggers[MAXPLAYERS+1][2];
  int frag_counter = 0;
  for(int i = 1; i < MaxClients; i++) {
    if(IsRealClient(i) && GetClientTeam(i) == TEAM_SURVIVORS && Players[i].frags > 0) {
      fraggers[frag_counter][0] = i;
      fraggers[frag_counter][1] = Players[i].frags;
      frag_counter++;
    }
  }
  if(frag_counter > 0) {
    SortCustom2D(fraggers, frag_counter, SortPlayerDamage);
    bool more_than_one = false;
    int length = (frag_counter > MAX_FRAGGERS) ? MAX_FRAGGERS : frag_counter;
    for (int i = 0; i < length; i++) {
      if (more_than_one) {
        Format(buffer, sizeof(buffer), "\x01, {blue}%N: \x01%d", fraggers[i][0], fraggers[i][0]);
      } else {
        Format(buffer, sizeof(buffer), "{blue}%N: \x01%d", fraggers[i][0], fraggers[i][1]);
        more_than_one = true;
      }
      StrCat(message, sizeof(message), buffer);
    }	
    if(client) {
      CPrintToChat(client, message);
    } else {
      CPrintToChatAll(message);
    }
  } else {
    CPrintToChatAll("\x04[\x05FRAGS\x04]\x01 Without frags");
  }
}