SELECT ws.id, ws.session_id, ws.exercise_id, e.name, e.category,
       ws.set_number, ws.reps_completed, ws.weight_lb, ws.rpe, ws.is_warmup, ws.created_at
FROM workout_sets ws
JOIN exercises e ON ws.exercise_id = e.id
WHERE ws.session_id = %s
ORDER BY ws.exercise_id, ws.set_number;
