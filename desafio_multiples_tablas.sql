CREATE DATABASE datausuarios;

\c datausuarios; 

CREATE TABLE usuarios (id SERIAL PRIMARY KEY, email VARCHAR(100) NOT NULL, nombre VARCHAR(250) NOT NULL, apellido VARCHAR(250) NOT NULL, rol VARCHAR(20)); 

INSERT INTO usuarios (email, nombre, apellido, rol) VALUES 
('correo1', 'jose', 'valencia', 'administrador'), 
('correo2', 'pedro', 'valenzuela', 'usuario'),
('correo3', 'carlos', 'valdivia', 'usuario'),
('correo4', 'manuel', 'vargas', 'usuario'),
('correo5', 'andres', 'valvuena', 'usuario');


CREATE TABLE posts (id SERIAL PRIMARY KEY, titulo VARCHAR(200) NOT NULL, contenido TEXT NOT NULL, fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP, fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP, destacado BOOLEAN, usuario_id BIGINT,  FOREIGN KEY (usuario_id) REFERENCES usuarios(id));

INSERT INTO posts (titulo, contenido, fecha_creacion, fecha_actualizacion, destacado, usuario_id)
VALUES 
    ('Mamas y Bebes', 'Contenido del Post 1', '2023-11-18 12:00:00', '2023-11-18 12:00:00', true, 1), 
    ('Plantas', 'Contenido del Post 2', '2023-11-18 12:30:00', '2023-11-18 12:30:00', true, 1), 
    ('El planeta', 'Contenido del Post 3', '2023-11-18 13:00:00', '2023-11-18 13:00:00', true, 2), 
    ('Enfermedades', 'Contenido del Post 4', '2023-11-18 13:30:00', '2023-11-18 13:30:00', false, 2), 
    ('Tratamientos AV', 'Contenido del Post 5', '2023-11-18 14:00:00', '2023-11-18 14:00:00', false, NULL); 

    CREATE TABLE comentarios (id SERIAL PRIMARY KEY, contenido TEXT NOT NULL, fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP, usuario_id BIGINT, post_id BIGINT, FOREIGN KEY (usuario_id) REFERENCES usuarios(id),FOREIGN KEY (post_id) REFERENCES posts(id));

INSERT INTO comentarios (contenido, fecha_creacion, usuario_id, post_id)
VALUES 
    ('Contenido del Comentario 1', '2023-11-18 15:00:00', 1, 1), 
    ('Contenido del Comentario 2', '2023-11-18 15:15:00', 2, 1), 
    ('Contenido del Comentario 3', '2023-11-18 15:30:00', 3, 1), 
    ('Contenido del Comentario 4', '2023-11-18 15:45:00', 1, 2), 
    ('Contenido del Comentario 5', '2023-11-18 16:00:00', 2, 2); 




1- Cruza los datos de la tabla usuarios y posts, mostrando las siguientes columnas:
nombre y email del usuario, junto al título y contenido del post.

R= SELECT usuarios.nombre, usuarios.email, posts.titulo, posts.contenido FROM usuarios INNER JOIN posts ON usuarios.id = posts.usuario_id;

nombre   |  email  |	titulo 	        |  	contenido
--------+---------+---------------+----------------------
 jose    | correo1 | Mamas y bebes      | Contenido del Post 1
 jose    | correo1 | Plantas   	        | Contenido del Post 2
 pedro   | correo2 | El planeta	        | Contenido del Post 3
 pedro   | correo2 | Enfermedades       | Contenido del Post 4



2- Muestra el id, título y contenido de los posts de los administradores.
a. El administrador puede ser cualquier id.

R= SELECT posts.id, posts.titulo, posts.contenido FROM posts JOIN usuarios ON posts.usuario_id = usuarios.id WHERE usuarios.rol = 'administrador';


 id |    titulo     |      contenido
----+---------------+----------------------
  1 | Mamas y bebes | Contenido del Post 1
  2 | Plantas       | Contenido del Post 2




3- Cuenta la cantidad de posts de cada usuario.
a. La tabla resultante debe mostrar el id e email del usuario junto con la
cantidad de posts de cada usuario.

