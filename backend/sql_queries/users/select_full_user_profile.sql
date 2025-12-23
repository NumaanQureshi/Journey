SELECT 
    u.id, u.username, u.email, u.created_at, u.updated_at,
    p.name, p.date_of_birth, p.gender, p.height_in, p.weight_lb,
    p.main_focus, p.fitness_level, p.injuries, p.goal_weight_lb, p.activity_intensity,
FROM users u
LEFT JOIN profiles p ON u.id = p.user_id
WHERE u.id = %s
