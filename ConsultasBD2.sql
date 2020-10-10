/*
===========================INCISO E===========================
*/
CREATE VIEW VICTIMA_FAVORITA AS
	SELECT E1.NOMBRE_EQUIPO AS EQUIPO_GANADOR, PARTIDO.RESULTADO_PARTIDO AS RESULTADO, E2.NOMBRE_EQUIPO AS EQUIPO_PERDEDOR, 
			PARTIDO.GOLES_LOCAL AS GOLES_LOCAL, PARTIDO.GOLES_VISITANTE AS GOLES_VISITA, PARTIDO.FECHA_PARTIDO AS FECHA
	FROM PARTIDO, EQUIPO AS E1, EQUIPO AS E2
	WHERE E1.ID_EQUIPO=PARTIDO.ID_EQUIPO_LOCAL AND
	E2.ID_EQUIPO=PARTIDO.ID_EQUIPO_VISITANTE AND
    PARTIDO.GOLES_LOCAL>PARTIDO.GOLES_VISITANTE
    UNION
    SELECT E1.NOMBRE_EQUIPO AS EQUIPO_GANADOR, PARTIDO.RESULTADO_PARTIDO AS RESULTADO, E2.NOMBRE_EQUIPO AS EQUIPO_PERDEDOR, 
			PARTIDO.GOLES_VISITANTE AS GOLES_LOCAL, PARTIDO.GOLES_LOCAL AS GOLES_VISITA, PARTIDO.FECHA_PARTIDO AS FECHA
	FROM PARTIDO, EQUIPO AS E1, EQUIPO AS E2
	WHERE E2.ID_EQUIPO=PARTIDO.ID_EQUIPO_LOCAL AND
	E1.ID_EQUIPO=PARTIDO.ID_EQUIPO_VISITANTE AND
    PARTIDO.GOLES_LOCAL<PARTIDO.GOLES_VISITANTE
;

SELECT COUNT(*) AS NUM_VICTORIAS, EQUIPO_PERDEDOR AS VICTIMA
FROM VICTIMA_FAVORITA
WHERE EQUIPO_GANADOR='Barcelona'
group by EQUIPO_PERDEDOR
order by NUM_VICTORIAS DESC; 

DROP VIEW IF EXISTS VICTIMA_FAVORITA;

