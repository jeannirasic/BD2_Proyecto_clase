-- ░█████╗░ Realizar un stored procedure que devuelva la tabla de 
-- ██╔══██╗ posiciones en cualquier momento. Como parámetro 
-- ███████║ debe recibir la temporada (id o año) y tener dos 
-- ██╔══██║ parámetros excluyentes, el número de jornada y la fecha.
-- ██║░░██║ Si recibe la fecha calcula la tabla a la fecha 
-- ╚═╝░░╚═╝ indicada aun así no haya terminado la jornada, y si 
-- recibe la jornada debe traer las posiciones hasta esa 
-- jornada. Si ambos están vacíos toma como si fuera el 
-- final de temporada.


-- id_temp(busca por id de temporada o temporada con un like para no ponerlo completo)
-- jornada (pasamos el numero de la jornada) 
-- fecha se pasa la fecha
-- si jornada no es null se busca por jornada aunque mandemos una fecha, si jornada es null y fecha no busca por fecha
-- de lo contrario busca como va actualmente en esa temporada

DROP procedure if exists PROC_TABLA_POSICIONES_A;
delimiter //
CREATE PROCEDURE PROC_TABLA_POSICIONES_A(IN id_temp varchar(500), IN jornada INT, IN fecha DATE)
BEGIN 
	if jornada is not null then 
    		select   nombre_equipo,sum(if(anio_fin <= 1995, PG * 2 + PE,  PG * 3 + PE)) as 'Puntos' , sum(pj) as 'PJ', sum(pg) as 'PG', sum(PE) as 'PE', sum(PP) as 'PP', sum(GF) as 'GF', sum(GC) as 'GC', id_temporada, nombre_temporada ,sum(GF)-sum(GC) as dif
            from (
			(
			select temporada.id_temporada, temporada.nombre_temporada, eqL.id_equipo, eqL.nombre_equipo, count(*) as 'PJ', sum(if(goles_local > goles_visitante, 1 , 0)) as 'PG', 
				sum(if(goles_local = goles_visitante, 1 , 0)) as 'PE', sum(if(goles_local < goles_visitante, 1 , 0)) as 'PP',
			 sum(goles_local) as 'GF', sum(goles_visitante) as 'GC' , temporada.anio_fin
			 from partido,  equipo as eqL, temporada where (id_temporada = ID_TEMP OR nombre_temporada  LIKE ID_TEMP)
			and eqL.id_equipo = partido.id_equipo_local and temporada.id_temporada = partido.id_temporada_partido 
            and partido.id_jornada_partido <= jornada
			group by id_temporada , eqL.id_equipo
			)
			union
			(
			select temporada.id_temporada, temporada.nombre_temporada, eqv.id_equipo, eqv.nombre_equipo, count(*) as 'PJ', sum(if(goles_local < goles_visitante, 1 , 0)) as 'PG', 
				sum(if(goles_local = goles_visitante, 1 , 0)) as 'PE', sum(if(goles_local > goles_visitante, 1 , 0)) as 'PP',
			 sum(goles_visitante) as 'GF', sum(goles_local) as 'GC' , temporada.anio_fin
			 from partido,  equipo as eqV, temporada where (id_temporada = ID_TEMP OR nombre_temporada  LIKE ID_TEMP)
			and eqv.id_equipo = partido.id_equipo_visitante  and temporada.id_temporada = partido.id_temporada_partido
            and partido.id_jornada_partido <= jornada
			group by id_temporada , eqv.id_equipo 
			)) as algo group by id_temporada ,  id_equipo order by id_temporada desc,  Puntos desc, dif desc;
    elseif fecha is not null then 
    		select   nombre_equipo,sum(if(anio_fin <= 1995, PG * 2 + PE,  PG * 3 + PE)) as 'Puntos' , sum(pj) as 'PJ', sum(pg) as 'PG', sum(PE) as 'PE', sum(PP) as 'PP', sum(GF) as 'GF', sum(GC) as 'GC', id_temporada, nombre_temporada, sum(GF)-sum(GC) as dif
            from (
			(
			select temporada.id_temporada, temporada.nombre_temporada, eqL.id_equipo, eqL.nombre_equipo, count(*) as 'PJ', sum(if(goles_local > goles_visitante, 1 , 0)) as 'PG', 
				sum(if(goles_local = goles_visitante, 1 , 0)) as 'PE', sum(if(goles_local < goles_visitante, 1 , 0)) as 'PP',
			 sum(goles_local) as 'GF', sum(goles_visitante) as 'GC' , temporada.anio_fin
			 from partido,  equipo as eqL, temporada where (id_temporada = ID_TEMP OR nombre_temporada  LIKE ID_TEMP)
			and eqL.id_equipo = partido.id_equipo_local and temporada.id_temporada = partido.id_temporada_partido 
            and partido.fecha_partido <= fecha
			group by id_temporada , eqL.id_equipo
			)
			union
			(
			select temporada.id_temporada, temporada.nombre_temporada, eqv.id_equipo, eqv.nombre_equipo, count(*) as 'PJ', sum(if(goles_local < goles_visitante, 1 , 0)) as 'PG', 
				sum(if(goles_local = goles_visitante, 1 , 0)) as 'PE', sum(if(goles_local > goles_visitante, 1 , 0)) as 'PP',
			 sum(goles_visitante) as 'GF', sum(goles_local) as 'GC' , temporada.anio_fin
			 from partido,  equipo as eqV, temporada where (id_temporada = ID_TEMP OR nombre_temporada  LIKE ID_TEMP)
			and eqv.id_equipo = partido.id_equipo_visitante  and temporada.id_temporada = partido.id_temporada_partido
            and partido.fecha_partido <= fecha
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
		 from partido,  equipo as eqL, temporada where (id_temporada = ID_TEMP OR nombre_temporada  LIKE ID_TEMP)
		and eqL.id_equipo = partido.id_equipo_local and temporada.id_temporada = partido.id_temporada_partido  
		group by id_temporada , eqL.id_equipo
		)
		union
		(
		select temporada.id_temporada, temporada.nombre_temporada, eqv.id_equipo, eqv.nombre_equipo, count(*) as 'PJ', sum(if(goles_local < goles_visitante, 1 , 0)) as 'PG', 
			sum(if(goles_local = goles_visitante, 1 , 0)) as 'PE', sum(if(goles_local > goles_visitante, 1 , 0)) as 'PP',
		 sum(goles_visitante) as 'GF', sum(goles_local) as 'GC' , temporada.anio_fin
		 from partido,  equipo as eqV, temporada where (id_temporada = ID_TEMP OR nombre_temporada  LIKE ID_TEMP)
		and eqv.id_equipo = partido.id_equipo_visitante  and temporada.id_temporada = partido.id_temporada_partido
		group by id_temporada , eqv.id_equipo 
		)) as algo group by id_temporada , id_equipo order by id_temporada desc,  Puntos desc, dif desc;
    end if;
	
