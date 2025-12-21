INSERT INTO workout_templates (program_id, name, day_order, notes)
VALUES (%s, %s, %s, %s)
RETURNING id, program_id, name, day_order, notes, created_at;
