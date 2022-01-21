--3.1 Consultas sobre una sola tabla

-- 1. Obtener ordenados ascendentemente los c�digos de los pa�ses de donde son 
--los actores.
SELECT DISTINCT COD_PAIS
FROM ACTOR
ORDER BY COD_PAIS;

--2. Obtener el c�digo y el t�tulo de las pel�culas de a�o anterior a 1970 que 
--no est�n basadas en ning�n libro ordenadas por t�tulo.
SELECT cod_peli, titulo
FROM PELICULA
WHERE anyo < 1970 AND cod_lib IS NULL 
ORDER BY titulo;

--3. Obtener el c�digo y el nombre de los actores cuyo nombre incluye �John�.
SELECT cod_act, nombre
FROM ACTOR
WHERE nombre LIKE '%John%';

--4. Obtener el c�digo y el t�tulo de las pel�culas de m�s de 120 minutos de la 
--d�cada de los 80.
SELECT cod_peli, titulo
FROM PELICULA
WHERE duracion > 120 AND anyo BETWEEN 1980 AND 1989;

--5. Obtener el c�digo y el t�tulo de las pel�culas que est�n basadas en alg�n 
--libro y cuyo director se apellide �Pakula�.
SELECT cod_peli, titulo 
FROM PELICULA
WHERE NOT cod_lib IS NULL AND director LIKE '%Pakula%';

--6. �Cu�ntas pel�culas hay de m�s de 120 minutos de la d�cada de los 80?
SELECT COUNT(*)
FROM PELICULA
WHERE duracion > 120 AND anyo LIKE '198_';

--7. �Cu�ntas pel�culas se han clasificado de los g�neros de c�digo 'BB5' 
--o 'GG4' o'JH6'
SELECT COUNT(DISTINCT cod_peli) AS CU�NTAS_PELIS
FROM CLASIFICACION
WHERE cod_gen IN ('BB5', 'GG4', 'JH6');

--8. �De qu� a�o es el libro m�s antiguo?
SELECT MIN(anyo) AS A�O
FROM LIBRO_PELI;

--9. �Cu�l es la duraci�n media de las pel�culas del a�o 1987?
SELECT AVG(duracion) AS DURACI�N_MEDIA
FROM PELICULA
WHERE anyo = '1987';

--10. �Cu�ntos minutos ocupan todas las pel�culas dirigidas por �Steven 
--Spielberg�?
SELECT SUM(duracion) AS DURAN_MIN
FROM PELICULA
WHERE director = 'Steven Spielberg';

--------------------------------------------------------------------------------
--3.2 Consultas sobre varias tablas

--11. Obtener el c�digo y el t�tulo de las pel�culas en las que act�a un actor 
--con el mismo nombre que el director de la pel�cula (ordenadas por t�tulo).
SELECT  DISTINCT PELICULA.cod_peli, PELICULA.titulo         --DISTINCT se usa ya que un actor puede estar en varias pelis como director
FROM PELICULA, ACTUA, ACTOR
WHERE PELICULA.cod_peli = ACTUA.cod_peli AND ACTUA.cod_act = ACTOR.cod_act
    AND ACTOR.nombre = PELICULA.director
ORDER BY PELICULA.titulo;

--12. Obtener el c�digo y el t�tulo de las pel�culas clasificadas del g�nero de 
--nombre �Comedia� (ordenadas por t�tulo).
SELECT PELICULA.cod_peli, PELICULA.titulo
FROM PELICULA, CLASIFICACION, GENERO
WHERE PELICULA.cod_peli = CLASIFICACION.cod_peli 
    AND CLASIFICACION.cod_gen = GENERO.cod_gen AND GENERO.nombre = 'Comedia'
ORDER BY PELICULA.titulo;

--13. Obtener el c�digo y el t�tulo de las pel�culas basadas en alg�n libro 
--anterior a 1950.
SELECT PELICULA.cod_peli, PELICULA.titulo
FROM PELICULA, LIBRO_PELI
WHERE PELICULA.cod_lib = LIBRO_PELI.cod_lib AND LIBRO_PELI.anyo < 1950
ORDER BY PELICULA.titulo;