END //
delimiter ;

-- call PROC_TABLA_POSICIONES_A('%-2020', null , null);
-- call PROC_TABLA_POSICIONES_A('%%', null , null);


-- ██████╗░  Vista que muestre los primeros 4 lugares de los últimos 40 
-- ██╔══██╗  años (TOP 10) columnas, puesto 1, puntos 1, puesto 2, 
-- ██████╦╝  puntos 2, puesto 3, puntos 3, puesto 4, puntos 4. 
-- ██╔══██╗  La vista tendrá entonces un total de 40 filas.
-- ██████╦╝
-- ╚═════╝░

/*
no se pudo de la siguiente manera por que son 40 jornadas mas la cantidad de equipos salian demasiados 
datos y tiraba error el order by
-- Concepto a seguir
select p1.nombre n1, p1.punteo p1,
p2.nombre n2, p2.punteo p2,
p3.nombre n3, p3.punteo p3,
p4.nombre n4, p4.punteo p4 from prueba p1, prueba p2, prueba p3, prueba p4
where p1.id != p2.id and p2.id !=  p3.id and p3.id != p4.id order by p1.punteo desc, p2.punteo desc, p3.punteo desc  
limit 1;
-- ========Intento uno============ 
-- select count(*) from show_tabla_res a, show_tabla_res b , show_tabla_res c , show_tabla_res d
-- where a.id_equipo != b.id_equipo and b.id_equipo != c.id_equipo and c.id_equipo != d.id_equipo and
-- a.id_temporada = b.id_temporada and b.id_temporada = c.id_temporada and c.id_temporada = d.id_temporada;
así que la solucion fue hacer primero la consulta del primer puesto, luego le añadimos el segundo y al ser solo dos tablas 
la union da solo 740 datos y no los 5279102 de la vez pasada. 
*/

