-- 2. Muestra los nombres de todas las películas con una clasificación por edades de ‘R’.
SELECT title, rating 
FROM film
WHERE rating = 'R';

-- 3. Encuentra los nombres de los actores que tengan un “actor_id” entre 30 y 40.
SELECT CONCAT(first_name, ' ', last_name) AS "actor", actor_id
FROM actor
WHERE actor_id >= 30 AND actor_id <= 40
ORDER BY actor_id ASC;

-- 4. Obtén las películas cuyo idioma coincide con el idioma original.
-- Tabla temporal con todas las películas y sus idiomas
CREATE TEMPORARY TABLE "idiomas" AS (
	SELECT f.film_id AS "id", f.title AS "title", l.name AS "idioma"
	FROM film AS f
	LEFT JOIN "language" AS l
	ON f.language_id = l.language_id);

-- Tabla temporal con todas las películas y sus idiomas originales
CREATE TEMPORARY TABLE "idiomas_originales" AS (
	SELECT f.film_id AS "id", f.title AS "title", l.name AS "idioma_original"
	FROM film AS f
	LEFT JOIN "language" AS l
	ON f.original_language_id = l.language_id);

-- Query de todas las peliculas con el mismo idioma y idioma original:
SELECT "idiomas"."title", "idiomas"."idioma"
FROM "idiomas" FULL JOIN "idiomas_originales"
ON "idiomas"."id" = "idiomas_originales"."id"
WHERE "idioma"="idioma_original";

-- No Existen! Porque todos los film.original_language_id son NULL:
SELECT title, original_language_id FROM film;

-- 5. Ordena las películas por duración de forma ascendente.
SELECT title, length
FROM film 
ORDER BY length ASC;

-- 6. Encuentra el nombre y apellido de los actores que tengan ‘Allen’ en su apellido.
SELECT first_name AS nombre, last_name AS apellido
FROM actor
WHERE last_name LIKE '%ALLEN%';

-- 7. Encuentra la cantidad total de películas en cada clasificación de la tabla “film” y muestra la clasificación junto con el recuento.
SELECT rating, COUNT(film_id) AS "Número de películas"
FROM film 
GROUP BY rating;

-- 8. Encuentra el título de todas las películas que son ‘PG-13’ o tienen una duración mayor a 3 horas en la tabla film.
SELECT title, rating, length
FROM film
WHERE rating = 'PG-13' OR length > 180
ORDER BY length ASC;

-- 9. Encuentra la variabilidad de lo que costaría reemplazar las películas.
SELECT STDDEV(replacement_cost) AS Variabilidad
FROM film;

-- 10. Encuentra la mayor y menor duración de una película de nuestra BBDD.
SELECT MAX(length) AS "Duracion máxima", MIN(length) AS "Duracion mínima"
FROM film;

-- 11. Encuentra lo que costó el antepenúltimo alquiler ordenado por día.
SELECT p.amount
FROM rental AS r
LEFT JOIN payment AS p
ON r.rental_id = p.rental_id 
ORDER BY r.rental_date DESC
LIMIT 1 OFFSET 2;

-- 12. Encuentra el título de las películas en la tabla “film” que no sean ni ‘NC-17’ ni ‘G’ en cuanto a su clasificación.
SELECT title, rating
FROM film AS f1
WHERE NOT EXISTS (
	SELECT 1
	FROM film AS f2
	WHERE f1.film_id = f2.film_id  AND (rating = 'NC-17' OR rating = 'G'));

-- 13. Encuentra el promedio de duración de las películas para cada clasificación de la tabla film y muestra la clasificación junto con el promedio de duración.
SELECT rating, AVG(length) AS "Promedio"
FROM film
GROUP BY rating
ORDER BY "Promedio" DESC;

-- 14. Encuentra el título de todas las películas que tengan una duración mayor a 180 minutos.
SELECT title, length
FROM film
WHERE length > 180
ORDER BY length ASC;

-- 15. ¿Cuánto dinero ha generado en total la empresa?
SELECT SUM(amount) AS "Total Generado"
FROM payment;

