-- Crear una base de datos que pertenezca a mi usuario
CREATE DATABASE analysis WITH OWNER = diego;


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

-- Para los dos casos anteriores se utiliza % como wildcar para 1 o más caracteres y _ para un solo caracter

--  NOT:
SELECT last_name, school, hire_date, salary FROM teachers WHERE salary NOT BETWEEN 20000 AND 40000;

-- Se pueden concatenar expresiones de comparación con AND y OR:
SELECT * FROM teachers WHERE (school = 'Myers Middle School') AND (salary < 40000);

SELECT * FROM teachers WHERE (last_name = 'Cole') OR (last_name = 'Bush');

SELECT * FROM teachers WHERE (school = 'F.D. Roosevelt HS') AND ((salary < 30000) OR (salary > 40000));

-- NOTA: los paréntesis no son necesarios todo el tiempo pero es que yo me confundo xd,
--       btw la precedencia de operadores es AND y luego OR


/* Con lo que se ha visto hasta ahora el orden de las keywords es:

   SELECT columns
   FROM table
   WHERE criteria
   ORDER BY colum(s)

   Por ejemplo: */
SELECT first_name, last_name, school, hire_date, salary
FROM teachers
WHERE school LIKE '%Roos%'
ORDER BY hire_date DESC;

-- Ejercicios del Capítulo 3

/* The school district superintendent asks for a list of teachers in each school. Write a
query that lists the schools in alphabetical order along with teachers ordered by last name A–Z.*/
SELECT school, last_name, first_name FROM teachers ORDER BY school, last_name;

/* Write a query that finds the one teacher whose first name starts with the letter S
and who earns more than $40,000.*/
SELECT * FROM teachers WHERE first_name LIKE 'S%' AND salary > 40000;

/* Rank teachers hired since January 1, 2010, ordered by highest paid to lowest. */
SELECT * FROM teachers WHERE hire_date > '2010-01-01' ORDER BY salary DESC;

-- Chapter 4 understanding data types

/* There's 3 character types in SQL (all of them part of the ANSI SQL standard):
    char(n)/character(n): receives a fixed-length string of at most n characters, when you insert
                            fewer characters than n, PostgreSQL pads the rest with spaces.

    varchar(n)/character varying(n): receives a variable-length string where the maximum is n, if you
                            insert fewer characters than n, PostgreSQL will not store extra spaces.
    
    text: receives a variable-length string of unlimited characters (in PostgreSQL this at most 1GB of text). */


-- The following example creates a table with 3 colums, each of them of each character type,
-- then we export it to a txt file

CREATE TABLE char_data_types (
    char_column char(10),
    varchar_column varchar(10),
    text_column text
);

INSERT INTO char_data_types VALUES
    ('abc', 'abc', 'abc'),
    ('defghi', 'defghi', 'defghi');

COPY char_data_types TO '/home/diego/ml/typetest.txt' WITH (FORMAT CSV, HEADER, DELIMITER '|');


/* The output in the file was:

char_column|varchar_column|text_column
abc       |abc|abc
defghi    |defghi|defghi

The char column is the only one that pads the value with trailing spaces.

NOTE: When trying to perform the COPY ... TO ... sentence the psql server threw a write permission error,
that's because on server-side the COPY sentence is executed with the postgres user (which doesn't have write
permissions) so I used:

psql -d analysis -c "\copy char_data_types TO '/home/diego/ml/char_data_types.csv' \
                                            WITH (FORMAT CSV, HEADER, DELIMITER '|')"

in a terminal. */

-- INTEGER numbers


-- Those are SMALLINT (2 bytes), INTEGER (4 bytes) and BIGINT (8 bytes)

CREATE TABLE people (
    id_people INTEGER GENERATED ALWAYS AS IDENTITY,
    person_name VARCHAR(100)
);

-- Decimal numbers

/* numeric(precision, scale), decimal(precision, scale) where:

        precision is the total number of digits in the whole number
        scale determines how many of the digits come after the point

for example: numeric(5, 2) accepts from -999.99 to 999.99 whilst 1490.45 overflows it.

A key point of fixed-point numbers is that you can't insert a value that has more digits in the whole part than
(precision - scale) digits, but you can insert values with more digits in the decimal part than scale, postgres
automatically rounds the value to [scale] decimal positions. */

/* real, double precision where
        real allows precision to 6 decimal digits
        double precision allows precision to 15 decimal digits
        
Just as numerics/decimal data types, the precision in this case also include the digits of the whole number,
postgres stores the value in parts representing the digits and an exponent (scientific notation): 23.5 = 235*10^{-1}.
The decimal point isn't fixed so it 'floats'. */

