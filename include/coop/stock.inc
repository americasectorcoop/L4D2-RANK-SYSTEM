/**
* Metodo para ordernar listados
* @return integer
*/
stock int iSortFunc(int[] x, int[] y, const int[][] array, Handle hndl) {
  if (x[1] > y[1]) {
    return -1;
  } else if (x[1] == y[1]) {
    return 0;
  }
  return 1;
}

/**
* Metodo para obtener un porcentaje
* @param int units
* @param int total_units
* return integer
*/
stock int iGetPercent(int units, int total_units) {
  return RoundToZero(units * 100.0 / total_units);
}

/**
* Metodo para verificar si el tank esta incapacitado
* @param int client
* @return bool
*/
stock bool bIsTankIncapacitated(int client) {
  // Verificando si el jugador no esta incapacitado y su vida es mayor a 0
  return view_as<bool>( bIsPlayerIncapped(client) || GetClientHealth(client) < 0 );
}

/**
* Metodo para verificar si el jugador esta vivo
* @param int client
* @return bool
*/
stock bool bIsPlayerIncapped(int client) {
  return view_as<bool>(GetEntProp(client, Prop_Send, "m_isIncapacitated", 1));
}

/**
* Metodo para verificar si el jugador esta colgando
* @param int client
* @return bool
*/
stock bool bIsPlayerGrapEdge(int client) {
  return view_as<bool>(GetEntProp(client, Prop_Send, "m_isHangingFromLedge", 1) || GetEntProp(client, Prop_Send, "m_isFallingFromLedge", 1));
}

/**
* Metodo para verificar si el primer mapa de la campaña
* @return bool
*/
stock bool bIsFirstMapOfCampaign() {
  char MapName[128];
  GetCurrentMap(MapName, sizeof(MapName));
  return (StrContains(MapName, "c", true) > -1) && (StrContains(MapName, "m1", true) > -1);
}

/**
* Método para obtener la clase de un zombie
*/
stock int iGetZombieClass(int client) {
  if(IsValidEntity(client)) {
    if(IsValidEdict(client)) {
      return GetEntProp(client, Prop_Send, "m_zombieClass");
    }
  }
  return 0;
}

void vGetTimeLabel(float TheSeconds, char[] TimeLabel, int maxsize) {
  int FlooredSeconds = RoundToFloor(TheSeconds);
  int FlooredSecondsMod = FlooredSeconds % 60;
  float Seconds = TheSeconds - float(FlooredSeconds) + float(FlooredSecondsMod);
  int Minutes = (TheSeconds < 60.0 ? 0 : RoundToNearest(float(FlooredSeconds - FlooredSecondsMod) / 60));
  int MinutesMod = Minutes % 60;
  int Hours = (Minutes < 60 ? 0 : RoundToNearest(float(Minutes - MinutesMod) / 60));
  Minutes = MinutesMod;
  if (Hours > 0) {
    Format(TimeLabel, maxsize, "%t", "%ih %im %.1fs", Hours, Minutes, Seconds);
  } else if (Minutes > 0) {
    Format(TimeLabel, maxsize, "%t", "%i min %.1f sec", Minutes, Seconds);
  } else {
    Format(TimeLabel, maxsize, "%t", "%.1f seconds", Seconds);
  }
}
