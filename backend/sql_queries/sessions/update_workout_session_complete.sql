UPDATE workout_sessions
SET end_time = %s, status = 'completed', duration_min = %s, 
    total_volume_lb = %s, calories_burned = %s, notes = %s
WHERE id = %s
RETURNING id, user_id, start_time, end_time, status, duration_min, 
          total_volume_lb, calories_burned, notes;
