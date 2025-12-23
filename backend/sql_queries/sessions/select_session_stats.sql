SELECT 
    COALESCE(SUM(reps_completed * weight_lb), 0) as total_volume_lb,
    COUNT(DISTINCT exercise_id) as exercise_count
FROM workout_sets
WHERE session_id = %s AND is_warmup = false;
