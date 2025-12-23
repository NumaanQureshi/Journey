UPDATE ai_workout_plans
SET feedback_rating = %s, feedback_notes = %s, was_completed = TRUE
WHERE id = %s
RETURNING id, user_id, goal, workout_data, generated_at, was_completed, feedback_rating, feedback_notes;