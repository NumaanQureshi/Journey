INSERT INTO programs (user_id, name, description, is_active)
VALUES (%s, %s, %s, %s)
RETURNING id, user_id, name, description, is_active, created_at, updated_at;
