INSERT INTO ai_workout_plans (user_id, goal, workout_data)
VALUES (%s, %s, %s)
RETURNING id
