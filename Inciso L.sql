

CREATE TABLE if not exists partido_simulacion(
		fecha_partido_simulacion DATE NOT NULL,
		goles_local INT NOT NULL,
		goles_visitante INT NOT NULL,
		resultado_partido_simulacion VARCHAR(10) NOT NULL,
		id_temporada_partido_simulacion INT NOT NULL,
		id_jornada_partido_simulacion INT NOT NULL,
		id_equipo_local INT NOT NULL,
		id_equipo_visitante INT NOT NULL,
		PRIMARY KEY(id_temporada_partido_simulacion, id_jornada_partido_simulacion, id_equipo_local, id_equipo_visitante),
		FOREIGN KEY(id_temporada_partido_simulacion) REFERENCES TEMPORADA(id_temporada),
		FOREIGN KEY(id_jornada_partido_simulacion) REFERENCES JORNADA(id_jornada),
		FOREIGN KEY (id_equipo_local) REFERENCES EQUIPO(id_equipo),
		FOREIGN KEY(id_equipo_visitante) REFERENCES EQUIPO(id_equipo)
	);


DROP PROCEDURE IF EXISTS PROC_INICIAR_SIMULACION;
delimiter //
CREATE PROCEDURE PROC_INICIAR_SIMULACION()
BEGIN 
	DELETE FROM PARTIDO_SIMULACION WHERE id_temporada_partido_simulacion != -1;
    INSERT INTO PARTIDO_SIMULACION SELECT * FROM PARTIDO; 
    
    select 'normal' as tabla, count(*) as f from partido union
	select 'simulado' , count(*) as f from partido_simulacion ;
