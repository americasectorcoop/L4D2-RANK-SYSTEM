DROP PROCEDURE IF EXISTS PLAYER_JOINED;
DELIMITER $$
CREATE PROCEDURE `PLAYER_JOINED`(IN `_steamid` VARCHAR(32), IN `_ip` VARCHAR(16), IN `_name` VARCHAR(32))
    NO SQL
BEGIN
  DECLARE _auth_id BIGINT DEFAULT SteamIdTo64(_steamid);
  DECLARE _ipv4 BIGINT DEFAULT INET_ATON(_ip);
  DECLARE _is_admin INT DEFAULT 0;
  DECLARE _flags VARCHAR(32) DEFAULT '';
  DECLARE _immunity TINYINT(3) UNSIGNED DEFAULT 0;
  -- Consulta para ver si el jugador es admin
  SELECT 
    IF(A.flags LIKE '%z%' OR A.flags LIKE '%b%', 1 , 0), A.flags, A.immunity INTO _is_admin, _flags, _immunity
  FROM permits AS A
    INNER JOIN players AS P ON A.id = P.permit_id
  WHERE P.steamid = _auth_id;
  -- Verificando si el jugador es administrador
  CASE _is_admin
    WHEN 1 THEN
      BEGIN
        -- Actualizando la informacion del jugador
        UPDATE players SET last_time_online = UNIX_TIMESTAMP(), ip_address = _ipv4, nickname = _name, server_join = server_join + 1 WHERE steamid = _auth_id;
        -- Obteniendo la informacion del jugador
        SELECT
          IF(B.id IS NOT NULL , 1, 0) AS is_banned,
          BS.description AS ban_reason,
          P.kill_bosses,
          0 AS factor,
          P.points,
          P.playtime,
          0 AS rank,
          0 AS points_for_next_rank,
          _flags AS flags,
          _immunity AS immunity
        FROM players AS P
        LEFT JOIN ks_bans_logs AS B ON P.steamid = B.target_steam_id AND B.actived=1
        LEFT JOIN ks_bans_reasons AS BS ON BS.id=B.ban_reason_id
        WHERE P.steamid = _auth_id;
      END;
    ELSE 
      BEGIN
        DECLARE _player_rank INT DEFAULT 0; -- rank
        DECLARE _players_points INT DEFAULT 0; -- player points
        DECLARE _points_nr INT DEFAULT 0; -- points of player of the next rank
        /**
        * El jugador se registrara en caso de no existir, ingresando lo que es su steam id sus puntos iniciales, su ip, su nombre de usuario, y el tiempo de insercion
        para tener registro de su primera entrada al servidor
        * En caso de que ya exista el jugador se le actualiza el last on time, su ip y por ultimo su nombre
        */
        INSERT INTO players( steamid, points, ip_address, nickname, created_at, last_time_online)
          VALUES ( _auth_id , 0, _ipv4, _name, NOW(), UNIX_TIMESTAMP())
          ON DUPLICATE KEY UPDATE last_time_online = UNIX_TIMESTAMP(), ip_address = _ipv4, nickname = _name, server_join = server_join + 1;
        -- Obteniendo los puntos del jugador
        SELECT points INTO _players_points FROM players WHERE steamid = _auth_id;
        -- Obteniendo los puntos del rango que esta arriba del jugador
        SELECT points INTO _points_nr
          FROM players AS P
          LEFT JOIN permits AS A ON P.permit_id = A.id
        WHERE
          ((A.flags NOT LIKE '%z%' AND A.flags NOT LIKE '%b%') OR A.flags IS NULL)
          AND points > _players_points
          AND steamid <> _auth_id
        ORDER BY points LIMIT 1;
        -- Obteniendo el rank 
        SELECT COUNT(points) INTO _player_rank
        FROM players AS P
        LEFT JOIN permits AS A ON P.permit_id = A.id
        WHERE ((A.flags NOT LIKE '%z%' AND A.flags NOT LIKE '%b%') OR A.flags IS NULL)
          AND points >= _players_points;
        -- Seleccionando informacion necesaria para su union al servidor
        SELECT
          IF(B.id IS NOT NULL , 1, 0) AS is_banned,
          BS.description AS ban_reason,
          P.kill_bosses, 
          0 AS factor,
          P.points, 
          P.playtime,
          _player_rank AS `rank`,
          IF(_player_rank < 1, _points_nr - _players_points, 0) AS points_for_next_rank,
          _flags AS flags,
          _immunity AS immunity
        FROM players AS P
        LEFT JOIN ks_bans_logs AS B ON P.steamid = B.target_steam_id AND B.actived=1
        LEFT JOIN ks_bans_reasons AS BS ON BS.id=B.ban_reason_id
        WHERE P.steamid = _auth_id;
      END;
  END CASE;
END$$
DELIMITER ;
/***
TEST


CALL PLAYER_JOINED('STEAM_1:0:79793428', '127.0.0.1', 'Aleeexxx');

**/
