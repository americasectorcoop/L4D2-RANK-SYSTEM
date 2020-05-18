SET FOREIGN_KEY_CHECKS  = 0;
TRUNCATE TABLE tokscsol_supercoop.players;

INSERT INTO tokscsol_supercoop.players ( 
  `steamid`,
  `nickname`,
  `discordid`,
  `ip_address`,
  `last_time_online`,
  `playtime`,
  `points`,
  `melee_kills`,
  `kill_bosses`,
  `kill_boomers`,
  `kill_chargers`,
  `kill_hunters`,
  `kill_jockeys`,
  `kill_smookers`,
  `kill_spitters`,
  `kill_tanks`,
  `kill_tanks_without_deaths`,
  `kill_witches`,
  `kill_zombies`,
  `friends_adrenaline_given`,
  `friends_pills_given`,
  `friends_damage`,
  `friends_incapped`,
  `friends_cured`,
  `friends_revived`,
  `friends_killed`,
  `friends_rescued`,
  `friends_protected`,
  `infected_let_in_safehouse`,
  `friends_above`,
  `rounds_all_survive`,
  `left4dead`,
  `self_cured`
) SELECT
  SteamIdTo64(`steamid`),
  `name`,
  `discordid`,
  INET_ATON(`ip`),
  `lastontime`,
  `playtime`,
  `points`,
  `melee_kills`,
  (kill_boomer + kill_hunter + kill_jockey + kill_smoker + kill_spitter + kill_charger + kill_witch + award_tankkill),
  `kill_boomer`,
  `kill_charger`,
  `kill_hunter`,
  `kill_jockey`,
  `kill_smoker`,
  `kill_spitter`,
  `award_tankkill`,
  `award_tankkillnodeaths`,
  `kill_witch`,
  `kill_infected`,
  `award_adrenaline`,
  `award_pills`,
  `award_friendlyfire`,
  `award_fincap`,
  `award_medkit`,
  `award_defib`,
  `award_teamkill`,
  `award_rescue`,
  `award_protect`,
  `award_letinsafehouse`,
  `award_revive`,
  `award_allinsafehouse`,
  `award_left4dead`,
  `heal`
FROM tokscsol_asc.players;

UPDATE tokscsol_supercoop.players AS P
INNER JOIN tokscsol_asc.sm_admins AS A ON SteamIdTo64(A.identity)=P.steamid
INNER JOIN tokscsol_supercoop.permits AS R ON R.flags=A.flags
SET P.permit_id=R.id;

SET FOREIGN_KEY_CHECKS  = 1;