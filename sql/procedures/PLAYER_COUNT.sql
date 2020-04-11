SELECT COUNT(*) AS counter
FROM players AS P
LEFT JOIN permits AS A ON P.id_permit = A.id
WHERE ((A.flags NOT LIKE '%z%' AND A.flags NOT LIKE '%b%') OR A.flags IS NULL)