CREATE TABLE number_data_types (
    numeric_column NUMERIC(20, 5),
    real_column REAL,
    double_column DOUBLE PRECISION
);

INSERT INTO number_data_types VALUES
    (0.7, 0.7, 0.7),
    (2.13579, 2.13579, 2.13579),
    (2.1357987654, 2.1357987654, 2.1357987654);

SELECT * FROM number_data_types;

SELECT numeric_column * 10000000 AS fixed, real_column * 10000000 AS floating
FROM number_data_types
WHERE numeric_column = .7;

-- Dates

CREATE TABLE date_time_types (
    timestamp_column TIMESTAMP WITH TIME ZONE,
    interval_column INTERVAL
);

INSERT INTO date_time_types VALUES
    ('2022-12-31 01:00 EST', '2 days'),
    ('2022-12-31 01:00 -8', '1 month'),
    ('2022-12-31 01:00 Australia/Melbourne', '1 century'),
    (now(), '1 week');

SELECT * FROM date_time_types;

SELECT timestamp_column, interval_column, timestamp_column - interval_column AS new_date
FROM date_time_types;

-- CAST

SELECT timestamp_column, CAST(timestamp_column AS VARCHAR(10)) FROM date_time_types;

SELECT numeric_column, CAST(numeric_column AS INTEGER), CAST(numeric_column AS TEXT)
FROM number_data_types;

SELECT timestamp_column, timestamp_column::VARCHAR(10) FROM date_time_types;

SELECT numeric_column, numeric_column::INTEGER, numeric_column::TEXT
FROM number_data_types;


-- Chapter 4 Exercises

/* Your company delivers fruit and vegetables to local grocery stores, and you need to
track the mileage driven by each driver each day to a tenth of a mile. Assuming no
driver would ever travel more than 999 miles in a day, what would be an appropriate
data type for the mileage column in your table? Why? 

A: A DECIMAL type is appropriate since we know the maximum number of digits the mileage
is going to have: DECIMAL(4, 1)
*/

/* In the table listing each driver in your company, what are appropriate data types for the
drivers’ first and last names? Why is it a good idea to separate first and last names into
two columns rather than having one larger name column?

A: Names tend to have a reasonable maximum number of characters so VARCHAR fits better
in this case. On the other hand, it's much better to separate first and last names because
we can perform sort and filter more precisely on the retrieved data */

/* Assume you have a text column that includes strings formatted as dates. One of the
strings is written as '4//2021'. What will happen when you try to convert that string to
the timestamp data type? */

INSERT INTO date_time_types VALUES ('4//2021', '1000 years');

/* pgAdmin threw this error:

ERROR:  invalid input syntax for type timestamp with time zone: "4//2021"
LINE 1: INSERT INTO date_time_types VALUES ('4//2021', '1000 years')...
                                            ^ 

SQL state: 22007
Character: 37 */

-- Chapter 5: Exporting and Importing Data


-- We'll use the us_counties_pop_est_2019 CSV file
CREATE TABLE us_counties_pop_est_2019 (
    -- These are descriptive field not actual quantities
    state_fips TEXT,
    county_fips TEXT,
    -- From 1 to 4 (Northeast, Midwest, South and West)
    region SMALLINT,
    -- Complete names
    state_name TEXT,
    county_name TEXT,
    -- Both represents the total area of each county
    area_land BIGINT,
    area_water BIGINT,
    -- Latitude and Longitude of a point near the center of each county
    internal_point_lat NUMERIC(10, 7),
    internal_point_lon NUMERIC(10, 7),
    -- All of these are from July 1, 2018 to June 30, 2019
    pop_est_2018 INTEGER,
    pop_est_2019 INTEGER,
    births_2019 INTEGER,
    deaths_2019 INTEGER,
    international_migr_2019 INTEGER,
    domestic_migr_2019 INTEGER,
    residual_2019 INTEGER,
    CONSTRAINT counties_2019_key PRIMARY KEY (state_fips, county_fips)
);

SELECT * FROM us_counties_pop_est_2019;

-- Once again, using COPY WITH from pgAdmin didn't work, so I use instead
-- psql -d analysis -c "\copy us_counties_pop_est_2019 FROM '/home/diego/ml/us_counties_pop_est_2019.csv' WITH (FORMAT CSV, HEADER)"
COPY us_counties_pop_est_2019
FROM '/home/diego/ml/us_counties_pop_est_2019.csv'
WITH (FORMAT CSV, HEADER);






