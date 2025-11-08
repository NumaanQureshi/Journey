SELECT u.id,
    u.email,
    p.age,
    p.gender,
    p.height_in,
    p.weight_lb,
    u.updated_at
FROM users u
    INNER JOIN profiles p ON u.id = p.user_id
WHERE u.id = %s