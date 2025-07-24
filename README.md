# hospital-encounters-sql-project

This project explores patient readmissions, encounter types, lengths of stay, revenue, and procedural trends using SQL Server Management Studio.


**DATASET OVERVIEW**
_This is a synthetic dataset for a single hospital detailing 27,891 patient encounters spanning from from January 2011 - Feburary 2022.
This dataset contains the following tables:_

- 'encounters': Hospital visit details including start/stop date/times, encounter class, encounter/patient/payer/ IDs, and claims cost details
- 'patients': Patient details and demographics (birth/death dates, gender, etc.)
- 'payers': Insurance provider details linked to encounters
- 'procedures': Procedure details linked to the encounters
- 'organization': General details about the hospital (name, address, city, etc.)

_The 'encounters' table is the parent table; other tables have a foreign key linking back to 'encounters'._

**Business Problem:**
How does hospital leadership excel revenue optimization, improve operational efficiency, and reduce readmission risk by understanding patient volume patterns and the different trends across different age groups, insurance types, and clinical services?


**Key Questions Answered:**

**PATIENT VOLUME TRENDS: Which patient types drive encounter volume across time, age, procedures, and encounter class?**

  1. How many total encounters occur each month? year? Year-over-year changes?
  2.  Which age groups make up the most amount of encounters?
  3.  Which procedures are most commonly performed by the hospital
  4.  What encounter types are the most common?


**LENGTH OF STAY: Which patients and procedures result in longer stays? What times of year contribute to longer stays and how does that change year-to-year?**

  1. What is the average length of stay (LoS) based on age group?
  2. What is the average length of stay (LoS) over time, by month and year?
  3. What are the procedures that contribute most to the longest length of stays?


**READMISSION RATES: Which patients are most likely to be readmitted back to the hospital within 30 days? How do these rates vary by age, encounter class, and payer?**

  1. What is the overall readmission rate?
  2. Which age groups have the highest readmission rates?
  3. Which encounter classes have the highest readmission rates?
  4. Which Payers have the highest readmission rates?


**REVENUE ANALYSIS: Which procedures and insurance providers generate the most revenue for the hospital?**

  1. Which nsurance providers bringing in the most revenue?
  2. Which procedures are bringing in the most revenue?


**TOP PROCEDURES: What are the most common procedures by age group and gender?**

  1. What are the top 5 procedures for each age group?
  2. What are the top 10 procedures for each gender?

  
