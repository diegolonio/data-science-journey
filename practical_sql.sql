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
    ('Lee', 'Reynolds', 'F.D. Roosevelt HS', '1993-05-22', 65000), -- PostgresSQL va incrementando el valor
	('Samuel', 'Cole', 'Myers Middle School', '2005-08-01', 43500),
	('Samantha', 'Bush', 'Myers Middle School', '2011-10-30', 36200),
	('Betty', 'Diaz', 'Myers Middle School', '2005-08-30', 43500),
	('Kathleen', 'Roush', 'F.D. Roosevelt HS', '2010-10-22', 38500);

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
-- medida que se hacen ordenamientos con más columnas
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
SELECT last_name, school, hire_date FROM teachers WHERE first_name ILIKE 'sam%';

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

SELECT county_name, state_name, area_land
FROM us_counties_pop_est_2019
ORDER BY area_land DESC
LIMIT 3;

-- Get the 5 counties with the highest longitude
SELECT county_name, state_name, internal_point_lat, internal_point_lon
FROM us_counties_pop_est_2019
ORDER BY internal_point_lon DESC
LIMIT 5;

-- Importing a subset of columns
CREATE TABLE supervisor_salaries (
	id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	town TEXT,
	county TEXT,
	supervisor TEXT,
	start_date DATE,
	salary NUMERIC(10, 2),
	benefits NUMERIC(10, 2)
);

-- Since I can't use COPY statement I executed it from the command line:
-- psql -d analysis -c "\copy supervisor_salaries (town, supervisor, salary)
-- 							FROM '/home/diego/ml/supervisor_salaries.csv' WITH (FORMAT CSV, HEADER)"

SELECT * FROM supervisor_salaries;

DELETE FROM supervisor_salaries;

-- Importing a subset of rows
-- psql -d analysis -c "\copy supervisor_salaries (town, supervisor, salary)
--						FROM '/home/diego/ml/supervisor_salaries.csv'
--						WITH (FORMAT CSV, HEADER)
--						WHERE town = 'New Brillig'"

-- TEMPORARY TABLES
CREATE TEMPORARY TABLE supervisor_salaries_temp (LIKE supervisor_salaries INCLUDING ALL);

COPY supervisor_salaries_temp (town, supervisor, salary)
FROM '/home/diego/ml/supervisor_salaries.csv'
WITH (FORMAT CSV, HEADER);

INSERT INTO supervisor_salaries (town, county, supervisor, salary)
SELECT town, 'Mills', supervisor, salary
FROM supervisor_salaries_temp;

DROP TABLE supervisor_salaries_temp;

SELECT * FROM supervisor_salaries;

-- EXPORTING DATA
COPY us_counties_pop_est_2019
TO '/home/diego/ml/us_counties_export.txt'
WITH (FORMAT CSV, HEADER, DELIMITER '|');

COPY us_counties_pop_est_2019 (county_name, internal_point_lat, internal_point_lon)
TO '/home/diego/ml/us_counties_export.txt'
WITH (FORMAT CSV, HEADER, DELIMITER '|');

COPY (
	SELECT county_name, state_name
	FROM us_counties_pop_est_2019
	WHERE county_name ILIKE '%mill%'
) TO '/home/diego/ml/us_counties_export.txt'
WITH (FORMAT CSV, HEADER, DELIMITER '|');

-- Chapter 5 exercises

/* 1. Write a WITH statement to include with COPY to handle the import of an imaginary text file
whose first couple of rows look like this:

id:movie:actor
50:#Mission: Impossible#:Tom Cruise*/

CREATE TABLE movies (
	id INTEGER,
	name TEXT,
	actor TEXT
);

SELECT * FROM movies;

COPY movies
FROM '/home/diego/ml/movies.csv'
WITH (FORMAT CSV, HEADER, DELIMITER ':', QUOTE '#');

/* 2. Using the table us_counties_pop_est_2019 you created and filled in this chapter, export
to a CSV file the 20 counties in the United States that had the most births. Make sure
you export only each county’s name, state, and number of births. (Hint: births are
totaled for each county in the column births_2019.)*/

COPY (
	SELECT county_name, state_name, births_2019
	FROM us_counties_pop_est_2019
	ORDER BY births_2019 DESC
	LIMIT 20
) TO '/home/diego/ml/20_counties.csv'
WITH (FORMAT CSV, HEADER);

/* 3. Imagine you’re importing a file that contains a column with these values:

17519.668
20084.461
18976.335

Will a column in your target table with data type numeric(3,8) work for these values?
Why or why not?*/

-- No, because numeric(3, 8) means numbers lesser than 0.001; thus they don't fit in.

-- Chapter 6: Basic math and stats with SQL

-- Basic operations

SELECT 2 + 2 AS result;
SELECT 4 - 3 AS result;
SELECT 5 * 4 AS result;

-- Integer division + modulo
SELECT 10 / 8 AS quotient, 10 % 8 as reminder;
-- Result: |  1  |  2  |

-- Using float, numeric or decimal types performs the entire division
SELECT 10.0 / 4 AS quotient;
-- Result: 2.5000000000000000

SELECT 10::REAL / 4 AS quotient;
-- Result: 2.5

SELECT 10 / 4::DOUBLE PRECISION AS quotient;
-- Result: 2.5

SELECT 10::NUMERIC(3, 1) / 4 AS quotient;
-- Result: 2.5000000000000000

