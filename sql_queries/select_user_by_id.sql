SELECT u.id,
    u.email,
    u.username,
    u.created_at,
    p.name,
    p.date_of_birth,
    p.gender,
    p.height_in,
    p.weight_lb
FROM users u
    INNER JOIN profiles p ON u.id = p.user_id
WHERE u.id = %s