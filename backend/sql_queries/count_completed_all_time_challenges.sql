SELECT COUNT(id) FROM public.challenges 
WHERE user_id = %s 
AND challenge_type = 'All-Time' 
AND is_completed = TRUE 
AND challenge_title != 'Journey Master';