-- 16. Muestra los 10 clientes con mayor valor de id.
SELECT CONCAT(first_name, ' ', last_name) AS "Cliente", customer_id
FROM customer
ORDER BY customer_id DESC
LIMIT 10;

-- 17. Encuentra el nombre y apellido de los actores que aparecen en la película con título ‘Egg Igby’.
WITH "Id_Egg_Igby" AS (
	SELECT film_id, title
	FROM film
	WHERE title = 'EGG IGBY'
	), 
"Id_Actores_Egg_Igby" AS (
	SELECT actor_id
	FROM film_actor AS ac
	INNER JOIN "Id_Egg_Igby"
	ON ac.film_id = "Id_Egg_Igby".film_id
	)
SELECT CONCAT(first_name, ' ', last_name) AS "Actor"
FROM actor
INNER JOIN "Id_Actores_Egg_Igby" 
ON actor.actor_id = "Id_Actores_Egg_Igby"."actor_id"; 

-- 18. Selecciona todos los nombres de las películas únicos.
SELECT DISTINCT title
FROM film;

-- 19. Encuentra el título de las películas que son comedias y tienen una duración mayor a 180 minutos en la tabla “film”.
WITH "Id_comedia" AS (
	SELECT category_id, name AS "Categoría"
	FROM category
	WHERE name = 'Comedy'
),
"Id_peliculas_comedia" AS (
	SELECT fc.film_id, "Categoría"
	FROM film_category AS fc 
	INNER JOIN "Id_comedia"
	ON fc.category_id = "Id_comedia".category_id
)
SELECT title, length, "Categoría"
FROM "Id_peliculas_comedia" INNER JOIN film
ON "Id_peliculas_comedia".film_id = film.film_id 
WHERE length > 180
ORDER BY length ASC;
 

-- 20. Encuentra las categorías de películas que tienen un promedio de duración superior a 110 minutos y muestra el nombre de la categoría junto con el promedio de duración.
CREATE VIEW "Categorías Películas" AS 
SELECT f.film_id, f.title, c.name AS "Categoría"
FROM film AS f
LEFT JOIN film_category AS fc ON f.film_id = fc.film_id
INNER JOIN category AS c ON fc.category_id = c.category_id;

SELECT * FROM "Categorías Películas";

SELECT "c"."Categoría", AVG(f.length) AS "Promedio"
FROM "Categorías Películas" AS c
INNER JOIN film AS f ON c.film_id = f.film_id
GROUP BY "c"."Categoría"
HAVING AVG(f.length) > 110
ORDER BY "Promedio" ASC;

-- 21. ¿Cuál es la media de duración del alquiler de las películas?
SELECT return_date FROM rental
WHERE return_date IS NULL;

SELECT AVG(return_date - rental_date) AS "Promedio duracion alquiler"
FROM rental
WHERE return_date IS NOT NULL;

-- 22. Crea una columna con el nombre y apellidos de todos los actores y actrices.
CREATE VIEW "Nombres_apellidos_actores" AS
SELECT actor_id, CONCAT(first_name, ' ', last_name) AS "Actor"
FROM actor;

SELECT * FROM "Nombres_apellidos_actores";

-- 23. Números de alquiler por día, ordenados por cantidad de alquiler de forma descendente.
SELECT DATE(rental_date) AS "Día Alquiler", COUNT(*) AS "Total"
FROM rental
GROUP BY DATE(rental_date)
ORDER BY "Total" DESC;

-- 24. Encuentra las películas con una duración superior al promedio.
SELECT title, length
FROM film
WHERE length > (
	SELECT AVG(length)
	FROM film);

-- 25. Averigua el número de alquileres registrados por mes.
SELECT TO_CHAR(rental_date, 'YYYY-MM') AS mes, COUNT(rental_id) AS total_alquileres
FROM rental
GROUP BY mes
ORDER BY mes ASC;

-- 26. Encuentra el promedio, la desviación estándar y varianza del total pagado.
SELECT 
	AVG(amount) AS "Promedio",
	STDDEV(amount) AS "Desviación Estandar",
	VARIANCE(amount) AS "Varianza"
FROM payment;

