WITH latest AS (
    SELECT 
        e.name,
        MAX(wst.weight_lb) as current_weight,
        MAX(wst.reps_completed) as current_reps
    FROM workout_sets wst
    JOIN workout_sessions ws ON wst.session_id = ws.id
    JOIN exercises e ON wst.exercise_id = e.id
    WHERE ws.user_id = %s
    GROUP BY e.name
)
SELECT * FROM latest
LIMIT 10
