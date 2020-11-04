module.exports = (app, carga) => {
    app.post('/incisoB', (req, res) => {
        carga.find({}, function (err, response) {
            if (!err) {
                
                var temporadas = [];
                var temporadares = []; 
                
              




                for (var i = 0; i < response.length; i++) {


                    var nTemporada = temporadas.indexOf(response[i].Anio);

                    if(nTemporada == -1){
                        var tempo = {
                            temporada: response[i].Anio,
                            equipo : [],
                            posiciones : [],
                        }

                        temporadares.push(tempo); 
                        temporadas.push(response[i].Anio);
                        nTemporada = temporadas.indexOf(response[i].Anio);
                    }

                    var temporada = temporadares[nTemporada].temporada;
                    var equipo = temporadares[nTemporada].equipo; 
                    var posiciones = temporadares[nTemporada].posiciones; 

                    var pPG = 3; 
                    var pPE = 1; 
    
                    var anio_fin = temporada.split("-")[1];
                    anio_fin = parseInt(anio_fin); 
                    if( anio_fin <= 1995){
                        pPG = 2; 
                    }
    


                    var local=  response[i].Local;
                    var vis =  response[i].Visitante;

                    var resultado = response[i].Resultado;
                    var spl=resultado.split("—")
                    var golesLocal = Number(spl[0]);
                    var golesVisita = Number(spl[1]);


                    var nLocal  = equipo.indexOf(local);
                    var nVis = equipo.indexOf(vis);
                    if(nLocal == -1){
                        equipo.push(local); 
                        
                        var eq = {
                            equipo: local, 
                            puntos: 0, 
                            PJ : 1, 
                            PG : golesLocal > golesVisita ? 1 : 0,
                            PE : golesLocal == golesVisita ? 1 : 0, 
                            PP : golesLocal < golesVisita ? 1 : 0,
                            GF : golesLocal,
                            GC : golesVisita,
                            dif: 0
                        }
                        posiciones.push(eq); 
                    }else{
                        var eq = posiciones[nLocal];
                        eq.PJ++; 
                        eq.GC += golesVisita; 
                        eq.GF += golesLocal; 
                        eq.PG += golesLocal > golesVisita ? 1 : 0;
                        eq.PE += golesLocal == golesVisita ? 1 : 0;
                        eq.PP += golesLocal < golesVisita ? 1 : 0;
                    }

                    if(nVis == -1){
                        equipo.push(vis); 
                        var eq = {
                            equipo: vis, 
                            puntos: 0, 
                            PJ : 1, 
                            PG : golesLocal < golesVisita ? 1 : 0,
                            PE : golesLocal == golesVisita ? 1 : 0, 
                            PP : golesLocal > golesVisita ? 1 : 0,
                            GC : golesLocal,
                            GF : golesVisita,
                            dif: 0
                        }

                        posiciones.push(eq); 
                    }else{
                        var eq = posiciones[nVis];

                        eq.PJ++; 
                        eq.GC += golesLocal; 
                        eq.GF += golesVisita; 
                        eq.PG += golesLocal < golesVisita ? 1 : 0;
                        eq.PE += golesLocal == golesVisita ? 1 : 0;
                        eq.PP += golesLocal > golesVisita ? 1 : 0;
                    }
                }

                for(var b = 0; b < temporadares.length; b++){
                    var posiciones = temporadares[b].posiciones;
                    delete temporadares[b].equipo;  
                    for(var a = 0; a < posiciones.length; a++){
                        var eq = posiciones[a]; 
                        eq.puntos = eq.PG * pPG + eq.PE * pPE; 
                        eq.dif = eq.GF - eq.GC; 
                    }
                }

                for(var c = 0; c < temporadares.length; c++){
                    var posiciones = temporadares[c].posiciones; 
                    for(var a = 0; a < posiciones.length; a++){
                        for(var b =0; b < posiciones.length - 1; b++){
                            if(posiciones[b].puntos < posiciones[b + 1].puntos  || (posiciones[b].puntos == posiciones[b + 1].puntos && posiciones[b].dif < posiciones[b + 1].dif)){
                                var temp = posiciones[b]; 
                                posiciones[b] = posiciones[b + 1];
                                posiciones[b + 1] = temp;
                            }
                        }
                    }
                }


                for(var b = 0; b < temporadares.length; b++){
                    var posiciones = temporadares[b].posiciones;
                    var pos2 = []; 
                    for(var a = 0; a < 4; a++){
                        var equipo = {
                            equipo : posiciones[a].equipo,
                            punteo : posiciones[a].puntos
                        }
                        pos2.push(equipo); 
                    }
                    temporadares[b].posiciones = pos2; 
                }
                


                res.send(temporadares);
            }
            else {
                res.send(err);
            }
        });
    });
}