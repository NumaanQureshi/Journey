UPDATE public.challenges
SET current_progress = 1, is_completed = TRUE, last_updated = %s
WHERE user_id = %s AND challenge_title = 'First Time'
RETURNING id, user_id, challenge_type, challenge_title, goal, current_progress, is_completed, assigned_at, last_updated;