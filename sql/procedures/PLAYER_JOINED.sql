BEGIN
	DECLARE _is_admin INT DEFAULT 0;
	-- Consulta para ver si el jugador es admin
	SELECT 
		IF(A.flags LIKE '%z%' OR A.flags LIKE '%b%', 1 , 0) INTO _is_admin
	FROM permits AS A
		INNER JOIN players AS P ON A.id = P.id_permit
	WHERE P.steamid = _steamid;
	-- Verificando si el jugador es administrador
	CASE _is_admin
		WHEN 1 THEN
			BEGIN
				-- Actualizando la informacion del jugador
				UPDATE players SET last_time_online = UNIX_TIMESTAMP(), ip_address = _ip, nickname = _name WHERE steamid = _steamid;
				-- Obteniendo la informacion del jugador
				SELECT 
					P.kill_bosses,
					0 AS factor,
					P.points,
					P.playtime,
					0 AS rank,
					0 AS points_for_next_rank,
					IFNULL(B.ban_expired, 0) AS ban_expired
				FROM players AS P
				LEFT JOIN bans AS B ON P.id = B.id_player
				WHERE P.steamid = _steamid;
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
					VALUES ( _steamid , 0, _ip, _name, NOW(), UNIX_TIMESTAMP())
					ON DUPLICATE KEY UPDATE last_time_online = UNIX_TIMESTAMP(), ip_address = _ip, nickname = _name;
				-- Obteniendo los puntos del jugador
				SELECT points INTO _players_points FROM players WHERE steamid = _steamid;
				-- Obteniendo los puntos del rango que esta arriba del jugador
				SELECT points INTO _points_nr
					FROM players AS P
					LEFT JOIN permits AS A ON P.id = A.id
				WHERE
					((A.flags NOT LIKE '%z%' AND A.flags NOT LIKE '%b%') OR A.flags IS NULL)
					AND points > _players_points
					AND steamid <> _steamid
				ORDER BY points LIMIT 1;
				-- Obteniendo el rank 
				SELECT COUNT(points) INTO _player_rank
				FROM players AS P
				LEFT JOIN permits AS A ON P.id = A.id
				WHERE ((A.flags NOT LIKE '%z%' AND A.flags NOT LIKE '%b%') OR A.flags IS NULL)
					AND points >= _players_points;
				-- Seleccionando informacion necesaria para su union al servidor
				SELECT
					P.kill_bosses, 
					0 AS factor,
					P.points, 
					P.playtime, 
					_player_rank AS rank,
					_points_nr - _players_points AS points_for_next_rank,
					IFNULL(B.ban_expired, 0) AS ban_expired
				FROM players AS P
				LEFT JOIN bans AS B ON P.id = B.id_player
				WHERE P.steamid = _steamid;
			END;
	END CASE;
END