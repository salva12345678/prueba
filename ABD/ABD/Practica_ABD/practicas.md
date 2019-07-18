# PRACTICAS ABD.

## 4.Estructura  del  Almacenamiento  de  Oracle.


##EJECUTAR COSAS EN SQLPLUS
@DESCARGAS/ulcase1.sql


## Tablespaces.

1.Crear la carpeta /databases/app/ejercicios/data.

    mkdir /databases/app/ejercicios
    mkdir /databases/app/ejercicios/data

2.Crear los siguientes tablespaces permanentes, con un único fichero de datos de 50 M cada uno en la carpeta del paso 1:

    a) DATA con extensiones mínimas de 500K, incluyendo la inicial.

        create tablespace data datafile '/databases/app/ejercicios/data/data01.dbf' size 50 m minimum extent 500 k default storage (initial 500 k next 500k);

    b) RONLY de sólo lectura (realizar lo necesario). Intentar crear una tabla en dicho tablespace.

        create tablespace ronly datafile '/databases/app/ejercicios/datafiles/ronly01.dbf' size 10m minimum extent 500K default storage (initial 500k) offline;
        alter tablespace ronly online;
        alter tablespace ronly read only;
        create tablespace ronly  datafile '/databases/app/ejercicios/data/ronly01.dbf' size 50 m;

3.Ampliar a 100 M el tamaño de DATA01.dbf.

        alter database datafile '/databases/app/ejercicios/data/data01.dbf' resize 100 m;

4.Crear una tabla llamada prueba_data en DATA.

        create table prueba_data (a number) tablespace data;

5.Cambiar el nombre al datafile de RONLY;

        El profesor se ha creado una copia donde /databases/app/ejercicios/data/ de ronly01.dbf y la copia se llama ronly001.dbf.
        cp ronly01.dbf ronly001.dbf
        alter tablespace data offline;
        alter tablespace ronly rename datafile '/databases/app/ejercicios/data/ronly01.dbf' to '/data/app/ejercicios/data/ronly001.dbf';
        alter tablespace ronly online
        rm ronly001.dbf (en el directorio /databases/app/ejercicios/data)


6.Eliminar el tablespace RONLY y borrar sus ficheros.

        drop tablespace data including contents;
        drop tablespace ronly;
        Hay que borrar manualmente los ficheros al final


## Segmentos, Extensiones y Bloques.

1.Identificar los distintos tipos de segmentos que hay en la BD.

        select distinct segment_type from dba_segments;
        select segment_name ,extents ,max_entents from dba_segments;
        select extents,max_entents,extents/max_entents from dba_extents where extents =(select max(extents) from dba_segments);
        select max(extents) from dba_segments;

2.Averiguar qué segmentos tienen ocupadas más del 30% de sus extensiones.

        select segment_name from  dba_segments where extents > 0.3*max_entents;

3.¿Qué ficheros contienen datos de la tabla prueba_data? (dba_extents-dba_data_files).

        select segment_name, segment_type, file_name from dba_extents, dba_data_files where dba_extents.file_id=dba_data_files.file_id and segment_name='EMP';
        describe dba_extents;
        select segment_name from dba_segments where tablespace_name='DATA';

## Usuario

1.Crear el usuario Bob con password ALONG, asegurando que no utilice espacio en SYSTEM y que no sobrepase 1M en el tablespace USERS. Dejar que se conecte.

        create user bob identified by ALONG default tablespace users quota 1 m on users;
        grant connect to bob;

        En otra terminal:
              sqlplus bob@oradba

        alter users bob quota 0 m on system;      

2.Crear el usuario Kay con password Mary asegurando que los objetos y el espacio temporal necesarios no sean de SYSTEM. Asignar cuota ilimitada en el tb de datos.

        create user kay identified by Mary default tablespace users quota unlimited on users quota 0 m on system;


3.Copiar la tabla EMP del usuario SCOTT en la cuenta de Kay.

        create user SCOTT identified by tiger default tablespace users temporary tablespace temp quota unlimited on system;
        grant connect ,resource to scott;
        create table kay.emp as select * from scott.emp;

