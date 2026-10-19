
/* proyecto: base de datos musical - semana 8
   Carlos Pineda - Fundamentos de Bases de Datos - UNIMINUTO

   codigo organizado a partir del trabajo realizado en Workbench.
   ejecutar en una base de prueba vacia.
   no ejecutar sobre las tablas que ya existen.
*/

create database if not exists proyecto_bd_musical
character set utf8mb4
collate utf8mb4_unicode_ci;

use proyecto_bd_musical;

-- tablas principales

create table grupo (
    id_grupo int auto_increment,
    nombre varchar(100) not null,
    componente varchar(255),
    fecha_cre date,
    constraint pk_grupo primary key (id_grupo)
) engine=InnoDB default charset=utf8mb4 collate=utf8mb4_unicode_ci;

create table cancion (
    id_cancion int auto_increment,
    titulo varchar(150) not null,
    publica date,
    constraint pk_cancion primary key (id_cancion)
) engine=InnoDB default charset=utf8mb4 collate=utf8mb4_unicode_ci;

create table usuario (
    id_usuario int auto_increment,
    correo varchar(150) not null,
    url varchar(255),
    fecha_alta date,
    constraint pk_usuario primary key (id_usuario),
    constraint uq_usuario_correo unique (correo)
) engine=InnoDB default charset=utf8mb4 collate=utf8mb4_unicode_ci;

create table album (
    id_album int auto_increment,
    titulo varchar(150) not null,
    fecha_pub date,
    num_canciones int,
    id_grupo int null,
    constraint pk_album primary key (id_album),
    index idx_album_id_grupo (id_grupo),
    constraint fk_album_grupo
        foreign key (id_grupo)
        references grupo(id_grupo)
        on update cascade
        on delete cascade
) engine=InnoDB default charset=utf8mb4 collate=utf8mb4_unicode_ci;

create table registrado (
    id_registrado int auto_increment,
    cuota decimal(10,2),
    fecha_fin date,
    id_usuario int null,
    constraint pk_registrado primary key (id_registrado),
    index idx_registrado_id_usuario (id_usuario),
    constraint fk_registrado_usuario
        foreign key (id_usuario)
        references usuario(id_usuario)
        on update cascade
        on delete cascade
) engine=InnoDB default charset=utf8mb4 collate=utf8mb4_unicode_ci;

-- tablas relacionadas

create table contiene (
    id_album int not null,
    id_cancion int not null,
    constraint pk_contiene primary key (id_album, id_cancion),

    constraint fk_contiene_album
        foreign key (id_album)
        references album(id_album)
        on update cascade
        on delete cascade,

    constraint fk_contiene_cancion
        foreign key (id_cancion)
        references cancion(id_cancion)
        on update cascade
        on delete cascade
) engine=InnoDB default charset=utf8mb4 collate=utf8mb4_unicode_ci;

create table descarga (
    id_registrado int not null,
    id_cancion int not null,
    fecha date not null,
    n_veces int not null default 1,

    constraint pk_descarga
        primary key (id_registrado, id_cancion, fecha),

    constraint fk_descarga_registrado
        foreign key (id_registrado)
        references registrado(id_registrado)
        on update cascade
        on delete cascade,

    constraint fk_descarga_cancion
        foreign key (id_cancion)
        references cancion(id_cancion)
        on update cascade
        on delete cascade
) engine=InnoDB default charset=utf8mb4 collate=utf8mb4_unicode_ci;

create table stream (
    id_usuario int not null,
    id_cancion int not null,
    fecha date not null,

    constraint pk_stream
        primary key (id_usuario, id_cancion, fecha),

    constraint fk_stream_usuario
        foreign key (id_usuario)
        references usuario(id_usuario)
        on update cascade
        on delete cascade,

    constraint fk_stream_cancion
        foreign key (id_cancion)
        references cancion(id_cancion)
        on update cascade
        on delete cascade
) engine=InnoDB default charset=utf8mb4 collate=utf8mb4_unicode_ci;

-- datos de prueba

insert into grupo (nombre, componente, fecha_cre)
values
('Morat', 'Juan Pablo, Juan Pablo Isaza, Simón y Martín', '2011-01-01'),
('Aterciopelados', 'Andrea Echeverri y Héctor Buitrago', '1990-01-01');

insert into cancion (titulo, publica)
values
('Como te atreves', '2016-01-01'),
('Besos en guerra', '2017-11-03'),
('La camisa negra', '2004-09-28');

insert into usuario (correo, url, fecha_alta)
values
('usuario1@ejemplo.com', 'https://ejemplo.com/usuario1', '2026-01-15'),
('usuario2@ejemplo.com', 'https://ejemplo.com/usuario2', '2026-02-15');

insert into album (titulo, fecha_pub, num_canciones, id_grupo)
values
('Sobre el amor y sus efectos secundarios', '2016-06-17', 12, 1),
('Mi Sangre', '2004-09-28', 12, null);

insert into registrado (cuota, fecha_fin, id_usuario)
values
(15000.00, '2027-01-10', 1),
(20000.00, '2027-06-30', 2);

insert into contiene (id_album, id_cancion)
values
(1, 1),
(1, 2),
(2, 3);

