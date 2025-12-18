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
VALUES (%s, NULL, %s, %s, %s, %s, NULL, NULL, NULL) ON CONFLICT (user_id) DO NOTHING;