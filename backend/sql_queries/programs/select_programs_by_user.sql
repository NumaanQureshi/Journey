SELECT id, user_id, name, description, is_active, created_at, updated_at
FROM programs
WHERE user_id = %s
ORDER BY created_at DESC;
