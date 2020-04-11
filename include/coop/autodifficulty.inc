float RDifficultyMultiplier = 1.0;
int playerscount = 4;
bool l4d2_plugin_loot = true;
bool l4d2_plugin_monsterbots = true;
bool extra_charger = false;
bool autodifficulty_calculated = false;
ConVar hm_autodifficulty;
ConVar hm_autodifficulty_forcehp;
ConVar z_difficulty;
ConVar z_special_spawn_interval;
ConVar director_special_respawn_interval;
ConVar z_max_player_zombies;
ConVar tank_burn_duration;
ConVar sv_maxplayers;

ConVar hm_auto_tongue_range_min;
ConVar hm_auto_tongue_range_max;
ConVar hm_auto_tongue_miss_delay_min;
ConVar hm_auto_tongue_miss_delay_max;
ConVar hm_auto_tongue_hit_delay_min;
ConVar hm_auto_tongue_hit_delay_max;
ConVar hm_auto_tongue_choke_dmg_min;
ConVar hm_auto_tongue_choke_dmg_max;
ConVar hm_auto_tongue_drag_dmg_min;
ConVar hm_auto_tongue_drag_dmg_max;
ConVar hm_auto_boomer_pz_claw_dmg_min;
ConVar hm_auto_boomer_pz_claw_dmg_max;
ConVar hm_auto_hunter_pz_claw_dmg_min;
ConVar hm_auto_hunter_pz_claw_dmg_max;
ConVar hm_auto_jockey_pz_claw_dmg_min;
ConVar hm_auto_jockey_pz_claw_dmg_max;
ConVar hm_auto_smoker_pz_claw_dmg_min;
ConVar hm_auto_smoker_pz_claw_dmg_max;
ConVar hm_auto_spitter_pz_claw_dmg_min;
ConVar hm_auto_spitter_pz_claw_dmg_max;
ConVar hm_auto_z_charger_pound_dmg_min;
ConVar hm_auto_z_charger_pound_dmg_max;
ConVar hm_auto_z_jockey_ride_damage_min;
ConVar hm_auto_z_jockey_ride_damage_max;

ConVar hm_auto_grenade_lr_dmg_min;
ConVar hm_auto_grenade_lr_dmg_max;

ConVar damage_type;
ConVar hm_damage_ak47_min;
ConVar hm_damage_ak47_max;
ConVar hm_damage_awp_min;
ConVar hm_damage_awp_max;
ConVar hm_damage_m60_min;
ConVar hm_damage_m60_max;
ConVar hm_damage_scout_min;
ConVar hm_damage_scout_max;
ConVar hm_damage_sg552_min;
ConVar hm_damage_sg552_max;
ConVar hm_damage_spas_min;
ConVar hm_damage_spas_max;
ConVar hm_damage_sniper_military_min;
ConVar hm_damage_sniper_military_max;

ConVar hm_damage2_ak47_min;
ConVar hm_damage2_ak47_max;
ConVar hm_damage2_awp_min;
ConVar hm_damage2_awp_max;
ConVar hm_damage2_m60_min;
ConVar hm_damage2_m60_max;
ConVar hm_damage2_scout_min;
ConVar hm_damage2_scout_max;
ConVar hm_damage2_sg552_min;
ConVar hm_damage2_sg552_max;
ConVar hm_damage2_spas_min;
ConVar hm_damage2_spas_max;
ConVar hm_damage2_sniper_military_min;
ConVar hm_damage2_sniper_military_max;

ConVar hm_meleefix_min;
ConVar hm_meleefix_max;
ConVar hm_meleefix_headshot_min;
ConVar hm_meleefix_headshot_max;
ConVar hm_meleefix_tank_min;
ConVar hm_meleefix_tank_max;
ConVar hm_meleefix_tank_headshot_min;
ConVar hm_meleefix_tank_headshot_max;
ConVar hm_meleefix_witch_min;
ConVar hm_meleefix_witch_max;

ConVar hm_loot_mod;
ConVar hm_tank_hp_mod;
ConVar hm_infected_hp_mod;
ConVar hm_spawn_time_mod;
ConVar hm_spawn_count_mod;

ConVar hm_special_infected_min;
ConVar hm_special_infected_max;
ConVar hm_spawn_interval_min;
ConVar hm_spawn_interval_max;
ConVar hm_tank_burn_duration_min;
ConVar hm_tank_burn_duration_max;

ConVar hm_autohp_automod;
ConVar hm_autohp_supercharger_auto;
ConVar hm_autohp_zombie_min;
ConVar hm_autohp_zombie_max;
ConVar hm_autohp_hunter_min;
ConVar hm_autohp_hunter_max;
ConVar hm_autohp_smoker_min;
ConVar hm_autohp_smoker_max;
ConVar hm_autohp_boomer_min;
ConVar hm_autohp_boomer_max;
ConVar hm_autohp_jockey_min;
ConVar hm_autohp_jockey_max;
ConVar hm_autohp_charger_min;
ConVar hm_autohp_charger_max;
ConVar hm_autohp_spitter_min;
ConVar hm_autohp_spitter_max;
ConVar hm_autohp_witch_min;
ConVar hm_autohp_witch_max;
ConVar hm_autohp_tank_min;
ConVar hm_autohp_tank_max;

ConVar hm_items_automod;
ConVar hm_items_supercharger_auto;
ConVar hm_items_hunter_min;
ConVar hm_items_hunter_max;
ConVar hm_items_smoker_min;
ConVar hm_items_smoker_max;
ConVar hm_items_boomer_min;
ConVar hm_items_boomer_max;
ConVar hm_items_jockey_min;
ConVar hm_items_jockey_max;
ConVar hm_items_charger_min;
ConVar hm_items_charger_max;
ConVar hm_items_spitter_min;
ConVar hm_items_spitter_max;
ConVar hm_items_tank_min;
ConVar hm_items_tank_max;

ConVar hm_spawn_automod;
ConVar hm_spawn_zombie_min;
ConVar hm_spawn_zombie_max;
ConVar hm_spawn_hunter_min;
ConVar hm_spawn_hunter_max;
ConVar hm_spawn_smoker_min;
ConVar hm_spawn_smoker_max;
ConVar hm_spawn_boomer_min;
ConVar hm_spawn_boomer_max;
ConVar hm_spawn_jockey_min;
ConVar hm_spawn_jockey_max;
ConVar hm_spawn_charger_min;
ConVar hm_spawn_charger_max;
ConVar hm_spawn_spitter_min;
ConVar hm_spawn_spitter_max;

ConVar hm_speed_automod;
ConVar hm_speed_hunter_min;
ConVar hm_speed_hunter_max;
ConVar hm_speed_smoker_min;
ConVar hm_speed_smoker_max;
ConVar hm_speed_boomer_min;
ConVar hm_speed_boomer_max;
ConVar hm_speed_jockey_min;
ConVar hm_speed_jockey_max;
ConVar hm_speed_charger_min;
ConVar hm_speed_charger_max;
ConVar hm_speed_spitter_min;
ConVar hm_speed_spitter_max;
ConVar hm_speed_tank_min;
ConVar hm_speed_tank_max;

char sGameDifficulty[16];
char Server_UpTime[32];
int UpTime = 0;
int cvar_difficulty = 1;
int cvar_maxplayers;

int AutodifficultyHP[MAXPLAYERS+1][9];
int AutodifficultyGrenadeLRDmg[MAXPLAYERS+1];
int AutodifficultyItems[MAXPLAYERS+1][9];
int AutodifficultySpawnLimit[MAXPLAYERS+1][9];
int AutodifficultySpeed[MAXPLAYERS+1][9];
int AutodifficultySpawnInterval[MAXPLAYERS+1];
int AutodifficultySpawnCount[MAXPLAYERS+1];
int AutodifficultyTongueMissDelay[MAXPLAYERS+1];
int AutodifficultyTongueHitDelay[MAXPLAYERS+1];
int AutodifficultyTongueRange[MAXPLAYERS+1];
int AutodifficultyTongueChokeDmg[MAXPLAYERS+1];
int AutodifficultyTongueDragDmg[MAXPLAYERS+1];
int AutodifficultyClawDmg[MAXPLAYERS+1][5];
int AutodifficultyChargerPoundDmg[MAXPLAYERS+1];
int AutodifficultyJockeyRideDmg[MAXPLAYERS+1];
int AutodifficultyTankBurnTime[MAXPLAYERS+1];
int Autodifficulty_ak47_Dmg[MAXPLAYERS+1];
int Autodifficulty_awp_Dmg[MAXPLAYERS+1];
int Autodifficulty_m60_Dmg[MAXPLAYERS+1];
int Autodifficulty_scout_Dmg[MAXPLAYERS+1];
int Autodifficulty_sg552_Dmg[MAXPLAYERS+1];
int Autodifficulty_spas_Dmg[MAXPLAYERS+1];
int Autodifficulty_sniper_military_Dmg[MAXPLAYERS+1];
int Autodifficulty_meleefix_Dmg[MAXPLAYERS+1];
int Autodifficulty_meleefix_headshot_Dmg[MAXPLAYERS+1];
int Autodifficulty_meleefix_tank_Dmg[MAXPLAYERS+1];
int Autodifficulty_meleefix_tank_headshot_Dmg[MAXPLAYERS+1];
int Autodifficulty_meleefix_witch_Dmg[MAXPLAYERS+1];

bool g_IsTimeAutodifficulty;
int g_iLastRefreshTime;

