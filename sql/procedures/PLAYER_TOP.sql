BEGIN
	SELECT P.steamid, P.nickname, P.points, P.last_time_online
	FROM players AS P
	LEFT JOIN permits AS A ON P.id_permit = A.id
	WHERE (A.flags NOT LIKE '%z%' AND A.flags NOT LIKE '%b%') OR A.flags IS NULL
	ORDER BY P.points DESC
	LIMIT _start, _limit;
END