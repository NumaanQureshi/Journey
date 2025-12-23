UPDATE public.challenges
SET current_progress = %s, is_completed = %s, last_updated = NOW()
WHERE id = %s AND user_id = %s
RETURNING id, user_id, challenge_type, challenge_title, goal, current_progress, is_completed, assigned_at, last_updated;