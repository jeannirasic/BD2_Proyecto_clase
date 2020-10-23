@echo off
set /P username= Usuario MySQL: 
set /P Password= Contrasenia MySQL: 
set /P dbBackup= Ubicacion Backup:  
set /P nombredbdestino= Nombre Base de Datos Destino: 
"C:\Program Files\MySQL\MySQL Server 8.0\bin\mysqladmin.exe" --user=%username% --password=%password% create %nombredbdestino%
"C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" --user=%username% --password=%password% %nombredbdestino% < %dbBackup%.sql
PAUSE