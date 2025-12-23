SELECT 
    u.id, u.username, u.email,
    p.name, p.date_of_birth, p.gender, p.height_in, p.weight_lb,
    p.main_focus, p.fitness_level, p.injuries, 
    p.available_equipment, p.preferred_workout_days
FROM users u
LEFT JOIN profiles p ON u.id = p.user_id
WHERE u.id = %s
