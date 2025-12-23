INSERT INTO users (email, password_hash, username)
VALUES (%s, %s, %s)
RETURNING id, email, username, password_hash, created_at, updated_at