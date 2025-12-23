SELECT ws.id 
FROM workout_sets ws
JOIN workout_sessions wses ON ws.session_id = wses.id
WHERE ws.id = %s AND wses.user_id = %s;
