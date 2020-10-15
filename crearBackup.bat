@echo off
set /P username= Usuario MySQL: 
set /P Password= Contrasenia MySQL: 
set /P dbBackup= Nombre de la Base de datos:  
set /P nombreBackup= Nombre del backup: 
"C:\Program Files\MySQL\MySQL Server 8.0\bin\mysqldump.exe" -R --default-character-set=utf8 --user=%username% --password=%password% %dbBackup% > %nombreBackup%.sql
pause