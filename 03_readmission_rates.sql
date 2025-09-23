/* 30-Day Readmission Rates

Goal:
Reduce unnecessary hospital readmissions by identifying which patient groups, encounter types, and insurance payers are most frequently readmitted within 30 days. 
This analysis helps hospital administrators and care teams to develop better post-discharge strategies in reducing rates of readmission.

Business Questions:
(1) What is the overall 30-day readmission rate?
(2) How does readmission vary by age group?
(3) Are certain encounter types more likely to be readmitted than others?
(4) Which insurance payers have the highest readmission rates?


Key Findings:
(1) The overall 30-day readmission rate is 62.35%. 
(2) Patients over the age of 80 have the highest rates of readmission by far at 74.16% with 40-49 year olds with the least amount of readmission at 45.29%.
(3) Urgent care visits have the highest rates of readmission at 74.14% and wellness visits have the lowest rates of readmission at 21.28%.
(4) Patients with no insurance have the highest rates of readmission at 77.27% and those with Anthem insurance have the lowest rates of readmission at 32.24%.
NOTE: These RR% would be EXTREMELY high in a real world hospital, however coming from a synthetic dataset, the numbers do not reflect reality.

Recommendations:
(1) Overall Readmission Rate 62.35%
	- Make sure patients clearly understand their care and what to do after leaving to reduce readmissions
	- Keep in touch with patients after discharge for early detection of any problems causing them to readmit
(2) Readmission by Age Group - 80+
	- Provide extra support for 80+ age group patients as they have the highest readmission rates. This can include specialized after-care plans,
	more frequent follow up calls, and at home visits
	- Figure out why 40-49 year olds have lower readmission rates and try to implement those best practices with the other age groups
(3) High Readmission Encounter Classes - Urgent care
	- Pay closer attention to urgent care patients because they have the highest rates of readmission. Arrange follow up visits and prepare after care
	before they leave so they readmit less
	- Determine what best practices can be done to reduce the number of urgent care treatments in the first place
(4) Uninsured Patients Readmit the Most
	- Help uninsured patients get the medicines, transport, and community support that they need to reduce their readmission rates
*/

/*
-------------------------------------------------------
Create a VIEW to simplify all readmissions related queries
-------------------------------------------------------
*/

CREATE OR ALTER VIEW dbo.vw_readmissions AS
WITH encounters_ordered AS (
SELECT
	encount.encounter_id,
    encount.patient_id,
	encount.encounter_class,
	pay.payer_name,
	v.age_group_at_encounter,
	v.age_group_sort,
    CAST(encount.start AS DATE) AS start_date,
    CAST(encount.stop  AS DATE) AS stop_date,
    LEAD(CAST(encount.start AS DATE)) OVER (PARTITION BY encount.patient_id ORDER BY encount.start) AS next_start_date
FROM dbo.encounters encount
	LEFT JOIN dbo.payers pay
		ON encount.payer_id = pay.payer_id
	JOIN dbo.vw_encounter_age v
		ON encount.encounter_id = v.encounter_id
WHERE encount.stop IS NOT NULL
)

SELECT
	encounter_id,
	encounter_class,
	payer_name,
	age_group_at_encounter,
	age_group_sort,
    CASE
		WHEN next_start_date IS NOT NULL AND DATEDIFF(DAY, stop_date, next_start_date) <= 30 THEN 1 
		ELSE 0
    END AS yes_readmit_30d
FROM encounters_ordered
GO
	
/*
-------------------------------------------------------
(1) Overall Readmission Rate
-------------------------------------------------------
*/

SELECT 
	CAST(100.0 * SUM(yes_readmit_30d) / COUNT(*) AS DECIMAL(5,2)) AS readmission_rate_30d
FROM dbo.vw_readmissions;

/*
-------------------------------------------------------
(2) Readmission Rates by Age Group
-------------------------------------------------------
*/

SELECT
	age_group_at_encounter AS age_group,
	SUM(yes_readmit_30d) AS number_readmissions,
	COUNT(*) as total_encounters,
	CAST(100.0 * sum(yes_readmit_30d) / COUNT(*) AS DECIMAL(5,2)) AS readmission_rate_30d
FROM dbo.vw_readmissions
GROUP BY age_group_at_encounter, age_group_sort
ORDER BY age_group_sort;

/*
-------------------------------------------------------
(3) Readmission rates by Encounter Types
-------------------------------------------------------
*/
	
SELECT
	encounter_class,
	SUM(yes_readmit_30d) readmissions_number,
	COUNT(*) as total_encounters,
	CAST(100.0 * SUM(yes_readmit_30d) / COUNT(*) AS DECIMAL(5,2)) AS readmission_rate_30d
FROM dbo.vw_readmissions
GROUP BY encounter_class
ORDER BY readmission_rate_30d DESC

/*
-------------------------------------------------------
(4) Readmission rates per Insurance Type (payer)
-------------------------------------------------------
*/
	
SELECT
	payer_name,
	SUM(yes_readmit_30d) readmissions_number,
	COUNT(*) as total_encounters,
	CAST(100.0 * SUM(yes_readmit_30d) / COUNT(*) AS DECIMAL(5,2)) AS readmission_rate_30d
FROM dbo.vw_readmissions
GROUP BY payer_name
ORDER BY readmission_rate_30d DESC;
