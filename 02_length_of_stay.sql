/* Length of Stay Analysis

Goal:
Identify patient factors and services contributing to longer hospital stays to improve capacity planning, reduce resource bottlenecks, and lower care costs.

Business Questions:
(1) Which patients result in longer hospital stays?
(2) Which procedures result in longer stays?
(3) Are there seasonal or year-to-year changes in stay durations?

Key Findings
(1) 30-40 and 40-50 age groups have the highest average lengths of stay at 30 hours.
(2a) December (21hr) and March (17hr) have the highest average length of stay per month.
(2b) The average legnth of stay in 2014 is significantly higher than all the other years at 38 hours.
(3) The top 3 procedures with the longest average lengths of stay are all related to breast cancer:
	- Magnetic resonance imaging of breast - 3382hrs
	- Screening mammography - 1993hrs
	- Biopsy of breast - 1463 hrs

-------------------------------------------------------
(1) What is the average length of stay by age group?
-------------------------------------------------------
*/

with LOS_age as(
select
	encount.encounter_Id,
	encount.start,
	encount.stop,
	encount.encounter_class,
	datediff(hour, encount.start, encount.stop) LOS_hrs,
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
	avg(LOS_hrs) Avg_LOS_hrs
from LOS_age
group by age_group
order by age_group;


/*
-------------------------------------------------------
(2a) What is the average length of stay per month?
-------------------------------------------------------
*/

with LOS as(
select
	start,
	stop,
	datename(month, start) month,
	month(start) month_num,
	datediff(hour, start, stop) LOS_hrs
from encounters
)

select
	month,
	avg(los_hrs) Avg_LOS
from LOS
group by month, month_num
order by month_num;

/*
-------------------------------------------------------
(2b) What is the average length of stay per year?
-------------------------------------------------------
*/

with LOS as(
select
	start,
	stop,
	datename(year, start) year,
	year(start) year_num,
	datediff(hour, start, stop) LOS_hrs
from encounters
)

select
	year,
	avg(los_hrs) Avg_LOS
from LOS
group by year, year_num
order by year_num;

/*
-------------------------------------------------------
(3) Which procedures have the longest hospital stays?
-------------------------------------------------------
*/

with LOS as(
select
	encount.start,
	encount.stop,
	datediff(hour, encount.start, encount.stop) LOS_hrs,
	prod.procedure_code,
	prod.description
from encounters encount
	left join procedures prod
	on encount.encounter_id = prod.encounter_id
where prod.procedure_code is not null
)

select
	procedure_code,
	description,
	avg(los_hrs) Avg_LOS
from LOS
group by procedure_code, description
order by avg_los desc;
