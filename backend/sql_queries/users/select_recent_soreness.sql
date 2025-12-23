SELECT DISTINCT e.category
FROM workout_sets wst
JOIN workout_sessions ws ON wst.session_id = ws.id
JOIN exercises e ON wst.exercise_id = e.id
WHERE ws.user_id = %s AND ws.start_time > NOW() - INTERVAL '48 hours'
