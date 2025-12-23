SELECT id, user_id, goal, generated_at, was_completed, feedback_rating, feedback_notes
FROM ai_workout_plans
WHERE user_id = %s
ORDER BY generated_at DESC;