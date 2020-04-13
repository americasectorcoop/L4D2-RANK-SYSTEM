DROP PROCEDURE IF EXISTS PLAYER_NEXT_RANK;
DELIMITER $$
CREATE PROCEDURE `PLAYER_NEXT_RANK`(IN `_steamid` VARCHAR(32), IN `_points` INT)
    READS SQL DATA
    COMMENT 'Get list of Ranks up from you'
BEGIN
DECLARE _authid VARCHAR(64) DEFAULT SteamIdTo64(_steamid);

(SELECT P.name, P.points
FROM players AS P
	LEFT JOIN permits AS A ON P.id = A.id
WHERE
	((A.flags NOT LIKE '%z%' AND A.flags NOT LIKE '%b%') OR A.flags IS NULL) AND
	P.points > _points AND
	P.steamid <> _authid
ORDER BY points ASC
LIMIT 3)
UNION 
	(SELECT name, points FROM players WHERE steamid = _authid)
UNION 
	(SELECT P.name, P.points
	FROM players AS P
		LEFT JOIN permits AS A ON P.id = A.id
	WHERE
		((A.flags NOT LIKE '%z%' AND A.flags NOT LIKE '%b%') OR A.flags IS NULL) AND
		P.points < _points AND
		P.steamid <> _authid
	ORDER BY P.points DESC LIMIT 3) ORDER BY points DESC;
END$$
DELIMITER ;