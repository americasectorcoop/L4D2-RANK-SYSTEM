BEGIN
	SELECT
		P.nickname,
		0 AS factor,
		P.points,
		P.steamid
	FROM players AS P
		LEFT JOIN permits AS A ON P.id_permit = A.id
	WHERE (
		(A.flags NOT LIKE '%z%' AND A.flags NOT LIKE '%b%') OR A.flags IS NULL)
		AND P.points >= 10000
		AND P.playtime >= 86400
	ORDER BY factor DESC
	LIMIT _offset, _limit;
END