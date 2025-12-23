INSERT INTO workout_sets (session_id, exercise_id, set_number, reps_completed, weight_lb, rpe, is_warmup)
VALUES (%s, %s, %s, %s, %s, %s, %s)
RETURNING id, session_id, exercise_id, set_number, reps_completed, weight_lb, rpe, is_warmup, created_at;