--14. Obtener el c�digo y el nombre de los pa�ses de los actores que act�an en 
--pel�culas clasificadas del g�nero de nombre �Comedia� (ordenados por nombre).
SELECT DISTINCT pa.cod_pais, pa.nombre 
FROM PAIS pa, ACTOR act, ACTUA ac, CLASIFICACION ca, GENERO ge   --No se a�ade la tabla PELICULA ya que para 
WHERE pa.cod_pais = act.cod_pais AND act.cod_act = ac.cod_act    --enlazar PAIS con GENERO no es necesario
    AND ac.cod_peli = ca.cod_peli AND ca.cod_gen = ge.cod_gen 
    AND ge.nombre = 'Comedia'
ORDER BY pa.nombre;

--------------------------------------------------------------------------------
--3.3 Consultas con subconsultas

--15. Resolver los ejercicios 11, 12, 13 y 14 con subconsultas. Las soluciones 
--son exactamente las mismas.
    --11. Obtener el c�digo y el t�tulo de las pel�culas en las que act�a un actor 
    --con el mismo nombre que el director de la pel�cula (ordenadas por t�tulo).
    SELECT pe.cod_peli, pe.titulo
    FROM PELICULA pe
    WHERE EXISTS(
        SELECT *
        FROM ACTUA ac, ACTOR act
        WHERE pe.cod_peli = ac.cod_peli AND ac.cod_act = act.cod_act 
        AND pe.director = act.nombre
    )
    ORDER BY pe.titulo;
        -- ALTERNATIVA:
        SELECT pe.cod_peli, pe.titulo AS ALTERNATIVA_1
        FROM PELICULA pe
        WHERE EXISTS(
            SELECT *
            FROM ACTUA ac
            WHERE pe.cod_peli = ac.cod_peli AND EXISTS(
                SELECT *
                FROM ACTOR act
                WHERE ac.cod_act = act.cod_act AND pe.director = act.nombre
            )
        )
        ORDER BY pe.titulo;
        -- ALTERNATIVA:
        SELECT pe.cod_peli, pe.titulo AS ALTERNATIVA_2
        FROM PELICULA pe
        WHERE cod_peli IN(
            SELECT ac.cod_peli
            FROM ACTUA ac, ACTOR act
            WHERE ac.cod_act = act.cod_act AND pe.director = act.nombre
        )
        ORDER BY pe.titulo;
    
    --12. Obtener el c�digo y el t�tulo de las pel�culas clasificadas del g�nero de 
    --nombre �Comedia� (ordenadas por t�tulo).
    SELECT pe.cod_peli, pe.titulo
    FROM PELICULA pe
    WHERE EXISTS(
        SELECT *
        FROM CLASIFICACION ca
        WHERE pe.cod_peli = ca.cod_peli AND EXISTS(
            SELECT *
            FROM GENERO ge
            WHERE ca.cod_gen = ge.cod_gen AND ge.nombre = 'Comedia' 
        )
    )
    ORDER BY pe.titulo;
        --ALTERNATIVA
        SELECT pe.cod_peli, pe.titulo AS ALTERNATIVA
        FROM PELICULA pe
        WHERE pe.cod_peli IN(
            SELECT ca.cod_peli
            FROM CLASIFICACION ca
            WHERE ca.cod_gen IN(
                SELECT ge.cod_gen
                FROM GENERO ge
                WHERE ge.nombre = 'Comedia' 
            )
        )
        ORDER BY pe.titulo;
    
    
    --13. Obtener el c�digo y el t�tulo de las pel�culas basadas en alg�n libro 
    --anterior a 1950.
    SELECT pe.cod_peli, pe.titulo
    FROM PELICULA pe
    WHERE pe.cod_lib IN(
        SELECT lib.cod_lib
        FROM LIBRO_PELI lib
        WHERE lib.anyo < 1950
    )
    ORDER BY pe.titulo;
    
    --14. Obtener el c�digo y el nombre de los pa�ses de los actores que act�an en 
    --pel�culas clasificadas del g�nero de nombre �Comedia� (ordenados por nombre).
    SELECT pa.cod_pais, pa.nombre
    FROM PAIS pa
    WHERE pa.cod_pais IN(
        SELECT act.cod_pais
        FROM ACTOR act
        WHERE act.cod_act IN(
            SELECT ac.cod_act
            FROM ACTUA ac
            WHERE ac.cod_peli IN(
                SELECT ca.cod_peli
                FROM CLASIFICACION ca, GENERO ge
                WHERE ca.cod_gen = ge.cod_gen AND ge.nombre = 'Comedia'
            )
        )
    )
    ORDER BY pa.nombre;
    