public void CoopAutoDiffOnPluginStart()
{
	UpTime = GetTime();
	
	hm_autodifficulty = CreateConVar("hm_autodifficulty", "1", "Is the plugin enabled.", _FCVAR_PLUGIN_);
	hm_autodifficulty_forcehp = CreateConVar("hm_autodifficulty_forcehp", "0", "", _FCVAR_PLUGIN_);
	hm_loot_mod = CreateConVar("hm_loot_mod", "1.0", "", _FCVAR_PLUGIN_);
	hm_tank_hp_mod = CreateConVar("hm_tank_hp_mod", "1.0", "", _FCVAR_PLUGIN_);
	hm_infected_hp_mod = CreateConVar("hm_infected_hp_mod", "1.0", "", _FCVAR_PLUGIN_);
	hm_spawn_time_mod = CreateConVar("hm_spawn_time_mod", "1.0", "", _FCVAR_PLUGIN_);
	hm_spawn_count_mod = CreateConVar("hm_spawn_count_mod", "1.0", "", _FCVAR_PLUGIN_);

	z_difficulty = FindConVar("z_difficulty");
	HookConVarChange(z_difficulty, z_difficulty_changed);

	z_special_spawn_interval = FindConVar("z_special_spawn_interval");
	director_special_respawn_interval = FindConVar("director_special_respawn_interval");
	z_max_player_zombies = FindConVar("z_max_player_zombies");

	hm_auto_tongue_range_min = CreateConVar("hm_auto_tongue_range_min", "750", "", _FCVAR_PLUGIN_);
	hm_auto_tongue_range_max = CreateConVar("hm_auto_tongue_range_max", "2500", "", _FCVAR_PLUGIN_);	
	hm_auto_tongue_miss_delay_min = CreateConVar("hm_auto_tongue_miss_delay_min", "5", "Минимальное время перезарядки языка при промахе.", _FCVAR_PLUGIN_);
	hm_auto_tongue_miss_delay_max = CreateConVar("hm_auto_tongue_miss_delay_max", "15", "Максимальное время перезарядки языка при промахе.", _FCVAR_PLUGIN_);
	hm_auto_tongue_hit_delay_min = CreateConVar("hm_auto_tongue_hit_delay_min", "5", "Минимальное время перезарядки языка, после отпускания (не важно по какой причине) предыдущей жертвы.", _FCVAR_PLUGIN_);
	hm_auto_tongue_hit_delay_max = CreateConVar("hm_auto_tongue_hit_delay_max", "20", "Максимальное время перезарядки языка, после отпускания (не важно по какой причине) предыдущей жертвы.", _FCVAR_PLUGIN_);
	hm_auto_tongue_choke_dmg_min = CreateConVar("hm_auto_tongue_choke_dmg_min", "24", "", _FCVAR_PLUGIN_);
	hm_auto_tongue_choke_dmg_max = CreateConVar("hm_auto_tongue_choke_dmg_max", "67", "", _FCVAR_PLUGIN_);
	hm_auto_tongue_drag_dmg_min = CreateConVar("hm_auto_tongue_drag_dmg_min", "9", "", _FCVAR_PLUGIN_);
	hm_auto_tongue_drag_dmg_max = CreateConVar("hm_auto_tongue_drag_dmg_max", "45", "", _FCVAR_PLUGIN_);
	hm_auto_boomer_pz_claw_dmg_min = CreateConVar("hm_auto_boomer_pz_claw_dmg_min", "4", "", _FCVAR_PLUGIN_);
	hm_auto_boomer_pz_claw_dmg_max = CreateConVar("hm_auto_boomer_pz_claw_dmg_max", "24", "", _FCVAR_PLUGIN_);
	hm_auto_hunter_pz_claw_dmg_min = CreateConVar("hm_auto_hunter_pz_claw_dmg_min", "6", "", _FCVAR_PLUGIN_);
	hm_auto_hunter_pz_claw_dmg_max = CreateConVar("hm_auto_hunter_pz_claw_dmg_max", "38", "", _FCVAR_PLUGIN_);
	hm_auto_jockey_pz_claw_dmg_min = CreateConVar("hm_auto_jockey_pz_claw_dmg_min", "4", "", _FCVAR_PLUGIN_);
	hm_auto_jockey_pz_claw_dmg_max = CreateConVar("hm_auto_jockey_pz_claw_dmg_max", "28", "", _FCVAR_PLUGIN_);
	hm_auto_smoker_pz_claw_dmg_min = CreateConVar("hm_auto_smoker_pz_claw_dmg_min", "4", "", _FCVAR_PLUGIN_);
	hm_auto_smoker_pz_claw_dmg_max = CreateConVar("hm_auto_smoker_pz_claw_dmg_max", "24", "", _FCVAR_PLUGIN_);
	hm_auto_spitter_pz_claw_dmg_min = CreateConVar("hm_auto_spitter_pz_claw_dmg_min", "4", "", _FCVAR_PLUGIN_);
	hm_auto_spitter_pz_claw_dmg_max = CreateConVar("hm_auto_spitter_pz_claw_dmg_max", "32", "", _FCVAR_PLUGIN_);
	hm_auto_z_charger_pound_dmg_min = CreateConVar("hm_auto_z_charger_pound_dmg_min", "15", "", _FCVAR_PLUGIN_);
	hm_auto_z_charger_pound_dmg_max = CreateConVar("hm_auto_z_charger_pound_dmg_max", "52", "", _FCVAR_PLUGIN_);
	hm_auto_z_jockey_ride_damage_min = CreateConVar("hm_auto_z_jockey_ride_damage_min", "4", "", _FCVAR_PLUGIN_);
	hm_auto_z_jockey_ride_damage_max = CreateConVar("hm_auto_z_jockey_ride_damage_max", "7", "", _FCVAR_PLUGIN_);

	hm_auto_grenade_lr_dmg_min = CreateConVar("hm_auto_grenade_lr_dmg_min", "400", "", _FCVAR_PLUGIN_);
	hm_auto_grenade_lr_dmg_max = CreateConVar("hm_auto_grenade_lr_dmg_max", "4000", "", _FCVAR_PLUGIN_);
	
	hm_damage_ak47_min = CreateConVar("hm_damage_ak47_min", "2523", "", _FCVAR_PLUGIN_);
	hm_damage_ak47_max = CreateConVar("hm_damage_ak47_max", "11160", "", _FCVAR_PLUGIN_);
	hm_damage_awp_min = CreateConVar("hm_damage_awp_min", "9486", "", _FCVAR_PLUGIN_);
	hm_damage_awp_max = CreateConVar("hm_damage_awp_max", "39272", "", _FCVAR_PLUGIN_);
	hm_damage_m60_min = CreateConVar("hm_damage_m60_min", "1652", "", _FCVAR_PLUGIN_);
	hm_damage_m60_max = CreateConVar("hm_damage_m60_max", "9812", "", _FCVAR_PLUGIN_);
	hm_damage_scout_min = CreateConVar("hm_damage_scout_min", "4667", "", _FCVAR_PLUGIN_);
	hm_damage_scout_max = CreateConVar("hm_damage_scout_max", "20286", "", _FCVAR_PLUGIN_);
	hm_damage_sg552_min = CreateConVar("hm_damage_sg552_min", "1111", "", _FCVAR_PLUGIN_);
	hm_damage_sg552_max = CreateConVar("hm_damage_sg552_max", "4500", "", _FCVAR_PLUGIN_);
	hm_damage_spas_min = CreateConVar("hm_damage_spas_min", "3000", "", _FCVAR_PLUGIN_);
	hm_damage_spas_max = CreateConVar("hm_damage_spas_max", "12430", "", _FCVAR_PLUGIN_);
	hm_damage_sniper_military_min = CreateConVar("hm_damage_sniper_military_min", "1055", "", _FCVAR_PLUGIN_);
	hm_damage_sniper_military_max = CreateConVar("hm_damage_sniper_military_max", "2000", "", _FCVAR_PLUGIN_);
	
	hm_damage2_ak47_min = CreateConVar("hm_damage2_ak47_min", "140", "", _FCVAR_PLUGIN_);
	hm_damage2_ak47_max = CreateConVar("hm_damage2_ak47_max", "700", "", _FCVAR_PLUGIN_);
	hm_damage2_awp_min = CreateConVar("hm_damage2_awp_min", "750", "", _FCVAR_PLUGIN_);
	hm_damage2_awp_max = CreateConVar("hm_damage2_awp_max", "4400", "", _FCVAR_PLUGIN_);
	hm_damage2_m60_min = CreateConVar("hm_damage2_m60_min", "85", "", _FCVAR_PLUGIN_);
	hm_damage2_m60_max = CreateConVar("hm_damage2_m60_max", "500", "", _FCVAR_PLUGIN_);
	hm_damage2_scout_min = CreateConVar("hm_damage2_scout_min", "420", "", _FCVAR_PLUGIN_);
	hm_damage2_scout_max = CreateConVar("hm_damage2_scout_max", "2000", "", _FCVAR_PLUGIN_);
	hm_damage2_sg552_min = CreateConVar("hm_damage2_sg552_min", "70", "", _FCVAR_PLUGIN_);
	hm_damage2_sg552_max = CreateConVar("hm_damage2_sg552_max", "240", "", _FCVAR_PLUGIN_);
	hm_damage2_spas_min = CreateConVar("hm_damage2_spas_min", "80", "", _FCVAR_PLUGIN_);
	hm_damage2_spas_max = CreateConVar("hm_damage2_spas_max", "370", "", _FCVAR_PLUGIN_);
	hm_damage2_sniper_military_min = CreateConVar("hm_damage2_sniper_military_min", "50", "", _FCVAR_PLUGIN_);
	hm_damage2_sniper_military_max = CreateConVar("hm_damage2_sniper_military_max", "150", "", _FCVAR_PLUGIN_);
	
	hm_meleefix_min = CreateConVar("hm_meleefix_min", "1300", "", _FCVAR_PLUGIN_);
	hm_meleefix_max = CreateConVar("hm_meleefix_max", "8000", "", _FCVAR_PLUGIN_);
	hm_meleefix_headshot_min = CreateConVar("hm_meleefix_headshot_min", "1800", "", _FCVAR_PLUGIN_);
	hm_meleefix_headshot_max = CreateConVar("hm_meleefix_headshot_max", "9000", "", _FCVAR_PLUGIN_);
	hm_meleefix_tank_min = CreateConVar("hm_meleefix_tank_min", "700", "", _FCVAR_PLUGIN_);
	hm_meleefix_tank_max = CreateConVar("hm_meleefix_tank_max", "4000", "", _FCVAR_PLUGIN_);
	hm_meleefix_tank_headshot_min = CreateConVar("hm_meleefix_tank_headshot_min", "1000", "", _FCVAR_PLUGIN_);
	hm_meleefix_tank_headshot_max = CreateConVar("hm_meleefix_tank_headshot_max", "5000", "", _FCVAR_PLUGIN_);
	hm_meleefix_witch_min = CreateConVar("hm_meleefix_witch_min", "200", "", _FCVAR_PLUGIN_);
	hm_meleefix_witch_max = CreateConVar("hm_meleefix_witch_max", "400", "", _FCVAR_PLUGIN_);

	hm_special_infected_min = CreateConVar("hm_special_infected_min", "4", "", _FCVAR_PLUGIN_);
	hm_special_infected_max = CreateConVar("hm_special_infected_max", "6", "", _FCVAR_PLUGIN_);
	hm_spawn_interval_min = CreateConVar("hm_spawn_interval_min", "5", "", _FCVAR_PLUGIN_);
	hm_spawn_interval_max = CreateConVar("hm_spawn_interval_max", "20", "", _FCVAR_PLUGIN_);
	hm_tank_burn_duration_min = CreateConVar("hm_tank_burn_duration_min", "90", "", _FCVAR_PLUGIN_);
	hm_tank_burn_duration_max = CreateConVar("hm_tank_burn_duration_max", "270", "", _FCVAR_PLUGIN_);
	
	hm_autohp_automod = CreateConVar("hm_autohp_automod", "0", "", _FCVAR_PLUGIN_);
	hm_autohp_supercharger_auto = CreateConVar("hm_autohp_supercharger_auto", "1", "", _FCVAR_PLUGIN_);
	hm_autohp_zombie_min = CreateConVar("hm_autohp_zombie_min", "50", "", _FCVAR_PLUGIN_);
	hm_autohp_zombie_max = CreateConVar("hm_autohp_zombie_max", "150", "", _FCVAR_PLUGIN_);
	hm_autohp_hunter_min = CreateConVar("hm_autohp_hunter_min", "250", "", _FCVAR_PLUGIN_);
	hm_autohp_hunter_max = CreateConVar("hm_autohp_hunter_max", "3400", "", _FCVAR_PLUGIN_);
	hm_autohp_smoker_min = CreateConVar("hm_autohp_smoker_min", "250", "", _FCVAR_PLUGIN_);
	hm_autohp_smoker_max = CreateConVar("hm_autohp_smoker_max", "3500", "", _FCVAR_PLUGIN_);
	hm_autohp_boomer_min = CreateConVar("hm_autohp_boomer_min", "100", "", _FCVAR_PLUGIN_);
	hm_autohp_boomer_max = CreateConVar("hm_autohp_boomer_max", "1600", "", _FCVAR_PLUGIN_);
	hm_autohp_jockey_min = CreateConVar("hm_autohp_jockey_min", "325", "", _FCVAR_PLUGIN_);
	hm_autohp_jockey_max = CreateConVar("hm_autohp_jockey_max", "3800", "", _FCVAR_PLUGIN_);
	hm_autohp_spitter_min = CreateConVar("hm_autohp_spitter_min", "100", "", _FCVAR_PLUGIN_);
	hm_autohp_spitter_max = CreateConVar("hm_autohp_spitter_max", "2500", "", _FCVAR_PLUGIN_);
	hm_autohp_charger_min = CreateConVar("hm_autohp_charger_min", "650", "", _FCVAR_PLUGIN_);
	hm_autohp_charger_max = CreateConVar("hm_autohp_charger_max", "4000", "", _FCVAR_PLUGIN_);
	hm_autohp_witch_min = CreateConVar("hm_autohp_witch_min", "1000", "", _FCVAR_PLUGIN_);
	hm_autohp_witch_max = CreateConVar("hm_autohp_witch_max", "3000", "", _FCVAR_PLUGIN_);
	hm_autohp_tank_min = CreateConVar("hm_autohp_tank_min", "16000", "", _FCVAR_PLUGIN_);
	hm_autohp_tank_max = CreateConVar("hm_autohp_tank_max", "140000", "", _FCVAR_PLUGIN_);

	hm_items_automod = CreateConVar("hm_items_automod", "1", "", _FCVAR_PLUGIN_);
	hm_items_supercharger_auto = CreateConVar("hm_items_supercharger_auto", "1", "", _FCVAR_PLUGIN_);
	hm_items_hunter_min = CreateConVar("hm_items_hunter_min", "1", "", _FCVAR_PLUGIN_);
	hm_items_hunter_max = CreateConVar("hm_items_hunter_max", "3", "", _FCVAR_PLUGIN_);
	hm_items_smoker_min = CreateConVar("hm_items_smoker_min", "1", "", _FCVAR_PLUGIN_);
	hm_items_smoker_max = CreateConVar("hm_items_smoker_max", "2", "", _FCVAR_PLUGIN_);
	hm_items_boomer_min = CreateConVar("hm_items_boomer_min", "1", "", _FCVAR_PLUGIN_);
	hm_items_boomer_max = CreateConVar("hm_items_boomer_max", "2", "", _FCVAR_PLUGIN_);
	hm_items_jockey_min = CreateConVar("hm_items_jockey_min", "1", "", _FCVAR_PLUGIN_);
	hm_items_jockey_max = CreateConVar("hm_items_jockey_max", "3", "", _FCVAR_PLUGIN_);
	hm_items_charger_min = CreateConVar("hm_items_charger_min", "2", "", _FCVAR_PLUGIN_);
	hm_items_charger_max = CreateConVar("hm_items_charger_max", "3", "", _FCVAR_PLUGIN_);
	hm_items_spitter_min = CreateConVar("hm_items_spitter_min", "1", "", _FCVAR_PLUGIN_);
	hm_items_spitter_max = CreateConVar("hm_items_spitter_max", "2", "", _FCVAR_PLUGIN_);
	hm_items_tank_min = CreateConVar("hm_items_tank_min", "8", "", _FCVAR_PLUGIN_);
	hm_items_tank_max = CreateConVar("hm_items_tank_max", "16", "", _FCVAR_PLUGIN_);

	hm_spawn_automod = CreateConVar("hm_spawn_automod", "1", "", _FCVAR_PLUGIN_);
	hm_spawn_zombie_min = CreateConVar("hm_spawn_zombie_min", "15", "", _FCVAR_PLUGIN_);
	hm_spawn_zombie_max = CreateConVar("hm_spawn_zombie_max", "16", "", _FCVAR_PLUGIN_);
	hm_spawn_hunter_min = CreateConVar("hm_spawn_hunter_min", "1", "", _FCVAR_PLUGIN_);
	hm_spawn_hunter_max = CreateConVar("hm_spawn_hunter_max", "3", "", _FCVAR_PLUGIN_);
	hm_spawn_smoker_min = CreateConVar("hm_spawn_smoker_min", "1", "", _FCVAR_PLUGIN_);
	hm_spawn_smoker_max = CreateConVar("hm_spawn_smoker_max", "3", "", _FCVAR_PLUGIN_);
	hm_spawn_boomer_min = CreateConVar("hm_spawn_boomer_min", "1", "", _FCVAR_PLUGIN_);
	hm_spawn_boomer_max = CreateConVar("hm_spawn_boomer_max", "4", "", _FCVAR_PLUGIN_);
	hm_spawn_jockey_min = CreateConVar("hm_spawn_jockey_min", "1", "", _FCVAR_PLUGIN_);
	hm_spawn_jockey_max = CreateConVar("hm_spawn_jockey_max", "3", "", _FCVAR_PLUGIN_);
	hm_spawn_spitter_min = CreateConVar("hm_spawn_spitter_min", "1", "", _FCVAR_PLUGIN_);
	hm_spawn_spitter_max = CreateConVar("hm_spawn_spitter_max", "3", "", _FCVAR_PLUGIN_);
	hm_spawn_charger_min = CreateConVar("hm_spawn_charger_min", "1", "", _FCVAR_PLUGIN_);
	hm_spawn_charger_max = CreateConVar("hm_spawn_charger_max", "3", "", _FCVAR_PLUGIN_);

	hm_speed_automod = CreateConVar("hm_speed_automod", "1", "", _FCVAR_PLUGIN_);
	hm_speed_hunter_min = CreateConVar("hm_speed_hunter_min", "300", "", _FCVAR_PLUGIN_);
	hm_speed_hunter_max = CreateConVar("hm_speed_hunter_max", "350", "", _FCVAR_PLUGIN_);
	hm_speed_smoker_min = CreateConVar("hm_speed_smoker_min", "210", "", _FCVAR_PLUGIN_);
	hm_speed_smoker_max = CreateConVar("hm_speed_smoker_max", "315", "", _FCVAR_PLUGIN_);
	hm_speed_boomer_min = CreateConVar("hm_speed_boomer_min", "175", "", _FCVAR_PLUGIN_);
	hm_speed_boomer_max = CreateConVar("hm_speed_boomer_max", "300", "", _FCVAR_PLUGIN_);
	hm_speed_jockey_min = CreateConVar("hm_speed_jockey_min", "250", "", _FCVAR_PLUGIN_);
	hm_speed_jockey_max = CreateConVar("hm_speed_jockey_max", "340", "", _FCVAR_PLUGIN_);
	hm_speed_charger_min = CreateConVar("hm_speed_charger_min", "250", "", _FCVAR_PLUGIN_);
	hm_speed_charger_max = CreateConVar("hm_speed_charger_max", "350", "", _FCVAR_PLUGIN_);
	hm_speed_spitter_min = CreateConVar("hm_speed_spitter_min", "210", "", _FCVAR_PLUGIN_);
	hm_speed_spitter_max = CreateConVar("hm_speed_spitter_max", "345", "", _FCVAR_PLUGIN_);
	hm_speed_tank_min = CreateConVar("hm_speed_tank_min", "210", "", _FCVAR_PLUGIN_);
	hm_speed_tank_max = CreateConVar("hm_speed_tank_max", "350", "", _FCVAR_PLUGIN_);

	RegAdminCmd("sm_autodifficulty_init", Command_AutoDifficultyInit, ADMFLAG_CONFIG, "");
	RegAdminCmd("sm_autodifficulty_refresh", Command_AutoDifficultyRefresh, ADMFLAG_CONFIG, "");
	RegAdminCmd("sm_check", Command_Check, ADMFLAG_CONFIG, "");
	RegAdminCmd("sm_spawn_limits", Command_SpawnLimits, ADMFLAG_CONFIG, "");

	RegConsoleCmd("sm_rankmod", Command_RankMod);
	RegConsoleCmd("sm_ddfull", Command_ddfull);
	RegConsoleCmd("sm_damage", Command_damage);
	RegConsoleCmd("sm_chance", Command_ammo);
	RegConsoleCmd("sm_melee", Command_melee);
	RegConsoleCmd("sm_info1", Command_info2);
	RegConsoleCmd("sm_pinfo", Command_pinfo);
	RegAdminCmd("sm_swd", Command_swd, ADMFLAG_GENERIC, "sm_swd");
	RegAdminCmd("sm_swdoff", Command_swdoff, ADMFLAG_GENERIC, "sm_swdoff");
	
	sv_maxplayers = FindConVar("sv_maxplayers");
	HookConVarChange(sv_maxplayers, cvar_maxplayers_changed);
	
	// RegConsoleCmd("say", cmd_Say);
	// RegConsoleCmd("say_team", cmd_Say);
	// AddCommandListener(ActivatedTrigger, "say");
	// AddCommandListener(ActivatedTrigger, "say_team");
	
	g_iLastRefreshTime = GetTime();
}

