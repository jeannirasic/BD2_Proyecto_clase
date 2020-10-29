module.exports = (app,carga) => {
    app.get('/prueba', (req, res) => {
        carga.find({},function(err,response){
            if(!err){
                res.send(response);
            }
            else{
                res.send(err);
            }
        });
    });
}