--16. Obtener el c�digo y el nombre de los actores nacidos antes de 1950 que 
--act�an con un papel �Principal� en alguna pel�cula (ordenados por nombre).
SELECT act.cod_act, act.nombre
FROM ACTOR act
WHERE EXTRACT(YEAR FROM act.fecha_nac) < 1950 AND act.cod_act IN(
    SELECT ac.cod_act
    FROM  ACTUA ac
    WHERE ac.papel = 'Principal' --AND NOT ac.cod_peli IS NULL esto sobra porque en ACTUA {cod_act,cod_peli} son CP
)
ORDER BY act.nombre;

--17. Obtener el c�digo, el t�tulo y el autor de los libros en los que se ha 
--basado alguna pel�cula de la d�cada de los 90 (ordenados por t�tulo).
SELECT lib.cod_lib, lib.titulo, lib.autor
FROM LIBRO_PELI lib
WHERE EXISTS(
    SELECT *
    FROM PELICULA pe
    WHERE lib.cod_lib = pe.cod_lib AND pe.anyo BETWEEN 1990 AND 1999
)
ORDER BY lib.titulo;
    --ALTERNATIVA
    SELECT lib.cod_lib AS ALTERNATIVA, lib.titulo AS ALTERNATIVA, 
        lib.autor AS ALTERNATIVA
    FROM LIBRO_PELI lib
    WHERE lib.cod_lib IN(
        SELECT pe.cod_lib
        FROM PELICULA pe
        WHERE pe.anyo BETWEEN 1990 AND 1999
    )
    ORDER BY lib.titulo;
    
--18. Obtener el c�digo, el t�tulo y el autor de los libros en los que no se 
--haya basado ninguna pel�cula.
SELECT lib.cod_lib, lib.titulo, lib.autor
FROM LIBRO_PELI lib
WHERE NOT EXISTS(
    SELECT *
    FROM PELICULA pe
    WHERE lib.cod_lib = pe.cod_lib
);
    --ALTERNATIVA
    SELECT lib.cod_lib, lib.titulo, lib.autor
    FROM LIBRO_PELI lib
    WHERE lib.cod_lib NOT IN(
        SELECT pe.cod_lib
        FROM PELICULA pe
        WHERE pe.cod_lib IS NOT NULL
    );
    
--19. Obtener el nombre del g�nero o g�neros a los que pertenecen pel�culas en 
--las que no act�a ning�n actor (ordenados por nombre).
--ALTERNATIVA
SELECT ge.nombre
FROM GENERO ge
WHERE ge.cod_gen IN(
    SELECT ca.cod_gen
    FROM CLASIFICACION ca
    WHERE ca.cod_peli NOT IN(
        SELECT ac.cod_peli
        FROM ACTUA ac
        --WHERE ac.cod_act IS NOT NULL -- Esta l�nea sobra ya que {cad_act, cod_peli} es CP por lo que no contendr�n valor nulo
    )
)
ORDER BY ge.nombre;

--20. Obtener el t�tulo de los libros en los que se haya basado alguna pel�cula 
--en la que no hayan actuado actores del pa�s de nombre �USA� (ordenados por 
--t�tulo).
SELECT lib.titulo
FROM LIBRO_PELI lib
WHERE lib.cod_lib IN(
    SELECT pe.cod_lib
    FROM PELICULA pe
    WHERE pe.cod_peli NOT IN(
        SELECT ac.cod_peli 
        FROM ACTUA ac, ACTOR act
        WHERE ac.cod_act = act.cod_act AND act.cod_pais IN(
            SELECT pa.cod_pais
            FROM PAIS pa
            WHERE pa.nombre = 'USA'
        )
    )
)
ORDER BY lib.titulo;

--Alternativa con una subconsulta:
SELECT DISTINCT lib.titulo
FROM LIBRO_PELI lib, PELICULA p
WHERE lib.cod_lib = p.cod_lib AND p.cod_peli NOT IN(
        SELECT ac.cod_peli 
        FROM ACTUA ac, ACTOR act, PAIS pa
        WHERE ac.cod_act = act.cod_act AND act.cod_pais = pa.cod_pais
                    AND pa.nombre = 'USA'
        )
ORDER BY lib.titulo;

