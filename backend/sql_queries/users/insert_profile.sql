INSERT INTO profiles (
        user_id,
        name,
        date_of_birth,
        gender,
        height_in,
        weight_lb,
        main_focus,
        goal_weight_lb,
        activity_intensity
    )
VALUES (%s, NULL, %s, %s, %s, %s, NULL, NULL, NULL) ON CONFLICT (user_id) DO UPDATE SET
        date_of_birth = EXCLUDED.date_of_birth,
        gender = EXCLUDED.gender,
        height_in = EXCLUDED.height_in,
        weight_lb = EXCLUDED.weight_lb
RETURNING user_id, name, date_of_birth, gender, height_in, weight_lb, main_focus, goal_weight_lb, activity_intensity, fitness_level, injuries, available_equipment, preferred_workout_days;