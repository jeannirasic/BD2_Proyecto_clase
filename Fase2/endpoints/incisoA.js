module.exports = (app, carga) => {
    app.post('/incisoA', (req, res) => {
        var temporada=req.body.temporada;
        var condicion = 0; 

        var njornada = ""; 
        var nFecha = ""; 
        if(req.body.njornada){
            condicion = 1;
            njornada = req.body.njornada; 
        }
        if(req.body.fecha){
            /*
            var oDateOne = new Date();
            var oDateTwo = new Date();

            alert(oDateOne - oDateTwo === 0);
            alert(oDateOne - oDateTwo < 0);
            alert(oDateOne - oDateTwo > 0);
            */
           nFecha = req.body.nFecha; 
            condicion = 2; 
        }


        carga.find({"Anio": temporada}, function (err, response) {
            if (!err) {
                var equipo = []; 
                var equipores = []; 

                var pPG = 3; 
                var pPE = 1; 

                var anio_fin = temporada.split("-")[1];
                anio_fin = parseInt(anio_fin); 
                if( anio_fin <= 1995){
                    pPG = 2; 
                }



                for (var i = 0; i < response.length; i++) {

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
                        equipores.push(eq); 
                    }else{
                        var eq = equipores[nLocal];
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

                        equipores.push(eq); 
                    }else{
                        var eq = equipores[nVis];

                        eq.PJ++; 
                        eq.GC += golesLocal; 
                        eq.GF += golesVisita; 
                        eq.PG += golesLocal < golesVisita ? 1 : 0;
                        eq.PE += golesLocal == golesVisita ? 1 : 0;
                        eq.PP += golesLocal > golesVisita ? 1 : 0;
                    }
                }

                for(var a = 0; a < equipores.length; a++){
                    var eq = equipores[a]; 
                    eq.puntos = eq.PG * pPG + eq.PE * pPE; 
                    eq.dif = eq.GF - eq.GC; 
                }

                for(var a = 0; a < equipores.length; a++){
                    for(var b =0; b < equipores.length - 1; b++){
                        if(equipores[b].puntos < equipores[b + 1].puntos  || (equipores[b].puntos == equipores[b + 1].puntos && equipores[b].dif < equipores[b + 1].dif)){
                            var temp = equipores[b]; 
                            equipores[b] = equipores[b + 1];
                            equipores[b + 1] = temp;
                        }
                    }
                }


                equipo.push(anio_fin); 
                res.send(equipores);
            }
            else {
                res.send(err);
            }
        });
    });
}