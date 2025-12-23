UPDATE profiles
SET name = COALESCE(%s, name),
    date_of_birth = COALESCE(%s, date_of_birth),
    gender = COALESCE(%s, gender),
    height_in = COALESCE(%s, height_in),
    weight_lb = COALESCE(%s, weight_lb),
    goal_weight_lb = COALESCE(%s, goal_weight_lb),
    main_focus = COALESCE(%s, main_focus),
    activity_intensity = COALESCE(%s, activity_intensity)
WHERE user_id = %s
RETURNING user_id, name, date_of_birth, gender, height_in, weight_lb, main_focus, goal_weight_lb, activity_intensity, fitness_level, injuries, available_equipment, preferred_workout_days;