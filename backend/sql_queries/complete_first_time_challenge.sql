UPDATE public.challenges
SET current_progress = 1, is_completed = TRUE, last_updated = %s
WHERE user_id = %s AND challenge_title = 'First Time';