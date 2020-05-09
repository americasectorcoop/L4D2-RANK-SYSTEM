
bool g_bPlayerIgnore[MAXPLAYERS+1][MAXPLAYERS+1];

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
    Players[client].mute_others++;
    Players[target].times_muted++;
    SetListenOverride(client, target, Listen_No);
    CPrintToChat(client, "{blue}You\x01 will no longer listen to the annoying {blue}%N", target);
  } else {
    SetListenOverride(client, target, Listen_Yes);
    CPrintToChat(client, "Now {blue}you\x01 can hear to {blue}%N", target);
  }
}