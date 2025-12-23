SELECT id, name, day_order, notes, created_at
FROM workout_templates
WHERE program_id = %s
ORDER BY day_order ASC;
