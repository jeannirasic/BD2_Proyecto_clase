'use strict';
const fs = require('fs');
const express = require('express');
const bodyParser = require('body-parser');
let cors = require('cors');
const app = express();
//const http = require('http').Server(app);
app.use(bodyParser.json({ limit: '50mb', extended: true }));
app.use(bodyParser.urlencoded({ limit: '50mb', extended: true }));
app.use(cors());
const mongoose = require('mongoose');

//Estableciendo conección a mongodb atlas
const uri = 'mongodb+srv://erick:admin123@clusterbd2.2u9r0.mongodb.net/BD2_Clase';
mongoose.connect(uri, {
    useNewUrlParser: true, 
    useCreateIndex: true, 
    useUnifiedTopology: true
})
//SCHEMA DE CARGA CON LA COLECCION
const cargaSchema = new mongoose.Schema({
    _id:{type:String},
    Ronda:{type:String},
    Fecha:{type:String},
    Local:{type:String},
    Resultado:{type:String},
    Visitante:{type:String},
    Anio:{type:String},
    LocBien:{type:String},
},{collection: "CARGA"});
const carga= mongoose.model("Carga",cargaSchema);

//---------------------------------------------------ENDPOINTS------------------------------------------------------------
const prueba = require('./endpoints/prueba')(app,carga);


app.listen(3000, () => console.log('escuchando en puerto 3000'));