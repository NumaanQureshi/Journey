SELECT 
    id, 
    challenge_title, 
    challenge_type, 
    goal, 
    current_progress, 
    is_completed, 
    assigned_at
FROM public.challenges
WHERE user_id = %s;