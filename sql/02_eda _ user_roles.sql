SELECT  * FROM `saas-session-analytics.growth_data.user_roles` WHERE RAND() < 0.001;


# Check number of users and roles
SELECT COUNT(*) AS total_users,
       COUNT(DISTINCT user_id) AS unique_users
FROM `saas-session-analytics.growth_data.user_roles`;

SELECT role, COUNT(*) AS users_per_role
FROM `saas-session-analytics.growth_data.user_roles`
GROUP BY role;

# Check for missing roles
SELECT COUNT(*) AS missing_roles
FROM `saas-session-analytics.growth_data.user_roles`
WHERE role IS NULL;