-- 27. ¿Qué películas se alquilan por encima del precio medio?
WITH "precios_peliculas" AS (
	SELECT f.film_id, f.title, p.amount
	FROM film AS f 
	JOIN inventory AS i ON f.film_id=i.film_id
	JOIN rental AS r ON i.inventory_id=r.inventory_id
	JOIN payment AS p ON r.rental_id=p.rental_id
	)
SELECT title, amount
FROM "precios_peliculas" 
WHERE amount > (
	SELECT AVG(amount)
	FROM "precios_peliculas")
ORDER BY amount ASC;

-- 28. Muestra el id de los actores que hayan participado en más de 40 películas.
SELECT actor_id, COUNT(film_id) AS num_peliculas
FROM film_actor
GROUP BY actor_id 
HAVING COUNT(film_id) > 40
ORDER BY num_peliculas ASC;

-- 29. Obtener todas las películas y, si están disponibles en el inventario, mostrar la cantidad disponible.
SELECT f.title, cantidad
FROM film AS f
LEFT JOIN (SELECT i.film_id, COUNT(i.inventory_id) AS cantidad
		   FROM inventory AS i
		   GROUP BY i.film_id) AS "Cantidades"
ON f.film_id = "Cantidades".film_id 
ORDER BY cantidad ASC;

-- 30. Obtener los actores y el número de películas en las que ha actuado.
SELECT a."Actor", num_peliculas
FROM "Nombres_apellidos_actores" AS a
LEFT JOIN (SELECT actor_id, COUNT(film_id) AS num_peliculas
		   FROM film_actor
		   GROUP BY actor_id) AS "peliculas_por_actor"
ON a.actor_id = "peliculas_por_actor".actor_id
ORDER BY num_peliculas DESC;

-- 31. Obtener todas las películas y mostrar los actores que han actuado en ellas, incluso si algunas películas no tienen actores asociados.
SELECT f.title, STRING_AGG(a."Actor", ', ') AS "Actores"
FROM film AS f
LEFT JOIN film_actor AS fa ON f.film_id = fa.film_id
INNER JOIN "Nombres_apellidos_actores" AS a ON fa.actor_id = a.actor_id
GROUP BY (f.film_id);

-- 32. Obtener todos los actores y mostrar las películas en las que han actuado, incluso si algunos actores no han actuado en ninguna película.
SELECT a."Actor", STRING_AGG(f.title, ', ') AS "Películas"
FROM "Nombres_apellidos_actores" AS a
LEFT JOIN film_actor AS fa ON a.actor_id = fa.actor_id
INNER JOIN film AS f ON fa.film_id = f.film_id
GROUP BY a."Actor";

-- 33. Obtener todas las películas que tenemos y todos los registros de alquiler.
SELECT f.title, r.rental_id
FROM film AS f
FULL JOIN inventory AS i ON f.film_id = i.film_id 
FULL JOIN rental AS r ON i.inventory_id = r.inventory_id;

-- 34. Encuentra los 5 clientes que más dinero se hayan gastado con nosotros.
SELECT CONCAT(c.first_name, ' ', c.last_name) AS "Cliente", SUM(p.amount) AS "Total"
FROM customer AS c
LEFT JOIN rental AS r ON c.customer_id = r.customer_id 
INNER JOIN payment AS p ON r.rental_id = p.rental_id 
GROUP BY c.customer_id
ORDER BY "Total" DESC
LIMIT 5;

-- 35. Selecciona todos los actores cuyo primer nombre es 'Johnny'.
SELECT CONCAT(first_name, ' ', last_name) AS "Actor"
FROM actor
WHERE first_name = 'JOHNNY';

-- 36. Renombra la columna “first_name” como Nombre y “last_name” como Apellido.
CREATE TEMPORARY TABLE "Tabla Actores" AS (
SELECT actor_id, first_name AS "Nombre", last_name AS "Apellido", last_update
FROM actor);

SELECT * FROM "Tabla Actores";

-- 37. Encuentra el ID del actor más bajo y más alto en la tabla actor.
SELECT MIN(actor_id) AS "Id_minimo", MAX(actor_id) AS "Id_maximo"
FROM actor;

