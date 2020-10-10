#-------------------------------------------------------------------------------------------------------------------------------------------------------
#VALIDAR VARIABLES--------------------------------------------------------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------------------------------------------------------------------------
SHOW VARIABLES LIKE 'general_log%';

#-------------------------------------------------------------------------------------------------------------------------------------------------------
#ACTIVAR LOG--------------------------------------------------------------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------------------------------------------------------------------------
SET GLOBAL general_log = 0;

SELECT * 
FROM mysql.general_log 
ORDER BY event_time DESC;

#-------------------------------------------------------------------------------------------------------------------------------------------------------
#VALIDAR EL ESPACIO Y ESTADOS---------------------------------------------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------------------------------------------------------------------------

SELECT @@innodb_max_undo_log_size AS 'Maximo';
SELECT @@innodb_undo_log_truncate AS 'Estado';

SELECT * 
FROM INFORMATION_SCHEMA.INNODB_TABLESPACES
WHERE SPACE_TYPE = 'Undo' 
ORDER BY NAME; 

SHOW STATUS LIKE 'Innodb_undo_tablespaces%';

#-------------------------------------------------------------------------------------------------------------------------------------------------------
#CREAR MAS ESPACIO--------------------------------------------------------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE UNDO TABLESPACE bases2_temporary_undo_003 ADD DATAFILE 'bases2_undo_003.ibu';
CREATE UNDO TABLESPACE bases2_temporary_undo_004 ADD DATAFILE 'bases2_undo_004.ibu';

#-------------------------------------------------------------------------------------------------------------------------------------------------------
#DESACTIVAR ESPACIO-------------------------------------------------------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------------------------------------------------------------------------
ALTER UNDO TABLESPACE bases2_temporary_undo_003 SET INACTIVE;

#-------------------------------------------------------------------------------------------------------------------------------------------------------
#ELIMINAR ESPACIO---------------------------------------------------------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------------------------------------------------------------------------
DROP UNDO TABLESPACE bases2_temporary_undo_003;
