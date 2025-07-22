# hospital-encounters-sql-project
SQL project dealing with a synthetic hospital encounters dataset spanning 11 years. Analyzing patient readmissions, encounter , length of stay, revenue, and procedural trends

This is a synthetic dataset for a single hospital detailing 27,891 patient encounters spanning from from 2011-2022. This dataset contains the following tables:

- 'encounters': hospital visit details including start/stop date/times, encounter class, encounter/patient/payer/ IDs, and claims cost details
- 'patients': patient details and demographics (birth/death dates, gender, etc.)
- 'payers': insurance provider details linked to encounters
- 'procedures': procedure details of those performed during encounters
- 'organization': general details about the hospital (name, address, city, etc.)

-- All tables have foreign keys linking back to parent keys in the 'encounters' table
