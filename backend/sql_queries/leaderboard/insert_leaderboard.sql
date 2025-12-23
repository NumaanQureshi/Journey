INSERT INTO leaderboard (user_id)
VALUES (%s)
RETURNING user_id, total_points, workouts_completed, challenges_completed, current_streak_days, longest_streak_days, total_calories_burned, rank, last_updated;