--21. �Cu�ntas pel�culas hay clasificadas del g�nero de nombre �Comedia� y en 
--las que s�lo aparece un actor con el papel �Secundario�?
SELECT COUNT(*)
FROM PELICULA pe
WHERE pe.cod_peli IN(
    SELECT ca.cod_peli
    FROM CLASIFICACION ca
    WHERE ca.cod_gen IN(
        SELECT ge.cod_gen
        FROM GENERO ge
        WHERE ge.nombre = 'Comedia' 
    )
) AND (SELECT COUNT(*)
        FROM ACTUA ac
        WHERE ac.cod_peli = pe.cod_peli AND ac.papel = 'Secundario'
        )=1;

--22. Obtener el a�o de la primera pel�cula en la que el actor de nombre �Jude 
--Law� tuvo un papel como �Principal�.
SELECT MIN(pe.anyo) AS ANYO
FROM PELICULA pe
WHERE pe.cod_peli IN(
    SELECT ac.cod_peli
    FROM ACTUA ac
    WHERE ac.papel = 'Principal' AND ac.cod_act IN(
        SELECT act.cod_act
        FROM ACTOR act
        WHERE act.nombre = 'Jude Law'
    )
);

--23. Obtener el c�digo y el nombre de actor o actores m�s viejos.
SELECT act.cod_act, act.nombre
FROM ACTOR act
WHERE act.fecha_nac IN(
    SELECT MIN(ac.fecha_nac)
    FROM ACTOR ac
);

--24. Obtener el c�digo, el nombre y la fecha de nacimiento del actor m�s viejo 
--nacido en el a�o 1940.
SELECT act.cod_act, act.nombre, act.fecha_nac
FROM ACTOR act
WHERE act.fecha_nac IN(
    SELECT MIN(ac.fecha_nac)
    FROM ACTOR ac
    WHERE EXTRACT (YEAR FROM ac.fecha_nac) = 1940 
);

--25. Obtener el nombre del g�nero (o de los g�neros) en los que se ha 
--clasificado la pel�cula m�s larga.
SELECT gen.nombre
FROM GENERO gen
WHERE gen.cod_gen IN(
    SELECT ca.cod_gen
    FROM CLASIFICACION ca
    WHERE ca.cod_peli IN(
        SELECT pe.cod_peli
        FROM PELICULA pe
        WHERE pe.duracion IN(
            SELECT MAX(pe.duracion)
            FROM PELICULA pe
        )        
    )
);

--26. Obtener el c�digo y el t�tulo de los libros en los que se han basado 
--pel�culas en las que act�an actores del pa�s de nombre Espa�a (ordenados por 
--t�tulo).
SELECT lib.cod_lib, lib.titulo
FROM LIBRO_PELI lib 
WHERE lib.cod_lib IN(
    SELECT p.cod_lib
    FROM PELICULA p
    WHERE EXISTS(
        SELECT *
        FROM ACTUA ac, ACTOR act, PAIS pa
        WHERE ac.cod_peli = p.cod_peli AND ac.cod_act = act.cod_act
                AND pa.cod_pais = act.cod_pais AND pa.nombre = 'Espa�a'
    )
)
ORDER BY lib.titulo;

--27. Obtener el t�tulo de las pel�culas anteriores a 1950 clasificadas en m�s 
--de un g�nero (ordenadas por t�tulo).
SELECT p.titulo
FROM PELICULA p
WHERE p.anyo < 1950 AND (
    SELECT COUNT(*)
    FROM CLASIFICACION ca
    WHERE ca.cod_peli = p.cod_peli
) > 1
ORDER BY p.titulo;

--28. Obtener la cantidad de pel�culas en las que han participado menos de 4 
--actores.
SELECT COUNT(*)
FROM PELICULA p
WHERE (
    SELECT COUNT(*)
    FROM ACTUA ac
    WHERE ac.cod_peli = p.cod_peli 
) < 4;

--29. Obtener los directores que han dirigido m�s de 250 minutos entre todas 
--sus pel�culas.
SELECT DISTINCT p1.director
FROM PELICULA p1
WHERE (
    SELECT SUM(p2.duracion)
    FROM PELICULA p2
    WHERE p1.director = p2.director
) > 250;

--30. Obtener el a�o o a�os en el que nacieron m�s de 3 actores.
SELECT DISTINCT (EXTRACT (YEAR FROM act1.fecha_nac)) AS A�O
FROM ACTOR act1
WHERE (
    SELECT COUNT(*)
    FROM ACTOR act2
    WHERE (EXTRACT (YEAR FROM act1.fecha_nac)) = (EXTRACT 
                        (YEAR FROM act2.fecha_nac))
) > 3;

