DROP PROCEDURE IF EXISTS PLAYER_TOP;
DELIMITER $$
CREATE PROCEDURE `PLAYER_TOP`(IN `_start` INT, IN `_limit` INT)
    READS SQL DATA
BEGIN
	SELECT P.steamid, P.nickname, P.points, P.last_time_online
	FROM players AS P
	LEFT JOIN permits AS A ON P.permit_id = A.id
	WHERE (A.flags NOT LIKE '%z%' AND A.flags NOT LIKE '%b%') OR A.flags IS NULL
	ORDER BY P.points DESC
	LIMIT _start, _limit;
END$$
DELIMITER ;