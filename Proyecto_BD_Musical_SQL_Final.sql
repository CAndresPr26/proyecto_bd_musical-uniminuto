/* PROYECTO: BASE DE DATOS EN MYSQL — SEMANA 8
Estudiante: Carlos Pineda | Fundamentos de Bases de Datos | UNIMINUTO
Archivo organizado para anexar al informe. Ejecutar completo solo en una base nueva de prueba:
CREATE TABLE falla si las tablas ya existen. UPDATE/DELETE y prueba negativa del trigger están comentados.
*/
CREATE DATABASE IF NOT EXISTS proyecto_bd_musical CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE proyecto_bd_musical;

-- Tablas principales
CREATE TABLE grupo (id_grupo INT NOT NULL AUTO_INCREMENT, nombre VARCHAR(100) NOT NULL, componente VARCHAR(255), fecha_cre DATE, CONSTRAINT pk_grupo PRIMARY KEY(id_grupo)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE album (id_album INT NOT NULL AUTO_INCREMENT, titulo VARCHAR(150) NOT NULL, fecha_pub DATE, num_canciones INT, CONSTRAINT pk_album PRIMARY KEY(id_album)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE cancion (id_cancion INT NOT NULL AUTO_INCREMENT, titulo VARCHAR(150) NOT NULL, publica DATE, CONSTRAINT pk_cancion PRIMARY KEY(id_cancion)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE usuario (id_usuario INT NOT NULL AUTO_INCREMENT, correo VARCHAR(150) NOT NULL, url VARCHAR(255), fecha_alta DATE, CONSTRAINT pk_usuario PRIMARY KEY(id_usuario), CONSTRAINT uq_usuario_correo UNIQUE(correo)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE registrado (id_registrado INT NOT NULL AUTO_INCREMENT, cuota DECIMAL(10,2), fecha_fin DATE, CONSTRAINT pk_registrado PRIMARY KEY(id_registrado)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tablas dependientes
CREATE TABLE contiene (id_album INT NOT NULL, id_cancion INT NOT NULL, CONSTRAINT pk_contiene PRIMARY KEY(id_album,id_cancion), CONSTRAINT fk_contiene_album FOREIGN KEY(id_album) REFERENCES album(id_album) ON UPDATE CASCADE ON DELETE CASCADE, CONSTRAINT fk_contiene_cancion FOREIGN KEY(id_cancion) REFERENCES cancion(id_cancion) ON UPDATE CASCADE ON DELETE CASCADE) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE descarga (id_registrado INT NOT NULL, id_cancion INT NOT NULL, fecha DATE NOT NULL, n_veces INT NOT NULL DEFAULT 1, CONSTRAINT pk_descarga PRIMARY KEY(id_registrado,id_cancion,fecha), CONSTRAINT fk_descarga_registrado FOREIGN KEY(id_registrado) REFERENCES registrado(id_registrado) ON UPDATE CASCADE ON DELETE CASCADE, CONSTRAINT fk_descarga_cancion FOREIGN KEY(id_cancion) REFERENCES cancion(id_cancion) ON UPDATE CASCADE ON DELETE CASCADE) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE stream (id_usuario INT NOT NULL, id_cancion INT NOT NULL, fecha DATE NOT NULL, CONSTRAINT pk_stream PRIMARY KEY(id_usuario,id_cancion,fecha), CONSTRAINT fk_stream_usuario FOREIGN KEY(id_usuario) REFERENCES usuario(id_usuario) ON UPDATE CASCADE ON DELETE CASCADE, CONSTRAINT fk_stream_cancion FOREIGN KEY(id_cancion) REFERENCES cancion(id_cancion) ON UPDATE CASCADE ON DELETE CASCADE) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Datos de ejemplo
INSERT INTO grupo(nombre,componente,fecha_cre) VALUES ('Morat','Juan Pablo, Juan Pablo Isaza, Simón y Martín','2011-01-01'),('Aterciopelados','Andrea Echeverri y Héctor Buitrago','1990-01-01');
INSERT INTO album(titulo,fecha_pub,num_canciones) VALUES ('Sobre el amor y sus efectos secundarios','2016-06-17',12),('Mi Sangre','2004-09-28',12);
INSERT INTO cancion(titulo,publica) VALUES ('Como te atreves','2016-01-01'),('Besos en guerra','2017-11-03'),('La camisa negra','2004-09-28');
INSERT INTO usuario(correo,url,fecha_alta) VALUES ('usuario1@ejemplo.com','https://ejemplo.com/usuario1','2026-01-10'),('usuario2@ejemplo.com','https://ejemplo.com/usuario2','2026-02-15');
INSERT INTO registrado(cuota,fecha_fin) VALUES (15000.00,'2027-01-10'),(20000.00,'2027-06-30');
INSERT INTO contiene(id_album,id_cancion) VALUES (1,1),(1,2),(2,3);
INSERT INTO descarga(id_registrado,id_cancion,fecha,n_veces) VALUES (1,1,'2026-10-10',3),(1,2,'2026-10-11',1),(2,3,'2026-10-12',2);
INSERT INTO stream(id_usuario,id_cancion,fecha) VALUES (1,1,'2026-10-13'),(1,2,'2026-10-14'),(2,3,'2026-10-15'),(2,1,'2026-10-15');

-- Índice, vista y trigger
CREATE INDEX idx_usuario_fecha_alta ON usuario(fecha_alta);
CREATE OR REPLACE VIEW vista_albumes_canciones AS SELECT a.titulo AS album,c.titulo AS cancion FROM album a INNER JOIN contiene co ON a.id_album=co.id_album INNER JOIN cancion c ON co.id_cancion=c.id_cancion;
DELIMITER //
CREATE TRIGGER validar_descarga BEFORE INSERT ON descarga FOR EACH ROW BEGIN IF NEW.n_veces < 1 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='El numero de descargas debe ser mayor que cero'; END IF; END //
DELIMITER ;

-- Consultas solicitadas
SELECT a.titulo AS album,c.titulo AS cancion FROM album a INNER JOIN contiene co ON a.id_album=co.id_album INNER JOIN cancion c ON co.id_cancion=c.id_cancion;
SELECT a.titulo AS album,c.titulo AS cancion FROM album a INNER JOIN contiene co ON a.id_album=co.id_album INNER JOIN cancion c ON co.id_cancion=c.id_cancion WHERE a.titulo='Sobre el amor y sus efectos secundarios';
SELECT a.titulo AS album,COUNT(co.id_cancion) AS total_canciones FROM album a INNER JOIN contiene co ON a.id_album=co.id_album GROUP BY a.id_album,a.titulo;
SELECT titulo,publica FROM cancion WHERE publica>(SELECT MIN(publica) FROM cancion);
SELECT titulo FROM cancion WHERE id_cancion IN (SELECT id_cancion FROM contiene WHERE id_album=1);
SELECT titulo FROM cancion WHERE id_cancion IN (SELECT id_cancion FROM contiene WHERE id_album=(SELECT id_album FROM contiene GROUP BY id_album ORDER BY COUNT(id_cancion) DESC LIMIT 1));
SELECT * FROM vista_albumes_canciones;
SELECT * FROM vista_albumes_canciones WHERE album='Mi Sangre';
SHOW INDEX FROM usuario;
SHOW TRIGGERS FROM proyecto_bd_musical;

-- UPDATE y DELETE ya probados. Descomentar solo para repetir en entorno de prueba.
-- UPDATE usuario SET fecha_alta='2026-01-15' WHERE id_usuario=1;
-- DELETE FROM stream WHERE id_usuario=2 AND id_cancion=3 AND fecha='2026-10-15';
-- Prueba del trigger: debe generar SQLSTATE 45000.
-- INSERT INTO descarga(id_registrado,id_cancion,fecha,n_veces) VALUES(1,2,'2026-10-18',0);

-- Verificación de FK y CASCADE
SELECT table_name AS tabla,constraint_name AS nombre_fk,column_name AS columna,referenced_table_name AS tabla_referenciada,referenced_column_name AS columna_referenciada FROM information_schema.key_column_usage WHERE table_schema='proyecto_bd_musical' AND referenced_table_name IS NOT NULL ORDER BY table_name,constraint_name;
SELECT table_name AS tabla,constraint_name AS nombre_fk,update_rule AS al_actualizar,delete_rule AS al_eliminar FROM information_schema.referential_constraints WHERE constraint_schema='proyecto_bd_musical' ORDER BY table_name,constraint_name;
SELECT table_name AS tabla,column_name AS columna_pk,ordinal_position AS posicion FROM information_schema.key_column_usage WHERE table_schema='proyecto_bd_musical' AND constraint_name='PRIMARY' ORDER BY table_name,ordinal_position;
