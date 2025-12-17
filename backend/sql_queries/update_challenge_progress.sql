UPDATE public.challenges
SET current_progress = %s, is_completed = %s, last_updated = NOW()
WHERE id = %s AND user_id = %s;