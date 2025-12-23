SELECT id, user_id, goal, generated_at, workout_data, was_completed, feedback_rating, feedback_notes
FROM ai_workout_plans
WHERE id = %s AND user_id = %s;