--31. Obtener el c�digo y nombre del actor m�s joven que ha participado en una 
--pel�cula clasificada del g�nero de c�digo �DD8�.
SELECT act.cod_act, act.nombre 
FROM ACTOR act
WHERE act.fecha_nac = (
    SELECT MAX(act2.fecha_nac)
    FROM ACTOR act2
    WHERE act2.cod_act IN (
        SELECT ac.cod_act
        FROM ACTUA ac, CLASIFICACION ca
        WHERE ac.cod_peli = ca.cod_peli AND ca.cod_gen = 'DD8'
    )
);

--3.4 Consultas universalmente cuantificadas

--32. Obtener el c�digo y el nombre de los pa�ses con actores y tales que todos los 
--actores de ese pa�s han nacido en el siglo XX (ordenados por nombre).
SELECT pa.cod_pais, pa.nombre
FROM PAIS pa
WHERE NOT EXISTS(
    SELECT *
    FROM ACTOR act
    WHERE act.cod_pais = pa.cod_pais 
        AND EXTRACT(YEAR FROM act.fecha_nac) NOT BETWEEN 1899 AND 2000 
) AND pa.cod_pais IN(
    SELECT cod_pais
    FROM ACTOR
)
ORDER BY pa.nombre;

--Alternativa:

SELECT pa.cod_pais, pa.nombre
FROM PAIS pa
WHERE (
    SELECT COUNT(*)
    FROM ACTOR act
    WHERE pa.cod_pais = act.cod_pais
) = (
    SELECT COUNT(*)
    FROM ACTOR act
    WHERE pa.cod_pais = act.cod_pais
        AND EXTRACT(YEAR FROM act.fecha_nac) LIKE '19__' 
) AND pa.cod_pais IN(
    SELECT cod_pais
    FROM ACTOR
);

--33. Obtener el c�digo y el nombre de los actores tales que todos los papeles que 
--han tenido son de �Secundario�. S�lo interesan aquellos actores que hayan actuado
--en alguna pel�cula.
SELECT act.cod_act, act.nombre
FROM ACTOR act
WHERE NOT EXISTS(
    SELECT *
    FROM ACTUA ac
    WHERE ac.cod_act = act.cod_act AND ac.papel <> 'Secundario'
) AND act.cod_act IN (
    SELECT cod_act FROM ACTUA 
)
ORDER BY act.nombre;

--Alternativa: 

SELECT act.cod_act, act.nombre
FROM ACTOR act
WHERE (
    SELECT COUNT(*)
    FROM ACTUA ac1
    WHERE ac1.cod_act = act.cod_act AND ac1.papel = 'Secundario'
) = (
    SELECT COUNT(*)
    FROM ACTUA ac2
    WHERE ac2.cod_act = act.cod_act
) AND act.cod_act IN (
    SELECT cod_act FROM ACTUA 
)
ORDER BY act.nombre;

--34. Obtener el c�digo y el nombre de los actores que han aparecido en todas las 
--pel�culas del director �Guy Ritchie� (s�lo si ha dirigido al menos una).
SELECT act.cod_act, act.nombre
FROM ACTOR act
WHERE NOT EXISTS(
    SELECT *
    FROM PELICULA p
    WHERE p.director = 'Guy Ritchie' AND NOT EXISTS(
        SELECT *
        FROM ACTUA ac
        WHERE act.cod_act = ac.cod_act
                    AND ac.cod_peli = p.cod_peli
    )
) AND EXISTS (
    SELECT *
    FROM PELICULA p
    WHERE p.director = 'Guy Ritchie'
);

--Alternativa:

SELECT act.cod_act, act.nombre
FROM ACTOR act
WHERE (
    SELECT COUNT(*)
    FROM PELICULA p
    WHERE p.director = 'Guy Ritchie' 
) = (
    SELECT COUNT(*)
    FROM Actua ac, PELICULA p
    WHERE ac.cod_act = act.cod_act AND ac.cod_peli = p.cod_peli AND
        p.director = 'Guy Ritchie' 
) AND EXISTS (
    SELECT *
    FROM PELICULA p
    WHERE p.director = 'Guy Ritchie' 
);

