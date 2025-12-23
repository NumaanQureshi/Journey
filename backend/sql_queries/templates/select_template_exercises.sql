SELECT te.id, te.exercise_id, e.name AS exercise_name, te.target_sets, te.target_reps, te.target_weight_lb, te.rest_seconds, te.order_index
FROM template_exercises te
JOIN exercises e ON te.exercise_id = e.id
WHERE te.template_id = %s
ORDER BY te.order_index ASC;
