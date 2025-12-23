UPDATE workout_templates
SET name = %s, notes = %s, day_order = %s
WHERE id = %s
RETURNING id, program_id, name, day_order, notes, created_at;
