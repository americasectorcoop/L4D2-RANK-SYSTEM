public Action cmdVoteKick(int client, int args) {
  if(	IsFromStaff(client) || (Players[client].rank > 0 && Players[client].rank < 21)) {
    if(Players[client].vote_kick < 3) {
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
    if(client != i && IsRealClient(i) && !IsFromStaff(i)) {
      IntToString(i, str_userid, sizeof(str_userid));
      Format(str_name, sizeof(str_name), "%N [RANK: %d]", i, Players[i].rank);
      hMenu.AddItem(str_userid, str_name);
      players++;
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
      char char_client_id[12];
      menu.GetItem(item, char_client_id, sizeof(char_client_id));
      int target_client_id = StringToInt(char_client_id);
      if(target_client_id > 0) {
        Players[target_client_id].times_vkick++;
        Players[client].vote_kick += 1;
        ServerCommand("sm_votekick \"#%d\" \"%s %N\"", GetClientUserId(target_client_id), "Vote kick, started by ", client);
        CPrintToChatAll("\x04[\x05ASC\x04] %N\x01 start a vote kick for \x04%N", client, target_client_id);
      }
    }
  }
}