END //
delimiter ;
-- ---------------------------------------------------------------------------
-- Inciso A
DROP procedure if exists PROC_TABLA_POSICIONES_A_SIMU;
delimiter //
CREATE PROCEDURE PROC_TABLA_POSICIONES_A_SIMU(IN id_temp varchar(500), IN jornada INT, IN fecha DATE)
BEGIN 
	if jornada is not null then 
    		select   nombre_equipo,sum(if(anio_fin <= 1995, PG * 2 + PE,  PG * 3 + PE)) as 'Puntos' , sum(pj) as 'PJ', sum(pg) as 'PG', sum(PE) as 'PE', sum(PP) as 'PP', sum(GF) as 'GF', sum(GC) as 'GC', id_temporada, nombre_temporada ,sum(GF)-sum(GC) as dif
            from (
			(
			select temporada.id_temporada, temporada.nombre_temporada, eqL.id_equipo, eqL.nombre_equipo, count(*) as 'PJ', sum(if(goles_local > goles_visitante, 1 , 0)) as 'PG', 
				sum(if(goles_local = goles_visitante, 1 , 0)) as 'PE', sum(if(goles_local < goles_visitante, 1 , 0)) as 'PP',
			 sum(goles_local) as 'GF', sum(goles_visitante) as 'GC' , temporada.anio_fin
			 from partido_simulacion,  equipo as eqL, temporada where (id_temporada = ID_TEMP OR nombre_temporada  LIKE ID_TEMP)
			and eqL.id_equipo = partido_simulacion.id_equipo_local and temporada.id_temporada = partido_simulacion.id_temporada_partido_simulacion 
            and partido_simulacion.id_jornada_partido_simulacion <= jornada
			group by id_temporada , eqL.id_equipo
			)
			union
			(
			select temporada.id_temporada, temporada.nombre_temporada, eqv.id_equipo, eqv.nombre_equipo, count(*) as 'PJ', sum(if(goles_local < goles_visitante, 1 , 0)) as 'PG', 
				sum(if(goles_local = goles_visitante, 1 , 0)) as 'PE', sum(if(goles_local > goles_visitante, 1 , 0)) as 'PP',
			 sum(goles_visitante) as 'GF', sum(goles_local) as 'GC' , temporada.anio_fin
			 from partido_simulacion,  equipo as eqV, temporada where (id_temporada = ID_TEMP OR nombre_temporada  LIKE ID_TEMP)
			and eqv.id_equipo = partido_simulacion.id_equipo_visitante  and temporada.id_temporada = partido_simulacion.id_temporada_partido_simulacion
            and partido_simulacion.id_jornada_partido_simulacion <= jornada
			group by id_temporada , eqv.id_equipo 
			)) as algo group by id_temporada ,  id_equipo order by id_temporada desc,  Puntos desc, dif desc;
    elseif fecha is not null then 
    		select   nombre_equipo,sum(if(anio_fin <= 1995, PG * 2 + PE,  PG * 3 + PE)) as 'Puntos' , sum(pj) as 'PJ', sum(pg) as 'PG', sum(PE) as 'PE', sum(PP) as 'PP', sum(GF) as 'GF', sum(GC) as 'GC', id_temporada, nombre_temporada, sum(GF)-sum(GC) as dif
            from (
			(
			select temporada.id_temporada, temporada.nombre_temporada, eqL.id_equipo, eqL.nombre_equipo, count(*) as 'PJ', sum(if(goles_local > goles_visitante, 1 , 0)) as 'PG', 
				sum(if(goles_local = goles_visitante, 1 , 0)) as 'PE', sum(if(goles_local < goles_visitante, 1 , 0)) as 'PP',
			 sum(goles_local) as 'GF', sum(goles_visitante) as 'GC' , temporada.anio_fin
			 from partido_simulacion,  equipo as eqL, temporada where (id_temporada = ID_TEMP OR nombre_temporada  LIKE ID_TEMP)
			and eqL.id_equipo = partido_simulacion.id_equipo_local and temporada.id_temporada = partido_simulacion.id_temporada_partido_simulacion 
            and partido_simulacion.fecha_partido_simulacion <= fecha
			group by id_temporada , eqL.id_equipo
			)
			union
			(
			select temporada.id_temporada, temporada.nombre_temporada, eqv.id_equipo, eqv.nombre_equipo, count(*) as 'PJ', sum(if(goles_local < goles_visitante, 1 , 0)) as 'PG', 
				sum(if(goles_local = goles_visitante, 1 , 0)) as 'PE', sum(if(goles_local > goles_visitante, 1 , 0)) as 'PP',
			 sum(goles_visitante) as 'GF', sum(goles_local) as 'GC' , temporada.anio_fin
			 from partido_simulacion,  equipo as eqV, temporada where (id_temporada = ID_TEMP OR nombre_temporada  LIKE ID_TEMP)
			and eqv.id_equipo = partido_simulacion.id_equipo_visitante  and temporada.id_temporada = partido_simulacion.id_temporada_partido_simulacion
            and partido_simulacion.fecha_partido_simulacion <= fecha
			group by id_temporada , eqv.id_equipo 
			)) as algo group by id_temporada ,  id_equipo order by id_temporada desc, Puntos desc, dif desc;
    else 
		select   nombre_equipo,sum(if(anio_fin <= 1995, PG * 2 + PE,  PG * 3 + PE)) as 'Puntos' , sum(pj) as 'PJ', sum(pg) as 'PG', sum(PE) as 'PE', sum(PP) as 'PP', sum(GF) as 'GF', sum(GC) as 'GC', id_temporada, nombre_temporada , sum(GF)-sum(GC) as dif
        from (
	-- select  * from (
		(
		select temporada.id_temporada, temporada.nombre_temporada, eqL.id_equipo, eqL.nombre_equipo, count(*) as 'PJ', sum(if(goles_local > goles_visitante, 1 , 0)) as 'PG', 
			sum(if(goles_local = goles_visitante, 1 , 0)) as 'PE', sum(if(goles_local < goles_visitante, 1 , 0)) as 'PP',
		 sum(goles_local) as 'GF', sum(goles_visitante) as 'GC' , temporada.anio_fin
		 from partido_simulacion,  equipo as eqL, temporada where (id_temporada = ID_TEMP OR nombre_temporada  LIKE ID_TEMP)
		and eqL.id_equipo = partido_simulacion.id_equipo_local and temporada.id_temporada = partido_simulacion.id_temporada_partido_simulacion  
		group by id_temporada , eqL.id_equipo
		)
		union
		(
		select temporada.id_temporada, temporada.nombre_temporada, eqv.id_equipo, eqv.nombre_equipo, count(*) as 'PJ', sum(if(goles_local < goles_visitante, 1 , 0)) as 'PG', 
			sum(if(goles_local = goles_visitante, 1 , 0)) as 'PE', sum(if(goles_local > goles_visitante, 1 , 0)) as 'PP',
		 sum(goles_visitante) as 'GF', sum(goles_local) as 'GC' , temporada.anio_fin
		 from partido_simulacion,  equipo as eqV, temporada where (id_temporada = ID_TEMP OR nombre_temporada  LIKE ID_TEMP)
		and eqv.id_equipo = partido_simulacion.id_equipo_visitante  and temporada.id_temporada = partido_simulacion.id_temporada_partido_simulacion
		group by id_temporada , eqv.id_equipo 
		)) as algo group by id_temporada , id_equipo order by id_temporada desc,  Puntos desc, dif desc;
    end if;
	
END //
delimiter ;
-- ---------------------------------------------------------------------------
-- Inciso B
DROP VIEW IF EXISTS show_tabla_res_simu ;
CREATE VIEW show_tabla_res_simu AS
select id_equipo,  nombre_equipo,sum(if(anio_fin <= 1995, PG * 2 + PE,  PG * 3 + PE)) as 'Puntos' , sum(pj) as 'PJ', sum(pg) as 'PG', sum(PE) as 'PE', sum(PP) as 'PP', sum(GF) as 'GF', sum(GC) as 'GC', id_temporada, nombre_temporada , sum(GF)-sum(GC) as dif
from (
	-- select  * from (
		(
		select temporada.id_temporada, temporada.nombre_temporada, eqL.id_equipo, eqL.nombre_equipo, count(*) as 'PJ', sum(if(goles_local > goles_visitante, 1 , 0)) as 'PG', 
			sum(if(goles_local = goles_visitante, 1 , 0)) as 'PE', sum(if(goles_local < goles_visitante, 1 , 0)) as 'PP',
		 sum(goles_local) as 'GF', sum(goles_visitante) as 'GC' , temporada.anio_fin
		 from partido_simulacion,  equipo as eqL, temporada where eqL.id_equipo = partido_simulacion.id_equipo_local and 
         temporada.id_temporada = partido_simulacion.id_temporada_partido_simulacion  
		group by id_temporada, eqL.id_equipo
		)
		union
		(
		select temporada.id_temporada, temporada.nombre_temporada, eqv.id_equipo, eqv.nombre_equipo, count(*) as 'PJ', sum(if(goles_local < goles_visitante, 1 , 0)) as 'PG', 
			sum(if(goles_local = goles_visitante, 1 , 0)) as 'PE', sum(if(goles_local > goles_visitante, 1 , 0)) as 'PP',
		 sum(goles_visitante) as 'GF', sum(goles_local) as 'GC' , temporada.anio_fin
		 from partido_simulacion,  equipo as eqV, temporada where  eqv.id_equipo = partido_simulacion.id_equipo_visitante  and 
         temporada.id_temporada = partido_simulacion.id_temporada_partido_simulacion
		group by id_temporada, eqv.id_equipo 
		)) as algo group by id_temporada , id_equipo  order by id_temporada desc,   Puntos desc, dif desc;


DROP VIEW IF EXISTS primeros4_por_temporada_B_SIMU;
CREATE VIEW primeros4_por_temporada_B_SIMU AS
select t4.nombre_temporada temporada, ta.puesto1, ta.puntos1, ta.puesto2, ta.puntos2, ta.puesto3, ta.puntos3, t4.nombre_equipo puesto4, t4.puntos puntos4 from (
	select ta.* , t3.id_equipo idp3, t3.nombre_equipo puesto3, t3.puntos puntos3 from (
		select t1.id_temporada, t1.id_equipo idp1, t1.nombre_equipo puesto1 , t1.puntos puntos1, t2.id_equipo idp2, t2.nombre_equipo puesto2, t2.puntos puntos2  from (
			select id_temporada, id_equipo, nombre_equipo, max(puntos) puntos from show_tabla_res_simu
			group by id_temporada ) t1, show_tabla_res_simu t2
		where t1.id_temporada = t2.id_temporada and t1.id_equipo != t2.id_equipo
		group by t1.id_temporada order by t1.id_temporada desc, t2.puntos desc
	) ta , show_tabla_res_simu t3
	where ta.id_temporada = t3.id_temporada and (ta.idp1 != t3.id_equipo and ta.idp2 != t3.id_equipo)
	group by ta.id_temporada order by ta.id_temporada desc, t3.puntos desc ) ta , show_tabla_res_simu t4
where ta.id_temporada = t4.id_temporada and (ta.idp1 != t4.id_equipo and ta.idp2 != t4.id_equipo and ta.idp3 != t4.id_equipo)
group by ta.id_temporada order by ta.id_temporada desc, t4.puntos desc;

-- ----------------------------------------------------------------------------
-- Inciso D

DROP PROCEDURE IF EXISTS PROC_DESCALIFICADO_TEMP_ANTERIOR_D_SIMU;
delimiter //
CREATE PROCEDURE PROC_DESCALIFICADO_TEMP_ANTERIOR_D_SIMU(IN temporada varchar(500))
BEGIN 
	DECLARE temp INT default null;
    DECLARE TEMP_ACTUAL INT DEFAULT NULL;
    DECLARE VTEMP_ACTUAL varchar(500) DEFAULT '';
    DECLARE TEMP_ANT INT DEFAULT NULL; 
    DECLARE VTEMP_ANT VARCHAR(500) DEFAULT ''; 
    select  id_temporada, (anio_fin - 1), nombre_temporada  INTO TEMP_ACTUAL, temp, VTEMP_ACTUAL from temporada where id_temporada = temporada or nombre_temporada = temporada limit 1;
--    select  id_temporada INTO TEMP_ACTUAL from temporada where id_temporada = temporada or nombre_temporada = temporada limit 1;
--    SELECT (anio_fin - 1) into temp  FROM temporada where id_temporada = TEMP_ACTUAL;

    select  id_temporada, nombre_temporada into TEMP_ANT, VTEMP_ANT from temporada where anio_fin = temp; 
    
    
    if TEMP_ANT is null then 
		select concat('No hay registros del año ' , temp) as 'Info';
    else 
		select nombre_equipo 
        , VTEMP_ANT 'Aparece en', VTEMP_ACTUAL 'No aparece'
        from partido_simulacion , equipo where (equipo.id_equipo = partido_simulacion.id_equipo_local or equipo.id_equipo = partido_simulacion.id_equipo_visitante)
        and id_temporada_partido_simulacion = TEMP_ANT and (partido_simulacion.id_equipo_local  not in (select id_equipo_local from partido_simulacion where id_temporada_partido_simulacion = TEMP_ACTUAL )
        and partido_simulacion.id_equipo_visitante  not in (select id_equipo_visitante from partido_simulacion where id_temporada_partido_simulacion = TEMP_ACTUAL )) 
        group by id_equipo ;
    end if;
END //
delimiter ;
-- ----------------------------------------------------------------------------
-- Inciso E 
DROP VIEW IF EXISTS VICTIMA_FAVORITA_SIMU;
CREATE VIEW VICTIMA_FAVORITA_SIMU AS
	SELECT E1.NOMBRE_EQUIPO AS EQUIPO_GANADOR, partido_simulacion.RESULTADO_partido_simulacion AS RESULTADO, E2.NOMBRE_EQUIPO AS EQUIPO_PERDEDOR, 
			partido_simulacion.GOLES_LOCAL AS GOLES_LOCAL, partido_simulacion.GOLES_VISITANTE AS GOLES_VISITA, partido_simulacion.FECHA_partido_simulacion AS FECHA
	FROM partido_simulacion, EQUIPO AS E1, EQUIPO AS E2
	WHERE E1.ID_EQUIPO=partido_simulacion.ID_EQUIPO_LOCAL AND
	E2.ID_EQUIPO=partido_simulacion.ID_EQUIPO_VISITANTE AND
    partido_simulacion.GOLES_LOCAL>partido_simulacion.GOLES_VISITANTE
    UNION
    SELECT E1.NOMBRE_EQUIPO AS EQUIPO_GANADOR, partido_simulacion.RESULTADO_partido_simulacion AS RESULTADO, E2.NOMBRE_EQUIPO AS EQUIPO_PERDEDOR, 
			partido_simulacion.GOLES_VISITANTE AS GOLES_LOCAL, partido_simulacion.GOLES_LOCAL AS GOLES_VISITA, partido_simulacion.FECHA_partido_simulacion AS FECHA
	FROM partido_simulacion, EQUIPO AS E1, EQUIPO AS E2
	WHERE E2.ID_EQUIPO=partido_simulacion.ID_EQUIPO_LOCAL AND
	E1.ID_EQUIPO=partido_simulacion.ID_EQUIPO_VISITANTE AND
    partido_simulacion.GOLES_LOCAL<partido_simulacion.GOLES_VISITANTE
;

-- --------------------------------------------------------------------------
-- Inciso F
DROP PROCEDURE IF EXISTS PROC_POSICIONES_POR_TEMPORADA_SIMU;
delimiter //
CREATE PROCEDURE PROC_POSICIONES_POR_TEMPORADA_SIMU(IN nNombre_Equipo varchar(200))
BEGIN
	SELECT POSICION, nombre_equipo, Puntos, gf, gc, nombre_temporada 
    from(
			SELECT if(id_temporada_partido_simulacion<=8,if(@rownum<18,@rownum:=@rownum+1,@rownum:=1),@rownum:=0) as 'POSICION', nombre_equipo, Puntos, gf, gc, nombre_temporada
			from(
				select nombre_equipo,sum(if(anio_fin <= 1995, PG * 2 + PE,  PG * 3 + PE)) as 'Puntos', sum(pj) as 'PJ', sum(pg) as 'PG', sum(PE) as 'PE', sum(PP) as 'PP', sum(GF) as 'GF', sum(GC) as 'GC' , nombre_temporada, id_temporada_partido_simulacion
				from (
					(
						select eqL.id_equipo, eqL.nombre_equipo, count(*) as 'PJ', sum(if(goles_local > goles_visitante, 1 , 0)) as 'PG', 
						sum(if(goles_local = goles_visitante, 1 , 0)) as 'PE', sum(if(goles_local < goles_visitante, 1 , 0)) as 'PP',
						sum(goles_local) as 'GF', sum(goles_visitante) as 'GC' , temporada.anio_fin, temporada.nombre_temporada, partido_simulacion.id_temporada_partido_simulacion
						from partido_simulacion,  equipo as eqL, temporada 
						where  eqL.id_equipo = partido_simulacion.id_equipo_local and temporada.id_temporada = partido_simulacion.id_temporada_partido_simulacion and partido_simulacion.id_temporada_partido_simulacion<=8
						group by eqL.id_equipo, temporada.nombre_temporada 
					)
					union
					(
						select eqv.id_equipo, eqv.nombre_equipo, count(*) as 'PJ', sum(if(goles_local < goles_visitante, 1 , 0)) as 'PG', 
						sum(if(goles_local = goles_visitante, 1 , 0)) as 'PE', sum(if(goles_local > goles_visitante, 1 , 0)) as 'PP',
						sum(goles_visitante) as 'GF', sum(goles_local) as 'GC' , temporada.anio_fin, temporada.nombre_temporada, partido_simulacion.id_temporada_partido_simulacion
						from partido_simulacion,  equipo as eqV, temporada 
						where eqv.id_equipo = partido_simulacion.id_equipo_visitante and temporada.id_temporada = partido_simulacion.id_temporada_partido_simulacion and partido_simulacion.id_temporada_partido_simulacion<=8
						group by eqv.id_equipo, temporada.nombre_temporada 
					)
				) as algo group by id_equipo, nombre_temporada order by nombre_temporada asc, puntos desc 
			) as algo2, (SELECT @rownum:=0) r
			UNION
			SELECT if((id_temporada_partido_simulacion>8 and id_temporada_partido_simulacion<17),if(@rownum1<20,@rownum1:=@rownum1+1,@rownum1:=1),@rownum1:=0) as 'POSICION', nombre_equipo, Puntos, gf, gc, nombre_temporada
			from(
				select nombre_equipo,sum(if(anio_fin <= 1995, PG * 2 + PE,  PG * 3 + PE)) as 'Puntos', sum(pj) as 'PJ', sum(pg) as 'PG', sum(PE) as 'PE', sum(PP) as 'PP', sum(GF) as 'GF', sum(GC) as 'GC' , nombre_temporada, id_temporada_partido_simulacion
				from (
					(
						select eqL.id_equipo, eqL.nombre_equipo, count(*) as 'PJ', sum(if(goles_local > goles_visitante, 1 , 0)) as 'PG', 
						sum(if(goles_local = goles_visitante, 1 , 0)) as 'PE', sum(if(goles_local < goles_visitante, 1 , 0)) as 'PP',
						sum(goles_local) as 'GF', sum(goles_visitante) as 'GC' , temporada.anio_fin, temporada.nombre_temporada, partido_simulacion.id_temporada_partido_simulacion
						from partido_simulacion,  equipo as eqL, temporada 
						where  eqL.id_equipo = partido_simulacion.id_equipo_local and temporada.id_temporada = partido_simulacion.id_temporada_partido_simulacion and partido_simulacion.id_temporada_partido_simulacion>8 and
                        partido_simulacion.id_temporada_partido_simulacion<17
						group by eqL.id_equipo, temporada.nombre_temporada 
					)
					union
					(
						select eqv.id_equipo, eqv.nombre_equipo, count(*) as 'PJ', sum(if(goles_local < goles_visitante, 1 , 0)) as 'PG', 
						sum(if(goles_local = goles_visitante, 1 , 0)) as 'PE', sum(if(goles_local > goles_visitante, 1 , 0)) as 'PP',
						sum(goles_visitante) as 'GF', sum(goles_local) as 'GC' , temporada.anio_fin, temporada.nombre_temporada, partido_simulacion.id_temporada_partido_simulacion
						from partido_simulacion,  equipo as eqV, temporada 
						where eqv.id_equipo = partido_simulacion.id_equipo_visitante and temporada.id_temporada = partido_simulacion.id_temporada_partido_simulacion and partido_simulacion.id_temporada_partido_simulacion>8 and
                        partido_simulacion.id_temporada_partido_simulacion<17
						group by eqv.id_equipo, temporada.nombre_temporada 
					)
				) as algo group by id_equipo, nombre_temporada order by nombre_temporada asc, puntos desc 
			) as algo2, (SELECT @rownum1:=0) r
            UNION
            SELECT if((id_temporada_partido_simulacion>=17 and id_temporada_partido_simulacion<19),if(@rownum2<22,@rownum2:=@rownum2+1,@rownum2:=1),@rownum2:=0) as 'POSICION', nombre_equipo, Puntos, gf, gc, nombre_temporada
			from(
				select nombre_equipo,sum(if(anio_fin <= 1995, PG * 2 + PE,  PG * 3 + PE)) as 'Puntos', sum(pj) as 'PJ', sum(pg) as 'PG', sum(PE) as 'PE', sum(PP) as 'PP', sum(GF) as 'GF', sum(GC) as 'GC' , nombre_temporada, id_temporada_partido_simulacion
				from (
					(
						select eqL.id_equipo, eqL.nombre_equipo, count(*) as 'PJ', sum(if(goles_local > goles_visitante, 1 , 0)) as 'PG', 
						sum(if(goles_local = goles_visitante, 1 , 0)) as 'PE', sum(if(goles_local < goles_visitante, 1 , 0)) as 'PP',
						sum(goles_local) as 'GF', sum(goles_visitante) as 'GC' , temporada.anio_fin, temporada.nombre_temporada, partido_simulacion.id_temporada_partido_simulacion
						from partido_simulacion,  equipo as eqL, temporada 
						where  eqL.id_equipo = partido_simulacion.id_equipo_local and temporada.id_temporada = partido_simulacion.id_temporada_partido_simulacion and partido_simulacion.id_temporada_partido_simulacion>=17 and
                        partido_simulacion.id_temporada_partido_simulacion<19
						group by eqL.id_equipo, temporada.nombre_temporada 
					)
					union
					(
						select eqv.id_equipo, eqv.nombre_equipo, count(*) as 'PJ', sum(if(goles_local < goles_visitante, 1 , 0)) as 'PG', 
						sum(if(goles_local = goles_visitante, 1 , 0)) as 'PE', sum(if(goles_local > goles_visitante, 1 , 0)) as 'PP',
						sum(goles_visitante) as 'GF', sum(goles_local) as 'GC' , temporada.anio_fin, temporada.nombre_temporada, partido_simulacion.id_temporada_partido_simulacion
						from partido_simulacion,  equipo as eqV, temporada 
						where eqv.id_equipo = partido_simulacion.id_equipo_visitante and temporada.id_temporada = partido_simulacion.id_temporada_partido_simulacion and partido_simulacion.id_temporada_partido_simulacion>=17 and
                        partido_simulacion.id_temporada_partido_simulacion<19
						group by eqv.id_equipo, temporada.nombre_temporada 
					)
				) as algo group by id_equipo, nombre_temporada order by nombre_temporada asc, puntos desc 
			) as algo2, (SELECT @rownum2:=0) r
            UNION
            SELECT if(id_temporada_partido_simulacion>=19,if(@rownum3<20,@rownum3:=@rownum3+1,@rownum3:=1),@rownum3:=0) as 'POSICION', nombre_equipo, Puntos, gf, gc, nombre_temporada
			from(
				select nombre_equipo,sum(if(anio_fin <= 1995, PG * 2 + PE,  PG * 3 + PE)) as 'Puntos', sum(pj) as 'PJ', sum(pg) as 'PG', sum(PE) as 'PE', sum(PP) as 'PP', sum(GF) as 'GF', sum(GC) as 'GC' , nombre_temporada, id_temporada_partido_simulacion
				from (
					(
						select eqL.id_equipo, eqL.nombre_equipo, count(*) as 'PJ', sum(if(goles_local > goles_visitante, 1 , 0)) as 'PG', 
						sum(if(goles_local = goles_visitante, 1 , 0)) as 'PE', sum(if(goles_local < goles_visitante, 1 , 0)) as 'PP',
						sum(goles_local) as 'GF', sum(goles_visitante) as 'GC' , temporada.anio_fin, temporada.nombre_temporada, partido_simulacion.id_temporada_partido_simulacion
						from partido_simulacion,  equipo as eqL, temporada 
						where  eqL.id_equipo = partido_simulacion.id_equipo_local and temporada.id_temporada = partido_simulacion.id_temporada_partido_simulacion and partido_simulacion.id_temporada_partido_simulacion>=19
						group by eqL.id_equipo, temporada.nombre_temporada 
					)
					union
					(
						select eqv.id_equipo, eqv.nombre_equipo, count(*) as 'PJ', sum(if(goles_local < goles_visitante, 1 , 0)) as 'PG', 
						sum(if(goles_local = goles_visitante, 1 , 0)) as 'PE', sum(if(goles_local > goles_visitante, 1 , 0)) as 'PP',
						sum(goles_visitante) as 'GF', sum(goles_local) as 'GC' , temporada.anio_fin, temporada.nombre_temporada, partido_simulacion.id_temporada_partido_simulacion
						from partido_simulacion,  equipo as eqV, temporada 
						where eqv.id_equipo = partido_simulacion.id_equipo_visitante and temporada.id_temporada = partido_simulacion.id_temporada_partido_simulacion and partido_simulacion.id_temporada_partido_simulacion>=19
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
-- --------------------------------------------------------------------------
-- G consulta 
-- --------------------------------------------------------------------------
-- H 
drop procedure if exists PROC_HISTORIAL_PRIMER_PUESTO_POR_TEMPORADA_SIMU;
delimiter //
CREATE PROCEDURE PROC_HISTORIAL_PRIMER_PUESTO_POR_TEMPORADA_SIMU(IN nId_Temporada integer)
BEGIN
	declare num_jornadas integer;
    declare num_equipos integer;
    truncate PRIMEROS_LUGARES_POR_JORNADA;
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
		SELECT if(@rownum<num_equipos,@rownum:=@rownum+1,@rownum:=1) as posicion, nombre_equipo as nombre_equipo, partido_simulacion.fecha_partido_simulacion as fecha, puntos as puntos, partido_simulacion.id_jornada_partido_simulacion as jornada
		from(
		select nombre_equipo,sum(if(anio_fin <= 1995, PG * 2 + PE,  PG * 3 + PE)) as 'Puntos' , sum(pj) as 'PJ', sum(pg) as 'PG', sum(PE) as 'PE', sum(PP) as 'PP', sum(GF) as 'GF', sum(GC) as 'GC', temporada, sum(GF)-sum(GC) as dif
		from (
				(
					select eqL.id_equipo, eqL.nombre_equipo, count(*) as 'PJ', sum(if(goles_local > goles_visitante, 1 , 0)) as 'PG', 
					sum(if(goles_local = goles_visitante, 1 , 0)) as 'PE', sum(if(goles_local < goles_visitante, 1 , 0)) as 'PP',
					sum(goles_local) as 'GF', sum(goles_visitante) as 'GC' , temporada.anio_fin, partido_simulacion.id_jornada_partido_simulacion, partido_simulacion.fecha_partido_simulacion, temporada.nombre_temporada as temporada
					from partido_simulacion,  equipo as eqL, temporada where temporada.id_temporada=nId_Temporada
					and eqL.id_equipo = partido_simulacion.id_equipo_local and partido_simulacion.id_temporada_partido_simulacion = temporada.id_temporada  and partido_simulacion.id_jornada_partido_simulacion <= num_jornadas
					group by eqL.id_equipo, partido_simulacion.id_jornada_partido_simulacion, partido_simulacion.fecha_partido_simulacion
				)
				union
				(
					select eqv.id_equipo, eqv.nombre_equipo, count(*) as 'PJ', sum(if(goles_local < goles_visitante, 1 , 0)) as 'PG', 
					sum(if(goles_local = goles_visitante, 1 , 0)) as 'PE', sum(if(goles_local > goles_visitante, 1 , 0)) as 'PP',
					sum(goles_visitante) as 'GF', sum(goles_local) as 'GC' , temporada.anio_fin, partido_simulacion.id_jornada_partido_simulacion, partido_simulacion.fecha_partido_simulacion, temporada.nombre_temporada as temporada
					from partido_simulacion,  equipo as eqV, temporada where temporada.id_temporada=nId_Temporada
					and eqv.id_equipo = partido_simulacion.id_equipo_visitante  and partido_simulacion.id_temporada_partido_simulacion = temporada.id_temporada and partido_simulacion.id_jornada_partido_simulacion <= num_jornadas
					group by eqv.id_equipo, partido_simulacion.id_jornada_partido_simulacion, partido_simulacion.fecha_partido_simulacion
				)
			) as algo group by id_equipo order by Puntos desc, dif desc
			) as algo2, partido_simulacion, temporada, (select @rownum:=0) r
			where partido_simulacion.id_jornada_partido_simulacion=num_jornadas and
			temporada.nombre_temporada=temporada and 
			partido_simulacion.id_temporada_partido_simulacion=temporada.id_temporada
			LIMIT 1;
			set num_jornadas=num_jornadas-1;
        end while;
        select * from PRIMEROS_LUGARES_POR_JORNADA group by posicion, nombre_equipo, fecha, puntos, jornada order by jornada asc;
END //
delimiter ;

-- ---------------------------------------------------------------------------
-- I
drop procedure if exists PROC_HISTORIAL_ULTIMO_PUESTO_POR_TEMPORADA_SIMU;
delimiter //
CREATE PROCEDURE PROC_HISTORIAL_ULTIMO_PUESTO_POR_TEMPORADA_SIMU(IN nId_Temporada integer)
BEGIN
	declare num_jornadas integer;
    declare num_equipos integer;
    truncate PRIMEROS_LUGARES_POR_JORNADA;
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
		SELECT if(@rownum<num_equipos,@rownum:=@rownum+1,@rownum:=1) as posicion, nombre_equipo as nombre_equipo, partido_simulacion.fecha_partido_simulacion as fecha, puntos as puntos, partido_simulacion.id_jornada_partido_simulacion as jornada, dif
		from(
		select nombre_equipo,sum(if(anio_fin <= 1995, PG * 2 + PE,  PG * 3 + PE)) as 'Puntos' , sum(pj) as 'PJ', sum(pg) as 'PG', sum(PE) as 'PE', sum(PP) as 'PP', sum(GF) as 'GF', sum(GC) as 'GC', temporada, sum(GF)-sum(GC) as dif
		from (
				(
					select eqL.id_equipo, eqL.nombre_equipo, count(*) as 'PJ', sum(if(goles_local > goles_visitante, 1 , 0)) as 'PG', 
					sum(if(goles_local = goles_visitante, 1 , 0)) as 'PE', sum(if(goles_local < goles_visitante, 1 , 0)) as 'PP',
					sum(goles_local) as 'GF', sum(goles_visitante) as 'GC' , temporada.anio_fin, partido_simulacion.id_jornada_partido_simulacion, partido_simulacion.fecha_partido_simulacion, temporada.nombre_temporada as temporada
					from partido_simulacion,  equipo as eqL, temporada where temporada.id_temporada=nId_Temporada
					and eqL.id_equipo = partido_simulacion.id_equipo_local and partido_simulacion.id_temporada_partido_simulacion = temporada.id_temporada  and partido_simulacion.id_jornada_partido_simulacion <= num_jornadas
					group by eqL.id_equipo, partido_simulacion.id_jornada_partido_simulacion, partido_simulacion.fecha_partido_simulacion
				)
				union
				(
					select eqv.id_equipo, eqv.nombre_equipo, count(*) as 'PJ', sum(if(goles_local < goles_visitante, 1 , 0)) as 'PG', 
					sum(if(goles_local = goles_visitante, 1 , 0)) as 'PE', sum(if(goles_local > goles_visitante, 1 , 0)) as 'PP',
					sum(goles_visitante) as 'GF', sum(goles_local) as 'GC' , temporada.anio_fin, partido_simulacion.id_jornada_partido_simulacion, partido_simulacion.fecha_partido_simulacion, temporada.nombre_temporada as temporada
					from partido_simulacion,  equipo as eqV, temporada where temporada.id_temporada=nId_Temporada
					and eqv.id_equipo = partido_simulacion.id_equipo_visitante  and partido_simulacion.id_temporada_partido_simulacion = temporada.id_temporada and partido_simulacion.id_jornada_partido_simulacion <= num_jornadas
					group by eqv.id_equipo, partido_simulacion.id_jornada_partido_simulacion, partido_simulacion.fecha_partido_simulacion
				)
			) as algo group by id_equipo order by Puntos desc, dif desc
			) as algo2, partido_simulacion, temporada, (select @rownum:=0) r
			where partido_simulacion.id_jornada_partido_simulacion=num_jornadas and
			temporada.nombre_temporada=temporada and 
			partido_simulacion.id_temporada_partido_simulacion=temporada.id_temporada
            ) as algo3 where posicion=num_equipos group by posicion, nombre_equipo, fecha, puntos, jornada order by puntos asc, dif asc LIMIT 1;
			set num_jornadas=num_jornadas-1;
        end while;
        select * from PRIMEROS_LUGARES_POR_JORNADA group by posicion, nombre_equipo, fecha, puntos, jornada order by jornada asc;
END //
delimiter ;
-- ---------------------------------------------------------------------------
-- J

DROP VIEW IF EXISTS VIEW_INFORMACION_TEMPORADAS_SIMU;

CREATE VIEW VIEW_INFORMACION_TEMPORADAS_SIMU AS
	SELECT TEMPORADA.NOMBRE_TEMPORADA as 'Temporada', A1.TOTAL_TEMPORADA as 'Goles_Totales', 
    A2.EQUIPO 'Max_Anotador', MAX(A2.GOLES) as 'Goles_Max', A3.EQUIPO as 'Min_Anotador', MIN(A3.GOLES) as 'Goles_Min'
    FROM(
		SELECT partido_simulacion.ID_TEMPORADA_partido_simulacion, SUM(partido_simulacion.GOLES_LOCAL+partido_simulacion.GOLES_VISITANTE) as 'Total_Temporada' 
		FROM partido_simulacion
		GROUP BY partido_simulacion.ID_TEMPORADA_partido_simulacion, 'Total_Temporada'
    ) as A1,
    (
		SELECT ID_TEMPORADA_partido_simulacion, EQUIPO, MAX(TOTAL_GOLES) AS 'GOLES'
		FROM(
			SELECT ID_TEMPORADA_partido_simulacion, EQUIPO, SUM(GOLES) AS 'Total_Goles'
			FROM(
				SELECT partido_simulacion.ID_TEMPORADA_partido_simulacion, partido_simulacion.ID_JORNADA_partido_simulacion, EQUIPO.NOMBRE_EQUIPO as 'Equipo', partido_simulacion.GOLES_LOCAL AS 'Goles'
				FROM partido_simulacion, EQUIPO
                WHERE partido_simulacion.ID_EQUIPO_LOCAL=EQUIPO.ID_EQUIPO
				UNION
				SELECT partido_simulacion.ID_TEMPORADA_partido_simulacion, partido_simulacion.ID_JORNADA_partido_simulacion, EQUIPO.NOMBRE_EQUIPO as 'Equipo', partido_simulacion.GOLES_VISITANTE AS 'Goles'
				FROM partido_simulacion, EQUIPO
                WHERE partido_simulacion.ID_EQUIPO_VISITANTE=EQUIPO.ID_EQUIPO
			) AS T1
			GROUP BY ID_TEMPORADA_partido_simulacion, EQUIPO, 'Total_Goles'
		) AS K
		GROUP BY ID_TEMPORADA_partido_simulacion, EQUIPO, TOTAL_GOLES
		ORDER BY ID_TEMPORADA_partido_simulacion ASC, TOTAL_GOLES DESC
    ) as A2,
	(
		SELECT ID_TEMPORADA_partido_simulacion, EQUIPO, MIN(TOTAL_GOLES) AS 'GOLES'
		FROM(
			SELECT ID_TEMPORADA_partido_simulacion, EQUIPO, SUM(GOLES) AS 'Total_Goles'
			FROM(
				SELECT partido_simulacion.ID_TEMPORADA_partido_simulacion, partido_simulacion.ID_JORNADA_partido_simulacion, EQUIPO.NOMBRE_EQUIPO as 'Equipo', partido_simulacion.GOLES_LOCAL AS 'Goles'
				FROM partido_simulacion, EQUIPO
                WHERE partido_simulacion.ID_EQUIPO_LOCAL=EQUIPO.ID_EQUIPO
				UNION
				SELECT partido_simulacion.ID_TEMPORADA_partido_simulacion, partido_simulacion.ID_JORNADA_partido_simulacion, EQUIPO.NOMBRE_EQUIPO as 'Equipo', partido_simulacion.GOLES_VISITANTE AS 'Goles'
				FROM partido_simulacion, EQUIPO
                WHERE partido_simulacion.ID_EQUIPO_VISITANTE=EQUIPO.ID_EQUIPO
			) AS T1
			GROUP BY ID_TEMPORADA_partido_simulacion, EQUIPO, 'Total_Goles'
		) AS K
		GROUP BY ID_TEMPORADA_partido_simulacion, EQUIPO, TOTAL_GOLES
		ORDER BY ID_TEMPORADA_partido_simulacion ASC, TOTAL_GOLES ASC
    ) as A3, TEMPORADA, EQUIPO
    WHERE A1.ID_TEMPORADA_partido_simulacion=A2.ID_TEMPORADA_partido_simulacion AND 
    TEMPORADA.ID_TEMPORADA=A1.ID_TEMPORADA_partido_simulacion AND 
    A3.ID_TEMPORADA_partido_simulacion=A1.ID_TEMPORADA_partido_simulacion
    GROUP BY A1.ID_TEMPORADA_partido_simulacion;

-- ---------------------------------------------------------------------------


-- ██████╗░██████╗░░█████╗░██████╗░░█████╗░███╗░░██╗██████╗░░█████╗░
-- ██╔══██╗██╔══██╗██╔══██╗██╔══██╗██╔══██╗████╗░██║██╔══██╗██╔══██╗
-- ██████╔╝██████╔╝██║░░██║██████╦╝███████║██╔██╗██║██║░░██║██║░░██║
-- ██╔═══╝░██╔══██╗██║░░██║██╔══██╗██╔══██║██║╚████║██║░░██║██║░░██║
-- ██║░░░░░██║░░██║╚█████╔╝██████╦╝██║░░██║██║░╚███║██████╔╝╚█████╔╝
-- ╚═╝░░░░░╚═╝░░╚═╝░╚════╝░╚═════╝░╚═╝░░╚═╝╚═╝░░╚══╝╚═════╝░░╚════╝░

-- Probando Todo 
-- Iniciando simulacion 
call PROC_INICIAR_SIMULACION;


-- A  call PROC_TABLA_POSICIONES_A('%-2020', null , null);
call PROC_TABLA_POSICIONES_A_SIMU('%-2020', null , null);
-- B  select * from primeros4_por_temporada_B;
select * from primeros4_por_temporada_B_SIMU;
-- C
select  nombre_equipo , count(nombre_equipo) as veces_campeon from (
select  id_equipo, nombre_equipo, max(puntos) puntos from show_tabla_res_simu where nombre_temporada like '2%-%'
			group by id_temporada ) campeones group by id_equipo order by veces_campeon desc limit 5;
-- D  call PROC_DESCALIFICADO_TEMP_ANTERIOR_D(40);
call PROC_DESCALIFICADO_TEMP_ANTERIOR_D_SIMU(40);
-- E
/*
SELECT COUNT(*) AS NUM_VICTORIAS, EQUIPO_PERDEDOR AS VICTIMA FROM VICTIMA_FAVORITA
WHERE EQUIPO_GANADOR='Barcelona' group by EQUIPO_PERDEDOR order by NUM_VICTORIAS DESC LIMIT 1; 
*/
SELECT COUNT(*) AS NUM_VICTORIAS, EQUIPO_PERDEDOR AS VICTIMA FROM VICTIMA_FAVORITA_SIMU
WHERE EQUIPO_GANADOR='Barcelona' group by EQUIPO_PERDEDOR order by NUM_VICTORIAS DESC LIMIT 1; 

-- F   call PROC_POSICIONES_POR_TEMPORADA('Barcelona');
call PROC_POSICIONES_POR_TEMPORADA_SIMU('Barcelona');
-- G
SELECT E1.NOMBRE_EQUIPO AS EQUIPO1, partido_simulacion.GOLES_LOCAL, partido_simulacion.GOLES_VISITANTE, E2.NOMBRE_EQUIPO AS EQUIPO2, partido_simulacion.FECHA_partido_simulacion
FROM EQUIPO AS E1, EQUIPO AS E2, partido_simulacion
WHERE E1.ID_EQUIPO=partido_simulacion.ID_EQUIPO_LOCAL AND
E2.ID_EQUIPO=partido_simulacion.ID_EQUIPO_VISITANTE
GROUP BY EQUIPO1, partido_simulacion.GOLES_LOCAL, partido_simulacion.GOLES_VISITANTE, EQUIPO2
ORDER BY partido_simulacion.GOLES_LOCAL DESC, partido_simulacion.GOLES_VISITANTE ASC
LIMIT 1
;

-- H call PROC_HISTORIAL_PRIMER_PUESTO_POR_TEMPORADA(1);
call PROC_HISTORIAL_PRIMER_PUESTO_POR_TEMPORADA_SIMU(1);

-- I call PROC_HISTORIAL_ULTIMO_PUESTO_POR_TEMPORADA(17);
call PROC_HISTORIAL_ULTIMO_PUESTO_POR_TEMPORADA_SIMU(17);

-- J SELECT * FROM VIEW_INFORMACION_TEMPORADAS;
SELECT * FROM VIEW_INFORMACION_TEMPORADAS_SIMU;
-- K 
SELECT A1.Equipo as 'Mas_Victorias', Num_Victorias, A2.EQUIPO AS 'MAS_DERROTAS', NUM_DERROTAS, A3.EQUIPO AS 'MAS_EMPATES', NUM_EMPATES
FROM(
	SELECT Equipo, SUM(Victorias) AS 'Num_Victorias'
	FROM(
		SELECT EQUIPO.NOMBRE_EQUIPO AS 'Equipo', COUNT(partido_simulacion.ID_EQUIPO_LOCAL) AS 'Victorias'
		from partido_simulacion, EQUIPO
		WHERE partido_simulacion.GOLES_LOCAL>partido_simulacion.GOLES_VISITANTE AND EQUIPO.ID_EQUIPO=partido_simulacion.ID_EQUIPO_LOCAL
		GROUP BY partido_simulacion.ID_EQUIPO_LOCAL
		UNION 
		SELECT EQUIPO.NOMBRE_EQUIPO AS 'Equipo', COUNT(partido_simulacion.ID_EQUIPO_VISITANTE) AS 'Victorias'
		from partido_simulacion, EQUIPO
		WHERE partido_simulacion.GOLES_LOCAL<partido_simulacion.GOLES_VISITANTE AND EQUIPO.ID_EQUIPO=partido_simulacion.ID_EQUIPO_VISITANTE
		GROUP BY partido_simulacion.ID_EQUIPO_VISITANTE
	) AS T1
	GROUP BY Equipo
	ORDER BY Num_Victorias desc
	LIMIT 1
) AS A1,
(
	SELECT Equipo, SUM(Derrotas) AS 'Num_Derrotas'
	FROM(
		SELECT EQUIPO.NOMBRE_EQUIPO AS 'Equipo', COUNT(partido_simulacion.ID_EQUIPO_LOCAL) AS 'Derrotas'
		from partido_simulacion, EQUIPO
		WHERE partido_simulacion.GOLES_LOCAL<partido_simulacion.GOLES_VISITANTE AND EQUIPO.ID_EQUIPO=partido_simulacion.ID_EQUIPO_LOCAL
		GROUP BY partido_simulacion.ID_EQUIPO_LOCAL
		UNION 
		SELECT EQUIPO.NOMBRE_EQUIPO AS 'Equipo', COUNT(partido_simulacion.ID_EQUIPO_VISITANTE) AS 'Derrotas'
		from partido_simulacion, EQUIPO
		WHERE partido_simulacion.GOLES_LOCAL>partido_simulacion.GOLES_VISITANTE AND EQUIPO.ID_EQUIPO=partido_simulacion.ID_EQUIPO_VISITANTE
		GROUP BY partido_simulacion.ID_EQUIPO_VISITANTE
	) AS T1
	GROUP BY Equipo
	ORDER BY Num_Derrotas desc
	LIMIT 1
) AS A2,
(
	SELECT Equipo, SUM(Empates) AS 'Num_Empates'
	FROM(
		SELECT EQUIPO.NOMBRE_EQUIPO AS 'Equipo', COUNT(partido_simulacion.ID_EQUIPO_LOCAL) AS 'Empates'
		from partido_simulacion, EQUIPO
		WHERE partido_simulacion.GOLES_LOCAL=partido_simulacion.GOLES_VISITANTE AND EQUIPO.ID_EQUIPO=partido_simulacion.ID_EQUIPO_LOCAL
		GROUP BY partido_simulacion.ID_EQUIPO_LOCAL
		UNION 
		SELECT EQUIPO.NOMBRE_EQUIPO AS 'Equipo', COUNT(partido_simulacion.ID_EQUIPO_VISITANTE) AS 'Empates'
		from partido_simulacion, EQUIPO
		WHERE partido_simulacion.GOLES_LOCAL=partido_simulacion.GOLES_VISITANTE AND EQUIPO.ID_EQUIPO=partido_simulacion.ID_EQUIPO_VISITANTE
		GROUP BY partido_simulacion.ID_EQUIPO_VISITANTE
	) AS T1
	GROUP BY Equipo
	ORDER BY Num_Empates desc
	LIMIT 1
) AS A3
; 