R= SELECT usuarios.id, usuarios.email, COUNT(posts.id) AS cantidad_posts FROM usuarios LEFT JOIN posts ON usuarios.id = posts.usuario_id GROUP BY usuarios.id, usuarios.email ORDER BY usuarios.email ASC;

 id |  email  | cantidad_posts
----+---------+----------------
  1 | correo1 |              2
  2 | correo2 |              2
  3 | correo3 |              0
  4 | correo4 |              0
  5 | correo5 |              0




4- Muestra el email del usuario que ha creado más posts.
a. Aquí la tabla resultante tiene un único registro y muestra solo el email

R= SELECT usuarios.email FROM usuarios JOIN (SELECT usuario_id, COUNT(id) AS cantidad_posts FROM posts GROUP BY usuario_id ORDER BY cantidad_posts DESC LIMIT 1) AS subquery ON usuarios.id = subquery.usuario_id;

  email
---------
 correo2

 

 5- Muestra la fecha del último post de cada usuario
 Hint: Utiliza la función de agregado MAX sobre la fecha de creación.

 R= SELECT usuarios.id, MAX(posts.fecha_creacion) AS fecha_ultimo_post FROM usuarios LEFT JOIN posts ON usuarios.id = posts.usuario_id GROUP BY usuarios.id ORDER BY usuarios.id;

  id |     fecha_ultimo_post
----+----------------------------
  1 | 2023-11-18 01:06:38.653228
  2 | 2023-11-18 01:06:38.653228


  6- Muestra el título y contenido del post (artículo) con más comentarios.
  
R= SELECT posts.titulo, posts.contenido FROM posts JOIN (SELECT post_id, COUNT(id) AS cantidad_comentarios FROM comentarios GROUP BY post_id ORDER BY cantidad_comentarios DESC LIMIT 1) AS subquery ON posts.id = subquery.post_id;

    titulo     |      contenido
---------------+----------------------
 Mamas y bebes | Contenido del Post 1

7- Muestra en una tabla el título de cada post, el contenido de cada post y el contenido
de cada comentario asociado a los posts mostrados, junto con el email del usuario
que lo escribió.

R= SELECT posts.titulo AS titulo_post, posts.contenido AS contenido_post, comentarios.contenido AS contenido_comentario, usuarios.email AS email_usuario FROM posts JOIN comentarios ON posts.id = comentarios.post_id JOIN usuarios ON comentarios.usuario_id = usuarios.id;


  titulo_post  |    contenido_post    |    contenido_comentario    | email_usuario
---------------+----------------------+----------------------------+---------------
 Mamas y bebes | Contenido del Post 1 | Contenido del Comentario 1 | correo1
 Mamas y bebes | Contenido del Post 1 | Contenido del Comentario 2 | correo2
 Mamas y bebes | Contenido del Post 1 | Contenido del Comentario 3 | correo3
 Plantas       | Contenido del Post 2 | Contenido del Comentario 4 | correo1
 Plantas       | Contenido del Post 2 | Contenido del Comentario 5 | correo2

8- Muestra el contenido del último comentario de cada usuario

R= SELECT usuario_id, fecha_creacion, contenido FROM (SELECT DISTINCT ON (usuario_id) usuario_id, fecha_creacion, contenido FROM comentarios ORDER BY usuario_id, fecha_creacion DESC) AS ultimo_comentario ORDER BY usuario_id;

 usuario_id |       fecha_creacion       |         contenido
------------+----------------------------+----------------------------
          1 | 2023-11-18 02:01:21.855973 | Contenido del Comentario 1
          2 | 2023-11-18 02:01:21.855973 | Contenido del Comentario 2
          3 | 2023-11-18 02:01:21.855973 | Contenido del Comentario 3

9-  Muestra los emails de los usuarios que no han escrito ningún comentario.
Hint: Recuerda el uso de Having

R= SELECT usuarios.email FROM usuarios LEFT JOIN comentarios ON usuarios.id = comentarios.usuario_id GROUP BY usuarios.id, usuarios.email HAVING COUNT(comentarios.id) = 0;

  email
---------
 correo4
 correo5

