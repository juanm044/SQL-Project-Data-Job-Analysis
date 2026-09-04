SELECT *
FROM job_postings_fact
LIMIT 5

SELECT *
FROM company_dim
--INNER JOIN job_postings_fact AS company_name ON company_name.company_id = company_dim.company_id


