SELECT 
    id,
    name,
    description,
    category,
    difficulty_level,
    mechanic,
    equipment,
    primary_muscles,
    secondary_muscles,
    instructions,
    category_major,
    images
FROM exercises
WHERE id = %s;
