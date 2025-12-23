UPDATE users SET updated_at = NOW() WHERE id = %s
RETURNING id, email, username, created_at, updated_at;