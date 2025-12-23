DELETE FROM template_exercises
WHERE id = %s
RETURNING id;
