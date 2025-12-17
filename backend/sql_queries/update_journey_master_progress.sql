UPDATE public.challenges
SET current_progress = %s, 
    is_completed = CASE WHEN goal <= %s THEN TRUE ELSE FALSE END,
    last_updated = NOW()
WHERE user_id = %s AND challenge_title = 'Journey Master';