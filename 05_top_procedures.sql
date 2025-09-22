/* Most Utilized Medical Procedures

Goal:
To understand which procedures are most frequently performed based on age group and gender. This information helps guide staffing and resource planning strategies tailored to patient demographics.

Business Questions:
(1) What are the top procedures performed in each age group?
(2) What are the top procedures performed amongst male and female patients?

Key Findings:
(1) Top procedures for each age group:
	- 30-40 - Ultrasound scan for fetal viability
	- 40-50 - Auscultation of the fetal heart
	- 50-60 - Assessment of health and social care needs
	- 60-70 - Assessment of health and social care needs 
	- 70-80 - Assessment of health and social care needs
	- 80+ - Assessment of health and social care needs
(2) Top procedures for male and female patients
	- Male:
		- Assessment of health and social care needs
		- Depression screening using Patient Health Questionnaire Two-Item score
		- Depression screening 
	- Female:
		- Renal dialysis
		- Assessment of health and social care needs
		- Depression screening 

Recommendations:
(1) Top Procedures by Age Group
	- Make sure the most common procedures in each age group are well equipped and staffed to keep up with demand
	- For patients 50+ plan for more health and social care support since these are the most frequent procedures for them
(2) Top Procedures by Gender
	- For both men and women prioritize mental health screenings and proper care by staff to address depression needs.
	Also, focus on health and social care to address these needs
	- For women make sure there is adequate support for kidney dialysis and regular health check ups
*/

/*
-------------------------------------------------------
(1) What are the top 5 procedures performed by each age group?
-------------------------------------------------------
*/

WITH age_group_procedures AS(
	SELECT
		encount.encounter_Id,
		v.age_at_encounter AS age,
		v.age_group_at_encounter AS age_group,
		prod.procedure_code,
		prod.description
	FROM encounters encount
		LEFT JOIN procedures prod
			ON encount.encounter_id = prod.encounter_id
		JOIN dbo.vw_encounter_age v
			ON encount.encounter_id = v.encounter_id
		WHERE prod.procedure_code IS NOT NULL
),

ranked_procedures as(
SELECT
	age_group,
	procedure_code,
	description,
	COUNT(DISTINCT encounter_id) as total_encounters,
	DENSE_RANK() OVER(PARTITION BY age_group ORDER BY COUNT(DISTINCT encounter_id) DESC) as ranking
FROM age_group_procedures
GROUP BY age_group, procedure_code, description
)


SELECT
	age_group,
	procedure_code,
	description,
	total_encounters
FROM ranked_procedures
WHERE ranking <=5;


/*
-------------------------------------------------------
(2) What are the top 5 procedures performed by gender?
-------------------------------------------------------
*/

WITH gender_procedures AS(
SELECT
	encount.encounter_Id,
	pat.gender,
	prod.procedure_code,
	prod.description
FROM encounters encount
	LEFT JOIN patients pat
		ON encount.patient_id = pat.patient_id
	LEFT JOIN procedures prod
		ON encount.encounter_id = prod.encounter_ID
		WHERE prod.procedure_code IS NOT NULL
),

ranked_procedures AS (
SELECT
	gender,
	procedure_code,
	description,
	COUNT(DISTINCT encounter_id) AS total_encounters,
	DENSE_RANK() OVER(PARTITION BY gender ORDER BY COUNT(DISTINCT encounter_id) DESC) AS ranking
FROM gender_procedures
GROUP BY gender, procedure_code, description
)

SELECT
	gender,
	procedure_code,
	description,
	total_encounters
FROM ranked_procedures
WHERE ranking <=5;
