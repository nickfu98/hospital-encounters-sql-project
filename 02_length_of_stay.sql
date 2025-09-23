/* Length of Stay Analysis

Goal:
Identify patient factors and services contributing to longer hospital stays to improve capacity planning, reduce resource bottlenecks, and lower care costs.

Business Questions:
(1) Which patients result in longer hospital stays?
(2) Are there seasonal or year-to-year changes in stay durations?
(3) Which procedures result in longer stays?


Key Findings:
(1) Patients under 30 years old (41.9 hrs) and 30-39 (29.3 hrs) have the highest average lengths of stay
(2a) December (21hr) and March (17hr) have the highest average length of stay per month.
(2b) The average length of stay in 2014 is significantly higher than all the other years at 38 hours.
(3) The top 3 procedures with the longest average lengths of stay are all related to breast cancer:
	- Magnetic resonance imaging of breast - 3382hrs
	- Screening mammography - 1993hrs
	- Biopsy of breast - 1463 hrs

Recommendations
(1) Focus on the <40 Age Group Patients
	- Patients in this age group have the longest hospital stays
	- Improve discharge planning and follow-up care to reduce length of stay
(2) Understand What Causes Longer Stays
	- Look into why patients stay longer in December and March, such as more illnesses during certain seasons or holidays
	- Check what happened in 2014 that made average hospital stays longer and make sure to correct any problems found
	- Plan resources accordingly to reduce lengths of stay especially during busier months
(3) Improve Breast Cancer Procedure Management
	- Breast cancer related procedures have the longest average stays
	- Make sure there are enough trained staff and care teams available
	- Streamline care for these procedures to reduce patient stays
*/

/*
-------------------------------------------------------
(1) What is the average length of stay by age group?
-------------------------------------------------------
*/

-- Using dbo.vw_encounter_age VIEW created in (01)

WITH LOS_age_group AS
	(
	SELECT
		v.age_group_at_encounter AS age_group,
		v.age_group_sort AS sort_key,
		DATEDIFF(HOUR, encount.start, encount.stop) AS LOS_hours

	FROM dbo.vw_encounter_age AS v
	JOIN dbo.encounters AS encount
		ON encount.encounter_id = v.encounter_id
	WHERE encount.stop IS NOT NULL
	)

SELECT
	age_group,
	ROUND(AVG(CAST(LOS_hours AS FLOAT)),1) AS avg_LOS_hrs
FROM LOS_age_group
GROUP BY age_group, sort_key
ORDER BY sort_key


/*
-------------------------------------------------------
(2a) What is the average length of stay per month?
-------------------------------------------------------
*/

WITH LOS_monthly AS(
SELECT
	start,
	stop,
	DATENAME(MONTH, start) month,
	MONTH(start) month_num,
	DATEDIFF(hour, start, stop) LOS_hrs
FROM encounters
)

SELECT
	month,
	AVG(los_hrs) AVG_LOS
FROM LOS_monthly
GROUP BY MONTH, month_num
ORDER BY month_num;

/*
-------------------------------------------------------
(2b) What is the average length of stay per year?
-------------------------------------------------------
*/

WITH LOS_yearly AS(
SELECT
	start,
	stop,
	DATENAME(YEAR, start) year,
	YEAR(start) year_num,
	DATEDIFF(hour, start, stop) LOS_hrs
FROM encounters
)

SELECT
	year,
	AVG(los_hrs) AVG_LOS
FROM LOS_yearly
GROUP BY YEAR, YEAR_num
ORDER BY YEAR_num;

/*
-------------------------------------------------------
(3) Which procedures have the longest hospital stays?
-------------------------------------------------------
*/

WITH LOS_procedures AS(
SELECT
	encount.start,
	encount.stop,
	DATEDIFF(HOUR, encount.start, encount.stop) AS LOS_hrs,
	prod.procedure_code,
	prod.description
FROM encounters encount
	LEFT JOIN procedures prod
	ON encount.encounter_id = prod.encounter_id
WHERE prod.procedure_code is not null
)

SELECT TOP 10
	procedure_code,
	description,
	AVG(los_hrs) AVG_LOS
FROM LOS_procedures
GROUP BY procedure_code, description
ORDER BY AVG_los DESC;