void ADOnMapStart()
{
	g_IsTimeAutodifficulty = false;
#if DEBUG
	PrintToRoot("{red}[AUTODIFFICULTY] \x04ADOnMapStart");
#endif
}

void ADRoundStart()
{
	if (FindConVar("monsterbots_interval") == INVALID_HANDLE) {
		l4d2_plugin_monsterbots = false;
		int flags = GetConVarFlags(FindConVar("z_max_player_zombies"));
		SetConVarBounds(FindConVar("z_max_player_zombies"), ConVarBound_Upper, false);
		SetConVarFlags(FindConVar("z_max_player_zombies"), flags & ~FCVAR_NOTIFY);
	} else {
		l4d2_plugin_monsterbots = true;
	}
	cvar_maxplayers = FindConVar("sv_maxplayers").IntValue - 5;
	CreateTimer(24.5, TimedAutoDifficulty);
}

public Action TimedAutoDifficulty(Handle timer, any client)
{
	g_IsTimeAutodifficulty = true;
	Autodifficulty();
#if DEBUG
	PrintToRoot("{red}[AUTODIFFICULTY] \x04TimedAutoDifficulty");
#endif
}

public Action Command_AutoDifficultyInit(int client, int args)
{
	AutoDifficultyInit();
}

public Action Command_AutoDifficultyRefresh(int client, int args) {
	AutoDifficultyRefresh();
}

