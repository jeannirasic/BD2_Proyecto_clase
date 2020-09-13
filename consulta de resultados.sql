/*select * from partido; 
select * from equipo; 
select * from temporada; 

select eqL.nombre_equipo , goles_local, eqV.nombre_equipo, goles_visitante from partido, equipo as eqv, equipo as eqL where id_temporada_partido = 1
and eqv.id_equipo = partido.id_equipo_visitante and eqL.id_equipo = partido.id_equipo_local;*/

-- Consulta por año yqlg
select  nombre_equipo,sum(if(anio_fin <= 1995, PG * 2 + PE,  PG * 3 + PE)) as 'Puntos' , sum(pj) as 'PJ', sum(pg) as 'PG', sum(PE) as 'PE', sum(PP) as 'PP', sum(GF) as 'GF', sum(GC) as 'GC' from (
(
select eqL.id_equipo, eqL.nombre_equipo, count(*) as 'PJ', sum(if(goles_local > goles_visitante, 1 , 0)) as 'PG', 
	sum(if(goles_local = goles_visitante, 1 , 0)) as 'PE', sum(if(goles_local < goles_visitante, 1 , 0)) as 'PP',
 sum(goles_local) as 'GF', sum(goles_visitante) as 'GC' , temporada.anio_fin
 from partido,  equipo as eqL, temporada where id_temporada_partido = 1
and eqL.id_equipo = partido.id_equipo_local and temporada.id_temporada = partido.id_temporada_partido  
group by eqL.id_equipo
)
union
(
select eqv.id_equipo, eqv.nombre_equipo, count(*) as 'PJ', sum(if(goles_local < goles_visitante, 1 , 0)) as 'PG', 
	sum(if(goles_local = goles_visitante, 1 , 0)) as 'PE', sum(if(goles_local > goles_visitante, 1 , 0)) as 'PP',
 sum(goles_visitante) as 'GF', sum(goles_local) as 'GC' , temporada.anio_fin
 from partido,  equipo as eqV, temporada where id_temporada_partido = 1
and eqv.id_equipo = partido.id_equipo_visitante  and temporada.id_temporada = partido.id_temporada_partido
group by eqv.id_equipo 
)) as algo group by id_equipo order by Puntos desc;


