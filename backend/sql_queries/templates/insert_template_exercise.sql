INSERT INTO template_exercises (template_id, exercise_id, target_sets, target_reps, target_weight_lb, rest_seconds, order_index)
VALUES (%s, %s, %s, %s, %s, %s, %s)
RETURNING id, template_id, exercise_id, target_sets, target_reps, target_weight_lb, rest_seconds, order_index;