--35. Resolver la consulta anterior pero para el director de nombre �John Steel�.
SELECT act.cod_act, act.nombre
FROM ACTOR act
WHERE NOT EXISTS(
    SELECT *
    FROM PELICULA p
    WHERE p.director = 'John Steel' AND NOT EXISTS(
        SELECT *
        FROM ACTUA ac
        WHERE act.cod_act = ac.cod_act
                    AND ac.cod_peli = p.cod_peli
    )
) AND EXISTS (
    SELECT *
    FROM PELICULA p
    WHERE p.director = 'John Steel'
);

--Alternativa:

SELECT act.cod_act, act.nombre
FROM ACTOR act
WHERE (
    SELECT COUNT(*)
    FROM PELICULA p
    WHERE p.director = 'John Steel'
) = (
    SELECT COUNT(*)
    FROM Actua ac, PELICULA p
    WHERE ac.cod_act = act.cod_act AND ac.cod_peli = p.cod_peli AND
        p.director = 'John Steel'
) AND EXISTS (
    SELECT *
    FROM PELICULA p
    WHERE p.director = 'John Steel'
);

--36. Obtener el c�digo y el t�tulo de las pel�culas de menos de 100 minutos en las 
--que todos los actores que han actuado son de un mismo pa�s.
SELECT p.cod_peli, p.titulo
FROM PELICULA p
WHERE p.duracion < 100 AND NOT EXISTS(
    SELECT * 
    FROM ACTUA ac2, ACTUA ac1, ACTOR act1, ACTOR act2
    WHERE p.cod_peli = ac1.cod_peli AND p.cod_peli = ac2.cod_peli 
                AND ac2.cod_act = act2.cod_act AND ac1.cod_act = act1.cod_act 
                AND NOT act1.cod_pais = act2.cod_pais
) AND p.cod_peli IN (
    SELECT cod_peli
    FROM ACTUA
) ;

--37. Obtener el c�digo, el t�tulo y el a�o de las pel�culas en las que haya actuado 
--alg�n actor si se cumple que todos los actores que han actuado en ella han nacido 
--antes del a�o 1943 (hasta el 31/12/1942).
SELECT p.cod_peli, p.titulo, p.anyo
FROM PELICULA p
WHERE NOT EXISTS(
    SELECT *
    FROM ACTUA ac, ACTOR act
    WHERE p.cod_peli = ac.cod_peli AND ac.cod_act = act.cod_act
                AND NOT EXTRACT(YEAR FROM act.fecha_nac) < 1943
) AND p.cod_peli IN (
    SELECT cod_peli
    FROM ACTUA
) 
ORDER BY p.titulo;

--38. Obtener el c�digo y el nombre de cada pa�s si se cumple que todos sus actores 
--han actuado en al menos una pel�cula de m�s de 120 minutos. (Ordenados por 
--nombre).
SELECT pa.cod_pais, pa.nombre 
FROM PAIS pa
WHERE NOT EXISTS(
    SELECT *
    FROM ACTOR act
    WHERE act.cod_pais = pa.cod_pais AND NOT EXISTS(
        SELECT *
        FROM ACTUA ac, PELICULA p
        WHERE ac.cod_act = act.cod_act AND p.cod_peli = ac.cod_peli
                    AND p.duracion >120
    )
) AND pa.cod_pais IN (
    SELECT cod_pais
    FROM ACTOR
)
ORDER BY pa.nombre;

--3.5 Consultas agrupadas

--39. Obtener el c�digo y el t�tulo del libro o libros en que se ha basado m�s de una 
--pel�cula, indicando cu�ntas pel�culas se han hecho sobre �l.
SELECT lib.cod_lib, lib.titulo, COUNT(*)
FROM LIBRO_PELI lib, PELICULA p
WHERE lib.cod_lib = p.cod_lib
GROUP BY lib.cod_lib, lib.titulo
HAVING COUNT(*)>1;

--40. Obtener para cada g�nero en el que se han clasificado m�s de 5 pel�culas, el 
--c�digo y el nombre del g�nero indicando la cantidad de pel�culas del mismo y 
--duraci�n media de sus pel�culas. (Ordenados por nombre). (La funci�n ROUND 
--redondea al entero m�s cercano).
SELECT gen.cod_gen, gen.nombre, COUNT(*) AS CU�NTAS, 
            ROUND(AVG(p.duracion)) AS DUR_MEDI
FROM GENERO gen, CLASIFICACION ca, PELICULA p
WHERE gen.cod_gen = ca.cod_gen AND p.cod_peli = ca.cod_peli
GROUP BY gen.cod_gen, gen.nombre
HAVING COUNT(*) > 5
ORDER BY gen.nombre;

