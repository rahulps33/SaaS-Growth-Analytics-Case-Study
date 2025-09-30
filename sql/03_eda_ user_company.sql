SELECT * FROM `saas-session-analytics.growth_data.user_company` WHERE RAND() < 0.001;


# Check number of users and companies
SELECT COUNT(*) AS total_rows,
       COUNT(DISTINCT user_id) AS unique_users,
       COUNT(DISTINCT company_id) AS unique_companies
FROM `saas-session-analytics.growth_data.user_company`;


# Check fleet size distribution
SELECT 
    COUNT(*) AS total_users,
    MIN(fleet_size) AS min_fleet,
    MAX(fleet_size) AS max_fleet,
    AVG(fleet_size) AS avg_fleet
FROM `saas-session-analytics.growth_data.user_company`;


# Check for missing fleet sizes
SELECT COUNT(*) AS missing_fleet
FROM `saas-session-analytics.growth_data.user_company`
WHERE fleet_size IS NULL;


# Categorize companies by size
SELECT
  CASE
    WHEN fleet_size <= 50 THEN 'Small'
    WHEN fleet_size <= 150 THEN 'Mid'
    ELSE 'Large'
  END AS company_size,
  COUNT(*) AS users
FROM `saas-session-analytics.growth_data.user_company`
GROUP BY company_size;




