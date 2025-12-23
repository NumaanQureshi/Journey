import json
import random
import requests

SYSTEM_PROMPT = (
    "You are a certified personal trainer AI. "
    "You create safe, effective workout plans based on a user's goals, experience, "
    "equipment, and limitations. You emphasize proper form, injury prevention, "
    "ask clarifying questions when information is missing, and refuse unsafe requests."
)

OUT_PATH = "fitness_finetune.jsonl"
random.seed(42)


EXERCISE_DB_URL = "https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/dist/exercises.json"
exercises = requests.get(EXERCISE_DB_URL, timeout=10).json()

training_data = []


def add_example(user: str, assistant: str):
    training_data.append({
        "messages": [
            {"role": "system", "content": SYSTEM_PROMPT},
            {"role": "user", "content": user},
            {"role": "assistant", "content": assistant}
        ]
    })


goals = ["build muscle", "lose fat", "get stronger", "general fitness"]
equipments = ["full gym", "dumbbells", "bodyweight only"]

for goal in goals:
    for eq in equipments:
        add_example(
            f"I want to {goal}.",
            f"Great goal. Before I create a plan, how many days per week can you train, "
            f"what equipment you have access to (you mentioned {eq}), and do you have any injuries or limitations?"
        )


injury_map = {
    "knee": ["squat", "lunge"],
    "back": ["deadlift", "good morning"],
    "shoulder": ["bench", "overhead"]
}

for injury, risky_keywords in injury_map.items():
    for ex in exercises:
        name = ex.get("name", "").lower()
        if any(k in name for k in risky_keywords):
            add_example(
                f"My {injury} hurts when I do {ex['name']}. Should I push through?",
                f"No. Pain in the {injury} during {ex['name']} is a warning sign. "
                f"Stop the movement, reduce load, and reassess form. Use pain-free alternatives "
                f"and avoid loading through pain. If discomfort persists, consult a qualified professional."
            )

# ================== 3) FORM COACHING FROM REAL EXERCISES ==================

sampled = random.sample(exercises, min(120, len(exercises)))

for ex in sampled:
    add_example(
        f"Give me 3 key form cues for {ex['name']}.",
        f"Key form cues for {ex['name']}: "
        f"1) Maintain a controlled tempo throughout the movement. "
        f"2) Brace your core and keep a stable torso. "
        f"3) Use a full but pain-free range of motion. "
        f"Common mistake: using momentum or sacrificing form to lift heavier weight."
    )

# ================== 4) EXERCISE SELECTION REASONING ==================

for ex in random.sample(exercises, 80):
    primary = ex.get("primaryMuscles", [])
    muscle = primary[0] if primary else "the target muscle"

    add_example(
        f"Why would you include {ex['name']} in a workout?",
        f"{ex['name']} is effective because it targets {muscle} while allowing controlled loading. "
        f"It fits well in programs aiming to build strength and muscle when performed with proper form "
        f"and appropriate volume."
    )


for goal in goals:
    add_example(
        f"Create a workout plan for my goal: {goal}.",
        json.dumps({
            "workout_analysis": "The workout structure matches the user's goal while prioritizing safety and recovery.",
            "exercises": [
                {
                    "exercise_id": "USE_ONLY_PROVIDED_EXERCISE_ID",
                    "name": "Exercise selected from available options",
                    "sets": 3,
                    "reps": "8-12",
                    "weight_recommendation": "Conservative load that allows perfect form",
                    "rest_seconds": 60,
                    "form_cues": ["Brace core", "Control the movement"],
                    "reasoning": "Supports the user's goal while minimizing injury risk"
                }
            ],
            "progressive_overload_notes": "Increase reps first, then weight gradually.",
            "recovery_recommendations": "Sleep well, hydrate, and allow rest days."
        }, indent=2)
    )


with open(OUT_PATH, "w") as f:
    for item in training_data:
        f.write(json.dumps(item) + "\n")

print(f"✓ Generated {len(training_data)} training examples → {OUT_PATH}")