4.Mostar la información sobre Bob y Kay y sobre sus límites de espacio en los tablespaces correspondientes.

        select username, tablespace_name, max_bytes from dba_ts_quotas where username in ('BOB', 'KAY');


## Perfiles.

1.Crear un perfil “nuevo” que permita dos sesiones concurrentes por usuario y un máx. de un minuto de inactividad. Asignárselo a Bob.

CREATE PROFILE nuevo LIMIT SESSION_PER_USER 2 IDLE_TIME 1;

ALTER USER Bob PROFILE nuevo;

2.Conectarse como Bob más de dos veces.(Con dos terminales en plan concurrente)
Te metes desde otra terminal y pones:
sqlplus Bob
y la contraseña.

ALTER SYSTEM SET RESOURCE_LIMIT=TRUE;

3.Asignar los siguientes límites al perfil nuevo (Al final a default no).
a)Bloquear la cuenta tras dos intentos fallidos.
b)La password expira a los 30 dias
c)La password tiene un periodo de gracia de 5 días para ser cambiada.

ALTER PROFILE nuevo LIMIT FAILED_LOGIN_ATTEMPTS 2 PASSWORD_LIFE_TIME 30 PASSWORD_GRACE_TIME 5;

select * from dba_profiles where profile='DEFAULT' and resource_type='PASSWORD';

4.Alterar el perfil por defecto para que la password no expire nunca
alter profile default limit password_life_time unlimited;


## PRIVILEGIOS


1.Permitir a kay conectarse a la BD y crear tablas propias

grant connect ,resource to Kay;

2.Conectar como kay y crear la tabla DEPT (ejecutar script ulcase1.sql)

@DESCARGAS/ulcase1.sql



3.Conectar como sys y rellenar las tablas de kay con las de scott.EMP y scott.DEPT

desde sys creas una tablas a kay
create table kay.emp as select * from scott.emp;



4.Conceder a Bob (como sys) el privilegio de consultar la tabla EMP de Kay. Hacerlo como Kay y conceder grant option.

conectarme como sys
slect user from dual

grant select on kay.emp to bob;

para probarlo te vas a otra ventana bob
along contraseña

desde bob
select * from kay.EMP

select * from kay.dept //no existe para ti


me conecto como kay

grant select on select on emp to bob with grant option;

si me vuelvo a bob:


5.Consultar los cambios en el catálogo.

con sys
select view name from dba_view where dba_

describe dba_tba_privs

select grantee, privilege,grantable from dba_tba_privs where owner ='kay' and table_name ='EMP'



6.Crear el usuario Todd con capacidad de conexión.

create user todd identified by along default tablespace users quoa 1m on users;
grant connect to todd;

nos conectamos como todd para ver si funciona

7.Conectar como Bob y permitir a Todd acceder a la tabla EMP de Kay.
nos conectamos como bob  
grant slect on kay.emp to Todd

como Todd
select * from kay.emp;


8.Conectar como Kay y quitarle el privilegio a Bob de consultar su tabla EMP.

como kay
revoke select on emp from bob;


9.Conectar como Todd y consultar la tabla EMP de Kay.

select * from kay.emp (no debe aparecer)

## ROLES

1.Listar todos los privilegios que tiene el role RESOURCE
select * from role_sys_privs where role = "resource";

2.Crear el role DEV para crear tablas, crear vistas y consultar la tabla EMP de Kay.
create role dev;
grant connect, resource to dev;
3.Conceder a Bob los roles DEV y RESOURCE, pero habilitarle sólo RESOURCE cuando se conecte.
grant dev to bob;
alter user bob default role resource; (Antigua version) Los predefinidos no se pueden poner pero los creados como dev si se pueden dar.
4.Conceder a Bob el role que le permite consultar todo el catálogo. Comprobar alcance
grant select_catalog_role to bob;
conectar como bob.
HABILITAR ROL DICE QUE LO VA A MIRAR
select * from dba_tables XXXXXX;
