UPDATE users
SET password_hash = %s, updated_at = NOW()
WHERE id = %s
RETURNING id, email, username, created_at, updated_at;
