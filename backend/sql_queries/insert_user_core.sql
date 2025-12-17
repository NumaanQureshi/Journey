INSERT INTO users (email, password_hash, username)
VALUES (%s, %s, %s)
RETURNING id