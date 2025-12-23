INSERT INTO ai_conversations (user_id, message, response)
VALUES (%s, %s, %s)
RETURNING id, user_id, message, response, created_at;