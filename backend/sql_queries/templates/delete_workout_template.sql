DELETE FROM workout_templates
WHERE id = %s
RETURNING id;
