INSERT INTO public.challenges (
        user_id,
        challenge_type,
        challenge_title,
        goal,
        assigned_at,
        last_updated
    )
VALUES (%s, %s, %s, %s, %s, %s);