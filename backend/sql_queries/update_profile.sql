UPDATE profiles
SET name = COALESCE(%s, name),
    age = COALESCE(%s, age),
    gender = COALESCE(%s, gender),
    height_in = COALESCE(%s, height_in),
    weight_lb = COALESCE(%s, weight_lb),
    goal_weight_lb = COALESCE(%s, goal_weight_lb),
    main_focus = COALESCE(%s, main_focus),
    activity_intensity = COALESCE(%s, activity_intensity)
WHERE user_id = %s