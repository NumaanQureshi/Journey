INSERT INTO public.challenges (user_id)
VALUES (%s)
RETURNING id, user_id, challenge_type, challenge_title, goal, current_progress, is_completed, assigned_at, last_updated;