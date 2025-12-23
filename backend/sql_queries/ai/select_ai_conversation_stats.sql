SELECT 
    COUNT(*) as total_conversations,
    MAX(created_at) as last_conversation_at
FROM ai_conversations
WHERE user_id = %s;