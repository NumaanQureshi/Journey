SELECT 
    COUNT(*) as total_plans_generated,
    COALESCE(SUM(CASE WHEN was_completed = true THEN 1 ELSE 0 END), 0) as plans_completed,
    COALESCE(AVG(feedback_rating), 0) as avg_feedback_rating
FROM ai_workout_plans
WHERE user_id = %s;