void AutoDifficultyRefresh() {
	if (GetTeamClientCount(TEAM_SURVIVORS) > 0 && g_IsTimeAutodifficulty && ((GetTime() - g_iLastRefreshTime) > 3)) {
		Autodifficulty();
	}
}


public Action Command_Check(int client, int args)
{
	PrintToServer("hm_autohp_charger_min = %d, hm_autohp_charger_max = %d, sv_maxplayers = %d", hm_autohp_charger_min.IntValue, hm_autohp_charger_max.IntValue, cvar_maxplayers);
	for (int i = 4; i <= MaxClients; i++)
	{
		PrintToServer("AutodifficultyItems[%d][ZC_SMOKER] = %d | AutodifficultyHP[%d][ZC_CHARGER] = %d", i, AutodifficultyItems[i][ZC_SMOKER], i, AutodifficultyHP[i][ZC_CHARGER]);
	}
}

public Action Command_SpawnLimits(int client, int args)
{
	if (client)
	{
		PrintToChat(client, "z_common_limit = %d", FindConVar("z_common_limit").IntValue);
		PrintToChat(client, "z_hunter_limit = %d", FindConVar("z_hunter_limit").IntValue);
		PrintToChat(client, "z_smoker_limit = %d", FindConVar("z_smoker_limit").IntValue);
		PrintToChat(client, "z_boomer_limit = %d", FindConVar("z_boomer_limit").IntValue);
		PrintToChat(client, "z_spitter_limit = %d", FindConVar("z_spitter_limit").IntValue);
		PrintToChat(client, "z_jockey_limit = %d", FindConVar("z_jockey_limit").IntValue);
		PrintToChat(client, "z_charger_limit = %d", FindConVar("z_charger_limit").IntValue);
	}
	else
	{
		PrintToServer("z_common_limit = %d", FindConVar("z_common_limit").IntValue);
		PrintToServer("z_hunter_limit = %d (spawned %d)", FindConVar("z_hunter_limit").IntValue, CountMonsters(ZC_HUNTER));
		PrintToServer("z_smoker_limit = %d (spawned %d)", FindConVar("z_smoker_limit").IntValue, CountMonsters(ZC_SMOKER));
		PrintToServer("z_boomer_limit = %d (spawned %d)", FindConVar("z_boomer_limit").IntValue, CountMonsters(ZC_BOOMER));
		PrintToServer("z_spitter_limit = %d (spawned %d)", FindConVar("z_spitter_limit").IntValue, CountMonsters(ZC_SPITTER));
		PrintToServer("z_jockey_limit = %d (spawned %d)", FindConVar("z_jockey_limit").IntValue, CountMonsters(ZC_JOCKEY));
		PrintToServer("z_charger_limit = %d (spawned %d)", FindConVar("z_charger_limit").IntValue, CountMonsters(ZC_CHARGER));
	}
}

int CountMonsters(int ZOMBIE_CLASS)
{
	int count = 0;
	for (int i = 1; i <= MaxClients; i++) if (iGetZombieClass(i) == ZOMBIE_CLASS) count++;
	return count;
}

public void z_difficulty_changed(Handle hVariable, const char[] strOldValue, const char[] strNewValue)
{
	UpdateDifficultyName();
}

/*public void hm_ad_options_changed(Handle hVariable, const char[] strOldValue, const char[] strNewValue)
{
	AutoDifficultyInit();
}*/

void UpdateDifficultyName()
{
	z_difficulty.GetString(sGameDifficulty, sizeof(sGameDifficulty));
	if (ReplaceString(sGameDifficulty, sizeof(sGameDifficulty), "Impossible", "Expert", false)) cvar_difficulty = 4;
	else if (ReplaceString(sGameDifficulty, sizeof(sGameDifficulty), "Hard", "Master", false)) cvar_difficulty = 3;
}

