UPDATE workout_sessions
SET end_time = NOW(),
    status = 'completed',
    duration_min = %s,
    calories_burned = %s,
    total_volume_lb = %s,
    notes = %s
WHERE id = %s
RETURNING id;