/*
===========================INCISO F===========================
*/
DROP PROCEDURE IF EXISTS PROC_POSICIONES_POR_TEMPORADA;
delimiter //
CREATE PROCEDURE PROC_POSICIONES_POR_TEMPORADA(IN nNombre_Equipo varchar(200))
BEGIN
	SELECT POSICION, nombre_equipo, Puntos, gf, gc, nombre_temporada 
    from(
			SELECT if(id_temporada_partido<=8,if(@rownum<18,@rownum:=@rownum+1,@rownum:=1),@rownum:=0) as 'POSICION', nombre_equipo, Puntos, gf, gc, nombre_temporada
			from(
				select nombre_equipo,sum(if(anio_fin <= 1995, PG * 2 + PE,  PG * 3 + PE)) as 'Puntos', sum(pj) as 'PJ', sum(pg) as 'PG', sum(PE) as 'PE', sum(PP) as 'PP', sum(GF) as 'GF', sum(GC) as 'GC' , nombre_temporada, id_temporada_partido
				from (
					(
						select eqL.id_equipo, eqL.nombre_equipo, count(*) as 'PJ', sum(if(goles_local > goles_visitante, 1 , 0)) as 'PG', 
						sum(if(goles_local = goles_visitante, 1 , 0)) as 'PE', sum(if(goles_local < goles_visitante, 1 , 0)) as 'PP',
						sum(goles_local) as 'GF', sum(goles_visitante) as 'GC' , temporada.anio_fin, temporada.nombre_temporada, partido.id_temporada_partido
						from partido,  equipo as eqL, temporada 
						where  eqL.id_equipo = partido.id_equipo_local and temporada.id_temporada = partido.id_temporada_partido and partido.id_temporada_partido<=8
						group by eqL.id_equipo, temporada.nombre_temporada 
					)
					union
					(
						select eqv.id_equipo, eqv.nombre_equipo, count(*) as 'PJ', sum(if(goles_local < goles_visitante, 1 , 0)) as 'PG', 
						sum(if(goles_local = goles_visitante, 1 , 0)) as 'PE', sum(if(goles_local > goles_visitante, 1 , 0)) as 'PP',
						sum(goles_visitante) as 'GF', sum(goles_local) as 'GC' , temporada.anio_fin, temporada.nombre_temporada, partido.id_temporada_partido
						from partido,  equipo as eqV, temporada 
						where eqv.id_equipo = partido.id_equipo_visitante and temporada.id_temporada = partido.id_temporada_partido and partido.id_temporada_partido<=8
						group by eqv.id_equipo, temporada.nombre_temporada 
					)
				) as algo group by id_equipo, nombre_temporada order by nombre_temporada asc, puntos desc 
			) as algo2, (SELECT @rownum:=0) r
			UNION
			SELECT if((id_temporada_partido>8 and id_temporada_partido<17),if(@rownum1<20,@rownum1:=@rownum1+1,@rownum1:=1),@rownum1:=0) as 'POSICION', nombre_equipo, Puntos, gf, gc, nombre_temporada
			from(
				select nombre_equipo,sum(if(anio_fin <= 1995, PG * 2 + PE,  PG * 3 + PE)) as 'Puntos', sum(pj) as 'PJ', sum(pg) as 'PG', sum(PE) as 'PE', sum(PP) as 'PP', sum(GF) as 'GF', sum(GC) as 'GC' , nombre_temporada, id_temporada_partido
				from (
					(
						select eqL.id_equipo, eqL.nombre_equipo, count(*) as 'PJ', sum(if(goles_local > goles_visitante, 1 , 0)) as 'PG', 
						sum(if(goles_local = goles_visitante, 1 , 0)) as 'PE', sum(if(goles_local < goles_visitante, 1 , 0)) as 'PP',
						sum(goles_local) as 'GF', sum(goles_visitante) as 'GC' , temporada.anio_fin, temporada.nombre_temporada, partido.id_temporada_partido
						from partido,  equipo as eqL, temporada 
						where  eqL.id_equipo = partido.id_equipo_local and temporada.id_temporada = partido.id_temporada_partido and partido.id_temporada_partido>8 and
                        partido.id_temporada_partido<17
						group by eqL.id_equipo, temporada.nombre_temporada 
					)
					union
					(
						select eqv.id_equipo, eqv.nombre_equipo, count(*) as 'PJ', sum(if(goles_local < goles_visitante, 1 , 0)) as 'PG', 
						sum(if(goles_local = goles_visitante, 1 , 0)) as 'PE', sum(if(goles_local > goles_visitante, 1 , 0)) as 'PP',
						sum(goles_visitante) as 'GF', sum(goles_local) as 'GC' , temporada.anio_fin, temporada.nombre_temporada, partido.id_temporada_partido
						from partido,  equipo as eqV, temporada 
						where eqv.id_equipo = partido.id_equipo_visitante and temporada.id_temporada = partido.id_temporada_partido and partido.id_temporada_partido>8 and
                        partido.id_temporada_partido<17
						group by eqv.id_equipo, temporada.nombre_temporada 
					)
				) as algo group by id_equipo, nombre_temporada order by nombre_temporada asc, puntos desc 
			) as algo2, (SELECT @rownum1:=0) r
            UNION
            SELECT if((id_temporada_partido>=17 and id_temporada_partido<19),if(@rownum2<22,@rownum2:=@rownum2+1,@rownum2:=1),@rownum2:=0) as 'POSICION', nombre_equipo, Puntos, gf, gc, nombre_temporada
			from(
				select nombre_equipo,sum(if(anio_fin <= 1995, PG * 2 + PE,  PG * 3 + PE)) as 'Puntos', sum(pj) as 'PJ', sum(pg) as 'PG', sum(PE) as 'PE', sum(PP) as 'PP', sum(GF) as 'GF', sum(GC) as 'GC' , nombre_temporada, id_temporada_partido
				from (
					(
						select eqL.id_equipo, eqL.nombre_equipo, count(*) as 'PJ', sum(if(goles_local > goles_visitante, 1 , 0)) as 'PG', 
						sum(if(goles_local = goles_visitante, 1 , 0)) as 'PE', sum(if(goles_local < goles_visitante, 1 , 0)) as 'PP',
						sum(goles_local) as 'GF', sum(goles_visitante) as 'GC' , temporada.anio_fin, temporada.nombre_temporada, partido.id_temporada_partido
						from partido,  equipo as eqL, temporada 
						where  eqL.id_equipo = partido.id_equipo_local and temporada.id_temporada = partido.id_temporada_partido and partido.id_temporada_partido>=17 and
                        partido.id_temporada_partido<19
						group by eqL.id_equipo, temporada.nombre_temporada 
					)
					union
					(
						select eqv.id_equipo, eqv.nombre_equipo, count(*) as 'PJ', sum(if(goles_local < goles_visitante, 1 , 0)) as 'PG', 
						sum(if(goles_local = goles_visitante, 1 , 0)) as 'PE', sum(if(goles_local > goles_visitante, 1 , 0)) as 'PP',
						sum(goles_visitante) as 'GF', sum(goles_local) as 'GC' , temporada.anio_fin, temporada.nombre_temporada, partido.id_temporada_partido
						from partido,  equipo as eqV, temporada 
						where eqv.id_equipo = partido.id_equipo_visitante and temporada.id_temporada = partido.id_temporada_partido and partido.id_temporada_partido>=17 and
                        partido.id_temporada_partido<19
						group by eqv.id_equipo, temporada.nombre_temporada 
					)
				) as algo group by id_equipo, nombre_temporada order by nombre_temporada asc, puntos desc 
			) as algo2, (SELECT @rownum2:=0) r
            UNION
            SELECT if(id_temporada_partido>=19,if(@rownum3<20,@rownum3:=@rownum3+1,@rownum3:=1),@rownum3:=0) as 'POSICION', nombre_equipo, Puntos, gf, gc, nombre_temporada
			from(
				select nombre_equipo,sum(if(anio_fin <= 1995, PG * 2 + PE,  PG * 3 + PE)) as 'Puntos', sum(pj) as 'PJ', sum(pg) as 'PG', sum(PE) as 'PE', sum(PP) as 'PP', sum(GF) as 'GF', sum(GC) as 'GC' , nombre_temporada, id_temporada_partido
				from (
					(
						select eqL.id_equipo, eqL.nombre_equipo, count(*) as 'PJ', sum(if(goles_local > goles_visitante, 1 , 0)) as 'PG', 
						sum(if(goles_local = goles_visitante, 1 , 0)) as 'PE', sum(if(goles_local < goles_visitante, 1 , 0)) as 'PP',
						sum(goles_local) as 'GF', sum(goles_visitante) as 'GC' , temporada.anio_fin, temporada.nombre_temporada, partido.id_temporada_partido
						from partido,  equipo as eqL, temporada 
						where  eqL.id_equipo = partido.id_equipo_local and temporada.id_temporada = partido.id_temporada_partido and partido.id_temporada_partido>=19
						group by eqL.id_equipo, temporada.nombre_temporada 
					)
					union
					(
						select eqv.id_equipo, eqv.nombre_equipo, count(*) as 'PJ', sum(if(goles_local < goles_visitante, 1 , 0)) as 'PG', 
						sum(if(goles_local = goles_visitante, 1 , 0)) as 'PE', sum(if(goles_local > goles_visitante, 1 , 0)) as 'PP',
						sum(goles_visitante) as 'GF', sum(goles_local) as 'GC' , temporada.anio_fin, temporada.nombre_temporada, partido.id_temporada_partido
						from partido,  equipo as eqV, temporada 
						where eqv.id_equipo = partido.id_equipo_visitante and temporada.id_temporada = partido.id_temporada_partido and partido.id_temporada_partido>=19
						group by eqv.id_equipo, temporada.nombre_temporada 
					)
				) as algo group by id_equipo, nombre_temporada order by nombre_temporada asc, puntos desc 
			) as algo2, (SELECT @rownum3:=0) r
		) as algo3
        where nombre_equipo=nNombre_Equipo
        group by nombre_equipo, nombre_temporada
        order by nombre_temporada asc;
