-- id_temp(busca por id de temporada o temporada con un like para no ponerlo completo)
-- jornada (pasamos el numero de la jornada) 
-- fecha se pasa la fecha
-- si jornada no es null se busca por jornada aunque mandemos una fecha, si jornada es null y fecha no busca por fecha
-- de lo contrario busca como va actualmente en esa temporada
call PROC_TABLA_POSICIONES_A('%-2020', 5 , null);
DROP procedure if exists PROC_TABLA_POSICIONES_A;
delimiter //
CREATE PROCEDURE PROC_TABLA_POSICIONES_A(IN id_temp varchar(500), IN jornada INT, IN fecha DATE)
BEGIN 
	if jornada is not null then 
    		select   nombre_equipo,sum(if(anio_fin <= 1995, PG * 2 + PE,  PG * 3 + PE)) as 'Puntos' , sum(pj) as 'PJ', sum(pg) as 'PG', sum(PE) as 'PE', sum(PP) as 'PP', sum(GF) as 'GF', sum(GC) as 'GC', id_temporada, nombre_temporada from (
			(
			select temporada.id_temporada, temporada.nombre_temporada, eqL.id_equipo, eqL.nombre_equipo, count(*) as 'PJ', sum(if(goles_local > goles_visitante, 1 , 0)) as 'PG', 
				sum(if(goles_local = goles_visitante, 1 , 0)) as 'PE', sum(if(goles_local < goles_visitante, 1 , 0)) as 'PP',
			 sum(goles_local) as 'GF', sum(goles_visitante) as 'GC' , temporada.anio_fin
			 from partido,  equipo as eqL, temporada where (id_temporada = ID_TEMP OR nombre_temporada  LIKE ID_TEMP)
			and eqL.id_equipo = partido.id_equipo_local and temporada.id_temporada = partido.id_temporada_partido 
            and partido.id_jornada_partido <= jornada
			group by eqL.id_equipo
			)
			union
			(
			select temporada.id_temporada, temporada.nombre_temporada, eqv.id_equipo, eqv.nombre_equipo, count(*) as 'PJ', sum(if(goles_local < goles_visitante, 1 , 0)) as 'PG', 
				sum(if(goles_local = goles_visitante, 1 , 0)) as 'PE', sum(if(goles_local > goles_visitante, 1 , 0)) as 'PP',
			 sum(goles_visitante) as 'GF', sum(goles_local) as 'GC' , temporada.anio_fin
			 from partido,  equipo as eqV, temporada where (id_temporada = ID_TEMP OR nombre_temporada  LIKE ID_TEMP)
			and eqv.id_equipo = partido.id_equipo_visitante  and temporada.id_temporada = partido.id_temporada_partido
            and partido.id_jornada_partido <= jornada
			group by eqv.id_equipo 
			)) as algo group by id_equipo order by Puntos desc;
    elseif fecha is not null then 
    
    		select   nombre_equipo,sum(if(anio_fin <= 1995, PG * 2 + PE,  PG * 3 + PE)) as 'Puntos' , sum(pj) as 'PJ', sum(pg) as 'PG', sum(PE) as 'PE', sum(PP) as 'PP', sum(GF) as 'GF', sum(GC) as 'GC', id_temporada, nombre_temporada from (
			(
			select temporada.id_temporada, temporada.nombre_temporada, eqL.id_equipo, eqL.nombre_equipo, count(*) as 'PJ', sum(if(goles_local > goles_visitante, 1 , 0)) as 'PG', 
				sum(if(goles_local = goles_visitante, 1 , 0)) as 'PE', sum(if(goles_local < goles_visitante, 1 , 0)) as 'PP',
			 sum(goles_local) as 'GF', sum(goles_visitante) as 'GC' , temporada.anio_fin
			 from partido,  equipo as eqL, temporada where (id_temporada = ID_TEMP OR nombre_temporada  LIKE ID_TEMP)
			and eqL.id_equipo = partido.id_equipo_local and temporada.id_temporada = partido.id_temporada_partido 
            and partido.fecha_partido <= fecha
			group by eqL.id_equipo
			)
			union
			(
			select temporada.id_temporada, temporada.nombre_temporada, eqv.id_equipo, eqv.nombre_equipo, count(*) as 'PJ', sum(if(goles_local < goles_visitante, 1 , 0)) as 'PG', 
				sum(if(goles_local = goles_visitante, 1 , 0)) as 'PE', sum(if(goles_local > goles_visitante, 1 , 0)) as 'PP',
			 sum(goles_visitante) as 'GF', sum(goles_local) as 'GC' , temporada.anio_fin
			 from partido,  equipo as eqV, temporada where (id_temporada = ID_TEMP OR nombre_temporada  LIKE ID_TEMP)
			and eqv.id_equipo = partido.id_equipo_visitante  and temporada.id_temporada = partido.id_temporada_partido
            and partido.fecha_partido <= fecha
			group by eqv.id_equipo 
			)) as algo group by id_equipo order by Puntos desc;
		
    
    
    
    else 
		select   nombre_equipo,sum(if(anio_fin <= 1995, PG * 2 + PE,  PG * 3 + PE)) as 'Puntos' , sum(pj) as 'PJ', sum(pg) as 'PG', sum(PE) as 'PE', sum(PP) as 'PP', sum(GF) as 'GF', sum(GC) as 'GC', id_temporada, nombre_temporada from (
	-- select  * from (
		(
		select temporada.id_temporada, temporada.nombre_temporada, eqL.id_equipo, eqL.nombre_equipo, count(*) as 'PJ', sum(if(goles_local > goles_visitante, 1 , 0)) as 'PG', 
			sum(if(goles_local = goles_visitante, 1 , 0)) as 'PE', sum(if(goles_local < goles_visitante, 1 , 0)) as 'PP',
		 sum(goles_local) as 'GF', sum(goles_visitante) as 'GC' , temporada.anio_fin
		 from partido,  equipo as eqL, temporada where (id_temporada = ID_TEMP OR nombre_temporada  LIKE ID_TEMP)
		and eqL.id_equipo = partido.id_equipo_local and temporada.id_temporada = partido.id_temporada_partido  
		group by eqL.id_equipo
		)
		union
		(
		select temporada.id_temporada, temporada.nombre_temporada, eqv.id_equipo, eqv.nombre_equipo, count(*) as 'PJ', sum(if(goles_local < goles_visitante, 1 , 0)) as 'PG', 
			sum(if(goles_local = goles_visitante, 1 , 0)) as 'PE', sum(if(goles_local > goles_visitante, 1 , 0)) as 'PP',
		 sum(goles_visitante) as 'GF', sum(goles_local) as 'GC' , temporada.anio_fin
		 from partido,  equipo as eqV, temporada where (id_temporada = ID_TEMP OR nombre_temporada  LIKE ID_TEMP)
		and eqv.id_equipo = partido.id_equipo_visitante  and temporada.id_temporada = partido.id_temporada_partido
		group by eqv.id_equipo 
		)) as algo group by id_equipo order by Puntos desc;
    end if;
	
END //
delimiter ;
-- where (id_temporada = ID_TEMP OR nombre_temporada  LIKE ID_TEMP)
