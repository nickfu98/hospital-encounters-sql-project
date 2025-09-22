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
	- Auscultation of the fetal heart - $18,332,574
	- Evaluation of uterine fundal height - $18,332,574
(2b) Top 3 procedures by average revenue per encounter
	- Transfer to stepdown unit - $385,387
	- Admit to ICU - $385,130
	- Resuscitation using intravenous fluid - $321,102

Recommendations:
(1) Focus on Building Strong Partnerships with Medicare, Medicaid, and Blue Cross Blue Shield
	- Find ways to increase the revenue earned per encounter through improved billing and contracts with these providers
(2) Keep High Revenue Procedures Well Equipped
	- Make sure the high revenue procedures are well staffed and scheduled efficiently to keep up with demand
*/


/*
-------------------------------------------------------
(1) Which insurance payers generates the most total revenue and average revenue per encounter?
-------------------------------------------------------
*/

WITH encounters_payment AS (
	SELECT
		encount.encounter_id,
		encount.payer_id,
		pay.payer_name,
		round(encount.total_claim_cost, 2) AS total_claim_cost,
		round(encount.payer_coverage, 2) AS payer_coverage,
		round((encount.total_claim_cost - encount.payer_coverage), 2) AS patient_cost
	FROM encounters encount
		LEFT JOIN payers pay
		ON encount.payer_id = pay.payer_id
	WHERE total_claim_cost is not null
)

SELECT
	payer_name,
	round(sum(payer_coverage), 0) AS total_payer_revenue,
	round(AVG(payer_coverage), 0) AS avg_revenue_per_encounter
FROM encounters_payment
GROUP BY payer_name
ORDER BY total_payer_revenue DESC;


/*
-------------------------------------------------------
(2) Which procedures generate the most revenue and average revenue per encounter?
-------------------------------------------------------
*/

WITH procedures_payment AS(
	SELECT
		encount.encounter_id,
		prod.procedure_code,
		prod.description,
		round(encount.total_claim_cost, 2) AS total_claim_cost
	FROM encounters encount
		LEFT JOIN procedures prod
			ON encount.encounter_id = prod.encounter_id
	WHERE prod.procedure_code is not null
	)

SELECT TOP 10
	procedure_code,
	description,
	round(sum(total_claim_cost), 0) AS total_revenue,
	round(AVG(total_claim_cost), 0) AS AVG_revenue_per_encounter
FROM procedures_payment
GROUP BY procedure_code, description
ORDER BY total_revenue DESC;
