/* Patient Volume Trends

Goal:
To analyze how patient encounter volume changes over time across different patient demographics, procedure types, and encounter types. 
These insights help hospitals optimize scheduling, resource allocation, and targeted outreach for higher usage areas.

Business Question:
Which patient types drive encounter volume across time, age, procedures and encounter class?

Key Findings:
(1a) February has the highest share of visits (10%)
(1b) Yearly encounters stays around 2,300-2,500 except for increased volume in 2014 and 2021
(2) Age 80+ patients overwhelmingly account for the largest proportion of visits (60%)
(3) Assessments of health/social care needs and depression screenings are the most frequent procedures
(4) Ambulatory and outpatient encounters account for the majority of the visits (66%)

Recommendations:
(1) Plan ahead for February visits surge
	- February sees the highest encounter volume of the year
	- Plan for extra staff, flexible schedules, and more appointment times
(2) Prioritize care for 80+ age group
	- Seniors 80+ account for 60% of all visits
	- Make the hospital easy to access with wheelchair ramps and transport help for elderly patients with mobility issues
	- Offer more elderly care programs and support for chronic conditions
	- Ensure safety measures are put in place to prevent injuries from falls
(3) Improve mental health and social support
	- Depression checks and social care are the most common procedures
	- Train staff to recognize and respond to mental health needs
	- Work with social workers to provide better follow-up and support
(4) Optimize ambulatory and outpatient services
	- 66% of encounters fall under ambulatory and outpatient categories
	- Make sure outpatient areas are well staffed and equipped
	- Reallocate resources away low-demand areas if needed
*/

/*
-------------------------------------------------------
(1a) How many total encounters occur each month?
-------------------------------------------------------
*/ 

WITH encounter_date_details AS(
SELECT
	encount.encounter_id,
	encount.start,
	encount.stop,
	CAST(encount.start AS date) date
FROM encounters encount
)

SELECT
	MONTH,
	encounters,
	round(100* encounters/sum(encounters) over() ,2) AS pct_of_total
FROM
	(
	SELECT
		DATENAME(MONTH, date) AS month,
		MONTH(date) MONTH_num,
		COUNT(DISTINCT encounter_id) encounters
	FROM encounter_date_details
	GROUP BY DATENAME(MONTH, date), MONTH(date)
	) MONTHly_encounters
ORDER BY MONTH_num;

/*
-------------------------------------------------------
(1b) How many encounters occur each year?
     What are the year-over-year % changes? 		
-------------------------------------------------------
*/
	
WITH encounters_YEAR AS(
SELECT
	encount.encounter_id,
	YEAR(encount.start) AS YEAR
FROM encounters encount
)

, encounters_by_YEAR AS(
SELECT
	YEAR,
	COUNT(encounter_id) AS total_encounters
FROM encounters_YEAR
GROUP BY YEAR
)

, YoY_Difference AS(
SELECT
	YEAR,
	total_encounters,
	LAG(total_encounters) over(ORDER BY YEAR) last_year,
	total_encounters - LAG(total_encounters) over(ORDER BY YEAR) AS difference
FROM encounters_by_year
GROUP BY YEAR, total_encounters
)


SELECT
	YEAR,
	total_encounters,
	CASE 
		WHEN last_year is null THEN null 
		ELSE ROUND((100.0*difference/ last_year), 2) END AS YoY_Pct_change
FROM yoy_difference;

/*
-------------------------------------------------------
(2) What age groups make up the most encounters?
-------------------------------------------------------
*/

-- Create a VIEW for easier queries involving age at encounter

