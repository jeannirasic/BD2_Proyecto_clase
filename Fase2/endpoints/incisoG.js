module.exports = (app, carga) => {
    app.get('/incisoG', (req, res) => {
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
                        resultado:response[i].Resultado,
                        visitante: response[i].Visitante,
                        golesLocal: golesLocal,
                        golesVisita: golesVisita
                    }
                    lista_partidos.push(partido);
                }
                let sortBy = [{
                    prop: 'golesLocal',
                    direction: -1
                }, {
                    prop: 'golesVisita',
                    direction: -1
                }];
                lista_partidos.sort(function (a, b) {
                    let i = 0, result = 0;
                    while (i < sortBy.length && result == 0) {
                        result = sortBy[i].direction * (a[sortBy[i].prop].toString() < b[sortBy[i].prop].toString() ? -1 : (a[sortBy[i].prop].toString() > b[sortBy[i].prop].toString() ? 1 : 0));
                        i++;
                    }
                    return result;
                })
                lista_partidos.sort(function (a, b) {
                    let i = 0, result = 0;
                    while (i < sortBy.length && result == 0) {
                        result = sortBy[i].direction * (a[sortBy[i].prop] < b[sortBy[i].prop] ? -1 : (a[sortBy[i].prop] > b[sortBy[i].prop] ? 1 : 0));
                        i++;
                    }
                    return result;
                })
                res.status(200).send(lista_partidos[0]);
            }
            else {
                res.send(err);
            }
        });
    });
}