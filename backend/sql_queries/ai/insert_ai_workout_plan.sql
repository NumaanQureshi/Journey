INSERT INTO ai_workout_plans (user_id, goal, workout_data)
VALUES (%s, %s, %s)
RETURNING id, user_id, goal, workout_data, generated_at, was_completed, feedback_rating, feedback_notes