CREATE OR ALTER VIEW dbo.vw_encounter_age AS
SELECT
    encount.encounter_id,
    encount.patient_id,
    encount.start AS encounter_start,
    pat.gender,
    FLOOR(DATEDIFF(DAY, pat.birth_date, CAST(encount.start AS DATE)) / 365.25) AS age_at_encounter,
    CASE
		WHEN DATEDIFF(DAY, pat.birth_date, CAST(encount.start AS DATE)) / 365.25 >= 0 AND DATEDIFF(DAY, pat.birth_date, CAST(encount.start AS DATE)) / 365.25 < 30 THEN '<30'
        WHEN DATEDIFF(DAY, pat.birth_date, CAST(encount.start AS DATE)) / 365.25 >= 30 AND DATEDIFF(DAY, pat.birth_date, CAST(encount.start AS DATE)) / 365.25 < 40 THEN '30-39'
        WHEN DATEDIFF(DAY, pat.birth_date, CAST(encount.start AS DATE)) / 365.25 >= 40 AND DATEDIFF(DAY, pat.birth_date, CAST(encount.start AS DATE)) / 365.25 < 50 THEN '40-49'
        WHEN DATEDIFF(DAY, pat.birth_date, CAST(encount.start AS DATE)) / 365.25 >= 50 AND DATEDIFF(DAY, pat.birth_date, CAST(encount.start AS DATE)) / 365.25 < 60 THEN '50-59'
        WHEN DATEDIFF(DAY, pat.birth_date, CAST(encount.start AS DATE)) / 365.25 >= 60 AND DATEDIFF(DAY, pat.birth_date, CAST(encount.start AS DATE)) / 365.25 < 70 THEN '60-69'
        WHEN DATEDIFF(DAY, pat.birth_date, CAST(encount.start AS DATE)) / 365.25 >= 70 AND DATEDIFF(DAY, pat.birth_date, CAST(encount.start AS DATE)) / 365.25 < 80 THEN '70-79'
		ELSE '80+'
    END AS age_group_at_encounter,
	CASE
		WHEN DATEDIFF(DAY, pat.birth_date, CAST(encount.start AS DATE)) / 365.25 >= 0 AND DATEDIFF(DAY, pat.birth_date, CAST(encount.start AS DATE)) / 365.25 < 30 THEN 0
        WHEN DATEDIFF(DAY, pat.birth_date, CAST(encount.start AS DATE)) / 365.25 >= 30 AND DATEDIFF(DAY, pat.birth_date, CAST(encount.start AS DATE)) / 365.25 < 40 THEN 1
        WHEN DATEDIFF(DAY, pat.birth_date, CAST(encount.start AS DATE)) / 365.25 >= 40 AND DATEDIFF(DAY, pat.birth_date, CAST(encount.start AS DATE)) / 365.25 < 50 THEN 2
        WHEN DATEDIFF(DAY, pat.birth_date, CAST(encount.start AS DATE)) / 365.25 >= 50 AND DATEDIFF(DAY, pat.birth_date, CAST(encount.start AS DATE)) / 365.25 < 60 THEN 3
        WHEN DATEDIFF(DAY, pat.birth_date, CAST(encount.start AS DATE)) / 365.25 >= 60 AND DATEDIFF(DAY, pat.birth_date, CAST(encount.start AS DATE)) / 365.25 < 70 THEN 4
        WHEN DATEDIFF(DAY, pat.birth_date, CAST(encount.start AS DATE)) / 365.25 >= 70 AND DATEDIFF(DAY, pat.birth_date, CAST(encount.start AS DATE)) / 365.25 < 80 THEN 5
		ELSE 6
	END AS age_group_sort
FROM dbo.encounters AS encount
JOIN dbo.patients AS pat
  ON pat.patient_id = encount.patient_id;
GO

-- Total Encounters per Age Group
WITH age_group_encounters AS
	(
    SELECT
        v.age_group_at_encounter AS age_group,
        MIN(v.age_group_sort) AS sort_key,
        COUNT(DISTINCT v.encounter_id) AS total_encounters
    FROM dbo.vw_encounter_age AS v
    GROUP BY v.age_group_at_encounter
	)

SELECT
    age_group,
    total_encounters,
    CAST(ROUND(100.0 * total_encounters / SUM(total_encounters) OVER (), 0) AS INT) AS pct_of_total
FROM age_group_encounters
ORDER BY sort_key;


/*
-------------------------------------------------------
(3) What are the most common procedures performed?
-------------------------------------------------------
*/

WITH procedure_encounters AS(	
SELECT
	encount.encounter_id,
	encount.encounter_class,
	prod.description,
	prod.procedure_code
FROM encounters encount 
	JOIN procedures prod
	ON encount.encounter_id = prod.encounter_id
)

SELECT TOP 10
	procedure_code,
	description,
	encounters,
	round(100* encounters/sum(encounters) over() ,0) AS pct_of_total
FROM 
	(
	SELECT
		procedure_code,
		description,
		COUNT(DISTINCT encounter_id) encounters
	FROM procedure_encounters
	GROUP BY 
		procedure_code, 
		description
	) procedure_encounter_COUNT
ORDER BY 
	encounters DESC;


/*
-------------------------------------------------------
(4) What encounter types are most common?
-------------------------------------------------------
*/

WITH encounter_class_encounters AS(
SELECT
	encount.encounter_id,
	encounter_class
FROM encounters encount 

)

SELECT
	encounter_class,
	encounters,
	round(100* encounters/sum(encounters) over() ,0) AS pct_of_total
FROM
	(
	SELECT
		encounter_class,
		COUNT(DISTINCT encounter_id) encounters
	FROM encounter_class_encounters
	GROUP BY encounter_class
	) class_encounters
ORDER BY encounters DESC;





