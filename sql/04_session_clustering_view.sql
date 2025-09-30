-- View to cluster requests into applications per user using 10-minute rule
CREATE OR REPLACE VIEW `saas-session-analytics.growth_data.applications_view` AS
WITH requests_with_gaps AS (
  SELECT
    mapped_user_id,
    timestamp,
    CASE 
      WHEN TIMESTAMP_DIFF(
            timestamp, 
            LAG(timestamp) OVER(PARTITION BY mapped_user_id ORDER BY timestamp), 
            MINUTE
           ) > 10
           OR LAG(timestamp) OVER(PARTITION BY mapped_user_id ORDER BY timestamp) IS NULL
      THEN 1 
      ELSE 0
    END AS new_app_flag
  FROM `saas-session-analytics.growth_data.requests_log`
  WHERE mapped_user_id IS NOT NULL
),
apps_grouped AS (
  SELECT
    mapped_user_id,
    timestamp,
    SUM(new_app_flag) OVER(PARTITION BY mapped_user_id ORDER BY timestamp) AS app_id
  FROM requests_with_gaps
)
SELECT
  mapped_user_id,
  app_id,
  MIN(timestamp) AS application_start_time,
  MAX(timestamp) AS application_end_time,
  COUNT(*) AS requests_in_application
FROM apps_grouped
GROUP BY mapped_user_id, app_id;


-- 1. Total applications, unique users, total requests, and request stats per application
SELECT 
  COUNT(*) AS total_applications,
  COUNT(DISTINCT mapped_user_id) AS unique_users,
  SUM(requests_in_application) AS total_requests,
  ROUND(AVG(requests_in_application), 2) as avg_requests_per_application,
  MIN(application_start_time) as earliest_application,
  MAX(application_start_time) as latest_application
FROM `saas-session-analytics.growth_data.applications_view`;


-- 2. Weekly applications with average, min, max per week
SELECT
  CONCAT(
    CAST(EXTRACT(YEAR FROM application_start_time) AS STRING),
    '-W',
    LPAD(CAST(EXTRACT(WEEK FROM application_start_time) AS STRING), 2, '0')
  ) AS year_week,
  COUNT(*) AS applications_per_week,
  ROUND(AVG(COUNT(*)) OVER(), 2) AS avg_applications_per_week,
FROM `saas-session-analytics.growth_data.applications_view`
GROUP BY year_week
ORDER BY year_week;


-- 3. Number of applications per user role
SELECT
  COALESCE(ur.role, 'role_unknown') AS role,
  COUNT(*) AS applications_per_role,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS percentage
FROM `saas-session-analytics.growth_data.applications_view` a
LEFT JOIN `saas-session-analytics.growth_data.user_roles` ur
  ON a.mapped_user_id = ur.user_id
GROUP BY role
ORDER BY applications_per_role DESC;


-- 4. Applications per company size with average fleet size and percentage
WITH company_categories AS (
  SELECT
    a.mapped_user_id,
    uc.fleet_size,
    CASE
      WHEN uc.fleet_size <= 50 THEN 'Small'
      WHEN uc.fleet_size <= 150 THEN 'Mid'
      WHEN uc.fleet_size > 150 THEN 'Large'
      ELSE 'Unknown'
    END AS company_size
  FROM `saas-session-analytics.growth_data.applications_view` a
  LEFT JOIN `saas-session-analytics.growth_data.user_company` uc
    ON a.mapped_user_id = uc.user_id
)
SELECT
  company_size,
  COUNT(*) AS applications_count,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1) AS percentage,
  CASE 
    WHEN company_size != 'Unknown' THEN ROUND(AVG(fleet_size), 0)
    ELSE NULL
  END AS avg_fleet_size
FROM company_categories
GROUP BY company_size
ORDER BY applications_count DESC;