--41. Obtener el c�digo y el t�tulo de las pel�culas de a�o posterior al 2000 junto con 
--el n�mero de g�neros en que est�n clasificadas, si es que est�n en alguno. 
--(Ordenadas por t�tulo).
SELECT p.cod_peli, p.titulo, COUNT(*)
FROM PELICULA p, CLASIFICACION ca
WHERE p.anyo > 2000 AND p.cod_peli = ca.cod_peli
GROUP BY p.cod_peli, p.titulo
ORDER BY p.titulo;

--42. Obtener los directores que tienen la cadena �George� en su nombre y que han 
--dirigido exactamente dos pel�culas.
SELECT p.director
FROM PELICULA p
WHERE p.director LIKE '%George%'
GROUP BY p.director
HAVING COUNT(*) = 2;

--43. Obtener para cada pel�cula clasificada exactamente en un g�nero y en la que 
--haya actuado alg�n actor, el c�digo, el t�tulo y la cantidad de actores que act�an 
--en ella.
SELECT p.cod_peli, p.titulo, COUNT(DISTINCT ac.cod_act)
FROM PELICULA p, ACTUA ac, CLASIFICACION ca
WHERE p.cod_peli = ac.cod_peli AND ca.cod_peli = p.cod_peli
GROUP BY p.cod_peli, p.titulo
HAVING COUNT(DISTINCT ca.cod_gen) = 1
ORDER BY p.titulo;

--45. Obtener el c�digo, el nombre del g�nero en el que hay clasificadas m�s 
--pel�culas (puede haber m�s de uno).
SELECT gen.cod_gen, gen.nombre
FROM GENERO gen, CLASIFICACION ca
WHERE gen.cod_gen = ca.cod_gen
GROUP BY gen.cod_gen, gen.nombre
HAVING COUNT(*) = (
    SELECT MAX(COUNT(*))
    FROM CLASIFICACION c
    GROUP BY c.cod_gen
);

--3.6 Consultas con concatenaci�n

--50. Obtener para todos los pa�ses que hay en la base de datos, el c�digo, el nombre 
--y la cantidad de actores que hay de ese pa�s.
SELECT pa.cod_pais, pa.nombre, COUNT(act.cod_pais) 
FROM PAIS pa LEFT JOIN ACTOR act ON pa.cod_pais = act.cod_pais
GROUP BY pa.cod_pais, pa.nombre
ORDER BY pa.nombre;

--51. Obtener el c�digo y el t�tulo de todos los libros de la base de datos de a�o 
--posterior a 1980 junto con la cantidad de pel�culas a que han dado lugar.
SELECT lib.cod_lib, lib.titulo, COUNT(p.cod_peli)
FROM LIBRO_PELI lib LEFT JOIN PELICULA p ON lib.cod_lib = p.cod_lib
WHERE lib.anyo > 1980
GROUP BY lib.cod_lib, lib.titulo;

--52. Obtener para todos los pa�ses que hay en la base de datos, el c�digo, el nombre 
--y la cantidad de actores que hay de ese pa�s que hayan tenido un papel como 
--�Secundario� en alguna pel�cula.
SELECT pa.cod_pais, pa.nombre, COUNT(DISTINCT act.cod_act)
FROM PAIS pa LEFT JOIN (ACTOR act JOIN ACTUA ac ON act.cod_act = ac.cod_act 
                        AND ac.papel = 'Secundario') ON pa.cod_pais = act.cod_pais
GROUP BY pa.cod_pais, pa.nombre
ORDER BY pa.nombre;

--53. Obtener para cada pel�cula que hay en la base de datos que dure m�s de 140 
--minutos, el c�digo, el t�tulo, la cantidad de g�neros en los que est� clasificado y la 
--cantidad de actores que han actuado en ella.
SELECT p.cod_peli, p.titulo, COUNT(DISTINCT ca.cod_gen) AS GENEROS, 
            COUNT(DISTINCT ac.cod_act) AS ACTORES
FROM PELICULA p LEFT JOIN CLASIFICACION ca ON p.cod_peli = ca.cod_peli
                            LEFT JOIN ACTUA ac ON p.cod_peli = ac.cod_peli
WHERE p.duracion > 140
GROUP BY p.cod_peli, p.titulo
ORDER BY p.titulo;
