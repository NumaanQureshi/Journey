SELECT p.id, p.user_id, p.name, p.description, p.is_active, p.created_at, p.updated_at
FROM programs p
WHERE p.id = %s;
