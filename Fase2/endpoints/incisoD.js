module.exports = (app, carga) => {
    app.post('/incisoD', (req, res) => {
        var temporada=req.body.temporada;


        console.log(temporada); 

        carga.find({}, function (err, response) {
            if (!err) {
                
                var equipo = []; 
                var equipoFalta = []; 
                var esElPrimero = false; 
                var tempAnterior = ""; 

                for(var a = 0; a < response.length; a++){
                    if(temporada == response[a].Anio){
                        if(a == 0){
                            esElPrimero = true; 
                            break;
                        }
                        tempAnterior = response[a - 1].Anio; 
                        break; 
                    }
                }

                

                if(esElPrimero){
                    var aux = []; 
                    var algo = {msg: "No se tiene informacion de la temporada anterior"}
                    aux.push(algo); 
                    res.send(aux);
                }else{
                    console.log(tempAnterior); 


                    for (var i = response.length - 1; i >= 0; i--) {
                        var local=  response[i].Local;
                        var vis =  response[i].Visitante;
                        var nLocal  = equipo.indexOf(local);
                        var nVis = equipo.indexOf(vis);
                       
                        if(response[i].Anio == temporada ){
                            if(nLocal == -1){
                                equipo.push(local); 
                            }
                            if(nVis == -1){
                                equipo.push(vis); 
                            }
                        }else if(response[i].Anio == tempAnterior){
                            if(nLocal == -1){
                                if(equipoFalta.indexOf(local) == -1){
                                    equipoFalta.push(local); 
                                }
                            }
                            if(nVis == -1){
                                if(equipoFalta.indexOf(vis) == -1){
                                    equipoFalta.push(vis); 
                                }
                            }    
                        }
                    }

                    var data = {
                        temporada : temporada,
                        tempAnterior: tempAnterior,
                        equipos: equipoFalta
                    }

                    res.send(data);
                }
            }
            else {
                res.send(err);
            }
        });
    });
}