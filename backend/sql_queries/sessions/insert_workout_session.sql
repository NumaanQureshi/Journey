INSERT INTO workout_sessions (user_id, template_id, start_time, status, notes)
VALUES (%s, %s, NOW(), 'in_progress', %s)
RETURNING id, user_id, template_id, start_time, end_time, status, duration_min, calories_burned, total_volume_lb, notes;
