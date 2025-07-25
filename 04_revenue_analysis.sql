/* Revenue Analysis

Goal:
To identify the primary sources of hospital revenue by analyzing which insurance payers contribute the most financially, and which medical procedures generate the highest revenues.

Business Questions:
(1a) Which insurance payers bring in the most revenue?
(1b) What is the average revenue per encounter for each insurance payer?
(2a) Which procedures generate the most total revenue?
(2b) What is the average revenue per encounter for these top procedures?

Key Findings
(1a) Top 3 insurance payers by total revenue:
	- Medicare - $19,215,691
	- Medicaid - $8,471,974
	- Blue Cross Blue Shield - $2,074,496
(1b) Top 3 insurance payers by average revenue per encounter:
	- Medicaid - $5,834 
	- Blue Cross Blue Shield - $2,243
	- Medicare - $1,690
(2a) Top 3 procedures by total revenue:
	- Electrical cardioversion - $36,464,315
	- Ausculation of the fetal heart - $18,332,574
	- Evaluation of uterine fundal height - $18,332,574
(2b) Top 3 procedures by average revenue per encounter
	- Transfer to stepdown unit - $385,387
	- Admit to ICU - $385,130
	- Resuscitation using intravenous fluid $321,102
*/


/*
-------------------------------------------------------
(1) Which insurance payers generates the most total revenue and average revenue per encounter?
-------------------------------------------------------
*/

with encounters_payment as (
	select
		encount.encounter_id,
		encount.payer_id,
		pay.payer_name,
		round(encount.total_claim_cost, 2) as total_claim_cost,
		round(encount.payer_coverage, 2) as payer_coverage,
		round((encount.total_claim_cost - encount.payer_coverage), 2) as patient_cost
	from encounters encount
		left join payers pay
		on encount.payer_id = pay.payer_id
	where total_claim_cost is not null
)

select
	payer_name,
	round(sum(payer_coverage), 0) as total_payer_revenue,
	round(avg(payer_coverage), 0) as avg_revenue_per_encounter,
	round(sum(patient_cost), 0) as total_patient_revenue,
	round(avg(patient_cost), 0) as avg_patient_cost
from encounters_payment
group by payer_name
order by total_payer_revenue desc;


/*
-------------------------------------------------------
(2) Which procedures generate the most revenue and average revenue per encounter?
-------------------------------------------------------
*/

with procedures_payment as(
	select
		encount.encounter_id,
		prod.procedure_code,
		prod.description,
		round(encount.total_claim_cost, 2) as total_claim_cost
	from encounters encount
		left join procedures prod
			on encount.encounter_id = prod.encounter_id
	where prod.procedure_code is not null
	)

select top 10
	procedure_code,
	description,
	round(sum(total_claim_cost), 0) as total_revenue,
	round(avg(total_claim_cost), 0) as avg_revenue_per_encounter
from procedures_payment
group by procedure_code, description
order by total_revenue desc;
