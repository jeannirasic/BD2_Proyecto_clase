module.exports = (app, carga) => {
    app.get('/incisoK', (req, res) => {
        carga.find({}, function (err, response) {
            if (!err) {
                let lista_partidos = [];
                for (let i = 0; i < response.length; i++) {
                    var resultado = response[i].Resultado;
                    var spl=resultado.split("—")
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
                    lista_partidos.push(partido);
                }
                var lista_temporadas = [];
                for (let i = 0; i < lista_partidos.length; i++) {
                    if (lista_temporadas.length == []) {
                        lista_temporadas.push(lista_partidos[i].anio);
                    }
                    else {
                        var flag = false;
                        for (let j = 0; j < lista_temporadas.length; j++) {
                            if (lista_temporadas[j] == lista_partidos[i].anio) {
                                flag = true;
                                break;
                            }
                        }
                        if (flag == false) {
                            lista_temporadas.push(lista_partidos[i].anio);
                        }
                    }
                }
                var lista_tablas = [];
                for (let i = 0; i < lista_temporadas.length; i++) {
                    var tabla = {
                        temporada: lista_temporadas[i],
                        equipos: [],
                        numEquipos: 0,
                        numJornadas: 0,
                        golesTotales:0
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
                    lista_tablas.push(tabla);
                }
                //ahora vamos a obtener los resultados y vamos a ir rellenando los campos
                //vamos a posicionarnos en la temporada actual lista_tablas[i].temporada
                for (let i = 0; i < lista_tablas.length; i++) {
                    var puntos = {
                        victoria: 3,
                        empate: 1,
                        derrota: 0
                    }
                    if (i < 15) {
                        puntos.victoria = 2
                    }
                    for (let j = 0; j < lista_partidos.length; j++) {
                        for (let k = 1; k < lista_tablas[i].numJornadas + 1; k++) {
                            ronda = "Round " + k;
                            if (lista_partidos[j].anio == lista_tablas[i].temporada && lista_partidos[j].ronda == ronda) {
                                lista_tablas[i].golesTotales+=(lista_partidos[j].golesLocal+lista_partidos[j].golesVisita)
                                if (lista_partidos[j].golesLocal > lista_partidos[j].golesVisita) {
                                    for (let l = 0; l < lista_tablas[i].equipos.length; l++) {
                                        if (lista_tablas[i].equipos[l].equipo == lista_partidos[j].local) {
                                            lista_tablas[i].equipos[l].puntos += puntos.victoria
                                            lista_tablas[i].equipos[l].PJ++;
                                            lista_tablas[i].equipos[l].PG++;
                                            lista_tablas[i].equipos[l].GF += lista_partidos[j].golesLocal;
                                            lista_tablas[i].equipos[l].GC += lista_partidos[j].golesVisita;
                                            lista_tablas[i].equipos[l].DG = lista_tablas[i].equipos[l].GF - lista_tablas[i].equipos[l].GC;
                                            break;
                                        }
                                    }
                                    for (let l = 0; l < lista_tablas[i].equipos.length; l++) {
                                        if (lista_tablas[i].equipos[l].equipo == lista_partidos[j].visitante) {
                                            lista_tablas[i].equipos[l].PJ++;
                                            lista_tablas[i].equipos[l].PP++;
                                            lista_tablas[i].equipos[l].GF += lista_partidos[j].golesVisita;
                                            lista_tablas[i].equipos[l].GC += lista_partidos[j].golesLocal;
                                            lista_tablas[i].equipos[l].DG = lista_tablas[i].equipos[l].GF - lista_tablas[i].equipos[l].GC;
                                            break;
                                        }
                                    }
                                }
                                else if (lista_partidos[j].golesLocal < lista_partidos[j].golesVisita) {
                                    for (let l = 0; l < lista_tablas[i].equipos.length; l++) {
                                        if (lista_tablas[i].equipos[l].equipo == lista_partidos[j].visitante) {
                                            lista_tablas[i].equipos[l].puntos += puntos.victoria
                                            lista_tablas[i].equipos[l].PJ++;
                                            lista_tablas[i].equipos[l].PG++;
                                            lista_tablas[i].equipos[l].GF += lista_partidos[j].golesVisita;
                                            lista_tablas[i].equipos[l].GC += lista_partidos[j].golesLocal;
                                            lista_tablas[i].equipos[l].DG = lista_tablas[i].equipos[l].GF - lista_tablas[i].equipos[l].GC;
                                            break;
                                        }
                                    }
                                    for (let l = 0; l < lista_tablas[i].equipos.length; l++) {
                                        if (lista_tablas[i].equipos[l].equipo == lista_partidos[j].local) {
                                            lista_tablas[i].equipos[l].PJ++;
                                            lista_tablas[i].equipos[l].PP++;
                                            lista_tablas[i].equipos[l].GF += lista_partidos[j].golesLocal;
                                            lista_tablas[i].equipos[l].GC += lista_partidos[j].golesVisita;
                                            lista_tablas[i].equipos[l].DG = lista_tablas[i].equipos[l].GF - lista_tablas[i].equipos[l].GC;
                                            break;
                                        }
                                    }
                                }
                                else if (lista_partidos[j].golesLocal == lista_partidos[j].golesVisita) {
                                    for (let l = 0; l < lista_tablas[i].equipos.length; l++) {
                                        if (lista_tablas[i].equipos[l].equipo == lista_partidos[j].visitante) {
                                            lista_tablas[i].equipos[l].puntos += puntos.empate
                                            lista_tablas[i].equipos[l].PJ++;
                                            lista_tablas[i].equipos[l].PE++;
                                            lista_tablas[i].equipos[l].GF += lista_partidos[j].golesVisita;
                                            lista_tablas[i].equipos[l].GC += lista_partidos[j].golesLocal;
                                            lista_tablas[i].equipos[l].DG = lista_tablas[i].equipos[l].GF - lista_tablas[i].equipos[l].GC;
                                            break;
                                        }
                                    }
                                    for (let l = 0; l < lista_tablas[i].equipos.length; l++) {
                                        if (lista_tablas[i].equipos[l].equipo == lista_partidos[j].local) {
                                            lista_tablas[i].equipos[l].puntos += puntos.empate
                                            lista_tablas[i].equipos[l].PJ++;
                                            lista_tablas[i].equipos[l].PE++;
                                            lista_tablas[i].equipos[l].GF += lista_partidos[j].golesVisita;
                                            lista_tablas[i].equipos[l].GC += lista_partidos[j].golesLocal;
                                            lista_tablas[i].equipos[l].DG = lista_tablas[i].equipos[l].GF - lista_tablas[i].equipos[l].GC;
                                            break;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                var masVictorias=[];
                let sortBy = [{
                    prop: 'PG',
                    direction: -1
                }];
                for (let j = 0; j < lista_tablas.length; j++) {
                    lista_tablas[j].equipos.sort(function (a, b) {
                        let i = 0, result = 0;
                        while (i < sortBy.length && result == 0) {
                            result = sortBy[i].direction * (a[sortBy[i].prop] < b[sortBy[i].prop] ? -1 : (a[sortBy[i].prop] > b[sortBy[i].prop] ? 1 : 0));
                            i++;
                        }
                        return result;
                    })
                    for(let k=0;k<lista_tablas[j].equipos.length;k++){
                        var victoria_equipos={
                            Equipo:lista_tablas[j].equipos[k].equipo,
                            Victorias:lista_tablas[j].equipos[k].PG
                        }
                        var existe=false;
                        for(let l=0;l<masVictorias.length;l++){
                            if(masVictorias[l].Equipo==victoria_equipos.Equipo){
                                masVictorias[l].Victorias+=victoria_equipos.Victorias;
                                existe=true;
                                break;
                            }
                        }
                        if(existe==false){
                            masVictorias.push(victoria_equipos);
                        }
                    }
                    
                }

                var masDerrotas=[];
                sortBy[0].prop='PP';
                for (let j = 0; j < lista_tablas.length; j++) {
                    lista_tablas[j].equipos.sort(function (a, b) {
                        let i = 0, result = 0;
                        while (i < sortBy.length && result == 0) {
                            result = sortBy[i].direction * (a[sortBy[i].prop] < b[sortBy[i].prop] ? -1 : (a[sortBy[i].prop] > b[sortBy[i].prop] ? 1 : 0));
                            i++;
                        }
                        return result;
                    })
                    for(let k=0;k<lista_tablas[j].equipos.length;k++){
                        var derrota_equipos={
                            Equipo:lista_tablas[j].equipos[k].equipo,
                            Derrotas:lista_tablas[j].equipos[k].PP
                        }
                        var existe=false;
                        for(let l=0;l<masDerrotas.length;l++){
                            if(masDerrotas[l].Equipo==derrota_equipos.Equipo){
                                masDerrotas[l].Derrotas+=derrota_equipos.Derrotas;
                                existe=true;
                                break;
                            }
                        }
                        if(existe==false){
                            masDerrotas.push(derrota_equipos);
                        }
                    }
                    
                }

                var masEmpates=[];
                sortBy[0].prop='PE';
                for (let j = 0; j < lista_tablas.length; j++) {
                    lista_tablas[j].equipos.sort(function (a, b) {
                        let i = 0, result = 0;
                        while (i < sortBy.length && result == 0) {
                            result = sortBy[i].direction * (a[sortBy[i].prop] < b[sortBy[i].prop] ? -1 : (a[sortBy[i].prop] > b[sortBy[i].prop] ? 1 : 0));
                            i++;
                        }
                        return result;
                    })
                    for(let k=0;k<lista_tablas[j].equipos.length;k++){
                        var empate_equipos={
                            Equipo:lista_tablas[j].equipos[k].equipo,
                            Empates:lista_tablas[j].equipos[k].PE
                        }
                        var existe=false;
                        for(let l=0;l<masEmpates.length;l++){
                            if(masEmpates[l].Equipo==empate_equipos.Equipo){
                                masEmpates[l].Empates+=empate_equipos.Empates;
                                existe=true;
                                break;
                            }
                        }
                        if(existe==false){
                            masEmpates.push(empate_equipos);
                        }
                    }
                    
                }
                var resumen={
                    MasVictorias:[],
                    MasDerrotas:[],
                    MasEmpates:[]
                }
                sortBy[0].prop='Victorias';
                masVictorias.sort(function (a, b) {
                    let i = 0, result = 0;
                    while (i < sortBy.length && result == 0) {
                        result = sortBy[i].direction * (a[sortBy[i].prop] < b[sortBy[i].prop] ? -1 : (a[sortBy[i].prop] > b[sortBy[i].prop] ? 1 : 0));
                        i++;
                    }
                    return result;
                })
                resumen.MasVictorias.push(masVictorias[0]);
                sortBy[0].prop='Derrotas';
                masDerrotas.sort(function (a, b) {
                    let i = 0, result = 0;
                    while (i < sortBy.length && result == 0) {
                        result = sortBy[i].direction * (a[sortBy[i].prop] < b[sortBy[i].prop] ? -1 : (a[sortBy[i].prop] > b[sortBy[i].prop] ? 1 : 0));
                        i++;
                    }
                    return result;
                })
                resumen.MasDerrotas.push(masDerrotas[0]);
                sortBy[0].prop='Empates';
                masEmpates.sort(function (a, b) {
                    let i = 0, result = 0;
                    while (i < sortBy.length && result == 0) {
                        result = sortBy[i].direction * (a[sortBy[i].prop] < b[sortBy[i].prop] ? -1 : (a[sortBy[i].prop] > b[sortBy[i].prop] ? 1 : 0));
                        i++;
                    }
                    return result;
                })
                resumen.MasEmpates.push(masEmpates[0]);
                res.send(resumen);
            }
            else {
                res.send(err);
            }
        });
    });
}