SELECT 10 / 4::DECIMAL(2, 1) AS quotient;
-- Result: 2.5000000000000000

SELECT 3 ^ 4 AS result;
-- Result: 81

SELECT |/ 4 AS result;
-- Result: 2

SELECT sqrt(4) AS result;
-- Result: 2

SELECT ||/ 8 AS result;
-- Result: 2

SELECT factorial(5) AS result;
-- Result: 120

SELECT 3 * 4 ^ 6 - 1 AS result;
-- Result: 12287

SELECT 3 * 4 ^ (6 - 1) AS result;
-- Result: 3072

SELECT (3 * 4) ^ 6 - 1 AS result;
-- Result: 2985983

SELECT county_name AS county,
state_name AS state,
pop_est_2019 AS pop,
births_2019 AS births,
deaths_2019 AS deaths,
international_migr_2019 AS int_migr,
domestic_migr_2019 AS dom_migr,
residual_2019 AS residual
FROM us_counties_pop_est_2019;

SELECT county_name AS county,
state_name AS state,
births_2019 AS births,
deaths_2019 AS deaths,
births_2019 - deaths_2019 AS natural_increase
FROM us_counties_pop_est_2019
ORDER BY state_name, county_name;

SELECT county_name AS county,
state_name AS state,
pop_est_2019 AS pop,
pop_est_2018
+ births_2019
- deaths_2019
+ international_migr_2019
+ domestic_migr_2019
+ residual_2019 AS components_total,
pop_est_2019 - (
pop_est_2018
+ births_2019
- deaths_2019
+ international_migr_2019
+ domestic_migr_2019
+ residual_2019) AS difference
FROM us_counties_pop_est_2019
ORDER BY difference DESC;

SELECT county_name AS county,
state_name AS state,
-- Also: CAST(area_water AS NUMERIC)
area_water::NUMERIC / (area_land + area_water) * 100 AS pct_water
FROM us_counties_pop_est_2019
ORDER BY pct_water DESC;


CREATE TABLE percent_change (
    department TEXT,
    spend_2019 NUMERIC(10, 2),
    spend_2022 NUMERIC(10, 2)
);

INSERT INTO percent_change VALUES
    ('Assessor', 178556, 179500),
    ('Building', 250000, 289000),
    ('Clerk', 451980, 650000),
    ('Library', 87777, 90001),
    ('Parks', 250000, 223000),
    ('Water', 199000, 195000);

SELECT department, spend_2019, spend_2022, round((spend_2022 - spend_2019) / spend_2019 * 100, 1) AS pct_change
FROM percent_change;

SELECT sum(pop_est_2019) AS county_sum, round(avg(pop_est_2019), 0) AS county_average
FROM us_counties_pop_est_2019;

CREATE TABLE percentile_test (
    numbers INTEGER
);

INSERT INTO percentile_test (numbers) VALUES (1), (2), (3), (4), (5), (6);

SELECT percentile_cont(0.5) WITHIN GROUP (ORDER BY numbers),
       percentile_disc(0.5) WITHIN GROUP (ORDER BY numbers)
FROM percentile_test;

SELECT percentile_cont(ARRAY[0.25, 0.5, 0.75]) WITHIN GROUP (ORDER BY numbers) FROM percentile_test;

SELECT sum(pop_est_2019) AS county_sum,
       round(avg(pop_est_2019), 0) AS county_average,
       percentile_cont(0.5) WITHIN GROUP (ORDER BY pop_est_2019) AS county_median
FROM us_counties_pop_est_2019;

SELECT percentile_cont(ARRAY[0.25, 0.5, 0.75]) WITHIN GROUP (ORDER BY pop_est_2019) AS quantiles
FROM us_counties_pop_est_2019;

SELECT unnest(percentile_cont(ARRAY[0.25, 0.5, 0.75]) WITHIN GROUP (ORDER BY pop_est_2019)) AS quantiles
FROM us_counties_pop_est_2019;

SELECT mode() WITHIN GROUP (ORDER BY births_2019)
FROM us_counties_pop_est_2019;

-- Chapter 6 exercises

/* 1. Write a SQL statement for calculating the area of a circle whose radius is 5 inches. (If
you don’t remember the formula, it’s an easy web search.) Do you need parentheses in
your calculation? Why or why not? */

-- A = pi * r ^ 2, we don't need parentheses since the power is evaluated before multiplication

SELECT pi() * 5 ^ 2 AS result;

/* 2. Using the 2019 US Census county estimates data, calculate a ratio of births to deaths
for each county in New York state. Which region of the state generally saw a higher
ratio of births to deaths in 2019? */

SELECT state_name AS state,
       county_name AS county,
       births_2019 AS births,
       deaths_2019 AS deaths,
       round(births_2019::NUMERIC / deaths_2019, 2) AS ratio
FROM us_counties_pop_est_2019
WHERE state_name LIKE 'New York'
ORDER BY ratio DESC;

/* R: Rockland, Jefferson and Kings counties saw the highest ratios of births to deaths. */

/* 3. Was the 2019 median county population estimate higher in California or New York? */

SELECT state_name AS state,
       percentile_cont(0.5) WITHIN GROUP (ORDER BY pop_est_2019) AS median
FROM us_counties_pop_est_2019
WHERE state_name IN ('New York', 'California')
GROUP BY state_name;

/* R: California had the highest median. */

-- Chapter 7: Joining tables in a relational database

-- To be continued...






