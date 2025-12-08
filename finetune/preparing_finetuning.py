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
muscle_groups = {}
for exercise in exercises:
    for muscle in exercise.get('primaryMuscles', []):
        if muscle not in muscle_groups:
            muscle_groups[muscle] = []
        muscle_groups[muscle].append(exercise)

for muscle, exs in list(muscle_groups.items())[:30]:
    sample_exercises = random.sample(exs, min(5, len(exs)))

    training_data.append({
        "messages": [
            {
                "role": "system",
                "content": "You are a fitness expert. Provide exercise recommendations for specific muscle groups."
            },
            {
                "role": "user",
                "content": f"What are good exercises for {muscle}?"
            },
            {
                "role": "assistant",
                "content": json.dumps({
                    "target_muscle": muscle,
                    "exercises": [
                        {
                            "name": ex['name'],
                            "id": ex['id'],
                            "equipment": ex.get('equipment'),
                            "level": ex.get('level')
                        }
                        for ex in sample_exercises
                    ]
                })
            }
        ]
    })
workout_scenarios = [
    {"goal": "build muscle", "equipment": "all", "categories": ["strength"], "target_muscles": "balanced"},
    {"goal": "lose weight", "equipment": "all", "categories": ["strength", "cardio", "plyometrics"],
     "target_muscles": "balanced"},
    {"goal": "gain strength", "equipment": "all", "categories": ["strength", "powerlifting"],
     "target_muscles": "balanced"},
    {"goal": "tone muscles", "equipment": "all", "categories": ["strength", "cardio"], "target_muscles": "balanced"},
    {"goal": "general fitness", "equipment": "all", "categories": ["strength", "cardio", "stretching"],
     "target_muscles": "balanced"},
    {"goal": "improve cardio", "equipment": "all", "categories": ["cardio"], "target_muscles": "any"},
    {"goal": "improve endurance", "equipment": "all", "categories": ["cardio", "strength"],
     "target_muscles": "balanced"},
    {"goal": "athletic performance", "equipment": "all", "categories": ["strength", "plyometrics", "cardio"],
     "target_muscles": "balanced"},

    {"goal": "build muscle", "equipment": ["body only"], "categories": ["strength"], "target_muscles": "balanced"},
    {"goal": "lose weight", "equipment": ["body only"], "categories": ["strength", "cardio", "plyometrics"],
     "target_muscles": "balanced"},
    {"goal": "gain strength", "equipment": ["body only"], "categories": ["strength"], "target_muscles": "balanced"},
    {"goal": "tone muscles", "equipment": ["body only"], "categories": ["strength", "cardio"],
     "target_muscles": "balanced"},
    {"goal": "general fitness", "equipment": ["body only"], "categories": ["strength", "cardio", "stretching"],
     "target_muscles": "balanced"},
    {"goal": "improve cardio", "equipment": ["body only"], "categories": ["cardio", "plyometrics"],
     "target_muscles": "any"},

    {"goal": "lose weight", "equipment": ["machine"], "categories": ["cardio"], "target_muscles": "any"},
    {"goal": "improve cardio", "equipment": ["machine"], "categories": ["cardio"], "target_muscles": "any"},
    {"goal": "improve endurance", "equipment": ["machine"], "categories": ["cardio"], "target_muscles": "any"},
    {"goal": "burn calories", "equipment": ["machine"], "categories": ["cardio"], "target_muscles": "any"},

    {"goal": "build muscle", "equipment": ["dumbbell"], "categories": ["strength"], "target_muscles": "balanced"},
    {"goal": "build muscle", "equipment": ["barbell"], "categories": ["strength"], "target_muscles": "balanced"},
    {"goal": "build muscle", "equipment": ["kettlebells"], "categories": ["strength"], "target_muscles": "balanced"},
    {"goal": "build muscle", "equipment": ["cable"], "categories": ["strength"], "target_muscles": "balanced"},
    {"goal": "build muscle", "equipment": ["machine"], "categories": ["strength"], "target_muscles": "balanced"},
    {"goal": "build muscle", "equipment": ["band"], "categories": ["strength"], "target_muscles": "balanced"},
    {"goal": "tone muscles", "equipment": ["dumbbell"], "categories": ["strength"], "target_muscles": "balanced"},
    {"goal": "gain strength", "equipment": ["barbell"], "categories": ["strength", "powerlifting"],
     "target_muscles": "balanced"},

    {"goal": "build muscle", "equipment": ["dumbbell", "body only"], "categories": ["strength"],
     "target_muscles": "balanced"},
    {"goal": "tone muscles", "equipment": ["dumbbell", "body only"], "categories": ["strength", "cardio"],
     "target_muscles": "balanced"},
    {"goal": "lose weight", "equipment": ["dumbbell", "body only"], "categories": ["strength", "cardio"],
     "target_muscles": "balanced"},
    {"goal": "general fitness", "equipment": ["dumbbell", "body only"], "categories": ["strength"],
     "target_muscles": "balanced"},

    {"goal": "build muscle", "equipment": ["barbell", "body only"], "categories": ["strength"],
     "target_muscles": "balanced"},
    {"goal": "gain strength", "equipment": ["barbell", "body only"], "categories": ["strength", "powerlifting"],
     "target_muscles": "balanced"},
    {"goal": "gain strength", "equipment": ["barbell", "dumbbell"], "categories": ["strength"],
     "target_muscles": "balanced"},
    {"goal": "build muscle", "equipment": ["barbell", "dumbbell"], "categories": ["strength"],
     "target_muscles": "balanced"},

    {"goal": "build muscle", "equipment": ["dumbbell", "barbell", "cable"], "categories": ["strength"],
     "target_muscles": "balanced"},
    {"goal": "build muscle", "equipment": ["dumbbell", "cable", "machine"], "categories": ["strength"],
     "target_muscles": "balanced"},
    {"goal": "tone muscles", "equipment": ["dumbbell", "cable", "machine"], "categories": ["strength"],
     "target_muscles": "balanced"},
    {"goal": "gain strength", "equipment": ["barbell", "dumbbell", "cable", "machine"], "categories": ["strength"],
     "target_muscles": "balanced"},

    {"goal": "lose weight", "equipment": ["machine", "body only"], "categories": ["cardio", "strength"],
     "target_muscles": "balanced"},
    {"goal": "lose weight", "equipment": ["machine", "dumbbell"], "categories": ["cardio", "strength"],
     "target_muscles": "balanced"},
    {"goal": "improve endurance", "equipment": ["machine", "body only"], "categories": ["cardio", "strength"],
     "target_muscles": "balanced"},
    {"goal": "general fitness", "equipment": ["machine", "dumbbell", "body only"], "categories": ["cardio", "strength"],
     "target_muscles": "balanced"},

    {"goal": "upper body workout", "equipment": "all", "categories": ["strength"],
     "target_muscles": ["chest", "back", "shoulders", "biceps", "triceps"]},
    {"goal": "upper body workout", "equipment": ["dumbbell", "barbell"], "categories": ["strength"],
     "target_muscles": ["chest", "back", "shoulders", "biceps", "triceps"]},
    {"goal": "upper body workout", "equipment": ["body only"], "categories": ["strength"],
     "target_muscles": ["chest", "back", "shoulders", "biceps", "triceps"]},

    {"goal": "leg workout", "equipment": "all", "categories": ["strength"],
     "target_muscles": ["quadriceps", "hamstrings", "glutes", "calves"]},
    {"goal": "leg workout", "equipment": ["barbell", "body only"], "categories": ["strength"],
     "target_muscles": ["quadriceps", "hamstrings", "glutes", "calves"]},
    {"goal": "leg workout", "equipment": ["body only"], "categories": ["strength"],
     "target_muscles": ["quadriceps", "hamstrings", "glutes", "calves"]},
    {"goal": "glutes workout", "equipment": "all", "categories": ["strength"],
     "target_muscles": ["glutes", "hamstrings"]},

    {"goal": "chest workout", "equipment": "all", "categories": ["strength"], "target_muscles": ["chest"]},
    {"goal": "chest workout", "equipment": ["barbell", "dumbbell"], "categories": ["strength"],
     "target_muscles": ["chest"]},
    {"goal": "chest workout", "equipment": ["dumbbell"], "categories": ["strength"], "target_muscles": ["chest"]},
    {"goal": "chest workout", "equipment": ["body only"], "categories": ["strength"], "target_muscles": ["chest"]},

    {"goal": "back workout", "equipment": "all", "categories": ["strength"], "target_muscles": ["back", "lats"]},
    {"goal": "back workout", "equipment": ["barbell", "dumbbell", "cable"], "categories": ["strength"],
     "target_muscles": ["back", "lats"]},
    {"goal": "back workout", "equipment": ["body only"], "categories": ["strength"],
     "target_muscles": ["back", "lats"]},

    {"goal": "arm workout", "equipment": "all", "categories": ["strength"],
     "target_muscles": ["biceps", "triceps", "forearms"]},
    {"goal": "arm workout", "equipment": ["dumbbell", "barbell"], "categories": ["strength"],
     "target_muscles": ["biceps", "triceps", "forearms"]},
    {"goal": "arm workout", "equipment": ["dumbbell"], "categories": ["strength"],
     "target_muscles": ["biceps", "triceps"]},
    {"goal": "biceps workout", "equipment": "all", "categories": ["strength"], "target_muscles": ["biceps"]},
    {"goal": "triceps workout", "equipment": "all", "categories": ["strength"], "target_muscles": ["triceps"]},

    {"goal": "shoulder workout", "equipment": "all", "categories": ["strength"], "target_muscles": ["shoulders"]},
    {"goal": "shoulder workout", "equipment": ["dumbbell", "barbell"], "categories": ["strength"],
     "target_muscles": ["shoulders"]},
    {"goal": "shoulder workout", "equipment": ["dumbbell"], "categories": ["strength"],
     "target_muscles": ["shoulders"]},

    {"goal": "abs workout", "equipment": "all", "categories": ["strength"], "target_muscles": ["abdominals"]},
    {"goal": "abs workout", "equipment": ["body only"], "categories": ["strength"], "target_muscles": ["abdominals"]},
    {"goal": "core workout", "equipment": "all", "categories": ["strength"],
     "target_muscles": ["abdominals", "lower back"]},

    {"goal": "push day", "equipment": "all", "categories": ["strength"],
     "target_muscles": ["chest", "shoulders", "triceps"]},
    {"goal": "push day", "equipment": ["barbell", "dumbbell"], "categories": ["strength"],
     "target_muscles": ["chest", "shoulders", "triceps"]},
    {"goal": "pull day", "equipment": "all", "categories": ["strength"], "target_muscles": ["back", "biceps"]},
    {"goal": "pull day", "equipment": ["barbell", "dumbbell", "body only"], "categories": ["strength"],
     "target_muscles": ["back", "biceps"]},

    {"goal": "chest and triceps", "equipment": "all", "categories": ["strength"],
     "target_muscles": ["chest", "triceps"]},
    {"goal": "back and biceps", "equipment": "all", "categories": ["strength"], "target_muscles": ["back", "biceps"]},
    {"goal": "shoulders and abs", "equipment": "all", "categories": ["strength"],
     "target_muscles": ["shoulders", "abdominals"]},

    {"goal": "athletic performance", "equipment": ["kettlebells", "body only"],
     "categories": ["strength", "plyometrics"], "target_muscles": "balanced"},
    {"goal": "general fitness", "equipment": ["kettlebells", "body only"], "categories": ["strength", "cardio"],
     "target_muscles": "balanced"},
    {"goal": "functional fitness", "equipment": ["kettlebells", "medicine ball", "body only"],
     "categories": ["strength"], "target_muscles": "balanced"},

    {"goal": "flexibility", "equipment": ["body only", "foam roll"], "categories": ["stretching"],
     "target_muscles": "any"},
    {"goal": "mobility", "equipment": ["body only", "foam roll", "band"], "categories": ["stretching"],
     "target_muscles": "any"},
    {"goal": "powerlifting", "equipment": ["barbell", "body only"], "categories": ["powerlifting", "strength"],
     "target_muscles": "balanced"},
    {"goal": "bodybuilding", "equipment": ["barbell", "dumbbell", "cable", "machine"], "categories": ["strength"],
     "target_muscles": "balanced"},

    {"goal": "start fitness journey", "equipment": ["body only"], "categories": ["strength", "cardio"],
     "target_muscles": "balanced"},
    {"goal": "start fitness journey", "equipment": ["machine"], "categories": ["strength", "cardio"],
     "target_muscles": "balanced"},
    {"goal": "start fitness journey", "equipment": ["dumbbell", "body only"], "categories": ["strength"],
     "target_muscles": "balanced"},

    {"goal": "lose weight", "equipment": ["body only", "medicine ball"], "categories": ["cardio", "plyometrics"],
     "target_muscles": "any"},
    {"goal": "burn fat", "equipment": ["machine", "body only"], "categories": ["cardio", "plyometrics"],
     "target_muscles": "any"},
    {"goal": "burn calories", "equipment": ["body only"], "categories": ["cardio", "plyometrics", "strength"],
     "target_muscles": "any"},

    {"goal": "recovery", "equipment": ["body only", "foam roll"], "categories": ["stretching"],
     "target_muscles": "any"},
    {"goal": "active rest", "equipment": ["machine"], "categories": ["cardio"], "target_muscles": "any"},
]
for scenario in workout_scenarios:
    if scenario['equipment'] == "all":
        relevant_exercises = [
            ex for ex in exercises
            if ex.get('category') in scenario['categories']
        ]
    else:
        relevant_exercises = [
            ex for ex in exercises
            if ex.get('category') in scenario['categories'] and
               ex.get('equipment') in scenario['equipment']
        ]

        # Filter by target muscles if specified
    if scenario['target_muscles'] != "balanced" and scenario['target_muscles'] != "any":
        muscle_filtered = []
        for ex in relevant_exercises:
            primary = ex.get('primaryMuscles', [])
            if any(muscle in primary for muscle in scenario['target_muscles']):
                muscle_filtered.append(ex)
        relevant_exercises = muscle_filtered

        # Sample exercises for the workout
    if len(relevant_exercises) > 0:
        num_exercises = min(8, len(relevant_exercises))
        workout_exercises = random.sample(relevant_exercises, num_exercises)

        training_data.append({
            "messages": [
                {
                    "role": "system",
                    "content": "You are a fitness expert. Create personalized workout plans based on user goals and available equipment."
                },
                {
                    "role": "user",
                    "content": f"Create a workout plan for: {scenario['goal']}. Available equipment: {scenario['equipment']}"
                },
                {
                    "role": "assistant",
                    "content": json.dumps({
                        "goal": scenario['goal'],
                        "equipment": scenario['equipment'],
                        "workout": [
                            {
                                "name": ex['name'],
                                "id": ex['id'],
                                "primary_muscles": ex.get('primaryMuscles', []),
                                "equipment": ex.get('equipment'),
                                "level": ex.get('level'),
                                "category": ex.get('category')
                            }
                            for ex in workout_exercises
                        ]
                    })
                }
            ]
        })

    # Save the training data to a JSONL file
    with open('fitness_training_data.jsonl', 'w') as f:
        for item in training_data:
            f.write(json.dumps(item) + '\n')
