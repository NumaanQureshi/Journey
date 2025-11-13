import requests
import json
import random
dataset = requests.get("https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/dist/exercises.json",timeout=10)
exercises = dataset.json()
training_data = []
#get exercises per difficulty
beginner_exercises = [ex for ex in exercises if ex.get('level') == 'beginner']
intermediate_exercises = [ex for ex in exercises if ex.get('level') == 'intermediate']
expert_exercises = [ex for ex in exercises if ex.get('level') == 'expert']
random_exercises = (
    random.sample(beginner_exercises, min(70, len(beginner_exercises))) +
    random.sample(intermediate_exercises, min(70, len(intermediate_exercises))) +
    random.sample(expert_exercises, min(55, len(expert_exercises))) #there's not as many expert exercises
)
for exercise in random_exercises: #to understand each exercise using the json metadata
    training_data.append({
        "messages": [
            {
                "role": "system",
                "content": "You are a fitness expert with in depth exercise knowledge."
            },
            {
                "role": "user",
                "content": f"Tell me about the exercise: {exercise['name']}"
            },
            {
                "role": "assistant",
                "content": json.dumps({
                    "exercise_id": exercise['id'],
                    "name": exercise['name'],
                    "primary_muscles": exercise.get('primaryMuscles', []),
                    "secondary_muscles": exercise.get('secondaryMuscles', []),
                    "equipment": exercise.get('equipment'),
                    "level": exercise.get('level'),
                    "instructions": exercise.get('instructions', [])[:3],
                    "category": exercise.get('category')
                })
            }
        ]
    })
workout_scenarios = [
    {"goal": "build muscle", "equipment": ["dumbbell", "barbell"], "categories": ["strength"]},
    {"goal": "lose weight", "equipment": ["body only"], "categories": ["strength", "cardio", "plyometrics"]},
    {"goal": "gain strength", "equipment": ["barbell", "body only"], "categories": ["strength", "powerlifting"]},
    {"goal": "tone muscles", "equipment": ["dumbbell", "body only"], "categories": ["strength", "cardio"]},
    {"goal": "general fitness", "equipment": ["body only"], "categories": ["strength", "cardio", "stretching"]},
]