END //
delimiter ;

call PROC_POSICIONES_POR_TEMPORADA('Barcelona');

/*
===========================INCISO G===========================
*/
SELECT E1.NOMBRE_EQUIPO AS EQUIPO1, PARTIDO.GOLES_LOCAL, PARTIDO.GOLES_VISITANTE, E2.NOMBRE_EQUIPO AS EQUIPO2, PARTIDO.FECHA_PARTIDO
FROM EQUIPO AS E1, EQUIPO AS E2, PARTIDO
WHERE E1.ID_EQUIPO=PARTIDO.ID_EQUIPO_LOCAL AND
E2.ID_EQUIPO=PARTIDO.ID_EQUIPO_VISITANTE
GROUP BY EQUIPO1, PARTIDO.GOLES_LOCAL, PARTIDO.GOLES_VISITANTE, EQUIPO2
ORDER BY PARTIDO.GOLES_LOCAL DESC, PARTIDO.GOLES_VISITANTE ASC
LIMIT 1
;

/*
===========================INCISO H===========================
*/

CREATE TABLE PRIMEROS_LUGARES_POR_JORNADA(
	posicion int,
    nombre_equipo varchar(200),
    fecha date,
    puntos int,
    jornada int
);

drop TABLE PRIMEROS_LUGARES_POR_JORNADA;

