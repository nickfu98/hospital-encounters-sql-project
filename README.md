# Hospital Encounters SQL Project

This project is meant to gain insights into patient readmissions, length of stay, revenue performance, and procedure trends using SQL queries.

Tools Used: SQL Server Management Studio (SSMS)
Data Size: 27,891 hospital encounters across 11 years
Focus Area: Healthcare operations and quality analytics

---

## Dataset Overview
_This is a synthetic dataset for a single hospital detailing 27,891 patient encounters spanning from January 2011 - February 2022.
This dataset contains the following tables:_

- `encounters`: Hospital visit details including start/stop date/times, encounter class, encounter/patient/payer/ IDs, and claims cost details
- `patients`: Patient details and demographics (birth/death dates, gender, etc.)
- `payers`: Insurance provider details linked to encounters
- `procedures`: Procedure details linked to the encounters
- `organization`: General details about the hospital (name, address, city, etc.)

_The 'encounters' table is the parent table; other tables have a foreign key linking back to 'encounters'._

---

## Executive Summary
Hospital leadership must reduce costs, and optimize operations all while improving patient outcomes. This project uses SSMS to:
  - Improve **operational efficiency** by analyzing patient volume and length of stay trends
  - Reduce **readmission risk** by identifying patterns in age, insurance, and encounter types
  - Maximize **revenue** by tracking the most profitable procedures and payer sources

By analyzing this dataset in SSMS, I demonstrate my practical SQL skills aligned with the goals of modern healthcare analytics and simulate the real world responsibilities of a healthcare data analyst.

---

## Key Business Questions Answered

### PATIENT VOLUME TRENDS
**Which patient types drive encounter volume across time, age, procedures, and encounter class?**

  - How many total encounters occur each month? year? Year-over-year changes?
  - Which age groups make up the most amount of encounters?
  - Which procedures are most commonly performed by the hospital
  - What encounter types are the most common?

---

### LENGTH OF STAY (LOS)
**Which patients and procedures result in longer hospital stays?**

  - What is the average length of stay by age group?
  - How does average length of stay trend over time (monthly and yearly)?
  - Which procedures contribute to the longest hospital stays?

---

### READMISSION RATES
**Who is most likely to return within 30 days, and why?**

  - What is the overall 30-day readmission rate?
  - Which age groups have the highest readmission rates?
  - Which encounter classes are associated with high readmissions?
  - Which insurance payers are associated with higher readmission rates?

---

### REVENUE ANALYSIS
**What does hospital revenue come from?**

  - Which insurance payers generate the most revenue?
  - Which procedures generate the most revenue?

---

### TOP PROCEDURES
**What clinical services are used most across patient populations?**

  - What are the top procedures for each age group?
  - What are the top procedures for each gender?

--- 

  
