/* What groups have the highest risk of returning to the hospital within 30 days (readmission)? 
What are the readmission rates for:
(1) Overall
(2) Age Groups
(3) Encounter Types
(4) Payer (Insurance Providers) */

-- (1) Overall Readmission Rate
with encounters_order as (
	select
		encount.patient_id,
		cast(encount.start as date) date,
		cast(encount.stop as date) discharge_date,
		encount.encounter_id,
		lag(encount.stop) over (partition by encount.patient_id order by cast(encount.start as date)) as previous_discharge_date,
		datediff(day, lag(encount.stop) over (partition by encount.patient_id order by encount.start), start) days_since_discharge,
		row_number() over(Partition by encount.patient_id order by encount.start) encounter_number
	from encounters encount
		left join patients pat
		on encount.patient_id = pat.patient_id
	where stop is not null
)

,Readmissions as (
	select
		now.patient_id,
		now.encounter_id as index_encounter_id,
		next.encounter_id as readmission_encounter_id,
		datediff(day, now.discharge_date, next.date) as days_between
	from encounters_order now
		join encounters_order next
		on now.patient_id = next.patient_id
		and next.encounter_number = now.encounter_number + 1
		and datediff(day, now.discharge_date, next.date) between 0 and 30
)

select
	count(distinct readmit.index_encounter_id) as number_readmissions,
	count(distinct encounto.encounter_id) as total_index_encounters,
	concat(round(100.0*cast(count(distinct readmit.index_encounter_id) as float) / count(distinct encounto.encounter_id), 2), '%') as readmission_rate_30_day
from encounters_order encounto
	left join readmissions readmit
	on encounto.encounter_id = readmit.index_encounter_id;



-- (2) Readmission Rates per Age Group
with encounters_order as (
	select
		encount.patient_id,
		cast(encount.start as date) date,
		cast(encount.stop as date) discharge_date,
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
		as age_group,
		lag(encount.stop) over (partition by encount.patient_id order by cast(encount.start as date)) as previous_discharge_date,
		datediff(day, lag(encount.stop) over (partition by encount.patient_id order by encount.start), start) days_since_discharge,
		row_number() over(Partition by encount.patient_id order by encount.start) encounter_number
	from encounters encount
		left join patients pat
		on encount.patient_id = pat.patient_id
	where stop is not null
)

,Readmissions as (
	select
		now.age_group,
		now.patient_id,
		now.encounter_id as index_encounter_id,
		next.encounter_id as readmission_encounter_id,
		datediff(day, now.discharge_date, next.date) as days_between
	from encounters_order now
		join encounters_order next
		on now.patient_id = next.patient_id
		and next.encounter_number = now.encounter_number + 1
		and datediff(day, now.discharge_date, next.date) between 0 and 30
)

select
	encounto.age_group,
	count(distinct readmit.index_encounter_id) as number_readmissions,
	count(distinct encounto.encounter_id) as total_index_encounters,
	concat(round(100.0*cast(count(distinct readmit.index_encounter_id) as float) / count(distinct encounto.encounter_id), 2), '%') as readmission_rate_30_day
from encounters_order encounto
	left join readmissions readmit
	on encounto.encounter_id = readmit.index_encounter_id
group by encounto.age_group
order by encounto.age_group



-- (3) Readmission rates by Encounter Types
with encounters_order as (
	select
		encount.patient_id,
		cast(encount.start as date) date,
		cast(encount.stop as date) discharge_date,
		encount.encounter_id,
		encount.encounter_class,
		lag(encount.stop) over (partition by encount.patient_id order by cast(encount.start as date)) as previous_discharge_date,
		datediff(day, lag(encount.stop) over (partition by encount.patient_id order by encount.start), start) days_since_discharge,
		row_number() over(Partition by encount.patient_id order by encount.start) encounter_number
	from encounters encount
		left join patients pat
		on encount.patient_id = pat.patient_id
	where stop is not null
)

,Readmissions as (
	select
		now.encounter_class, 
		now.patient_id,
		now.encounter_id as index_encounter_id,
		next.encounter_id as readmission_encounter_id,
		datediff(day, now.discharge_date, next.date) as days_between
	from encounters_order now
		join encounters_order next
		on now.patient_id = next.patient_id
		and next.encounter_number = now.encounter_number + 1
		and datediff(day, now.discharge_date, next.date) between 0 and 30
)

select
	encounto.encounter_class,
	count(distinct readmit.index_encounter_id) as number_readmissions,
	count(distinct encounto.encounter_id) as total_index_encounters,
	concat(round(100.0*cast(count(distinct readmit.index_encounter_id) as float) / count(distinct encounto.encounter_id), 2), '%') as readmission_rate_30_day
from encounters_order encounto
	left join readmissions readmit
	on encounto.encounter_id = readmit.index_encounter_id
group by encounto.encounter_class
order by readmission_rate_30_day desc



-- (4) Readmission rates per Insurance Type (payer)
with encounters_order as (
	select
		encount.patient_id,
		cast(encount.start as date) date,
		cast(encount.stop as date) discharge_date,
		encount.encounter_id,
		pay.payer_name,
		lag(encount.stop) over (partition by encount.patient_id order by cast(encount.start as date)) as previous_discharge_date,
		datediff(day, lag(encount.stop) over (partition by encount.patient_id order by encount.start), start) days_since_discharge,
		row_number() over(Partition by encount.patient_id order by encount.start) encounter_number
	from encounters encount
		left join patients pat
		on encount.patient_id = pat.patient_id
		left join payers pay
		on encount.payer_id = pay.payer_id
	where stop is not null
)

,Readmissions as (
	select
		now.payer_name,
		now.patient_id,
		now.encounter_id as index_encounter_id,
		next.encounter_id as readmission_encounter_id,
		datediff(day, now.discharge_date, next.date) as days_between
	from encounters_order now
		join encounters_order next
		on now.patient_id = next.patient_id
		and next.encounter_number = now.encounter_number + 1
		and datediff(day, now.discharge_date, next.date) between 0 and 30
)

select
	encounto.payer_name,
	count(distinct readmit.index_encounter_id) as number_readmissions,
	count(distinct encounto.encounter_id) as total_index_encounters,
	concat(round(100.0*cast(count(distinct readmit.index_encounter_id) as float) / count(distinct encounto.encounter_id), 2), '%') as readmission_rate_30_day
from encounters_order encounto
	left join readmissions readmit
	on encounto.encounter_id = readmit.index_encounter_id
group by encounto.payer_name
order by readmission_rate_30_day desc;
