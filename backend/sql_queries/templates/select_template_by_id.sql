SELECT wt.id, wt.program_id, wt.name, wt.day_order, wt.notes, wt.created_at
FROM workout_templates wt
WHERE wt.id = %s;
