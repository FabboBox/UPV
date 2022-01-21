--7. Mostrar todos los t�tulos de los libros que tienen t�tulo en orden 
--alfab�tico descendente.
SELECT titulo
FROM LIBRO
WHERE NOT titulo IS NULL
ORDER BY titulo DESC;

--8. Obtener cu�ntas obras hay en los libros publicados entre 1990 y 1999.
SELECT SUM(num_obras) AS OBRAS
FROM LIBRO
WHERE a�o BETWEEN 1990 AND 1999;

--13. Obtener el t�tulo y el identificador de los libros que tengan t�tulo y 
--m�s de una obra. Resolver este ejercicio sin utilizar el atributo num_obras.
SELECT DISTINCT lib.id_lib, lib.titulo 
FROM LIBRO lib, ESTA_EN e1, ESTA_EN e2
WHERE lib.titulo IS NOT NULL AND e1.id_lib = lib.id_lib 
    AND lib.id_lib = e2.id_lib AND e1.cod_ob <> e2.cod_ob;


--15. �Cu�ntos autores hay en la base de datos de los que no se tiene ninguna 
--obra?
SELECT COUNT(*) AS SIN_OBRA
FROM AUTOR au
WHERE au.autor_id NOT IN(
    SELECT es.autor_id
    FROM ESCRIBIR es
);

--16. Obtener el nombre de esos autores.
SELECT au.nombre
FROM AUTOR au
WHERE au.autor_id NOT IN(
    SELECT es.autor_id
    FROM ESCRIBIR es
);

--17. Obtener el nombre de los autores de nacionalidad �Espa�ola� que han 
--escrito dos o m�s obras.
SELECT au.nombre
FROM AUTOR au
WHERE au.nacionalidad = 'Espa�ola' AND (
    SELECT COUNT(*)
    FROM ESCRIBIR es
    WHERE es.autor_id = au.autor_id
)>1;

--19. Obtener el t�tulo y el c�digo de las obras que tengan m�s de un autor.
SELECT ob.titulo, ob.cod_ob
FROM OBRA ob
WHERE (
    SELECT COUNT(*)
    FROM ESCRIBIR es
    WHERE es.cod_ob = ob.cod_ob
)>1;