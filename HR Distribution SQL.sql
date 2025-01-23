CREATE DATABASE PROJECT;
USE PROJECT;
SELECT * FROM hr;
DESCRIBE hr;
ALTER TABLE hr
CHANGE COLUMN ï»¿id empl_id VARCHAR(20)NULL;
DESCRIBE hr;
 
-- fix birthdate format

SELECT birthdate FROM hr;
UPDATE hr
SET birthdate = CASE
WHEN birthdate LIKE '%/%' THEN date_format(str_to_date(birthdate,'%m/%d/%Y'),'%Y-%m-%d')
WHEN birthdate LIKE  '%-%'THEN date_format(str_to_date(birthdate,'%m-%d-%Y'),'%Y-%m-%d')
ELSE NULL

END;
SELECT birthdate FROM hr;

-- change bithdate value from text to date function
ALTER TABLE hr
MODIFY COLUMN birthdate DATE;

-- FIX hire_date

SELECT hire_date FROM hr;
UPDATE hr
SET hire_date = CASE
WHEN hire_date LIKE '%/%' THEN date_format(str_to_date(hire_date,'%m/%d/%Y'),'%Y-%m-%d')
WHEN hire_date LIKE  '%-%'THEN date_format(str_to_date(hire_date,'%m-%d-%Y'),'%Y-%m-%d')
ELSE NULL

END;
SELECT hire_date FROM hr;
SELECT termdate FROM hr;

ALTER TABLE hr
MODIFY COLUMN hire_date DATE;
SELECT hire_date FROM hr;
describe hr;

-- add column Age. 

ALTER TABLE hr ADD COLUMN age INT;
SELECT * FROM hr;

UPDATE hr
SET age = timestampdiff(YEAR,birthdate, CURDATE());
SELECT birthdate, age FROM hr;

SELECT
     min(age) AS youngest,
     max(age)AS oldest
 FROM hr;
 
SELECT count(*)FROM hr WHERE age <18;

-- gender breakdown of employees in the company. 

SELECT gender,count(*) AS count 
FROM hr 
WHERE age >=18 AND termdate!='0000-00-00' 
GROUP BY gender;

-- race breakdown of employees in the company. 
SELECT race, count(*) AS count FROM hr
WHERE age >= 18 AND termdate!='0000-00-00' 
GROUP BY race
ORDER BY count(*) DESC;

-- age distribution of employees
SELECT
     min(age) AS youngest,
     max(age)AS oldest
 FROM hr
 WHERE age >=18 AND termdate!='0000-00-00'; 
 
 SELECT
       CASE
          WHEN age >=18 AND age <=24 THEN '18-24'
          WHEN age >=25 AND age <=34 THEN '25-34'
          WHEN age >=35 AND age <=44 THEN '38-44'
          WHEN age >=45 AND age <=54 THEN '45-54'
          WHEN age >=54 AND age <=59 THEN '54-59'
          ELSE '59+'
       END AS group_age,
       count(*) AS count
FROM hr
WHERE age >=20 AND termdate!='0000-00-00'
GROUP BY group_age
ORDER BY group_age;

SELECT
       CASE
          WHEN age >=18 AND age <=24 THEN '18-24'
          WHEN age >=25 AND age <=34 THEN '25-34'
          WHEN age >=35 AND age <=44 THEN '38-44'
          WHEN age >=45 AND age <=54 THEN '45-54'
          WHEN age >=54 AND age <=59 THEN '54-59'
          ELSE '59+'
       END AS group_age, gender,
       count(*) AS count
FROM hr
WHERE age >=20 AND termdate!='0000-00-00'
GROUP BY group_age, gender
ORDER BY group_age, gender;

-- how many employees work at headquater and how many work remotely

SELECT location,count(*)AS count
FROM hr
WHERE age >=20 AND termdate!='0000-00-00'
GROUP BY location;

-- average lengh of employment for terminated employees

SELECT
    round(avg(datediff(termdate,hire_date))/365,0) AS avg_lengh_empls
FROM hr
WHERE termdate <= curdate()AND termdate <>'0000-00-00'AND age >= 20;

-- how does the gender distribution across the department and job title
SELECT department, gender, count(*) AS count FROM hr 
WHERE age >=20 AND termdate!='0000-00-00'
GROUP BY department, gender
ORDER BY department;

-- distribution of jobtitle across the company
SELECT jobtitle,gender, count(*)AS count
FROM hr
WHERE age >=20 AND termdate!='0000-00-00'
GROUP BY jobtitle, gender
ORDER BY jobtitle DESC;

-- which department has the highest turnover rate

SELECT department,
    total_count, terminated_count,
    terminated_count/total_count AS termination_rate
FROM(
   SELECT department,
   count(*)AS total_count,
   SUM(CASE WHEN termdate <>'0000-00-00'AND termdate <= curdate() THEN 1 ELSE 0 END) AS terminated_count
 FROM hr
 WHERE age >=20
 GROUP BY department
 
) AS subquery
ORDER BY termination_rate DESC;

-- distribution of employees across locations by city and states
SELECT location_state,count(*) AS count
FROM hr
WHERE age >=20 AND termdate!='0000-00-00'
GROUP BY location_state
ORDER BY count DESC;

-- how does the company's employee count changed over time based on hire and term dates

SELECT
year,
hires,
terminations,
hires - terminations AS net_change, 
round((hires - terminations)/hires*100,2) AS net_change_percent
FROM(
SELECT year(hire_date) AS year,
count(*) AS hires,
SUM(CASE WHEN termdate <>'0000-00-00'AND termdate<= curdate() THEN 1 ELSE 0 END) AS terminations
FROM hr
WHERE age >= 20
GROUP BY year(hire_date)
) AS subquery

ORDER BY year ASC;

-- what is the tenure distribution for each department

SELECT department, round(avg(datediff(termdate,hire_date)/365),0) AS avg_tenure
FROM hr
WHERE termdate<= curdate()AND termdate<>'0000-00-00'AND age >=20
GROUP BY department;