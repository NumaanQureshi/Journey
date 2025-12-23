INSERT INTO workout_sessions (user_id, template_id, start_time, status, notes)
VALUES (%s, %s, NOW(), 'in_progress', %s)
RETURNING id;
