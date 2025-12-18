UPDATE ai_workout_plans
SET feedback_rating = %s, feedback_notes = %s, was_completed = TRUE
WHERE id = %s
