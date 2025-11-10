UPDATE profiles
SET age = COALESCE(%s, age),
    gender = COALESCE(%s, gender),
    height_in = COALESCE(%s, height_in),
    weight_lb = COALESCE(%s, weight_lb)
WHERE user_id = %s