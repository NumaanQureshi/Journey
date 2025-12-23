UPDATE workout_sets
SET reps_completed = COALESCE(%s, reps_completed),
    weight_lb = COALESCE(%s, weight_lb),
    rpe = COALESCE(%s, rpe)
WHERE id = %s
RETURNING id, session_id, exercise_id, set_number, reps_completed, weight_lb, rpe;
