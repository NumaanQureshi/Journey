SELECT 1 FROM public.challenges 
WHERE user_id = %s 
AND challenge_type = 'Weekly' 
AND EXTRACT(WEEK FROM assigned_at AT TIME ZONE 'UTC') = %s
AND EXTRACT(ISOYEAR FROM assigned_at AT TIME ZONE 'UTC') = %s
LIMIT 1;