void AutoDifficultyInit()
{
	UpdateDifficultyName();
	if (!cvar_maxplayers) cvar_maxplayers = FindConVar("sv_maxplayers").IntValue - 5;
	if (cvar_maxplayers < 1) return;
	damage_type = FindConVar("hm_damage_type");
	if (FindConVar("l4d2_loot_h_drop_items") == null) l4d2_plugin_loot = false;
	else l4d2_plugin_loot = true;	
	if (FindConVar("monsterbots_interval") == null) l4d2_plugin_monsterbots = false;
	else l4d2_plugin_monsterbots = true;
	if (FindConVar("l4d2_charger_steering_allow") != null && FindConVar("l4d2_charger_steering_allow").IntValue > 0 && hm_autohp_supercharger_auto.FloatValue > 0) extra_charger = true;
	else extra_charger = false;
	for (int i = 4; i <= MaxClients; i++)
	{
		AutodifficultyHP[i][ZC_ZOMBIE] = GetLineFunction(hm_autohp_zombie_min.IntValue, hm_autohp_zombie_max.IntValue, i);
		AutodifficultyHP[i][ZC_SMOKER] = GetLineFunction(hm_autohp_smoker_min.IntValue, hm_autohp_smoker_max.IntValue, i);
		AutodifficultyHP[i][ZC_BOOMER] = GetLineFunction(hm_autohp_boomer_min.IntValue, hm_autohp_boomer_max.IntValue, i);
		AutodifficultyHP[i][ZC_HUNTER] = GetLineFunction(hm_autohp_hunter_min.IntValue, hm_autohp_hunter_max.IntValue, i);
		AutodifficultyHP[i][ZC_SPITTER] = GetLineFunction(hm_autohp_spitter_min.IntValue, hm_autohp_spitter_max.IntValue, i);
		AutodifficultyHP[i][ZC_JOCKEY] = GetLineFunction(hm_autohp_jockey_min.IntValue, hm_autohp_jockey_max.IntValue, i);
		AutodifficultyHP[i][ZC_CHARGER] = GetLineFunction(hm_autohp_charger_min.IntValue, hm_autohp_charger_max.IntValue, i);
		AutodifficultyHP[i][ZC_WITCH] = GetLineFunction(hm_autohp_witch_min.IntValue, hm_autohp_witch_max.IntValue, i);
		AutodifficultyHP[i][ZC_TANK] = RoundToNearest(GetLineFunction(hm_autohp_tank_min.IntValue, hm_autohp_tank_max.IntValue, i) / 2.0);
		if (l4d2_plugin_loot)
		{
			AutodifficultyItems[i][ZC_SMOKER] = GetLineFunction(hm_items_smoker_min.IntValue, hm_items_smoker_max.IntValue, i);
			AutodifficultyItems[i][ZC_BOOMER] = GetLineFunction(hm_items_boomer_min.IntValue, hm_items_boomer_max.IntValue, i);
			AutodifficultyItems[i][ZC_HUNTER] = GetLineFunction(hm_items_hunter_min.IntValue, hm_items_hunter_max.IntValue, i);
			AutodifficultyItems[i][ZC_SPITTER] = GetLineFunction(hm_items_spitter_min.IntValue, hm_items_spitter_max.IntValue, i);
			AutodifficultyItems[i][ZC_JOCKEY] = GetLineFunction(hm_items_jockey_min.IntValue, hm_items_jockey_max.IntValue, i);
			AutodifficultyItems[i][ZC_CHARGER] = GetLineFunction(hm_items_charger_min.IntValue, hm_items_charger_max.IntValue, i);
			AutodifficultyItems[i][ZC_TANK] = GetLineFunction(hm_items_tank_min.IntValue, hm_items_tank_max.IntValue, i);
		}
		AutodifficultySpawnLimit[i][ZC_ZOMBIE] = GetLineFunction(hm_spawn_zombie_min.IntValue, hm_spawn_zombie_max.IntValue, i);
		AutodifficultySpawnLimit[i][ZC_SMOKER] = GetLineFunction(hm_spawn_smoker_min.IntValue, hm_spawn_smoker_max.IntValue, i);
		AutodifficultySpawnLimit[i][ZC_BOOMER] = GetLineFunction(hm_spawn_boomer_min.IntValue, hm_spawn_boomer_max.IntValue, i);
		AutodifficultySpawnLimit[i][ZC_HUNTER] = GetLineFunction(hm_spawn_hunter_min.IntValue, hm_spawn_hunter_max.IntValue, i);
		AutodifficultySpawnLimit[i][ZC_SPITTER] = GetLineFunction(hm_spawn_spitter_min.IntValue, hm_spawn_spitter_max.IntValue, i);
		AutodifficultySpawnLimit[i][ZC_JOCKEY] = GetLineFunction(hm_spawn_jockey_min.IntValue, hm_spawn_jockey_max.IntValue, i);
		AutodifficultySpawnLimit[i][ZC_CHARGER] = GetLineFunction(hm_spawn_charger_min.IntValue, hm_spawn_charger_max.IntValue, i);

		AutodifficultySpeed[i][ZC_SMOKER] = GetLineFunction(hm_speed_smoker_min.IntValue, hm_speed_smoker_max.IntValue, i);
		AutodifficultySpeed[i][ZC_BOOMER] = GetLineFunction(hm_speed_boomer_min.IntValue, hm_speed_boomer_max.IntValue, i);
		AutodifficultySpeed[i][ZC_HUNTER] = GetLineFunction(hm_speed_hunter_min.IntValue, hm_speed_hunter_max.IntValue, i);
		AutodifficultySpeed[i][ZC_SPITTER] = GetLineFunction(hm_speed_spitter_min.IntValue, hm_speed_spitter_max.IntValue, i);
		AutodifficultySpeed[i][ZC_JOCKEY] = GetLineFunction(hm_speed_jockey_min.IntValue, hm_speed_jockey_max.IntValue, i);
		AutodifficultySpeed[i][ZC_CHARGER] = GetLineFunction(hm_speed_charger_min.IntValue, hm_speed_charger_max.IntValue, i);
		AutodifficultySpeed[i][ZC_TANK] = GetLineFunction(hm_speed_tank_min.IntValue, hm_speed_tank_max.IntValue, i);

		AutodifficultySpawnInterval[i] = GetLineFunction(hm_spawn_interval_max.IntValue, hm_spawn_interval_min.IntValue, i);
		AutodifficultySpawnCount[i] = GetLineFunction(hm_special_infected_min.IntValue, hm_special_infected_max.IntValue, i);
		AutodifficultyTongueRange[i] = GetLineFunction(hm_auto_tongue_range_min.IntValue, hm_auto_tongue_range_max.IntValue, i);
		AutodifficultyTongueMissDelay[i] = GetLineFunction(hm_auto_tongue_miss_delay_max.IntValue, hm_auto_tongue_miss_delay_min.IntValue, i);
		AutodifficultyTongueHitDelay[i] = GetLineFunction(hm_auto_tongue_hit_delay_max.IntValue, hm_auto_tongue_hit_delay_min.IntValue, i);
		AutodifficultyTongueChokeDmg[i] = GetLineFunction(hm_auto_tongue_choke_dmg_min.IntValue, hm_auto_tongue_choke_dmg_max.IntValue, i);
		AutodifficultyTongueDragDmg[i] = GetLineFunction(hm_auto_tongue_drag_dmg_min.IntValue, hm_auto_tongue_drag_dmg_max.IntValue, i);
		AutodifficultyClawDmg[i][0] = GetLineFunction(hm_auto_smoker_pz_claw_dmg_min.IntValue, hm_auto_smoker_pz_claw_dmg_max.IntValue, i);
		AutodifficultyClawDmg[i][1] = GetLineFunction(hm_auto_boomer_pz_claw_dmg_min.IntValue, hm_auto_boomer_pz_claw_dmg_max.IntValue, i);
		AutodifficultyClawDmg[i][2] = GetLineFunction(hm_auto_hunter_pz_claw_dmg_min.IntValue, hm_auto_hunter_pz_claw_dmg_max.IntValue, i);
		AutodifficultyClawDmg[i][3] = GetLineFunction(hm_auto_spitter_pz_claw_dmg_min.IntValue, hm_auto_spitter_pz_claw_dmg_max.IntValue, i);
		AutodifficultyClawDmg[i][4] = GetLineFunction(hm_auto_jockey_pz_claw_dmg_min.IntValue, hm_auto_jockey_pz_claw_dmg_max.IntValue, i);
		AutodifficultyChargerPoundDmg[i] = GetLineFunction(hm_auto_z_charger_pound_dmg_min.IntValue, hm_auto_z_charger_pound_dmg_max.IntValue, i);
		AutodifficultyJockeyRideDmg[i] = GetLineFunction(hm_auto_z_jockey_ride_damage_min.IntValue, hm_auto_z_jockey_ride_damage_max.IntValue, i);
		AutodifficultyGrenadeLRDmg[i] = GetLineFunction(hm_auto_grenade_lr_dmg_min.IntValue, hm_auto_grenade_lr_dmg_max.IntValue, i);
		AutodifficultyTankBurnTime[i] = GetLineFunction(hm_tank_burn_duration_min.IntValue, hm_tank_burn_duration_max.IntValue, i);
		
		if (damage_type.IntValue == 1)
		{
			Autodifficulty_ak47_Dmg[i] = GetLineFunction(hm_damage_ak47_min.IntValue, hm_damage_ak47_max.IntValue, i);
			Autodifficulty_awp_Dmg[i] = GetLineFunction(hm_damage_awp_min.IntValue, hm_damage_awp_max.IntValue, i);
			Autodifficulty_m60_Dmg[i] = GetLineFunction(hm_damage_m60_min.IntValue, hm_damage_m60_max.IntValue, i);
			Autodifficulty_scout_Dmg[i] = GetLineFunction(hm_damage_scout_min.IntValue, hm_damage_scout_max.IntValue, i);
			Autodifficulty_sg552_Dmg[i] = GetLineFunction(hm_damage_sg552_min.IntValue, hm_damage_sg552_max.IntValue, i);
			Autodifficulty_spas_Dmg[i] = GetLineFunction(hm_damage_spas_min.IntValue, hm_damage_spas_max.IntValue, i);
			Autodifficulty_sniper_military_Dmg[i] = GetLineFunction(hm_damage_sniper_military_min.IntValue, hm_damage_sniper_military_max.IntValue, i);
		}
		else if (damage_type.IntValue == 2)
		{
			Autodifficulty_ak47_Dmg[i] = GetLineFunction(hm_damage2_ak47_min.IntValue, hm_damage2_ak47_max.IntValue, i);
			Autodifficulty_awp_Dmg[i] = GetLineFunction(hm_damage2_awp_min.IntValue, hm_damage2_awp_max.IntValue, i);
			Autodifficulty_m60_Dmg[i] = GetLineFunction(hm_damage2_m60_min.IntValue, hm_damage2_m60_max.IntValue, i);
			Autodifficulty_scout_Dmg[i] = GetLineFunction(hm_damage2_scout_min.IntValue, hm_damage2_scout_max.IntValue, i);
			Autodifficulty_sg552_Dmg[i] = GetLineFunction(hm_damage2_sg552_min.IntValue, hm_damage2_sg552_max.IntValue, i);
			Autodifficulty_spas_Dmg[i] = GetLineFunction(hm_damage2_spas_min.IntValue, hm_damage2_spas_max.IntValue, i);
			Autodifficulty_sniper_military_Dmg[i] = GetLineFunction(hm_damage2_sniper_military_min.IntValue, hm_damage2_sniper_military_max.IntValue, i);
		}
		Autodifficulty_meleefix_Dmg[i] = GetLineFunction(hm_meleefix_min.IntValue, hm_meleefix_max.IntValue, i);
		Autodifficulty_meleefix_headshot_Dmg[i] = GetLineFunction(hm_meleefix_headshot_min.IntValue, hm_meleefix_headshot_max.IntValue, i);
		Autodifficulty_meleefix_tank_Dmg[i] = GetLineFunction(hm_meleefix_tank_min.IntValue, hm_meleefix_tank_max.IntValue, i);
		Autodifficulty_meleefix_tank_headshot_Dmg[i] = GetLineFunction(hm_meleefix_tank_headshot_min.IntValue, hm_meleefix_tank_headshot_max.IntValue, i);
		Autodifficulty_meleefix_witch_Dmg[i] = GetLineFunction(hm_meleefix_witch_min.IntValue, hm_meleefix_witch_max.IntValue, i);
	}
	autodifficulty_calculated = true;
#if DEBUG
	PrintToRoot("{red}[AUTODIFFICULTY] \x04AutoDifficultyInit");
#endif
}

int GetLineFunction(int GLF_Min, int GLF_Max, int i)
{
	int result = GetLineFunctionEx(GLF_Min, GLF_Max, i, cvar_maxplayers);
	if (result < 0) return GLF_Min;
	return result;
}

// Нахождение уровнения прямой по двум точкам : http://www.reshalki.ru/index.php/reshalki/77
int GetLineFunctionEx(int GLF_Min, int GLF_Max, int i, int GLF_maxplayers)
{
	float k = (GLF_Max - GLF_Min) * 1.0 / (GLF_maxplayers - 4) * 1.0;
	float b = GLF_Max * 1.0 - k * GLF_maxplayers;
	return RoundToNearest(k * i + b);
}

int GetTankHP()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidEntity(i) && IsClientInGame(i) && GetClientTeam(i) == 3)
		{
			if(GetEntProp(i, Prop_Send, "m_zombieClass") == 8)
			{
				if (GetEntProp(i, Prop_Send, "m_isIncapacitated")) return 0;
				return GetClientHealth(i);
			}
		}
	}
	return FindConVar("z_tank_health").IntValue * 2;
}