-- 38. Cuenta cuántos actores hay en la tabla “actor”.
SELECT COUNT(actor_id) AS "Cuenta de actores"
FROM actor;

-- 39. Selecciona todos los actores y ordénalos por apellido en orden ascendente.
SELECT CONCAT(first_name, ' ', last_name) AS "Actor"
FROM actor
ORDER BY last_name ASC;

-- 40. Selecciona las primeras 5 películas de la tabla “film”.
SELECT *
FROM film
LIMIT 5;

-- 41. Agrupa los actores por su nombre y cuenta cuántos actores tienen el mismo nombre. ¿Cuál es el nombre más repetido?
SELECT Nombre, COUNT(actor_id) AS "Cuenta"
FROM "Tabla Actores"
GROUP BY Nombre
ORDER BY "Cuenta" DESC;

-- 42. Encuentra todos los alquileres y los nombres de los clientes que los realizaron.
WITH "Nombres Clientes" AS (
	SELECT customer_id, CONCAT(first_name, ' ', last_name) AS "Nombre Cliente"
	FROM customer
	)
SELECT r.rental_id AS "Id Alquiler", n."Nombre Cliente"
FROM rental AS r
LEFT JOIN "Nombres Clientes" AS n
ON r.customer_id = n.customer_id;

-- 43. Muestra todos los clientes y sus alquileres si existen, incluyendo aquellos que no tienen alquileres.
SELECT CONCAT(c.first_name, ' ', c.last_name) AS "Nombre Cliente", r.rental_id
FROM customer AS c
LEFT JOIN rental AS r
ON c.customer_id = r.customer_id ;

-- 44. Realiza un CROSS JOIN entre las tablas film y category. ¿Aporta valor esta consulta? ¿Por qué? Deja después de la consulta la contestación
SELECT *
FROM film
CROSS JOIN category;
-- Esta consulta no aporta ningun valor, no nos sirve de nada considerar que una pelicula sea de una categoria que no es realmente.
-- Para asociar las peliculas con sus categorías ya tenemos la tabla film_category.

-- 45. Encuentra los actores que han participado en películas de la categoría 'Action'.
WITH "IDs_Peliculas_Accion" AS (
	SELECT f.film_id
	FROM film AS f
	LEFT JOIN film_category AS fc ON f.film_id = fc.film_id 
	INNER JOIN category AS c ON fc.category_id = c.category_id
	WHERE c.name = 'Action'
	)
SELECT n."Actor" 
FROM film_actor AS fa
LEFT JOIN "Nombres_apellidos_actores" AS n ON fa.actor_id = n.actor_id
WHERE fa.film_id IN (
	SELECT film_id
	FROM "IDs_Peliculas_Accion");

-- 46. Encuentra todos los actores que no han participado en películas.
SELECT *
FROM "Nombres_apellidos_actores" AS n
LEFT JOIN film_actor AS fa ON n.actor_id = fa.actor_id 
WHERE fa.film_id IS NULL;

-- 47. Selecciona el nombre de los actores y la cantidad de películas en las que han participado.
SELECT n."Actor", COUNT(fa.film_id) AS numero_peliculas
FROM "Nombres_apellidos_actores" AS n
INNER JOIN film_actor AS fa ON n.actor_id = fa.actor_id 
GROUP BY "Actor"
ORDER BY numero_peliculas DESC;

-- 48. Crea una vista llamada “actor_num_peliculas” que muestre los nombres de los actores y el número de películas en las que han participado. 
CREATE VIEW "actor_num_peliculas" AS (
SELECT n.actor_id, n."Actor", COUNT(fa.film_id) AS numero_peliculas
FROM "Nombres_apellidos_actores" AS n
INNER JOIN film_actor AS fa ON n.actor_id = fa.actor_id 
GROUP BY n.actor_id, n."Actor"
ORDER BY n.actor_id ASC
);

SELECT * FROM "actor_num_peliculas";

-- 49. Calcula el número total de alquileres realizados por cada cliente.
SELECT CONCAT(c.first_name, ' ', last_name) AS cliente, COUNT(r.rental_id) AS num_alquileres
FROM customer AS c
LEFT JOIN rental AS r ON c.customer_id = r.rental_id
GROUP BY cliente;