-- Vista auxiliar

DROP VIEW IF EXISTS show_tabla_res ;
CREATE VIEW show_tabla_res AS
select id_equipo,  nombre_equipo,sum(if(anio_fin <= 1995, PG * 2 + PE,  PG * 3 + PE)) as 'Puntos' , sum(pj) as 'PJ', sum(pg) as 'PG', sum(PE) as 'PE', sum(PP) as 'PP', sum(GF) as 'GF', sum(GC) as 'GC', id_temporada, nombre_temporada , sum(GF)-sum(GC) as dif
from (
	-- select  * from (
		(
		select temporada.id_temporada, temporada.nombre_temporada, eqL.id_equipo, eqL.nombre_equipo, count(*) as 'PJ', sum(if(goles_local > goles_visitante, 1 , 0)) as 'PG', 
			sum(if(goles_local = goles_visitante, 1 , 0)) as 'PE', sum(if(goles_local < goles_visitante, 1 , 0)) as 'PP',
		 sum(goles_local) as 'GF', sum(goles_visitante) as 'GC' , temporada.anio_fin
		 from partido,  equipo as eqL, temporada where eqL.id_equipo = partido.id_equipo_local and 
         temporada.id_temporada = partido.id_temporada_partido  
		group by id_temporada, eqL.id_equipo
		)
		union
		(
		select temporada.id_temporada, temporada.nombre_temporada, eqv.id_equipo, eqv.nombre_equipo, count(*) as 'PJ', sum(if(goles_local < goles_visitante, 1 , 0)) as 'PG', 
			sum(if(goles_local = goles_visitante, 1 , 0)) as 'PE', sum(if(goles_local > goles_visitante, 1 , 0)) as 'PP',
		 sum(goles_visitante) as 'GF', sum(goles_local) as 'GC' , temporada.anio_fin
		 from partido,  equipo as eqV, temporada where  eqv.id_equipo = partido.id_equipo_visitante  and 
         temporada.id_temporada = partido.id_temporada_partido
		group by id_temporada, eqv.id_equipo 
		)) as algo group by id_temporada , id_equipo  order by id_temporada desc,   Puntos desc, dif desc;

-- Creando la vista

DROP VIEW IF EXISTS primeros4_por_temporada_B;
CREATE VIEW primeros4_por_temporada_B AS
select t4.nombre_temporada temporada, ta.puesto1, ta.puntos1, ta.puesto2, ta.puntos2, ta.puesto3, ta.puntos3, t4.nombre_equipo puesto4, t4.puntos puntos4 from (
	select ta.* , t3.id_equipo idp3, t3.nombre_equipo puesto3, t3.puntos puntos3 from (
		select t1.id_temporada, t1.id_equipo idp1, t1.nombre_equipo puesto1 , t1.puntos puntos1, t2.id_equipo idp2, t2.nombre_equipo puesto2, t2.puntos puntos2  from (
			select id_temporada, id_equipo, nombre_equipo, max(puntos) puntos from show_tabla_res
			group by id_temporada ) t1, show_tabla_res t2
		where t1.id_temporada = t2.id_temporada and t1.id_equipo != t2.id_equipo
		group by t1.id_temporada order by t1.id_temporada desc, t2.puntos desc
	) ta , show_tabla_res t3
	where ta.id_temporada = t3.id_temporada and (ta.idp1 != t3.id_equipo and ta.idp2 != t3.id_equipo)
	group by ta.id_temporada order by ta.id_temporada desc, t3.puntos desc ) ta , show_tabla_res t4
where ta.id_temporada = t4.id_temporada and (ta.idp1 != t4.id_equipo and ta.idp2 != t4.id_equipo and ta.idp3 != t4.id_equipo)
group by ta.id_temporada order by ta.id_temporada desc, t4.puntos desc;

-- Probando la vista 
select * from primeros4_por_temporada_B;

-- ░█████╗░  Consulta que muestre los equipos que ha ganado 
-- ██╔══██╗  la liga más veces en los últimos 20 años (TOP 5)
-- ██║░░╚═╝
-- ██║░░██╗
-- ╚█████╔╝
-- ░╚════╝░

-- select * from show_tabla_res where nombre_temporada like '2%-%';;
-- select * from temporada where nombre_temporada like '2%-%';

select  nombre_equipo , count(nombre_equipo) as veces_campeon from (
select  id_equipo, nombre_equipo, max(puntos) puntos from show_tabla_res where nombre_temporada like '2%-%'
			group by id_temporada ) campeones group by id_equipo order by veces_campeon desc limit 5;


-- ██████╗░   Realizar una stored procedure que muestre que equipos 
-- ██╔══██╗   descendieron y no aparecen en la temporada que se 
-- ██║░░██║   envíe por parámetro.
-- ██║░░██║
-- ██████╔╝
-- ╚═════╝░


DROP PROCEDURE IF EXISTS PROC_DESCALIFICADO_TEMP_ANTERIOR_D;
delimiter //
CREATE PROCEDURE PROC_DESCALIFICADO_TEMP_ANTERIOR_D(IN temporada varchar(500))
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
        from partido , equipo where (equipo.id_equipo = partido.id_equipo_local or equipo.id_equipo = partido.id_equipo_visitante)
        and id_temporada_partido = TEMP_ANT and (partido.id_equipo_local  not in (select id_equipo_local from partido where id_temporada_partido = TEMP_ACTUAL )
        and partido.id_equipo_visitante  not in (select id_equipo_visitante from partido where id_temporada_partido = TEMP_ACTUAL )) 
        group by id_equipo ;
    end if;
END //
delimiter ;

call PROC_DESCALIFICADO_TEMP_ANTERIOR_D(40);


-- ░█▀▀█ █▀▀█ █▀▀█ █▀▀▄ █▀▀█ █▀▀█ 
-- ░█▄▄█ █▄▄▀ █──█ █▀▀▄ █▄▄█ █▄▄▀ 
-- ░█─── ▀─▀▀ ▀▀▀▀ ▀▀▀─ ▀──▀ ▀─▀▀

-- A
call PROC_TABLA_POSICIONES_A('%-2020', null , null);
-- B
select * from primeros4_por_temporada_B;
-- C
select  nombre_equipo , count(nombre_equipo) as veces_campeon from (
select  id_equipo, nombre_equipo, max(puntos) puntos from show_tabla_res where nombre_temporada like '2%-%'
			group by id_temporada ) campeones group by id_equipo order by veces_campeon desc limit 5;
-- D 
call PROC_DESCALIFICADO_TEMP_ANTERIOR_D(40);
-- F
-- G
-- H 
-- I 
-- J 
-- K 