public Action Command_info2(int client, int args)
{
	if (client == 0) return Plugin_Handled;
	
	char sFormattedTime[22];
	FormatTime(sFormattedTime, sizeof(sFormattedTime), "%m/%d/%Y - %H:%M:%S", GetTime());
	
	char Mapname[128];
	GetCurrentMap(Mapname, 128);
	
	UpdateServerUpTime();
	
	//PrintToChat(client, "Informantion:");
	
	CPrintToChat(client, "{green}ASC{blue}[v2] | UpTime: %s", Server_UpTime);
	
	if (RDifficultyMultiplier >= 1000.0)
	{
		char MapDifficultyMultiplier[8];
		FloatToString(RDifficultyMultiplier, MapDifficultyMultiplier, sizeof(MapDifficultyMultiplier));
		PrintToChat(client, "Difficulty: %s x %s | Players: %i", sGameDifficulty, MapDifficultyMultiplier, GetRealClientCount());
	}
	else if (RDifficultyMultiplier >= 100.0)
	{
		char MapDifficultyMultiplier[7];
		FloatToString(RDifficultyMultiplier, MapDifficultyMultiplier, sizeof(MapDifficultyMultiplier));
		PrintToChat(client, "Difficulty: %s x %s | Players: %i", sGameDifficulty, MapDifficultyMultiplier, GetRealClientCount());
	}
	else if (RDifficultyMultiplier >= 10.0)
	{
		char MapDifficultyMultiplier[6];
		FloatToString(RDifficultyMultiplier, MapDifficultyMultiplier, sizeof(MapDifficultyMultiplier));
		PrintToChat(client, "Difficulty: %s x %s | Players: %i", sGameDifficulty, MapDifficultyMultiplier, GetRealClientCount());
	}
	else
	{
		char MapDifficultyMultiplier[5];
		FloatToString(RDifficultyMultiplier, MapDifficultyMultiplier, sizeof(MapDifficultyMultiplier));
		CPrintToChat(client, "Difficulty: %s x %s | Players: %i | Live Survivors: %i", sGameDifficulty, MapDifficultyMultiplier, GetRealClientCount(), GetLiveSurvivorsCount());
	}
	if (IsTankAlive()) 
	{
		char Message[256];
		bool more_than_one = false;
		
		Format(Message, sizeof(Message), "Tank HP: ");
		
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i))
			{
				if (GetClientTeam(i) == 3 && !IsIncapacitated(i) && IsPlayerAlive(i) && iGetZombieClass(i) == ZC_TANK && GetClientHealth(i) > 0)
				{
					if (more_than_one)
					{
						Format(Message, sizeof(Message), "%s\x04& \x03%d ", Message, GetClientHealth(i));
					}
					else
					{
						Format(Message, sizeof(Message), "%s\x03%d ", Message, GetClientHealth(i));
					}
					more_than_one = true;
				}
			} 
		}
		
		Format(Message, sizeof(Message), "%s| Witch HP: %i | Zombie HP: %i", Message, FindConVar("z_witch_health").IntValue, FindConVar("z_health").IntValue);
		PrintToChat(client, Message);	
	}
	else PrintToChat(client, "Tank HP: %i | Witch HP: %i | Zombie HP: %i", GetTankHP(), FindConVar("z_witch_health").IntValue, FindConVar("z_health").IntValue);
	PrintToChat(client, "Hunter HP: %i | Smoker HP: %i | Boomer HP: %i \nCharger HP: %i | Spitter HP: %i | Jockey HP: %i", FindConVar("z_hunter_health").IntValue, FindConVar("z_gas_health").IntValue, FindConVar("z_exploding_health").IntValue, FindConVar("z_charger_health").IntValue, FindConVar("z_spitter_health").IntValue, FindConVar("z_jockey_health").IntValue);
	PrintToChat(client, "Grenade Launcher Damage: %d. Server time: %s", FindConVar("grenadelauncher_damage").IntValue, sFormattedTime);
	PrintToChat(client, "CurrentMap: %s", Mapname);
	
	return Plugin_Continue;
}

public void Autodifficulty()
{
	if (!hm_autodifficulty.BoolValue) return;
	if (!autodifficulty_calculated)
	{
		AutoDifficultyInit();
		return;
	}
	g_iLastRefreshTime = GetTime();
	
	int count = 0;
	for (int i = 1; i <= MaxClients; i++) if (IsClientInGame(i) && GetClientTeam(i) == 2) count++;
	
	if (playerscount != count)
	{
		playerscount = count;
	}
	
	if (playerscount < 4) playerscount = 4;
	if (playerscount > cvar_maxplayers) playerscount = cvar_maxplayers;
	if (l4d2_plugin_monsterbots)
	{
		FindConVar("monsterbots_maxbots").SetInt(RoundToNearest(AutodifficultySpawnCount[playerscount] * hm_spawn_count_mod.FloatValue), false, false);
		FindConVar("monsterbots_interval").SetInt(RoundToNearest(AutodifficultySpawnInterval[playerscount] * hm_spawn_time_mod.FloatValue), false, false);
	}
	else
	{
		z_special_spawn_interval.SetInt(RoundToNearest(AutodifficultySpawnInterval[playerscount] * hm_spawn_time_mod.FloatValue), false, false);
		director_special_respawn_interval.SetInt(RoundToNearest(AutodifficultySpawnInterval[playerscount] * hm_spawn_time_mod.FloatValue), false, false);
		z_max_player_zombies.SetInt(RoundToNearest(AutodifficultySpawnCount[playerscount] * hm_spawn_count_mod.FloatValue), false, false);
	}

	RDifficultyMultiplier = Calculate_Rank_Mod();

	if (hm_speed_automod.IntValue > 0)
	{
		FindConVar("z_hunter_speed").SetInt(AutodifficultySpeed[playerscount][ZC_HUNTER], false, false);
		FindConVar("z_gas_speed").SetInt(AutodifficultySpeed[playerscount][ZC_SMOKER], false, false);
		FindConVar("z_exploding_speed").SetInt(AutodifficultySpeed[playerscount][ZC_BOOMER], false, false);
		FindConVar("z_spitter_speed").SetInt(AutodifficultySpeed[playerscount][ZC_SPITTER], false, false);
		FindConVar("z_jockey_speed").SetInt(AutodifficultySpeed[playerscount][ZC_JOCKEY], false, false);
		FindConVar("z_charge_start_speed").SetInt(AutodifficultySpeed[playerscount][ZC_CHARGER], false, false);
		FindConVar("z_tank_speed").SetInt(AutodifficultySpeed[playerscount][ZC_TANK], false, false);
	}
	
	switch (cvar_difficulty)
	{
		case 1: tank_burn_duration = FindConVar("tank_burn_duration");
		case 3: tank_burn_duration = FindConVar("tank_burn_duration_hard");
		case 4: tank_burn_duration = FindConVar("tank_burn_duration_expert");
	}
	tank_burn_duration.SetInt(AutodifficultyTankBurnTime[playerscount], false, false);
	FindConVar("grenadelauncher_damage").SetInt(AutodifficultyGrenadeLRDmg[playerscount], false, false);
	
	if (hm_spawn_automod.IntValue > 0)
	{
		FindConVar("z_common_limit").SetInt(AutodifficultySpawnLimit[playerscount][ZC_ZOMBIE], false, false);
		FindConVar("z_hunter_limit").SetInt(AutodifficultySpawnLimit[playerscount][ZC_HUNTER], false, false);
		FindConVar("z_smoker_limit").SetInt(AutodifficultySpawnLimit[playerscount][ZC_SMOKER], false, false);
		FindConVar("z_boomer_limit").SetInt(AutodifficultySpawnLimit[playerscount][ZC_BOOMER], false, false);
		FindConVar("z_spitter_limit").SetInt(AutodifficultySpawnLimit[playerscount][ZC_SPITTER], false, false);
		FindConVar("z_jockey_limit").SetInt(AutodifficultySpawnLimit[playerscount][ZC_JOCKEY], false, false);
		FindConVar("z_charger_limit").SetInt(AutodifficultySpawnLimit[playerscount][ZC_CHARGER], false, false);
	}
	float HealthMod = hm_infected_hp_mod.FloatValue;
	if (hm_autohp_automod.IntValue > 0) HealthMod *= RDifficultyMultiplier;

	FindConVar("z_charger_health").SetInt(RoundToNearest(AutodifficultyHP[playerscount][ZC_CHARGER] * HealthMod), false, false);
	FindConVar("z_hunter_health").SetInt(RoundToNearest(AutodifficultyHP[playerscount][ZC_HUNTER] * HealthMod), false, false);
	FindConVar("z_gas_health").SetInt(RoundToNearest(AutodifficultyHP[playerscount][ZC_SMOKER] * HealthMod), false, false);
	FindConVar("z_exploding_health").SetInt(RoundToNearest(AutodifficultyHP[playerscount][ZC_BOOMER] * HealthMod), false, false);
	FindConVar("z_spitter_health").SetInt(RoundToNearest(AutodifficultyHP[playerscount][ZC_SPITTER] * HealthMod), false, false);
	FindConVar("z_jockey_health").SetInt(RoundToNearest(AutodifficultyHP[playerscount][ZC_JOCKEY] * HealthMod), false, false);
	FindConVar("z_witch_health").SetInt(RoundToNearest(AutodifficultyHP[playerscount][ZC_WITCH] * HealthMod), false, false);
	FindConVar("z_tank_health").SetInt(RoundToNearest(AutodifficultyHP[playerscount][ZC_TANK] * HealthMod * hm_tank_hp_mod.FloatValue), false, false);
	FindConVar("z_health").SetInt(RoundToNearest(AutodifficultyHP[playerscount][ZC_ZOMBIE] * 1.0), false, false);

	if (FindConVar("l4d2_ammo_witches") != null)
		FindConVar("l4d2_ammo_witches").SetInt(RoundToNearest(4 * (playerscount * 0.125 + 0.5) * RDifficultyMultiplier), false, false);
	
	if (l4d2_plugin_loot && hm_items_automod.IntValue > 0)
	{
		float LootMod = hm_loot_mod.FloatValue;
		FindConVar("l4d2_loot_h_drop_items").SetInt(RoundToNearest((AutodifficultyItems[playerscount][ZC_HUNTER]) * LootMod), false, false);
		FindConVar("l4d2_loot_b_drop_items").SetInt(RoundToNearest((AutodifficultyItems[playerscount][ZC_BOOMER]) * LootMod), false, false);
		FindConVar("l4d2_loot_s_drop_items").SetInt(RoundToNearest((AutodifficultyItems[playerscount][ZC_SMOKER]) * LootMod), false, false);
		FindConVar("l4d2_loot_sp_drop_items").SetInt(RoundToNearest((AutodifficultyItems[playerscount][ZC_SPITTER]) * LootMod), false, false);
		FindConVar("l4d2_loot_j_drop_items").SetInt(RoundToNearest((AutodifficultyItems[playerscount][ZC_JOCKEY]) * LootMod), false, false);
		FindConVar("l4d2_loot_t_drop_items").SetInt(RoundToNearest((AutodifficultyItems[playerscount][ZC_TANK]) * LootMod), false, false);

		if (extra_charger) FindConVar("l4d2_loot_c_drop_items").SetInt(RoundToNearest((AutodifficultyItems[playerscount][ZC_CHARGER] + hm_items_supercharger_auto.IntValue*LootMod)), false, false);
		else FindConVar("l4d2_loot_c_drop_items").SetInt(RoundToNearest((AutodifficultyItems[playerscount][ZC_CHARGER]) * LootMod), false, false);
	}

	FindConVar("tongue_miss_delay").SetInt(AutodifficultyTongueMissDelay[playerscount], false, false);
	FindConVar("tongue_hit_delay").SetInt(AutodifficultyTongueHitDelay[playerscount], false, false);
	FindConVar("tongue_range").SetInt(AutodifficultyTongueRange[playerscount], false, false);
	FindConVar("tongue_choke_damage_amount").SetInt(AutodifficultyTongueChokeDmg[playerscount], false, false);
	FindConVar("tongue_drag_damage_amount").SetInt(AutodifficultyTongueDragDmg[playerscount], false, false);
	FindConVar("smoker_pz_claw_dmg").SetInt(AutodifficultyClawDmg[playerscount][0], false, false);
	FindConVar("boomer_pz_claw_dmg").SetInt(AutodifficultyClawDmg[playerscount][1], false, false);
	FindConVar("hunter_pz_claw_dmg").SetInt(AutodifficultyClawDmg[playerscount][2], false, false);
	FindConVar("spitter_pz_claw_dmg").SetInt(AutodifficultyClawDmg[playerscount][3], false, false);
	FindConVar("jockey_pz_claw_dmg").SetInt(AutodifficultyClawDmg[playerscount][4], false, false);
	FindConVar("z_charger_pound_dmg").SetInt(AutodifficultyChargerPoundDmg[playerscount], false, false);
	FindConVar("z_jockey_ride_damage").SetInt(AutodifficultyJockeyRideDmg[playerscount], false, false);
	
	float WeaponMod = hm_infected_hp_mod.FloatValue;
	if (hm_autohp_automod.IntValue > 0) WeaponMod *= RDifficultyMultiplier;
	
	if (damage_type.IntValue == 1)
	{
		FindConVar("hm_damage_ak47").SetInt(RoundToNearest(Autodifficulty_ak47_Dmg[playerscount] * WeaponMod), false, false);
		FindConVar("hm_damage_awp").SetInt(RoundToNearest(Autodifficulty_awp_Dmg[playerscount] * WeaponMod), false, false);
		FindConVar("hm_damage_m60").SetInt(RoundToNearest(Autodifficulty_m60_Dmg[playerscount] * WeaponMod), false, false);
		FindConVar("hm_damage_scout").SetInt(RoundToNearest(Autodifficulty_scout_Dmg[playerscount] * WeaponMod), false, false);
		FindConVar("hm_damage_sg552").SetInt(RoundToNearest(Autodifficulty_sg552_Dmg[playerscount] * WeaponMod), false, false);
		FindConVar("hm_damage_spas").SetInt(RoundToNearest(Autodifficulty_spas_Dmg[playerscount] * WeaponMod), false, false);
		FindConVar("hm_damage_sniper_military").SetInt(RoundToNearest(Autodifficulty_sniper_military_Dmg[playerscount] * WeaponMod), false, false);
	}
	else if (damage_type.IntValue == 2)
	{
		FindConVar("hm_damage2_ak47").SetInt(RoundToNearest(Autodifficulty_ak47_Dmg[playerscount] * WeaponMod), false, false);
		FindConVar("hm_damage2_awp").SetInt(RoundToNearest(Autodifficulty_awp_Dmg[playerscount] * WeaponMod), false, false);
		FindConVar("hm_damage2_m60").SetInt(RoundToNearest(Autodifficulty_m60_Dmg[playerscount] * WeaponMod), false, false);
		FindConVar("hm_damage2_scout").SetInt(RoundToNearest(Autodifficulty_scout_Dmg[playerscount] * WeaponMod), false, false);
		FindConVar("hm_damage2_sg552").SetInt(RoundToNearest(Autodifficulty_sg552_Dmg[playerscount] * WeaponMod), false, false);
		FindConVar("hm_damage2_spas").SetInt(RoundToNearest(Autodifficulty_spas_Dmg[playerscount] * WeaponMod), false, false);
		FindConVar("hm_damage2_sniper_military").SetInt(RoundToNearest(Autodifficulty_sniper_military_Dmg[playerscount] * WeaponMod), false, false);
	}
	
	FindConVar("hm_meleefix_smoker").SetInt(RoundToNearest(Autodifficulty_meleefix_Dmg[playerscount] * WeaponMod), false, false);
	FindConVar("hm_meleefix_smoker_headshot").SetInt(RoundToNearest(Autodifficulty_meleefix_headshot_Dmg[playerscount] * WeaponMod), false, false);
	FindConVar("hm_meleefix_boomer").SetInt(RoundToNearest(Autodifficulty_meleefix_Dmg[playerscount] * WeaponMod), false, false);
	FindConVar("hm_meleefix_boomer_headshot").SetInt(RoundToNearest(Autodifficulty_meleefix_headshot_Dmg[playerscount] * WeaponMod), false, false);
	FindConVar("hm_meleefix_hunter").SetInt(RoundToNearest(Autodifficulty_meleefix_Dmg[playerscount] * WeaponMod), false, false);
	FindConVar("hm_meleefix_hunter_headshot").SetInt(RoundToNearest(Autodifficulty_meleefix_headshot_Dmg[playerscount] * WeaponMod), false, false);
	FindConVar("hm_meleefix_jockey").SetInt(RoundToNearest(Autodifficulty_meleefix_Dmg[playerscount] * WeaponMod), false, false);
	FindConVar("hm_meleefix_jockey_headshot").SetInt(RoundToNearest(Autodifficulty_meleefix_headshot_Dmg[playerscount] * WeaponMod), false, false);
	FindConVar("hm_meleefix_spitter").SetInt(RoundToNearest(Autodifficulty_meleefix_Dmg[playerscount] * WeaponMod), false, false);
	FindConVar("hm_meleefix_spitter_headshot").SetInt(RoundToNearest(Autodifficulty_meleefix_headshot_Dmg[playerscount] * WeaponMod), false, false);
	FindConVar("hm_meleefix_charger").SetInt(RoundToNearest(Autodifficulty_meleefix_Dmg[playerscount] * WeaponMod), false, false);
	FindConVar("hm_meleefix_charger_headshot").SetInt(RoundToNearest(Autodifficulty_meleefix_headshot_Dmg[playerscount] * WeaponMod), false, false);
	FindConVar("hm_meleefix_tank").SetInt(RoundToNearest(Autodifficulty_meleefix_tank_Dmg[playerscount] * WeaponMod), false, false);
	FindConVar("hm_meleefix_tank_headshot").SetInt(RoundToNearest(Autodifficulty_meleefix_tank_headshot_Dmg[playerscount] * WeaponMod), false, false);
	FindConVar("hm_meleefix_witch").SetInt(RoundToNearest(Autodifficulty_meleefix_witch_Dmg[playerscount] * WeaponMod), false, false);
	
	if (playerscount > 4)
	{
		FindConVar("z_spit_interval").SetInt(CheckCvarRange((24 - RoundToZero(playerscount * RDifficultyMultiplier)), 5, 20), false, false);
		FindConVar("z_vomit_interval").SetInt(28 - playerscount, false, false);
		FindConVar("tongue_range").SetInt(750 + RoundToZero((playerscount - 4) * 20 * RDifficultyMultiplier), false, false);
	}
	else
	{
		FindConVar("z_spit_interval").SetInt(20, false, false);
		FindConVar("z_vomit_interval").SetInt(30, false, false);
		FindConVar("tongue_range").SetInt(750, false, false);
	}
#if DEBUG
	PrintToRoot("{red}[AUTODIFFICULTY] \x04Autodifficulty");
#endif
}

