-- Crear una base de datos que pertenezca a mi usuario
CREATE DATABASE analysis WITH OWNER = diego


-- Crear una tabla
CREATE TABLE IF NOT EXISTS teachers ( -- IF NOT EXISTS impide que devuelva un error si la tabla ya existe
    id BIGSERIAL, -- Como AUTOINCREMENT en MySQL
    first_name VARCHAR(25),
    last_name VARCHAR(50),
    school VARCHAR(50),
    hire_date DATE,
    salary NUMERIC
);


-- Insertar datos en una tabla
INSERT INTO teachers (first_name, last_name, school, hire_date, salary) VALUES 
    ('Janet', 'Smith', 'F.D. Roosevelt HS', '2011-10-30', 36200),  -- El ID no se inserta porque
    ('Lee', 'Reynolds', 'F.D. Roosevelt HS', '1993-05-22', 65000); -- PostgresSQL va incrementando el valor


-- Seleccionar todos los registros de una tabla
SELECT * FROM teachers; -- (1)
TABLE teachers; -- (2)


-- Seleccionar todos los registros de una tabla de columnas específicas
SELECT last_name, first_name, salary FROM public.teachers;


-- Ordenar con respecto a una columna
SELECT last_name, first_name, salary FROM public.teachers ORDER BY salary DESC;

-- Cuando no se especifica la keyword DESC se ordena ascendentemente, pero si se quiere ser
-- más descriptivos se puede utilizar la keyword ASC


-- También se puede indicar la columna con la que se va a ordenar por su índice posicional comenzando con 1
SELECT last_name, first_name, salary FROM public.teachers ORDER BY 3 DESC;


-- Se puede ordenar con respecto a multiples columnas pero se hace difícil de leer a
-- medida que se hacen ordenamientos con m-as columnas
SELECT last_name, school, hire_date FROM teachers ORDER BY school ASC, hire_date DESC;


-- DISTINCT devuelve los valores únicos de la columna school
SELECT DISTINCT school FROM teachers ORDER By school;


-- En este caso la sentencia retorna los pares de valores únicos school, salary
SELECT DISTINCT school, salary FROM teachers ORDER BY school, salary;


SELECT last_name, school, hire_date FROM teachers WHERE school = 'Myers Middle School';
/* Esta parte me parece interesante por que, además de poder utilizar los comparadores de
toda la vida como =, !=, <, <=, >, >= se pueden utilizar:

    BETWEEN: */
SELECT last_name, school, hire_date, salary FROM teachers WHERE salary BETWEEN 20000 AND 40000;

--  IN:
SELECT last_name, school, hire_date FROM teachers WHERE last_name IN ('Bush', 'Roush');

--  LIKE (case sensitive):
SELECT last_name, school, hire_date FROM teachers WHERE first_name LIKE 'Sam%';

--  ILIKE (case insensitive):
SELECT last_name, school, hire_date FROM teachers WHERE first_name LIKE 'sam%';

--  NOT:
SELECT last_name, school, hire_date, salary FROM teachers WHERE salary NOT BETWEEN 20000 AND 40000;

-- Se pueden concatenar expresiones de comparación con AND y OR:
SELECT * FROM teachers WHERE (school = 'Myers Middle School') AND (salary < 40000);

SELECT * FROM teachers WHERE (last_name = 'Cole') OR (last_name = 'Bush');

SELECT * FROM teachers WHERE (school = 'F.D. Roosevelt HS') AND ((salary < 30000) OR (salary > 40000));

-- NOTA: los paréntesis no son necesarios todo el tiempo pero es que yo me confundo xd,
--       btw la precedencia de operadores es AND y luego OR


/* Con lo que se ha visto hasta ahora el orden delas keywords es:

   SELECT columns
   FROM table
   WHERE criteria
   ORDER BY colum(s)

   Por ejemplo: */
SELECT first_name, last_name, school, hire_date, salary
FROM teachers
WHERE school LIKE '%Roos%'
ORDER BY hire_date DESC;

-- Ejercicios del Capítulo 4

/* The school district superintendent asks for a list of teachers in each school. Write a
query that lists the schools in alphabetical order along with teachers ordered by last name A–Z.*/
SELECT school, last_name, first_name FROM teachers ORDER BY school, last_name;

/* Write a query that finds the one teacher whose first name starts with the letter S
and who earns more than $40,000.*/
SELECT * FROM teachers WHERE first_name LIKE 'S%' AND salary > 40000;

/* Rank teachers hired since January 1, 2010, ordered by highest paid to lowest. */
SELECT * FROM teachers WHERE hire_date > '2010-01-01' ORDER BY salary DESC;
















