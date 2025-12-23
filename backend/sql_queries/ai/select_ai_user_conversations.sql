SELECT id, message, response, created_at
FROM ai_conversations
WHERE user_id = %s
ORDER BY created_at ASC;