int CheckCvarRange(const int Cvar_Value, int Cvar_Value_Min, int Cvar_Value_Max)
{
	if (Cvar_Value < Cvar_Value_Min) return Cvar_Value_Min;
	else if (Cvar_Value > Cvar_Value_Max) return Cvar_Value_Max;
	else return Cvar_Value;
}

public void cvar_maxplayers_changed(Handle hVariable, const char[] strOldValue, const char[] strNewValue)
{
	cvar_maxplayers = FindConVar("sv_maxplayers").IntValue - 5;
}

public Action Command_RankMod(int client, int args)
{
	float RankMod = Calculate_Rank_Mod();
	if (client == 0) PrintToServer("local_result: %f", RankMod);
	else PrintToChat(client, "\x05loc_result: \x04%f", RankMod);
}

int ADPlayerSpawn(Event event)
{
	if (!hm_autodifficulty_forcehp.BoolValue) return;
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (IsValidClient(client)) {
		if(GetClientTeam(client) == TEAM_INFECTED) {
			switch(iGetZombieClass(client)) {
				case ZC_SMOKER: SetEntityHealth(client, FindConVar("z_gas_health").IntValue);
				case ZC_BOOMER: SetEntityHealth(client, FindConVar("z_exploding_health").IntValue);
				case ZC_HUNTER: SetEntityHealth(client, FindConVar("z_hunter_health").IntValue);
				case ZC_SPITTER: SetEntityHealth(client, FindConVar("z_spitter_health").IntValue);
				case ZC_JOCKEY: SetEntityHealth(client, FindConVar("z_jockey_health").IntValue);
				case ZC_CHARGER: SetEntityHealth(client, FindConVar("z_charger_health").IntValue);
				case ZC_TANK: SetEntityHealth(client, FindConVar("z_tank_health").IntValue*2);
			}
		}
	}
}

public Action Command_melee(int client, int args)
{
	if (IsClientInGame(client))
	{		
		PrintToChat(client, "\x05melee damage for bosses: \x04%d \x05| melee damage for bosses (HEADSHOT): \x04%d", FindConVar("hm_meleefix_boomer").IntValue, FindConVar("hm_meleefix_boomer_headshot").IntValue);
		PrintToChat(client, "\x05melee damage for tank: \x04%d \x05| tank headshot: \x04%d \x05| witch: \x04%d", FindConVar("hm_meleefix_tank").IntValue, FindConVar("hm_meleefix_tank_headshot").IntValue, FindConVar("hm_meleefix_witch").IntValue);
	}
	return Plugin_Continue;
}

public Action Command_ammo(int client, int args)
{
	if (IsClientInGame(client))
	{
		PrintToChat(client, "\x05witches: \x04%d \x05| ammochance medbox: \x04%d \x05| ammochance healbox: \x04%d", FindConVar("l4d2_ammo_witches").IntValue, FindConVar("l4d2_ammochance_medbox").IntValue, FindConVar("l4d2_ammochance_healbox").IntValue);
	}
	return Plugin_Continue;
}

