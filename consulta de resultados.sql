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
    		select   nombre_equipo,sum(if(anio_fin <= 1995, PG * 2 + PE,  PG * 3 + PE)) as 'Puntos' , sum(pj) as 'PJ', sum(pg) as 'PG', sum(PE) as 'PE', sum(PP) as 'PP', sum(GF) as 'GF', sum(GC) as 'GC', id_temporada, nombre_temporada from (
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
			)) as algo group by id_temporada ,  id_equipo order by id_temporada desc,  Puntos desc;
    elseif fecha is not null then 
    
    		select   nombre_equipo,sum(if(anio_fin <= 1995, PG * 2 + PE,  PG * 3 + PE)) as 'Puntos' , sum(pj) as 'PJ', sum(pg) as 'PG', sum(PE) as 'PE', sum(PP) as 'PP', sum(GF) as 'GF', sum(GC) as 'GC', id_temporada, nombre_temporada from (
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
			)) as algo group by id_temporada ,  id_equipo order by id_temporada desc, Puntos desc;
    else 
		select   nombre_equipo,sum(if(anio_fin <= 1995, PG * 2 + PE,  PG * 3 + PE)) as 'Puntos' , sum(pj) as 'PJ', sum(pg) as 'PG', sum(PE) as 'PE', sum(PP) as 'PP', sum(GF) as 'GF', sum(GC) as 'GC', id_temporada, nombre_temporada from (
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
		)) as algo group by id_temporada , id_equipo order by id_temporada desc,  Puntos desc;
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
select id_equipo,  nombre_equipo,sum(if(anio_fin <= 1995, PG * 2 + PE,  PG * 3 + PE)) as 'Puntos' , sum(pj) as 'PJ', sum(pg) as 'PG', sum(PE) as 'PE', sum(PP) as 'PP', sum(GF) as 'GF', sum(GC) as 'GC', id_temporada, nombre_temporada from (
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
		)) as algo group by id_temporada , id_equipo  order by id_temporada desc,   Puntos desc;

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




-- ░█▀▀█ █▀▀█ █▀▀█ █▀▀▄ █▀▀█ █▀▀█ 
-- ░█▄▄█ █▄▄▀ █──█ █▀▀▄ █▄▄█ █▄▄▀ 
-- ░█─── ▀─▀▀ ▀▀▀▀ ▀▀▀─ ▀──▀ ▀─▀▀

-- A
call PROC_TABLA_POSICIONES_A('%-2020', null , null);
-- B
select * from primeros4_por_temporada_B;
-- C
-- D 
-- E
-- F