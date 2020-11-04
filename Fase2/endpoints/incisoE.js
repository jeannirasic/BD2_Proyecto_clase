module.exports = (app, carga) => {
    app.post('/incisoE', (req, res) => {
        var equipo=req.body.equipo;
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
                        golesVisita: golesVisita
                    }
                    lista_partidos.push(partido);
                }
                var lista_contador = [];
                for (let i = 0; i < lista_partidos.length; i++) {
                    var victorias_por_equipos = {
                        ganador: "",
                        perdedor: "",
                        victorias: 1
                    }
                    //si el local es el ganador
                    if (lista_partidos[i].golesLocal > lista_partidos[i].golesVisita) {
                        victorias_por_equipos.ganador = lista_partidos[i].local;
                        victorias_por_equipos.perdedor = lista_partidos[i].visitante;
                    }
                    //si el visitante es el ganador
                    else if (lista_partidos[i].golesLocal < lista_partidos[i].golesVisita) {
                        victorias_por_equipos.perdedor = lista_partidos[i].local;
                        victorias_por_equipos.ganador = lista_partidos[i].visitante;
                    }
                    if (lista_contador.length == 0) {
                        lista_contador.push(victorias_por_equipos);
                    }
                    else {
                        //buscamos si ya existe
                        if (victorias_por_equipos.ganador == "" && victorias_por_equipos.perdedor == "") {

                        }
                        else {
                            var flag = false;
                            for (let j = 0; j < lista_contador.length; j++) {
                                if (lista_contador[j].ganador == victorias_por_equipos.ganador && lista_contador[j].perdedor == victorias_por_equipos.perdedor) {
                                    lista_contador[j].victorias++;
                                    flag = true;
                                    break;
                                }
                            }
                            //si no existe solo insertamos
                            if (flag == false) {
                                lista_contador.push(victorias_por_equipos);
                            }
                        }
                    }
                }
                //ordenamiento burbuja
                for (let i = 0; i < lista_contador.length; i++) {
                    for (let j = 0; j < lista_contador.length - 1; j++) {
                        if (lista_contador[j].victorias < lista_contador[j + 1].victorias) {
                            var temp = {
                                ganador: lista_contador[j].ganador,
                                perdedor: lista_contador[j].perdedor,
                                victorias: lista_contador[j].victorias
                            }
                            lista_contador[j].ganador=lista_contador[j+1].ganador
                            lista_contador[j].perdedor=lista_contador[j+1].perdedor
                            lista_contador[j].victorias=lista_contador[j+1].victorias
                            lista_contador[j+1].ganador=temp.ganador
                            lista_contador[j+1].perdedor=temp.perdedor
                            lista_contador[j+1].victorias=temp.victorias
                        }
                    }
                }
                for(let i=0;i<lista_contador.length;i++){
                    if(lista_contador[i].ganador==equipo){
                        res.send(lista_contador[i]);
                        break;
                    }
                }
                //res.status(200).send(golesVisita.toString());
            }
            else {
                res.send(err);
            }
        });
    });
}