SELECT p.user_id 
FROM programs p
JOIN workout_templates wt ON p.id = wt.program_id
WHERE wt.id = %s;
