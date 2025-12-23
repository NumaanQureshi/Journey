SELECT 
    id,
    user_id,
    challenge_title, 
    challenge_type, 
    goal, 
    current_progress, 
    is_completed, 
    assigned_at,
    last_updated
FROM public.challenges
WHERE user_id = %s;