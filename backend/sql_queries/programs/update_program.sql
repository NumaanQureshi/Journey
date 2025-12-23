UPDATE programs
SET name = %s, description = %s, is_active = %s, updated_at = NOW()
WHERE id = %s
RETURNING id, user_id, name, description, is_active, created_at, updated_at;
