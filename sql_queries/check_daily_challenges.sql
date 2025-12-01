SELECT 1 FROM public.challenges 
WHERE user_id = %s 
  AND challenge_type = 'Daily' 
  AND DATE(assigned_at AT TIME ZONE 'UTC') = %s LIMIT 1;