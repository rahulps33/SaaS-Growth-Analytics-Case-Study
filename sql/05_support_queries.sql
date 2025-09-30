-- Show examples of multi-request applications to validate the 10-min rule
SELECT 
    app_id,
    mapped_user_id,
    application_start_time,
    application_end_time,
    requests_in_application,
    DATETIME_DIFF(application_end_time, application_start_time, MINUTE) AS duration_minutes
FROM `saas-session-analytics.growth_data.applications_view`
WHERE requests_in_application > 1
ORDER BY requests_in_application DESC, duration_minutes DESC
LIMIT 10;


-- Distribution of requests per application
SELECT
    requests_in_application,
    COUNT(*) AS application_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1) AS percentage
FROM `saas-session-analytics.growth_data.applications_view`
GROUP BY requests_in_application
ORDER BY requests_in_application;


-- Applications Weekday vs Weekend
SELECT
  CASE 
    WHEN EXTRACT(DAYOFWEEK FROM application_start_time) IN (1,7) THEN 'Weekend'
    ELSE 'Weekday'
  END AS day_type,
  COUNT(*) AS applications
FROM `saas-session-analytics.growth_data.applications_view`
GROUP BY day_type;