drop procedure if exists PROC_HISTORIAL_PRIMER_PUESTO_POR_TEMPORADA;
delimiter //
CREATE PROCEDURE PROC_HISTORIAL_PRIMER_PUESTO_POR_TEMPORADA(IN nId_Temporada integer)
BEGIN
	declare num_jornadas integer;
    declare num_equipos integer;
    delete from PRIMEROS_LUGARES_POR_JORNADA;
    if nId_Temporada<9 then
		set num_jornadas=34;
        set num_equipos=18;
	elseif nId_Temporada>=9 and nId_Temporada<	17 then
		set num_jornadas=38;
        set num_equipos=20;
	elseif nId_Temporada>=17 and nId_Temporada<19 then
		set num_jornadas=42;
        set num_equipos=22;
	elseif nId_Temporada>=19 then
		set num_jornadas=38;
        set num_equipos=20;
    end if;
    while num_jornadas<>0 do
		INSERT INTO PRIMEROS_LUGARES_POR_JORNADA(posicion, nombre_equipo, fecha, puntos, jornada)
		SELECT if(@rownum<num_equipos,@rownum:=@rownum+1,@rownum:=1) as posicion, nombre_equipo as nombre_equipo, partido.fecha_partido as fecha, puntos as puntos, partido.id_jornada_partido as jornada
		from(
		select nombre_equipo,sum(if(anio_fin <= 1995, PG * 2 + PE,  PG * 3 + PE)) as 'Puntos' , sum(pj) as 'PJ', sum(pg) as 'PG', sum(PE) as 'PE', sum(PP) as 'PP', sum(GF) as 'GF', sum(GC) as 'GC', temporada, sum(GF)-sum(GC) as dif
		from (
				(
					select eqL.id_equipo, eqL.nombre_equipo, count(*) as 'PJ', sum(if(goles_local > goles_visitante, 1 , 0)) as 'PG', 
					sum(if(goles_local = goles_visitante, 1 , 0)) as 'PE', sum(if(goles_local < goles_visitante, 1 , 0)) as 'PP',
					sum(goles_local) as 'GF', sum(goles_visitante) as 'GC' , temporada.anio_fin, partido.id_jornada_partido, partido.fecha_partido, temporada.nombre_temporada as temporada
					from partido,  equipo as eqL, temporada where temporada.id_temporada=nId_Temporada
					and eqL.id_equipo = partido.id_equipo_local and partido.id_temporada_partido = temporada.id_temporada  and partido.id_jornada_partido <= num_jornadas
					group by eqL.id_equipo, partido.id_jornada_partido, partido.fecha_partido
				)
				union
				(
					select eqv.id_equipo, eqv.nombre_equipo, count(*) as 'PJ', sum(if(goles_local < goles_visitante, 1 , 0)) as 'PG', 
					sum(if(goles_local = goles_visitante, 1 , 0)) as 'PE', sum(if(goles_local > goles_visitante, 1 , 0)) as 'PP',
					sum(goles_visitante) as 'GF', sum(goles_local) as 'GC' , temporada.anio_fin, partido.id_jornada_partido, partido.fecha_partido, temporada.nombre_temporada as temporada
					from partido,  equipo as eqV, temporada where temporada.id_temporada=nId_Temporada
					and eqv.id_equipo = partido.id_equipo_visitante  and partido.id_temporada_partido = temporada.id_temporada and partido.id_jornada_partido <= num_jornadas
					group by eqv.id_equipo, partido.id_jornada_partido, partido.fecha_partido
				)
			) as algo group by id_equipo order by Puntos desc, dif desc
			) as algo2, partido, temporada, (select @rownum:=0) r
			where partido.id_jornada_partido=num_jornadas and
			temporada.nombre_temporada=temporada and 
			partido.id_temporada_partido=temporada.id_temporada
			LIMIT 1;
			set num_jornadas=num_jornadas-1;
        end while;