-- 50. Calcula la duración total de las películas en la categoría 'Action'. 
WITH "IDs_Peliculas_Accion" AS (
	SELECT f.film_id
	FROM film AS f
	LEFT JOIN film_category AS fc ON f.film_id = fc.film_id 
	INNER JOIN category AS c ON fc.category_id = c.category_id
	WHERE c.name = 'Action'
	)
SELECT SUM(length) AS "Duración Total"
FROM film ;

-- 51. Crea una tabla temporal llamada “cliente_rentas_temporal” para almacenar el total de alquileres por cliente.
CREATE TEMPORARY TABLE "cliente_rentas_temporal" AS (
SELECT CONCAT(c.first_name, ' ', last_name) AS cliente, COUNT(r.rental_id) AS num_alquileres
FROM customer AS c
LEFT JOIN rental AS r ON c.customer_id = r.rental_id
GROUP BY cliente);

SELECT * FROM "cliente_rentas_temporal";

-- 52. Crea una tabla temporal llamada “peliculas_alquiladas” que almacene las películas que han sido alquiladas al menos 10 veces.
CREATE TEMPORARY TABLE "peliculas_alquiladas" AS (
SELECT f.title, COUNT(r.rental_id) AS veces
FROM film AS f
INNER JOIN inventory AS i ON f.film_id = i.film_id
LEFT JOIN rental AS r ON i.inventory_id = r.inventory_id
GROUP BY f.film_id
ORDER BY veces DESC);

SELECT * FROM "peliculas_alquiladas";

-- 53. Encuentra el título de las películas que han sido alquiladas por el cliente
-- con el nombre ‘Tammy Sanders’ y que aún no se han devuelto. Ordena
-- los resultados alfabéticamente por título de película.
SELECT f.title
FROM film f
WHERE EXISTS (
    SELECT 1
    FROM inventory i
    JOIN rental r ON i.inventory_id = r.inventory_id
    JOIN customer c ON r.customer_id = c.customer_id
    WHERE i.film_id = f.film_id
      AND r.return_date IS NULL
      AND CONCAT(c.first_name, ' ', c.last_name) = 'TAMMY SANDERS'
)
ORDER BY f.title ASC;

-- 54. Encuentra los nombres de los actores que han actuado en al menos una
-- película que pertenece a la categoría ‘Sci-Fi’. Ordena los resultados
-- alfabéticamente por apellido.
SELECT CONCAT(first_name, ' ', last_name) AS  "Actor"
FROM actor AS a
WHERE a.actor_id IN (
	SELECT fa.actor_id
	FROM film_actor AS fa
	RIGHT JOIN "Categorías Películas" AS ca
	ON fa.film_id = ca.film_id 
	WHERE ca."Categoría" = 'Sci-Fi')
ORDER BY a.last_name , a.first_name ASC;

-- 55. Encuentra el nombre y apellido de los actores que han actuado en
-- películas que se alquilaron después de que la película ‘Spartacus
-- Cheaper’ se alquilara por primera vez. Ordena los resultados
-- alfabéticamente por apellido.
WITH "peliculas_filtradas" AS (
    SELECT f.film_id
    FROM film f
    JOIN inventory i ON f.film_id = i.film_id
    JOIN rental r ON i.inventory_id = r.inventory_id
    WHERE r.rental_date > (
        SELECT MIN(r2.rental_date)
        FROM film f2
        JOIN inventory i2 ON f2.film_id = i2.film_id
        JOIN rental r2 ON i2.inventory_id = r2.inventory_id
        WHERE f2.title = 'SPARTACUS CHEAPER'
    )
)
SELECT DISTINCT a.first_name, a.last_name
FROM actor a
JOIN film_actor fa ON a.actor_id = fa.actor_id
JOIN peliculas_filtradas pf ON fa.film_id = pf.film_id
ORDER BY a.last_name, a.first_name;


