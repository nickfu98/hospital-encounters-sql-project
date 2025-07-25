/* Which clinical services are being using the most by different patients? */

/*
-------------------------------------------------------
(1) Top 5 Procedures by Age Group
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
(2) Top 10 Procedures per Gender
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
