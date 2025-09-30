-- Quick sample exploration
SELECT * FROM `saas-session-analytics.growth_data.requests_log` WHERE RAND() < 0.001;

-- 1. Total requests, unique users, and owners
SELECT
    COUNT(*) AS total_requests,
    COUNT(DISTINCT mapped_user_id) AS unique_users,
    COUNT(DISTINCT owner_id) AS unique_owners
FROM `saas-session-analytics.growth_data.requests_log`;

-- 2. Check for missing values
SELECT
    COUNTIF(timestamp IS NULL) AS missing_timestamps,
    COUNTIF(mapped_user_id IS NULL) AS missing_user_ids,
    COUNTIF(owner_id IS NULL) AS missing_owner_ids,
    COUNTIF(context_os_name IS NULL) AS missing_os,
    COUNTIF(context_browser IS NULL) AS missing_browser
FROM `saas-session-analytics.growth_data.requests_log`;

-- 3. Duplicate request IDs
SELECT id, COUNT(*) AS duplicate_count
FROM `saas-session-analytics.growth_data.requests_log`
GROUP BY id
HAVING duplicate_count > 1;

-- 4. Distribution by OS / browser / device / locale / OS + browser
SELECT context_os_name, COUNT(*) AS requests
FROM `saas-session-analytics.growth_data.requests_log`
GROUP BY context_os_name
ORDER BY requests DESC;

SELECT context_browser, COUNT(*) AS requests
FROM `saas-session-analytics.growth_data.requests_log`
GROUP BY context_browser
ORDER BY requests DESC;

SELECT context_device_manufacturer, COUNT(*) AS requests
FROM `saas-session-analytics.growth_data.requests_log`
GROUP BY context_device_manufacturer
ORDER BY requests DESC;

SELECT context_locale, COUNT(*) AS requests
FROM `saas-session-analytics.growth_data.requests_log`
GROUP BY context_locale
ORDER BY requests DESC;

SELECT context_os_name, context_browser, COUNT(*) AS requests
FROM `saas-session-analytics.growth_data.requests_log`
GROUP BY context_os_name, context_browser
ORDER BY requests DESC;

-- 5. Time range of the dataset (Time Range & Distribution)
SELECT
    MIN(timestamp) AS first_request,
    MAX(timestamp) AS last_request
FROM `saas-session-analytics.growth_data.requests_log`;

-- 6. Requests per day
SELECT DATE(timestamp) AS day, COUNT(*) AS total_requests
FROM `saas-session-analytics.growth_data.requests_log`
GROUP BY day
ORDER BY day;

-- 7. Requests by hour of the day
SELECT EXTRACT(HOUR FROM timestamp) AS hour, COUNT(*) AS total_requests
FROM `saas-session-analytics.growth_data.requests_log`
GROUP BY hour
ORDER BY hour;

-- 8. Requests by weekday (1=Sunday, 7=Saturday)
SELECT EXTRACT(DAYOFWEEK FROM timestamp) AS weekday, COUNT(*) AS requests
FROM `saas-session-analytics.growth_data.requests_log`
GROUP BY weekday
ORDER BY weekday;

-- 9. Weekday vs Weekend analysis
SELECT
  CASE
    WHEN EXTRACT(DAYOFWEEK FROM timestamp) IN (1, 7) THEN 'Weekend'
    ELSE 'Weekday'
  END AS day_type,
  COUNT(*) AS total_requests
FROM `saas-session-analytics.growth_data.requests_log`
GROUP BY day_type
ORDER BY total_requests DESC;

-- 10. Time between requests per user (to validate 10-minute clustering rule)
WITH request_gaps AS (
  SELECT
    mapped_user_id,
    TIMESTAMP_DIFF(timestamp, LAG(timestamp) OVER(PARTITION BY mapped_user_id ORDER BY timestamp), MINUTE) AS gap_minutes
  FROM `saas-session-analytics.growth_data.requests_log`
)
SELECT
  mapped_user_id,
  AVG(gap_minutes) AS avg_gap_minutes,
  MIN(gap_minutes) AS min_gap,
  MAX(gap_minutes) AS max_gap
FROM request_gaps
WHERE gap_minutes IS NOT NULL
GROUP BY mapped_user_id
ORDER BY avg_gap_minutes DESC;

-- 11. Users with very frequent requests (< 10 minutes apart)
WITH request_gaps AS (
  SELECT 
    mapped_user_id,
    TIMESTAMP_DIFF(timestamp, LAG(timestamp) OVER(PARTITION BY mapped_user_id ORDER BY timestamp), MINUTE) AS gap_minutes
  FROM `saas-session-analytics.growth_data.requests_log`
)
SELECT DISTINCT mapped_user_id
FROM request_gaps
WHERE gap_minutes < 10;

-- 12. Detect potential spam (requests within 5 seconds)
WITH request_gaps AS (
  SELECT 
    mapped_user_id,
    timestamp,
    LEAD(timestamp) OVER (PARTITION BY mapped_user_id ORDER BY timestamp) AS next_ts
  FROM `saas-session-analytics.growth_data.requests_log`
)
SELECT 
  mapped_user_id,
  COUNT(*) AS requests_under_5s
FROM request_gaps
WHERE TIMESTAMP_DIFF(next_ts, timestamp, SECOND) < 5
GROUP BY mapped_user_id
ORDER BY requests_under_5s DESC;

-- 13. Flag suspicious requests with timestamps < 5 seconds apart
WITH request_gaps AS (
  SELECT 
    mapped_user_id,
    timestamp AS current_ts,
    LEAD(timestamp) OVER (PARTITION BY mapped_user_id ORDER BY timestamp) AS next_ts,
    TIMESTAMP_DIFF(LEAD(timestamp) OVER (PARTITION BY mapped_user_id ORDER BY timestamp), timestamp, SECOND) AS gap_seconds
  FROM `saas-session-analytics.growth_data.requests_log`
)
SELECT 
  mapped_user_id,
  current_ts,
  next_ts,
  gap_seconds
FROM request_gaps
WHERE gap_seconds IS NOT NULL AND gap_seconds < 5
ORDER BY mapped_user_id, current_ts;



