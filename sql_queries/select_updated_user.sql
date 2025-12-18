SELECT 
    u.id,
    u.email,
    p.date_of_birth,
    p.gender,
    p.height_in,
    p.weight_lb,
    u.updated_at,
    p.name,
    p.goal_weight_lb,
    p.main_focus,
    p.activity_intensity
FROM users u
    INNER JOIN profiles p ON u.id = p.user_id
WHERE u.id = %s