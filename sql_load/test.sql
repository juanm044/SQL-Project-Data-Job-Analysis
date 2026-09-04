WITH company_totals AS (
    SELECT 
    name,
        count(*) total_postings
    FROM company_dim
    INNER JOIN job_postings_fact AS company_name ON company_name.company_id = company_dim.company_id
    GROUP BY company_dim.company_id
)

SELECT *, 
CASE 
    WHEN total_postings < 10 THEN 'Small'
    WHEN total_postings >= 10 AND total_postings < 50 THEN 'Medium'
    ELSE 'Large'
End AS company_size
FROM company_totals


