SELECT u.id,
    u.email,
    u.username,
    u.created_at,
    u.updated_at,
    p.name,
    p.date_of_birth,
    p.gender,
    p.height_in,
    p.weight_lb,
    p.main_focus,
    p.goal_weight_lb,
    p.activity_intensity,
    p.fitness_level,
    p.injuries,
    p.available_equipment,
    p.preferred_workout_days
FROM users u
    INNER JOIN profiles p ON u.id = p.user_id
WHERE u.id = %s