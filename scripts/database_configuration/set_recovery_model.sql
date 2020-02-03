USE master;

ALTER DATABASE /* DATABASE NAME HERE */ SET RECOVERY SIMPLE ;
SELECT name, recovery_model,recovery_model_desc FROM sys.databases 
