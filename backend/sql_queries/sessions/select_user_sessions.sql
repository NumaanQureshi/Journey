SELECT id, user_id, template_id, start_time, end_time, status, 
       duration_min, calories_burned, total_volume_lb
FROM workout_sessions
WHERE user_id = %s
ORDER BY start_time DESC
LIMIT %s;
