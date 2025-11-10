INSERT INTO users (email, password_hash)
VALUES (%s, %s)
RETURNING id