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
(1) What are the top 5 procedures performed by age group?
-------------------------------------------------------
*/

with age_group_procedures as(
	select
		encount.encounter_Id,
		encount.encounter_class,
		case
			when pat.death_date is null then datediff(year, pat.birth_date, getdate())
			when pat.death_date is not null then datediff(year, pat.birth_date, pat.death_date) end
		 as age,
		 case
			when datediff(year, pat.birth_date, getdate()) between 30 and 40 then '30-40'
			when datediff(year, pat.birth_date, getdate()) between 40 and 50 then '40-50'
			when datediff(year, pat.birth_date, getdate()) between 50 and 60 then '50-60'
			when datediff(year, pat.birth_date, getdate()) between 60 and 70 then '60-70'
			when datediff(year, pat.birth_date, getdate()) between 70 and 80 then '70-80'
			when datediff(year, pat.birth_date, getdate()) > 80 then '80+' end
		as age_group,
		prod.procedure_code,
		prod.description
	from encounters encount
		left join patients pat
			on encount.patient_id = pat.PATIENT_ID
		left join procedures prod
			on encount.encounter_id = prod.ENCOUNTER_ID
)

select
	age_group,
	procedure_code,
	description,
	total_encounters,
	ranking
from
	(
	select
		age_group,
		procedure_code,
		description,
		count(distinct encounter_id) as total_encounters,
		dense_rank() over(partition by age_group order by count(distinct encounter_id) desc) as ranking
	from age_group_procedures
	where procedure_code is not null
	group by age_group,procedure_code, description
	) Ranked_Procedures
where ranking <= 5;


/*
-------------------------------------------------------
(2) What are the top 10 procedures performed by gender?
-------------------------------------------------------
*/

with gender_procedures as(
	select
		encount.encounter_Id,
		encount.encounter_class,
		pat.gender,
		prod.procedure_code,
		prod.description
	from encounters encount
		left join patients pat
			on encount.patient_id = pat.PATIENT_ID
		left join procedures prod
			on encount.encounter_id = prod.ENCOUNTER_ID
)

select
	gender,
	procedure_code,
	description,
	total_encounters,
	ranking
from
	(
	select
		gender,
		procedure_code,
		description,
		count(distinct encounter_id) as total_encounters,
		dense_rank() over(partition by gender order by count(distinct encounter_id) desc) as ranking
	from gender_procedures
	where procedure_code is not null
	group by gender,procedure_code, description
	) Ranked_Procedures
where ranking <= 10
order by gender desc;
