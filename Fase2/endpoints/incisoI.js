module.exports = (app, carga) => {
    app.post('/incisoI', (req, res) => {
        var temporadaBusqueda = req.body.temporada;
        carga.find({}, function (err, response) {
            if (!err) {
                let lista_partidos = [];
                for (let i = 0; i < response.length; i++) {
                    var resultado = response[i].Resultado;
                    var spl = resultado.split("—")
                    var golesLocal = Number(spl[0]);
                    var golesVisita = Number(spl[1]);
                    var partido = {
                        local: response[i].Local,
                        visitante: response[i].Visitante,
                        golesLocal: golesLocal,
                        golesVisita: golesVisita,
                        ronda: response[i].Ronda,
                        fecha: response[i].Fecha,
                        anio: response[i].Anio
                    }
                    if (partido.anio == temporadaBusqueda) {
                        lista_partidos.push(partido);
                    }
                }
                var lista_temporadas = [];
                for (let i = 0; i < response.length; i++) {
                    if (lista_temporadas.length == []) {
                        lista_temporadas.push(response[i].Anio);
                    }
                    else {
                        var flag = false;
                        for (let j = 0; j < lista_temporadas.length; j++) {
                            if (lista_temporadas[j] == response[i].Anio) {
                                flag = true;
                                break;
                            }
                        }
                        if (flag == false) {
                            lista_temporadas.push(response[i].Anio);
                        }
                    }
                }

                var lista_tablas = [];
                for (let i = 0; i < lista_temporadas.length; i++) {
                    var tabla = {
                        temporada: lista_temporadas[i],
                        equipos: [],
                        numEquipos: 0,
                        numJornadas: 0
                    }
                    for (let j = 0; j < lista_partidos.length; j++) {
                        var equipo = {
                            posicion: 0,
                            equipo: lista_partidos[j].local,
                            puntos: 0,
                            PJ: 0,
                            PG: 0,
                            PE: 0,
                            PP: 0,
                            GF: 0,
                            GC: 0,
                            DG: 0
                        }
                        if (tabla.temporada == lista_partidos[j].anio) {
                            var flag = false;
                            for (let k = 0; k < tabla.equipos.length; k++) {
                                if (tabla.equipos[k].equipo == equipo.equipo) {
                                    flag = true;
                                    break;
                                }
                            }
                            if (flag == false) {
                                tabla.equipos.push(equipo);
                            }
                        }
                    }
                    tabla.numEquipos = tabla.equipos.length;
                    tabla.numJornadas = (tabla.equipos.length - 1) * 2;
                    if (tabla.temporada == temporadaBusqueda) {
                        lista_tablas.push(tabla);
                    }
                }
                //res.send(lista_tablas);
                var lista_ultimos_lugares=[];
                for (let i = 0; i < lista_tablas.length; i++) {
                    var puntos = {
                        victoria: 3,
                        empate: 1,
                        derrota: 0
                    }
                    for (let j = 0; j < lista_temporadas.length; j++) {
                        if (j < 15 && lista_tablas[i].temporada==lista_temporadas[j]) {
                            puntos.victoria = 2
                        }
                    }
                    //iteramos sobre cada jornada
                    for (let j = 1; j < lista_tablas[i].numJornadas + 1; j++) {
                        ronda = "Round " + j;
                        //ahora entramos a verificar cada partido
                        for (let k = 0; k < lista_partidos.length; k++) {
                            if (lista_partidos[k].ronda == ronda) {
                                if (lista_partidos[k].golesLocal > lista_partidos[k].golesVisita) {
                                    for (let l = 0; l < lista_tablas[i].equipos.length; l++) {
                                        if (lista_tablas[i].equipos[l].equipo == lista_partidos[k].local) {
                                            lista_tablas[i].equipos[l].puntos += puntos.victoria
                                            lista_tablas[i].equipos[l].PJ++;
                                            lista_tablas[i].equipos[l].PG++;
                                            lista_tablas[i].equipos[l].GF += lista_partidos[k].golesLocal;
                                            lista_tablas[i].equipos[l].GC += lista_partidos[k].golesVisita;
                                            lista_tablas[i].equipos[l].DG = lista_tablas[i].equipos[l].GF - lista_tablas[i].equipos[l].GC;
                                            break;
                                        }
                                    }
                                    for (let l = 0; l < lista_tablas[i].equipos.length; l++) {
                                        if (lista_tablas[i].equipos[l].equipo == lista_partidos[k].visitante) {
                                            lista_tablas[i].equipos[l].PJ++;
                                            lista_tablas[i].equipos[l].PP++;
                                            lista_tablas[i].equipos[l].GF += lista_partidos[k].golesVisita;
                                            lista_tablas[i].equipos[l].GC += lista_partidos[k].golesLocal;
                                            lista_tablas[i].equipos[l].DG = lista_tablas[i].equipos[l].GF - lista_tablas[i].equipos[l].GC;
                                            break;
                                        }
                                    }
                                }
                                else if (lista_partidos[k].golesLocal < lista_partidos[k].golesVisita) {
                                    for (let l = 0; l < lista_tablas[i].equipos.length; l++) {
                                        if (lista_tablas[i].equipos[l].equipo == lista_partidos[k].visitante) {
                                            lista_tablas[i].equipos[l].puntos += puntos.victoria
                                            lista_tablas[i].equipos[l].PJ++;
                                            lista_tablas[i].equipos[l].PG++;
                                            lista_tablas[i].equipos[l].GF += lista_partidos[k].golesVisita;
                                            lista_tablas[i].equipos[l].GC += lista_partidos[k].golesLocal;
                                            lista_tablas[i].equipos[l].DG = lista_tablas[i].equipos[l].GF - lista_tablas[i].equipos[l].GC;
                                            break;
                                        }
                                    }
                                    for (let l = 0; l < lista_tablas[i].equipos.length; l++) {
                                        if (lista_tablas[i].equipos[l].equipo == lista_partidos[k].local) {
                                            lista_tablas[i].equipos[l].PJ++;
                                            lista_tablas[i].equipos[l].PP++;
                                            lista_tablas[i].equipos[l].GF += lista_partidos[k].golesLocal;
                                            lista_tablas[i].equipos[l].GC += lista_partidos[k].golesVisita;
                                            lista_tablas[i].equipos[l].DG = lista_tablas[i].equipos[l].GF - lista_tablas[i].equipos[l].GC;
                                            break;
                                        }
                                    }
                                }
                                else if (lista_partidos[k].golesLocal == lista_partidos[k].golesVisita) {
                                    for (let l = 0; l < lista_tablas[i].equipos.length; l++) {
                                        if (lista_tablas[i].equipos[l].equipo == lista_partidos[k].visitante) {
                                            lista_tablas[i].equipos[l].puntos += puntos.empate
                                            lista_tablas[i].equipos[l].PJ++;
                                            lista_tablas[i].equipos[l].PE++;
                                            lista_tablas[i].equipos[l].GF += lista_partidos[k].golesVisita;
                                            lista_tablas[i].equipos[l].GC += lista_partidos[k].golesLocal;
                                            lista_tablas[i].equipos[l].DG = lista_tablas[i].equipos[l].GF - lista_tablas[i].equipos[l].GC;
                                            break;
                                        }
                                    }
                                    for (let l = 0; l < lista_tablas[i].equipos.length; l++) {
                                        if (lista_tablas[i].equipos[l].equipo == lista_partidos[k].local) {
                                            lista_tablas[i].equipos[l].puntos += puntos.empate
                                            lista_tablas[i].equipos[l].PJ++;
                                            lista_tablas[i].equipos[l].PE++;
                                            lista_tablas[i].equipos[l].GF += lista_partidos[k].golesVisita;
                                            lista_tablas[i].equipos[l].GC += lista_partidos[k].golesLocal;
                                            lista_tablas[i].equipos[l].DG = lista_tablas[i].equipos[l].GF - lista_tablas[i].equipos[l].GC;
                                            break;
                                        }
                                    }
                                }
                            }
                        }
                        let sortBy = [{
                            prop: 'puntos',
                            direction: 1
                        }, {
                            prop: 'DG',
                            direction: 1
                        }];
                        lista_tablas[i].equipos.sort(function (a, b) {
                            let w = 0, result = 0;
                            while (w < sortBy.length && result == 0) {
                                result = sortBy[w].direction * (a[sortBy[w].prop] < b[sortBy[w].prop] ? -1 : (a[sortBy[w].prop] > b[sortBy[w].prop] ? 1 : 0));
                                w++;
                            }
                            return result;
                        })
                        for (let k = 0; k < lista_tablas[i].equipos.length; k++) {
                            lista_tablas[i].equipos[k].posicion = k + 1;
                        }
                        var e={
                            round:ronda,
                            equipo:lista_tablas[i].equipos[0].equipo,
                            puntos:lista_tablas[i].equipos[0].puntos
                        }
                        lista_ultimos_lugares.push(e);
                    }
                }
                res.send(lista_ultimos_lugares);
            }
            else {
                res.send(err);
            }
        });
    });
}