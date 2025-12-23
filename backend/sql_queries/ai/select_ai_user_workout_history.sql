SELECT 
    ws.id, ws.start_time, ws.end_time, ws.duration_min,
    COUNT(wst.id) as exercises_count
FROM workout_sessions ws
LEFT JOIN workout_sets wst ON ws.id = wst.session_id
WHERE ws.user_id = %s AND ws.end_time IS NOT NULL
GROUP BY ws.id
ORDER BY ws.start_time DESC
LIMIT %s