-- 56. Encuentra el nombre y apellido de los actores que no han actuado en ninguna película de la categoría ‘Music’.
WITH music_films AS (
    SELECT film_id
    FROM "Categorías Películas"
    WHERE "Categoría" = 'Music'
)
SELECT naa."Actor"
FROM "Nombres_apellidos_actores" AS naa
WHERE NOT EXISTS (
    SELECT 1
    FROM film_actor fa
    RIGHT JOIN music_films mf ON fa.film_id = mf.film_id
    WHERE fa.actor_id = naa.actor_id
)
ORDER BY naa."Actor";

-- 57. Encuentra el título de todas las películas que fueron alquiladas por más de 8 días.
SELECT f.title, (DATE(r.return_date) - DATE(r.rental_date)) AS "Duracion Alquiler"
FROM film AS f
LEFT JOIN inventory AS i ON f.film_id = i.film_id 
LEFT JOIN rental AS r ON i.inventory_id = r.inventory_id
WHERE (DATE(r.return_date) - DATE(r.rental_date)) > 8
ORDER BY "Duracion Alquiler" ASC;

-- 58. Encuentra el título de todas las películas que son de la misma categoría que ‘Animation’.
SELECT f.title, c."name" AS "Categoría"
FROM film AS f
LEFT JOIN film_category AS fc ON f.film_id = fc.film_id
LEFT JOIN category AS c ON fc.category_id = c.category_id 
WHERE c."name" = 'Animation';

-- 59. Encuentra los nombres de las películas que tienen la misma duración
-- que la película con el título ‘Dancing Fever’. Ordena los resultados
-- alfabéticamente por título de película.
SELECT f.title, f.length
FROM film AS f
WHERE f.length = (
	SELECT f2.length
	FROM film AS f2
	WHERE f2.title = 'DANCING FEVER')
ORDER BY f.title ASC;

-- 60. Encuentra los nombres de los clientes que han alquilado al menos 7
-- películas distintas. Ordena los resultados alfabéticamente por apellido.
SELECT CONCAT(c.first_name, ' ', c.last_name) AS cliente, COUNT(DISTINCT i.film_id) AS peliculas_alquiladas
FROM customer AS c 
LEFT JOIN rental AS r ON c.customer_id = r.customer_id 
LEFT JOIN inventory AS i ON r.inventory_id = i.inventory_id 
GROUP BY c.customer_id
ORDER BY c.last_name, c.first_name ASC;

-- 61. Encuentra la cantidad total de películas alquiladas por categoría y
-- muestra el nombre de la categoría junto con el recuento de alquileres.
SELECT cp."Categoría", COUNT(i.film_id) AS recuento
FROM "Categorías Películas" AS cp
INNER JOIN inventory AS i ON cp.film_id = i.film_id
INNER JOIN rental AS r ON i.inventory_id = r.inventory_id
GROUP BY cp."Categoría"
ORDER BY recuento DESC;

-- 62. Encuentra el número de películas por categoría estrenadas en 2006.
SELECT cp."Categoría", COUNT(f.film_id) AS recuento
FROM "Categorías Películas" AS cp
INNER JOIN film AS f ON cp.film_id = f.film_id
WHERE release_year = 2006
GROUP BY cp."Categoría"
ORDER BY recuento DESC;

-- 63. Obtén todas las combinaciones posibles de trabajadores con las tiendas que tenemos.
SELECT CONCAT(first_name, ' ', last_name) AS empleado, store.store_id
FROM staff 
CROSS JOIN store;

-- 64. Encuentra la cantidad total de películas alquiladas por cada cliente y
-- muestra el ID del cliente, su nombre y apellido junto con la cantidad de películas alquiladas.
WITH nombres_clientes AS ( 
	SELECT customer_id AS "ID", CONCAT(first_name, ' ', last_name) AS "Cliente"
	FROM customer
	)
SELECT nc."ID", nc."Cliente", COUNT(film_id) AS "Películas Alquiladas"
FROM nombres_clientes AS nc
LEFT JOIN rental AS r ON r.customer_id = nc."ID"
INNER JOIN inventory AS i ON r.inventory_id = i.inventory_id
GROUP BY nc."ID", nc."Cliente"
ORDER BY "Películas Alquiladas" DESC;

