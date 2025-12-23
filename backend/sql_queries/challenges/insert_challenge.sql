INSERT INTO public.challenges (
        user_id,
        challenge_type,
        challenge_title,
        goal,
        assigned_at,
        last_updated
    )
VALUES (%s, %s, %s, %s, %s, %s)
RETURNING id, user_id, challenge_type, challenge_title, goal, current_progress, is_completed, assigned_at, last_updated;