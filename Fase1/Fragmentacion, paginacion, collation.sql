#-------------------------------------------------------------------------------------------------------------------------------------------------------
#FRAGMENTACION Y COLLATION------------------------------------------------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT
 schema_name AS 'database', 
 default_character_set_name AS 'charset',
 default_collation_name AS 'collation'
FROM
 information_schema.SCHEMATA
WHERE
 schema_name = "bd2proyecto";

SELECT 
	TABLE_NAME,
    TABLE_ROWS,
    AVG_ROW_LENGTH,
    DATA_LENGTH,
    MAX_DATA_LENGTH,
    INDEX_LENGTH,
    DATA_FREE,
    TABLE_COLLATION,
    Round( DATA_LENGTH/1024/1024) AS data_length , 
    round(INDEX_LENGTH/1024/1024) AS index_length, 
    round(DATA_FREE/ 1024/1024) AS data_free 
FROM information_schema.tables 
WHERE table_schema = 'bd2proyecto';

SELECT 
	TABLE_NAME,
    COLUMN_NAME
    CHARACTER_SET_NAME,
    COLLATION_NAME,
    CHARACTER_MAXIMUM_LENGTH,
    CHARACTER_OCTET_LENGTH
    FROM information_schema.columns 
    WHERE table_schema="bd2proyecto";

#-------------------------------------------------------------------------------------------------------------------------------------------------------
#PAGINACION---------------------------------------------------------------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT * 
FROM INFORMATION_SCHEMA.INNODB_TABLESPACES
WHERE NAME LIKE 'bd2proyecto%';
