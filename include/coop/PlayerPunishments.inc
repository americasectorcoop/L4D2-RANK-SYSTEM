#define VOMIT_MIN_DAMAGE 50
#define VOMIT_MAX_DAMAGE 70

#define TK_MIN_DAMAGE 70
#define TK_MAX_DAMAGE 240

#define TK_BAN_REASON "Team killing"

bool bIsKarmaBanSystemActived = false;

native int KarmaBan(int client, int target, int reason_id);

public void PunishmentsOnAllPluginsLoaded() {
  bIsKarmaBanSystemActived = GetFeatureStatus(FeatureType_Native, "KarmaBan") == FeatureStatus_Available;
}

// los valores minimos son para iniciar votos
// cada cierto tiempo se debe iniciar un voto
// el tiempo del ultimo voto puede ser destruido por otra cosa
// se debe contar el tiempo del ultimo voto para recuperar
// si llega al máximo se castiga al prro

void PunishVomiter(int client, int damage) {
  if(Players[client].bonus_points > 0) Players[client].bonus_points--;
  Players[client].team_vomit.add(damage);
  if(Players[client].team_vomit.requireVoted(VOMIT_MIN_DAMAGE, VOMIT_MAX_DAMAGE)) {
    CPrintToChatAll(
      "{blue}Auto voteslay \x01against {blue}%N \x04[\x05{green}%i TK\x04]",
      Players[client].id,
      Players[client].team_vomit.counter
    );
    ServerCommand("sm_voteslay #%d", GetClientUserId(Players[client].id));
  } else if(Players[client].team_vomit.requirePunishment(VOMIT_MAX_DAMAGE)) {
    if(IsVoteInProgress()) CancelVote();
    ForcePlayerSuicide(Players[client].id);
    // Players[client].team_vomit.reset();
    CPrintToChatAll(
      "{blue}%N \x01has been slayed, because {blue}threw up\x01 the team \x04[\x05{green}%i TK\x04]",
      Players[client].id,
      Players[client].team_vomit.counter
    );
  }
}

void PunishTeamKiller(int client, int damage) {
  Players[client].subtractBonusPoints();
  Players[client].team_killer.add(damage);
  if(Players[client].points <= -1000) {
    KickClient(Players[client].id, "You have a very low score, to regain your respect:\ndon't shoot your teammates and kill infected");
  } else if(Players[client].team_killer.requireVoted(TK_MIN_DAMAGE, TK_MAX_DAMAGE)) {
    CPrintToChatAll(
      "{blue}Auto voteban \x01against {blue}%N \x04[\x05{green}%i TK\x04]",
      Players[client].id,
      Players[client].team_killer.counter
    );
    ServerCommand("sm_voteban #%d \"%s\"", GetClientUserId(Players[client].id), TK_BAN_REASON);
  } else if(Players[client].team_killer.requirePunishment(TK_MAX_DAMAGE)) {
    if(IsVoteInProgress()) CancelVote();
    CPrintToChatAll(
      "{blue}%N \x01has been banned, because {blue}team killer \x04[\x05{green}%i TK\x04]",
      Players[client].id,
      Players[client].team_killer.counter
    );
    if(bIsKarmaBanSystemActived) {
      KarmaBan(0, client, 1);
    } else {
      BanClient(client, 60, BANFLAG_AUTO, TK_BAN_REASON, "You have been banned because Team Killer", "sm_rank_system");
    }
  }
}
