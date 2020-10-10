CREATE DATABASE BD2PROYECTO;
USE BD2PROYECTO;

#CREACION DE TABLAS-------------------------------------------------------------------------------------------------------------------------------------
CREATE TABLE TEMPORADA(
	id_temporada INT PRIMARY KEY AUTO_INCREMENT,
    nombre_temporada VARCHAR(500) NOT NULL,
    anio_inicio INT NOT NULL,
    anio_fin INT NOT NULL
);

CREATE TABLE EQUIPO(
	id_equipo INT PRIMARY KEY AUTO_INCREMENT,
    nombre_equipo VARCHAR(500) NOT NULL,
    INDEX (nombre_equipo)
);

CREATE TABLE JORNADA(
	id_jornada INT PRIMARY KEY AUTO_INCREMENT,
    nombre_jornada VARCHAR(100) NOT NULL
);

CREATE TABLE PARTIDO(
	fecha_partido DATE NOT NULL,
    goles_local INT NOT NULL,
    goles_visitante INT NOT NULL,
    resultado_partido VARCHAR(10) NOT NULL,
    id_temporada_partido INT NOT NULL,
    id_jornada_partido INT NOT NULL,
    id_equipo_local INT NOT NULL,
    id_equipo_visitante INT NOT NULL,
    PRIMARY KEY(id_temporada_partido, id_jornada_partido, id_equipo_local, id_equipo_visitante),
    CONSTRAINT fk_id_temporada_partido FOREIGN KEY(id_temporada_partido) REFERENCES TEMPORADA(id_temporada),
    CONSTRAINT fk_id_jornada_partido FOREIGN KEY(id_jornada_partido) REFERENCES JORNADA(id_jornada),
    CONSTRAINT fk_id_equipo_local FOREIGN KEY (id_equipo_local) REFERENCES EQUIPO(id_equipo),
    CONSTRAINT id_equipo_visitante FOREIGN KEY(id_equipo_visitante) REFERENCES EQUIPO(id_equipo)
);

CREATE TABLE CARGA(
	ronda VARCHAR(100) NOT NULL,
    fecha VARCHAR(100) NOT NULL,
    equipo_local VARCHAR(100) NOT NULL,
    resultado VARCHAR(100) NOT NULL,
    equipo_visitante VARCHAR(100) NOT NULL,
    anio VARCHAR(100) NOT NULL
);

#SHOW VARIABLES LIKE 'local_infile';
#SET GLOBAL local_infile='ON';

#CARGA MASIVA 15,241-------------------------------------------------------------------------------------------------------------------------------------
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Datos_futbol.csv'
INTO TABLE CARGA
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

SELECT * FROM CARGA;

#INSERCIONES EN LA TABLA TEMPORADA----------------------------------------------------------------------------------------------------------------------
INSERT INTO TEMPORADA(nombre_temporada, anio_inicio, anio_fin)
	SELECT DISTINCT anio AS nombre_temporada, SUBSTRING_INDEX(anio, '-', 1) AS anio_inicio, SUBSTRING_INDEX(anio, '-', -1) AS anio_fin
	from CARGA;

SELECT * FROM TEMPORADA;

#INSERCIONES EN LA TABLA EQUIPO-------------------------------------------------------------------------------------------------------------------------
INSERT INTO EQUIPO (nombre_equipo)
	SELECT DISTINCT equipo_local as nombre_equipo
	FROM CARGA 
	ORDER BY equipo_local ASC;

SELECT * FROM EQUIPO;

#INSERCIONES EN LA TABLA JORNADA------------------------------------------------------------------------------------------------------------------------
INSERT INTO JORNADA(nombre_jornada)
	SELECT DISTINCT ronda FROM CARGA;

SELECT * FROM JORNADA;

#INSERCIONES EN LA TABLA PARTIDO------------------------------------------------------------------------------------------------------------------------
INSERT INTO PARTIDO(fecha_partido, goles_local, goles_visitante, resultado_partido, id_temporada_partido, 
id_jornada_partido, id_equipo_local, id_equipo_visitante)
	SELECT STR_TO_DATE(c.fecha,'%d/%m/%Y') AS fecha_partido, SUBSTRING_INDEX(c.resultado, '—', 1) AS goles_local, SUBSTRING_INDEX(c.resultado, '—', -1) AS goles_visitante, 
	c.resultado AS resultado_partido, t.id_temporada AS id_temporada_partido, j.id_jornada AS id_jornada_partido, e1.id_equipo AS id_equipo_local, 
	e2.id_equipo AS id_equipo_visitante
	FROM CARGA c, TEMPORADA t, JORNADA j, EQUIPO e1, EQUIPO e2
	WHERE c.anio = t.nombre_temporada AND c.ronda = j.nombre_jornada AND c.equipo_local = e1.nombre_equipo AND c.equipo_visitante = e2.nombre_equipo;

SELECT * FROM PARTIDO;

#ELIMINACIONES------------------------------------------------------------------------------------------------------------------------------------------
DROP TABLE CARGA;
DROP TABLE PARTIDO;
DROP TABLE JORNADA;
DROP TABLE EQUIPO;
DROP TABLE TEMPORADA;