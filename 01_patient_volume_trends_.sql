/* Patient Volume Trends

Business Question:
Which patient types drive encounter volume across time, age, procedures and encounter class?

Key Findings:
- February has the highest share of visits (10%)
- Yearly encounters stays around 2300-2500 except for increased volume in 2014 and 2021
- Age 80+ patients overwhelmingly account for the largest proportion of visits (60%)
- Asessments of health/social care needs and depression screenings are the most frequent procedures
- Ambulatory and outpatient encounters account for the majority of the visits (66%)

---------------------------------------------------
(1a) How many total encounters occur each month?
---------------------------------------------------
*/ 

with encounter_date_details as(
select
	encount.encounter_id,
	encount.start,
	encount.stop,
	cast(encount.start as date) date
from encounters encount
)

select
	month,
	encounters,
	round(100* encounters/sum(encounters) over() ,0) as pct_of_total
from
	(
	select
		datename(month, date) as month,
		month(date) month_num,
		count(distinct encounter_id) encounters
	from encounter_date_details
	group by datename(month, date), month(date)
	) Monthly_Encounters
order by month_num;

/*
---------------------------------------------------
(1b) How many encounters occur each year?
     What are the year-over-year % changes? 		
---------------------------------------------------
*/
	
with encounters_year as(
select
	encount.encounter_id,
	year(encount.start) as year
from encounters encount
)

, Encounters_by_year as(
select
	year,
	count(encounter_id) as total_encounters
from encounters_year
group by year
)

, YoY_Difference as(
select
	year,
	total_encounters,
	lag(total_encounters) over(order by year) last_year,
	total_encounters - lag(total_encounters) over(order by year) as difference
from Encounters_by_year
group by year, total_encounters
)

select
	year,
	total_encounters,
	case 
	when last_year is null then null else
	concat(100*difference/ last_year, '%') end as YoY_Pct_change
from yoy_difference;

/*
---------------------------------------------------
(2) What age groups make up the most encounters?
---------------------------------------------------
*/

with age_group_encounters as(
select
	encount.encounter_id,
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
	as age_group
from encounters encount 
	left join patients pat
	on encount.patient_id = pat.patient_id
)

select
	age_group,
	total_encounters,
	round(100* total_encounters/sum(total_encounters) over() ,0) as pct_of_total
from 
	(
	select
		age_group,
		count(distinct encounter_id) total_encounters
	from age_group_encounters
	group by age_group
	) age_group_encounters
order by age_Group;


/*
---------------------------------------------------
(3) What are the most common procedures performed?
---------------------------------------------------
*/

with procedure_encounters as(	
select
	encount.encounter_id,
	encount.encounter_class,
	prod.description,
	prod.procedure_code
from encounters encount 
	join procedures prod
	on encount.encounter_id = prod.encounter_id
)

select top 10
	procedure_code,
	description,
	encounters,
	round(100* encounters/sum(encounters) over() ,0) as pct_of_total
from 
	(
	select
		procedure_code,
		description,
		count(distinct encounter_id) encounters
	from procedure_encounters
	group by 
		procedure_code, 
		description
	) procedure_encounter_count
order by 
	encounters desc;


/*
---------------------------------------------------
(4) What encounter types are most common?
---------------------------------------------------
*/

with encounter_class_encounters as(
select
	encount.encounter_id,
	encounter_class
from encounters encount 
)

select
	encounter_class,
	encounters,
	round(100* encounters/sum(encounters) over() ,0) as pct_of_total
from
	(
	select
		encounter_class,
		count(distinct encounter_id) encounters
	from encounter_class_encounters
	group by encounter_class
	) Class_Encounters
order by encounters desc;