END //
delimiter ;

call PROC_HISTORIAL_PRIMER_PUESTO_POR_TEMPORADA(41);
select * from PRIMEROS_LUGARES_POR_JORNADA group by posicion, nombre_equipo, fecha, puntos, jornada order by jornada asc;

/*
===========================INCISO I===========================
*/
drop procedure if exists PROC_HISTORIAL_ULTIMO_PUESTO_POR_TEMPORADA;
delimiter //
CREATE PROCEDURE PROC_HISTORIAL_ULTIMO_PUESTO_POR_TEMPORADA(IN nId_Temporada integer)
BEGIN
	declare num_jornadas integer;
    declare num_equipos integer;
    delete from PRIMEROS_LUGARES_POR_JORNADA;
    if nId_Temporada<9 then
		set num_jornadas=34;
        set num_equipos=18;
	elseif nId_Temporada>=9 and nId_Temporada<	17 then
		set num_jornadas=38;
        set num_equipos=20;
	elseif nId_Temporada>=17 and nId_Temporada<19 then
		set num_jornadas=42;
        set num_equipos=22;
	elseif nId_Temporada>=19 then
		set num_jornadas=38;
        set num_equipos=20;
    end if;
    while num_jornadas<>0 do
		INSERT INTO PRIMEROS_LUGARES_POR_JORNADA(posicion, nombre_equipo, fecha, puntos, jornada)
        select posicion, nombre_equipo, fecha, puntos, jornada
        from(
		SELECT if(@rownum<num_equipos,@rownum:=@rownum+1,@rownum:=1) as posicion, nombre_equipo as nombre_equipo, partido.fecha_partido as fecha, puntos as puntos, partido.id_jornada_partido as jornada, dif
		from(
		select nombre_equipo,sum(if(anio_fin <= 1995, PG * 2 + PE,  PG * 3 + PE)) as 'Puntos' , sum(pj) as 'PJ', sum(pg) as 'PG', sum(PE) as 'PE', sum(PP) as 'PP', sum(GF) as 'GF', sum(GC) as 'GC', temporada, sum(GF)-sum(GC) as dif
		from (
				(
					select eqL.id_equipo, eqL.nombre_equipo, count(*) as 'PJ', sum(if(goles_local > goles_visitante, 1 , 0)) as 'PG', 
					sum(if(goles_local = goles_visitante, 1 , 0)) as 'PE', sum(if(goles_local < goles_visitante, 1 , 0)) as 'PP',
					sum(goles_local) as 'GF', sum(goles_visitante) as 'GC' , temporada.anio_fin, partido.id_jornada_partido, partido.fecha_partido, temporada.nombre_temporada as temporada
					from partido,  equipo as eqL, temporada where temporada.id_temporada=nId_Temporada
					and eqL.id_equipo = partido.id_equipo_local and partido.id_temporada_partido = temporada.id_temporada  and partido.id_jornada_partido <= num_jornadas
					group by eqL.id_equipo, partido.id_jornada_partido, partido.fecha_partido
				)
				union
				(
					select eqv.id_equipo, eqv.nombre_equipo, count(*) as 'PJ', sum(if(goles_local < goles_visitante, 1 , 0)) as 'PG', 
					sum(if(goles_local = goles_visitante, 1 , 0)) as 'PE', sum(if(goles_local > goles_visitante, 1 , 0)) as 'PP',
					sum(goles_visitante) as 'GF', sum(goles_local) as 'GC' , temporada.anio_fin, partido.id_jornada_partido, partido.fecha_partido, temporada.nombre_temporada as temporada
					from partido,  equipo as eqV, temporada where temporada.id_temporada=nId_Temporada
					and eqv.id_equipo = partido.id_equipo_visitante  and partido.id_temporada_partido = temporada.id_temporada and partido.id_jornada_partido <= num_jornadas
					group by eqv.id_equipo, partido.id_jornada_partido, partido.fecha_partido
				)
			) as algo group by id_equipo order by Puntos desc, dif desc
			) as algo2, partido, temporada, (select @rownum:=0) r
			where partido.id_jornada_partido=num_jornadas and
			temporada.nombre_temporada=temporada and 
			partido.id_temporada_partido=temporada.id_temporada
            ) as algo3 where posicion=18 group by posicion, nombre_equipo, fecha, puntos, jornada order by puntos asc, dif asc LIMIT 1;
			set num_jornadas=num_jornadas-1;
        end while;
END //
delimiter ;

call PROC_HISTORIAL_ULTIMO_PUESTO_POR_TEMPORADA(1);
select * from PRIMEROS_LUGARES_POR_JORNADA group by posicion, nombre_equipo, fecha, puntos, jornada order by jornada asc;

/*
===========================INCISO J===========================
*/


/*
===========================INCISO K===========================
*/

/*
==================CONSULTAS DE AYUDA INCISO E===================
SELECT *
FROM VICTIMA_FAVORITA
WHERE EQUIPO_GANADOR='Barcelona'
;

SELECT EQUIPO_LOCAL, EQUIPO_VISITA, GOLES_LOCAL, GOLES_VISITA, FECHA
FROM VICTIMA_FAVORITA
WHERE GOLES_LOCAL>GOLES_VISITA AND
EQUIPO_LOCAL='Barcelona' AND
EQUIPO_VISITA='Real Madrid' 
GROUP BY EQUIPO_LOCAL, EQUIPO_VISITA, GOLES_LOCAL, GOLES_VISITA, FECHA
ORDER BY FECHA ASC
;
*/
