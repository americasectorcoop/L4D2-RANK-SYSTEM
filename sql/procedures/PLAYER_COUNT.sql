DROP PROCEDURE IF EXISTS PLAYER_COUNT;
DELIMITER $$
CREATE PROCEDURE `PLAYER_COUNT`()
  READS SQL DATA
  COMMENT 'NUMBER OF PLAYERS'
SELECT COUNT(*) AS counter FROM players$$
DELIMITER ;