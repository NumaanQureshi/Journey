DELETE FROM programs
WHERE id = %s
RETURNING id;