public Action Command_damage(int client, int args)
{
	if (IsClientInGame(client))
	{
		if (damage_type.IntValue == 1)
		{
			PrintToChat(client, "\x05awp damage: \x04%d \x05| ak47 damage: \x04%d", FindConVar("hm_damage_awp").IntValue/1000*143, FindConVar("hm_damage_ak47").IntValue/1000*72);
			PrintToChat(client, "\x05scout damage: \x04%d \x05| m60 damage: \x04%d", FindConVar("hm_damage_scout").IntValue/1000*112, FindConVar("hm_damage_m60").IntValue/1000*62);
			PrintToChat(client, "\x05spas damage: \x04%d \x05| sg552 damage: \x04%d", FindConVar("hm_damage_spas").IntValue/1000*22, FindConVar("hm_damage_sg552").IntValue/1000*36);
		}
		else if (damage_type.IntValue == 2)
		{
			PrintToChat(client, "\x05awp damage: \x04%d \x05| ak47 damage: \x04%d", FindConVar("hm_damage2_awp").IntValue, FindConVar("hm_damage2_ak47").IntValue);
			PrintToChat(client, "\x05scout damage: \x04%d \x05| m60 damage: \x04%d", FindConVar("hm_damage2_scout").IntValue, FindConVar("hm_damage2_m60").IntValue);
			PrintToChat(client, "\x05spas damage: \x04%d \x05| sg552 damage: \x04%d", FindConVar("hm_damage2_spas").IntValue, FindConVar("hm_damage2_sg552").IntValue);
		}
	}
	return Plugin_Continue;
}

public Action Command_swd(int client, int args)
{
	FindConVar("hm_damage_showvalue").SetInt(1, false, false);
	PrintToChat(client, "\x05Показ урона \x04включен");
}

public Action Command_swdoff(int client, int args)
{
	FindConVar("hm_damage_showvalue").SetInt(0, false, false);
	PrintToChat(client, "\x05Показ урона \x04выключен");
}

public Action Command_ddfull(int client, int args)
{
	Command_melee(client, 0);
	Command_ammo(client, 0);
	Command_damage(client, 0);
}

bool IsTankAlive()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i))
		{
			if (IsPlayerAlive(i))
			{
				if (iGetZombieClass(i) == ZC_TANK && !IsIncapacitated(i))
					return true;
			}
		}
	}
	return false;
}

bool IsIncapacitated(int client) {
	return view_as<bool>(GetEntProp(client, Prop_Send, "m_isIncapacitated", 1));
}

int GetRealClientCount()
{
	int clients = 0;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i))
		{
			if (!IsFakeClient(i))
			{
				clients++;
			}
		}
	}
	return clients;
}

int GetLiveSurvivorsCount()
{
	int clients = 0;

	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i))
		{
			if (GetClientTeam(i) == 2)
			{
				if (IsPlayerAlive(i))
				{
					clients++;
				}
			}
		}
	}
	return clients;
}

void UpdateServerUpTime()
{
	char tmpTime[8];
	int Current_UpTime = GetTime() - UpTime;
	int Days = RoundToFloor(Current_UpTime / 86400.0);
	Current_UpTime -= Days * 86400;
	if (Days > 0)
	{
		if (Days > 1) Format(Server_UpTime, sizeof(Server_UpTime), "%d days ", Days);
		else Format(Server_UpTime, sizeof(Server_UpTime), "1 day ");
	}
	else Server_UpTime = "";
	int Hours = RoundToFloor(Current_UpTime / 3600.0);
	if (Hours < 10) Format(Server_UpTime, sizeof(Server_UpTime), "%s0%d:", Server_UpTime, Hours);
	else Format(Server_UpTime, sizeof(Server_UpTime), "%s%d:", Server_UpTime, Hours);
	Current_UpTime -= Hours * 3600;
	FormatTime(tmpTime, sizeof(tmpTime), "%M:%S", Current_UpTime);
	Format(Server_UpTime, sizeof(Server_UpTime), "%s%s", Server_UpTime, tmpTime);
}

public Action Command_pinfo(int client, int args)
{
	if (client > 0) ShowMyPanel(client);
	return Plugin_Handled;
}

int ShowMyPanel(int client)
{
	Panel panel = new Panel();
	char text[2048];
	
	char sFormattedTime[22];
	FormatTime(sFormattedTime, sizeof(sFormattedTime), "%m/%d/%Y - %H:%M:%S", GetTime());
	
	char Mapname[128];
	GetCurrentMap(Mapname, 128);
	
	UpdateServerUpTime();
	
	Format(text, sizeof(text), "ASC-v2 | UpTime: %s", Server_UpTime);
	panel.SetTitle(text);
	
	if (RDifficultyMultiplier >= 1000.0)
	{
		char MapDifficultyMultiplier[8];
		FloatToString(RDifficultyMultiplier, MapDifficultyMultiplier, sizeof(MapDifficultyMultiplier));
		Format(text, sizeof(text), "Difficulty: %s x %s | Players: %i (panel)", client, sGameDifficulty, MapDifficultyMultiplier, GetRealClientCount());
		panel.DrawText(text);
	}
	else if (RDifficultyMultiplier >= 100.0)
	{
		char MapDifficultyMultiplier[7];
		FloatToString(RDifficultyMultiplier, MapDifficultyMultiplier, sizeof(MapDifficultyMultiplier));
		Format(text, sizeof(text), "Difficulty: %s x %s | Players: %i (panel)", client, sGameDifficulty, MapDifficultyMultiplier, GetRealClientCount());
		panel.DrawText(text);
	}
	else if (RDifficultyMultiplier >= 10.0)
	{
		char MapDifficultyMultiplier[6];
		FloatToString(RDifficultyMultiplier, MapDifficultyMultiplier, sizeof(MapDifficultyMultiplier));
		Format(text, sizeof(text), "Difficulty: %s x %s | Players: %i (panel)", client, sGameDifficulty, MapDifficultyMultiplier, GetRealClientCount());
		panel.DrawText(text);
	}
	else
	{
		char MapDifficultyMultiplier[5];
		FloatToString(RDifficultyMultiplier, MapDifficultyMultiplier, sizeof(MapDifficultyMultiplier));
		Format(text, sizeof(text), "Difficulty: %s x %s | Players: %i | Live Survivors: %i (panel)", client, sGameDifficulty, MapDifficultyMultiplier, GetRealClientCount(), GetLiveSurvivorsCount());
		panel.DrawText(text);
	}
	if (IsTankAlive()) 
	{
		char Message[256];
		
		Format(Message, sizeof(Message), "Tank HP: (panel)", client);
		
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i))
			{
				if (GetClientTeam(i) == 3 && !IsIncapacitated(i) && IsPlayerAlive(i) && iGetZombieClass(i) == ZC_TANK && GetClientHealth(i) > 0)
				{
					Format(Message, sizeof(Message), "%s%d ", Message, GetClientHealth(i));
				}
			} 
		}
		Format(Message, sizeof(Message), "%s| Witch HP: %i | Zombie HP: %i (panel)", Message, client, FindConVar("z_witch_health").IntValue, FindConVar("z_health").IntValue);	
		panel.DrawText(Message);
	}
	else
	{
		Format(text, sizeof(text), "Tank HP: %i | Witch HP: %i | Zombie HP: %i (panel)", client, GetTankHP(), FindConVar("z_witch_health").IntValue, FindConVar("z_health").IntValue);
		panel.DrawText(text);
	}
	Format(text, sizeof(text), "Hunter HP: %i | Smoker HP: %i | Boomer HP: %i (panel)", client, FindConVar("z_hunter_health").IntValue, FindConVar("z_gas_health").IntValue, FindConVar("z_exploding_health").IntValue);
	panel.DrawText(text);
	Format(text, sizeof(text), "Charger HP: %i | Spitter HP: %i | Jockey HP: %i (panel)", client, FindConVar("z_charger_health").IntValue, FindConVar("z_spitter_health").IntValue, FindConVar("z_jockey_health").IntValue);
	panel.DrawText(text);
	Format(text, sizeof(text), "Grenade Launcher Damage: %d. Server time: %s (panel)", client, FindConVar("grenadelauncher_damage").IntValue, sFormattedTime);
	panel.DrawText(text);
	Format(text, sizeof(text), "CurrentMap: %s (panel)", client, Mapname);
	panel.DrawText(text);
	Format(text, sizeof(text), "Close", client);
	panel.DrawItem(text);
	panel.Send(client, PanelHandler, 20);
	delete panel;
}

public int PanelHandler(Menu menu, MenuAction action, int param1, int param2)
{
}

// public Action cmd_Say(int client, int args)
// {
// 	char Text[192];
// 	int Start = 0;

// 	GetCmdArgString(Text, sizeof(Text));

// 	int TextLen = strlen(Text);

// 	if (TextLen <= 0) return Plugin_Continue;

// 	if (Text[TextLen-1] == '"')
// 	{
// 		Text[TextLen-1] = '\0';
// 		Start = 1;
// 	}

// 	return HandleCommands(client, Text[Start]);
// }

// public Action HandleCommands(int client, const char[] Text)
// {
// 	if (strcmp(Text, "!info2", false) == 0) Command_info2(client, 0);
// 	else if (strcmp(Text, "/info2", false) == 0)
// 	{
// 		Command_info2(client, 0);
// 		return Plugin_Handled;
// 	}
// 	return Plugin_Continue;
// }

// public Action ActivatedTrigger(int client, char[] command, int arg)
// {
// 	char InfoStr[][] = {"!штащ", "/штащ", "!info", "/info"};

// 	char text[192];
// 	GetCmdArgString(text, sizeof(text));
// 	StripQuotes(text);
// 	TrimString(text);

// 	if (client && IsClientInGame(client))
// 	{	
// 		for (int i = 0; i < sizeof(InfoStr); i++)
// 		{
// 			if (StrEqual(text, InfoStr[i], false))
// 			{
// 				Command_info2(client, 0);
// 				return Plugin_Handled;
// 			}
// 		}
// 	}
// 	return Plugin_Continue;
// }

#if DEBUG
void PrintToRoot(const char[] format, any ...)
{
	AdminId adminID = INVALID_ADMIN_ID;
	char buffer[1024];
	VFormat(buffer, sizeof(buffer), format, 2);
	
	int i = 1;
	while (i <= MaxClients)
	{
		if (IsClientInGame(i))
		{
			adminID = GetUserAdmin(i);
			if (adminID != INVALID_ADMIN_ID)
			{
				if (GetAdminFlag(adminID, Admin_Root, Access_Effective))
					CPrintToChat(i, "%s", buffer);
			}
		}
		i += 1;
	}
}
#endif