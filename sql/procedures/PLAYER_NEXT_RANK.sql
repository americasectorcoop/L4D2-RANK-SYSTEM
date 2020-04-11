BEGIN
(SELECT P.name, P.points
FROM players AS P
	LEFT JOIN permits AS A ON P.id = A.id
WHERE
	((A.flags NOT LIKE '%z%' AND A.flags NOT LIKE '%b%') OR A.flags IS NULL) AND
	P.points > _points AND
	P.steamid <> _steamid
ORDER BY points ASC
LIMIT 3)
UNION 
	(SELECT name, points FROM players WHERE steamid = _steamid)
UNION 
	(SELECT P.name, P.points
	FROM players AS P
		LEFT JOIN permits AS A ON P.id = A.id
	WHERE
		((A.flags NOT LIKE '%z%' AND A.flags NOT LIKE '%b%') OR A.flags IS NULL) AND
		P.points < _points AND
		P.steamid <> _steamid
	ORDER BY P.points DESC LIMIT 3) ORDER BY points DESC;
END