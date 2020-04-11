BEGIN

DECLARE _np INT DEFAULT 0;

SELECT P.points INTO _np
FROM players AS P
LEFT JOIN permits AS A ON P.id_permit = A.id
WHERE ((A.flags NOT LIKE '%z%' AND A.flags NOT LIKE '%b%') OR A.flags IS NULL) AND P.points > _mp AND P.steamid != _steamid
ORDER BY points
LIMIT 1;

SELECT _np - _mp AS PointsNeededForNextRank;

END