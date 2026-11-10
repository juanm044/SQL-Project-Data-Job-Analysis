# Introduction
This project explores the data analyst job market, focusing on top-paying jobs, in-demand skills, and where high demand meets high salary in data analytics.

SQL queries are in the [project_sql folder](/project_sql/).

# Background
This project was created to better understand the data analyst job market by pinpointing the top-paying and most in-demand skills, making it easier for others to find the best job opportunities.

The data comes from the [SQL Course](https://www.lukebarousse.com/sql) and includes job titles, salaries, locations, and essential skills.

### Questions Answered with SQL

1. What are the top-paying data analyst jobs?
2. What skills are required for these top-paying jobs?
3. What skills are most in demand for data analysts?
4. Which skills are associated with higher salaries?
5. What are the most optimal skills to learn?

# Tools Used
The following tools were used for this analysis:
- **SQL**: The core of the analysis, used to query the database and pull out insights.
- **PostgreSQL**: The database management system used to store and query the job posting data.
- **Visual Studio Code**: Used for database management and for running SQL queries.
- **Git & GitHub**: Used for version control and for sharing the SQL scripts and analysis.

# The Analysis
Each query looks at a specific part of the data analyst job market. Here is how each question was approached.

### 1. Top Paying Data Analyst Jobs
To find the highest-paying roles, data analyst positions were filtered by average yearly salary and location, focusing on remote jobs. This query highlights the top-paying opportunities in the field.

```sql
SELECT
    job_id, 
    job_title, 
    job_location, 
    job_schedule_type, 
    salary_year_avg, 
    job_posted_date,
    name AS company_name
FROM
    job_postings_fact
LEFT JOIN company_dim ON job_postings_fact.company_id = company_dim.company_id
WHERE
    job_title_short = 'Data Analyst' AND 
    job_location = 'Anywhere' AND
    salary_year_avg IS NOT NULL
ORDER BY 
    salary_year_avg DESC
LIMIT 10
```
Here is a breakdown of the top data analyst jobs in 2023:
- **Wide Salary Range:** The top 10 paying data analyst roles range from $184,000 to $650,000, which shows significant salary potential in the field.
- **Diverse Employers:** Companies like SmartAsset, Meta, and AT&T are among those offering high salaries, showing interest across different industries.
- **Job Title Variety:** Job titles range from Data Analyst to Director of Analytics, reflecting the different roles and specializations within data analytics.

![Top Paying Roles](assets/1_top_paying_roles.png)
*Bar graph of the top 10 data analyst salaries; Claude generated this graph from the SQL query results*

### 2. Skills for Top Paying Jobs

To see which skills the top-paying jobs require, the job postings were joined with the skills data. This shows what employers look for in high-paying roles.

```sql
WITH top_paying_jobs AS (
    SELECT
        job_id, 
        job_title, 
        salary_year_avg, 
        name AS company_name
    FROM
        job_postings_fact
    LEFT JOIN company_dim ON job_postings_fact.company_id = company_dim.company_id
    WHERE
        job_title_short = 'Data Analyst' AND 
        job_location = 'Anywhere' AND
        salary_year_avg IS NOT NULL
    ORDER BY 
        salary_year_avg DESC
    LIMIT 10
)

SELECT 
    top_paying_jobs.*, 
    skills
FROM top_paying_jobs
INNER JOIN skills_job_dim ON top_paying_jobs.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
ORDER BY salary_year_avg DESC
```
Here is a breakdown of the most requested skills for the top 10 highest paying data analyst jobs in 2023:
- **SQL** is the most common, appearing in 8 of the 10 postings.
- **Python** follows closely, appearing in 7.
- **Tableau** appears in 6. Other skills like R, Snowflake, Pandas, and Excel show up less often.

![Top Paying Skills](assets/2_top_paying_job_skils.png)
*Bar graph of skill counts for the top 10 paying data analyst jobs; Claude generated this graph from the SQL query results*

### 3. In-Demand Skills for Data Analysts
This query identifies the skills most frequently requested in job postings, pointing to the areas with the highest demand.

```sql
SELECT 
    skills, 
    COUNT(skills_job_dim.job_id) AS demand_count 
FROM job_postings_fact
INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE 
    job_title_short = 'Data Analyst'
    AND job_work_from_home = TRUE 
GROUP BY skills
ORDER BY demand_count DESC
LIMIT 5
```
Here is a breakdown of the most requested skills for data analysts in 2023:
- **SQL** and **Excel** remain fundamental, showing the need for strong foundations in data processing and spreadsheets.
- **Python**, **Tableau**, and **Power BI** are also essential, pointing to the growing importance of programming and visualization tools for data storytelling and decision support.

| skills | demand_count |
|---|---|
| sql | 7291 |
| excel | 4611 |
| python | 4330 |
| tableau | 3745 |
| power bi | 2609 |

*Demand for the top 5 skills in data analyst job postings*

### 4. Skills Based on Salary
Looking at the average salary for each skill shows which skills are the highest paying.

```sql
SELECT 
    skills, 
    Round (AVG(salary_year_avg), 0) AS avg_salary
FROM job_postings_fact
INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE job_title_short = 'Data Analyst' AND
    salary_year_avg IS NOT NULL
GROUP BY skills
ORDER BY avg_salary DESC
LIMIT 25
```
Here is a breakdown of the results for the top paying skills for data analysts:

- **Big Data and Machine Learning Skills:** The highest salaries go to analysts with big data technologies (PySpark, Couchbase), machine learning tools (DataRobot, Jupyter), and Python libraries (Pandas, NumPy). This reflects how highly the industry values data processing and predictive modeling.
- **Software Development and Deployment Tools:** Skills in development and deployment tools (GitLab, Kubernetes, Airflow) show a valuable overlap between data analysis and engineering, with a premium on skills that support automation and efficient data pipelines.
- **Cloud Computing:** Familiarity with cloud and data engineering tools (Elasticsearch, Databricks, GCP) highlights the growing importance of cloud-based analytics, and suggests that cloud skills can significantly boost earning potential.

| skills | avg_salary |
|---|---|
| pyspark | 208172 |
| bitbucket | 189155 |
| watson | 160515 |
| couchbase | 160515 |
| datarobot | 155486 |
| gitlab | 154500 |
| swift | 153750 |
| jupyter | 152777 |
| pandas | 151821 |
| elasticsearch | 145000 |

*Average salary for the top 10 paying skills*

### 5. Most Optimal Skills to Learn

This query combines the demand and salary data to find skills that are both in high demand and well paid, which gives a more strategic focus for skill development.

```sql
WITH skills_demand AS (
    SELECT 
        skills_dim.skill_id,
        skills_dim.skills, 
        COUNT(skills_job_dim.job_id) AS demand_count 
    FROM job_postings_fact
    INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
    INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
    WHERE 
        job_title_short = 'Data Analyst' 
        AND salary_year_avg IS NOT NULL
        AND job_work_from_home = TRUE
    GROUP BY skills_dim.skill_id
), average_salary AS (
    SELECT 
        skills_job_dim.skill_id,
        Round (AVG(salary_year_avg), 0) AS avg_salary
    FROM job_postings_fact
    INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
    INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
    WHERE 
        job_title_short = 'Data Analyst' 
        AND salary_year_avg IS NOT NULL
        AND job_work_from_home = TRUE
    GROUP BY skills_job_dim.skill_id
)


SELECT
    skills_demand.skill_id,
    skills_demand.skillS,
    demand_count, 
    avg_salary
From    skills_demand
INNER JOIN average_salary ON skills_demand.skill_id = average_salary.skill_id
WHERE demand_count > 10
ORDER BY
    avg_salary DESC,
    demand_count DESC
```
| skill_id | skills | demand_count | avg_salary |
|---|---|---|---|
| 8 | go | 27 | 115320 |
| 234 | confluence | 11 | 114210 |
| 97 | hadoop | 22 | 113193 |
| 80 | snowflake | 37 | 112948 |
| 74 | azure | 34 | 111225 |
| 77 | bigquery | 13 | 109654 |
| 76 | aws | 32 | 108317 |
| 4 | java | 17 | 106906 |
| 194 | ssis | 12 | 106683 |
| 233 | jira | 20 | 104918 |

- **Cloud and big data platforms (Snowflake, Azure, AWS, BigQuery, Hadoop):** This is the largest and most consistent group, with 5 of the 10 skills. Demand ranges from 13 to 37 postings, and salaries cluster tightly between $108K and $113K. This makes cloud and big data infrastructure the strongest category to invest in, since it offers the best balance of demand and pay and applies across many employers rather than being tied to one company's stack.

- **Collaboration and project management tools (Confluence, Jira):** These pay well ($114,210 and $104,918) despite relatively low demand (11 and 20 postings). When these tools appear in a posting, it is often for more senior or cross-functional roles, where working in structured, agile team environments is valued. They work less as standalone technical skills and more as a sign of process maturity.

- **Programming languages (Go, Java):** Go leads the list in salary ($115,320) despite modest demand (27), while Java sits lower on both demand (17) and salary ($106,906). Go may be a differentiating, less commonly required skill that pays a premium because fewer analysts have it, while Java is more common and earns a smaller premium.

# What I Learned
This project built up my SQL skills in several areas:
- **Complex Query Building:** Joining multiple tables and using `WITH` clauses to create temporary tables for multi-step queries.
- **Data Aggregation:** Using `GROUP BY` with aggregate functions like `COUNT()` and `AVG()` to summarize data.
- **Analytical Problem Solving:** Turning real-world questions into SQL queries that produce useful insights.

### Conclusions
1. **Top-Paying Data Analyst Jobs:** The highest-paying remote data analyst jobs offer a wide range of salaries, with the highest at $650,000.
2. **Skills for Top-Paying Jobs:** High-paying data analyst jobs require advanced SQL skills, which suggests SQL is critical for earning a top salary.
3. **Most In-Demand Skills:** SQL is also the most requested skill in the data analyst job market, which makes it essential for job seekers.
4. **Skills with Higher Salaries:** Specialized skills such as SVN and Solidity are associated with the highest average salaries, which indicates a premium on niche expertise.
5. **Optimal Skills for Job Market Value:** SQL leads in demand and offers a high average salary, making it one of the best skills for data analysts to learn to maximize their market value.

### Closing Thoughts
This project strengthened my SQL skills and gave me useful insight into the data analyst job market. The findings can help guide skill development and job searching. Aspiring data analysts can position themselves well in a competitive market by focusing on high-demand, high-salary skills, and the project highlights the importance of continuing to learn as the field changes.
