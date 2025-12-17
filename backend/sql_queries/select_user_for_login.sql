SELECT u.id,
    u.email,
    u.password_hash,
    u.username,
    u.created_at,
    p.age,
    p.gender,
    p.height_in,
    p.weight_lb
FROM users u
    INNER JOIN profiles p ON u.id = p.user_id
WHERE u.email = %s