insert into descarga (id_registrado, id_cancion, fecha, n_veces)
values
(1, 1, '2026-10-10', 3),
(1, 2, '2026-10-11', 1),
(2, 3, '2026-10-12', 2),
(1, 1, '2026-10-17', 2);

-- quedan los tres registros que permanecieron en stream
-- despues de ejecutar el delete en Workbench

insert into stream (id_usuario, id_cancion, fecha)
values
(1, 1, '2026-10-13'),
(1, 2, '2016-10-14'),
(2, 1, '2026-10-15');

-- consultas de albumes y canciones

select
    a.titulo as album,
    c.titulo as cancion
from album as a
inner join contiene as co
    on a.id_album = co.id_album
inner join cancion as c
    on co.id_cancion = c.id_cancion;

select
    a.titulo as album,
    c.titulo as cancion
from album as a
inner join contiene as co
    on a.id_album = co.id_album
inner join cancion as c
    on co.id_cancion = c.id_cancion
where a.titulo = 'Sobre el amor y sus efectos secundarios';

select
    a.titulo as album,
    count(co.id_cancion) as total_canciones
from album as a
inner join contiene as co
    on a.id_album = co.id_album
group by a.id_album, a.titulo;

-- subconsulta con min

select titulo, publica
from cancion
where publica > (
    select min(publica)
    from cancion
);

-- subconsulta con in

select titulo
from cancion
where id_cancion in (
    select id_cancion
    from contiene
    where id_album = 1
);

-- subconsulta anidada

select titulo
from cancion
where id_cancion in (
    select id_cancion
    from contiene
    where id_album = (
        select id_album
        from contiene
        group by id_album
        order by count(id_cancion) desc
        limit 1
    )
);

-- vista

create or replace view vista_albumes_canciones as
select
    a.titulo as album,
    c.titulo as cancion
from album as a
inner join contiene as co
    on a.id_album = co.id_album
inner join cancion as c
    on co.id_cancion = c.id_cancion;

select * from vista_albumes_canciones;

select *
from vista_albumes_canciones
where album = 'Mi Sangre';

-- indice

create index idx_usuario_fecha_alta
on usuario (fecha_alta);

show index from usuario;

-- trigger

delimiter //

create trigger validar_descarga
before insert on descarga
for each row
begin
    if new.n_veces < 1 then
        signal sqlstate '45000'
        set message_text = 'El numero de descargas debe ser mayor que cero';
    end if;
end //

delimiter ;

show triggers from proyecto_bd_musical;

-- consultas sobre las descargas

select
    c.titulo as cancion,
    count(*) as registros_descarga,
    sum(d.n_veces) as total_descargas
from descarga as d
inner join cancion as c
    on d.id_cancion = c.id_cancion
group by c.id_cancion, c.titulo;

select titulo
from cancion
where id_cancion in (
    select id_cancion
    from descarga
    group by id_cancion
    having sum(n_veces) > (
        select avg(n_veces)
        from descarga
    )
);

select
    c.titulo as cancion,
    sum(d.n_veces) as total_descargas,
    (select avg(n_veces) from descarga) as promedio_por_registro
from cancion as c
inner join descarga as d
    on c.id_cancion = d.id_cancion
group by c.id_cancion, c.titulo;

select titulo
from cancion
where id_cancion in (
    select id_cancion
    from descarga
    where n_veces > (
        select avg(n_veces)
        from descarga
    )
);

select titulo
from cancion
where id_cancion in (
    select id_cancion
    from contiene
    where id_album = (
        select id_album
        from album
        where titulo = 'Sobre el amor y sus efectos secundarios'
    )
);

-- ver las claves foraneas

select
    table_name as tabla,
    constraint_name as nombre_fk,
    column_name as columna,
    referenced_table_name as tabla_referenciada,
    referenced_column_name as columna_referenciada
from information_schema.key_column_usage
where table_schema = 'proyecto_bd_musical'
  and referenced_table_name is not null
order by table_name, constraint_name;

-- ver las reglas al actualizar y eliminar

select
    table_name as tabla,
    constraint_name as nombre_fk,
    update_rule as al_actualizar,
    delete_rule as al_eliminar
from information_schema.referential_constraints
where constraint_schema = 'proyecto_bd_musical'
order by table_name, constraint_name;

-- ver las claves primarias

select
    table_name as tabla,
    column_name as columna_pk,
    ordinal_position as posicion
from information_schema.key_column_usage
where table_schema = 'proyecto_bd_musical'
  and constraint_name = 'PRIMARY'
order by table_name, ordinal_position;

-- comprobar cuántos registros hay en cada tabla

select 'grupo' as tabla, count(*) as registros from grupo
union all
select 'album', count(*) from album
union all
select 'cancion', count(*) from cancion
union all
select 'usuario', count(*) from usuario
union all
select 'registrado', count(*) from registrado
union all
select 'contiene', count(*) from contiene
union all
select 'descarga', count(*) from descarga
union all
select 'stream', count(*) from stream;

-- prueba del trigger: debe generar un error, por eso queda comentada
-- insert into descarga (id_registrado, id_cancion, fecha, n_veces)
-- values (1, 2, '2026-10-19', 0);
