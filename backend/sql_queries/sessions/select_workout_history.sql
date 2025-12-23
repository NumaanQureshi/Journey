SELECT 
    ws.id AS session_id,
    ws.user_id,
    ws.template_id,
    ws.start_time,
    ws.end_time,
    ws.status,
    ws.duration_min,
    ws.calories_burned,
    ws.total_volume_lb,
    ws.notes,
    wt.name AS template_name
FROM workout_sessions ws
LEFT JOIN workout_templates wt ON ws.template_id = wt.id
WHERE ws.user_id = %s AND ws.status = 'completed'
ORDER BY ws.start_time DESC
LIMIT %s;
