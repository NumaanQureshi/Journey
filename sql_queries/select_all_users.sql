SELECT u.id,
    u.email,
    u.created_at,
    p.date_of_birth,
    p.gender,
    p.height_in,
    p.weight_lb
FROM users u
    INNER JOIN profiles p ON u.id = p.user_id