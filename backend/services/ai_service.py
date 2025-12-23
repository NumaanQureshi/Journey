import os
import json
from openai import OpenAI
from typing import List, Dict, Any, Optional
import requests
from datetime import datetime
import psycopg2
from utils.sql_loader import load_sql_query
SYSTEM_PROMPT = "You are a certified personal trainer AI assistant. You help users create safe, effective workout plans, explain exercises, provide form cues, and answer general fitness or app-related questions. You prioritize safety, avoid unsafe advice, and ask clarifying questions when information is missing. Avoid misinformation and help the user the best you can. When evaluating exercises or weight loads, classify them using one safety label: Safe, Optimal, Caution, or Dangerous. Always explain the reasoning, consider the user’s experience level and context, and suggest safer alternatives when appropriate. Do not encourage unsafe behavior and flag whether to Cautious or something is Dangerous with in detail explanation and provide better alternatives."
APP_CONTEXT = """
APP CONTEXT (Journey):
- Users have a primary fitness goal (build muscle, lose fat, general fitness)
- The app allows user to track workouts
- The app allows users to create AI-powered personalized workouts
- The AI focuses on safety, information, and progress
"""


class FitnessAIAgent:
    def __init__(self):
        self.client = OpenAI(api_key=os.environ.get("OPENAI_API_KEY"))
        self.model_id = os.environ.get("FINETUNED_MODEL_ID", "gpt-4o-mini-2024-07-18")

        # Load exercises database
        self.exercises = self._load_exercises()

    def _load_exercises(self):
        res = requests.get(
            "https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/dist/exercises.json",
            timeout=10
        )
        res.raise_for_status()
        return res.json()

    def _build_user_context(self, user_data: Dict[str, Any]) -> str:
        context_parts = []

        if user_data.get('fitness_level'):
            context_parts.append(f"Fitness Level: {user_data['fitness_level']}")
        if user_data.get('age'):
            context_parts.append(f"Age: {user_data['age']}")
        if user_data.get('weight'):
            context_parts.append(f"Weight: {user_data['weight']} lbs")

        if user_data.get('workout_history'):
            history = user_data['workout_history']
            context_parts.append(f"\nRecent Workout History ({len(history)} workouts):")
            for workout in history[-5:]:
                context_parts.append(
                    f"- {workout.get('start_time')}: {workout.get('exercises_count', 0)} exercises, "
                    f"{workout.get('duration_min', 0)}min"
                )

        if user_data.get('strength_progress'):
            context_parts.append("\nStrength Progress:")
            for exercise, data in user_data['strength_progress'].items():
                context_parts.append(
                    f"- {exercise}: {data.get('current_weight')}lbs x {data.get('current_reps')} reps "
                    f"(+{data.get('progress_percent')}%)"
                )

        if user_data.get('goals'):
            context_parts.append(f"\nGoals: {', '.join(user_data['goals'])}")
        if user_data.get('injuries'):
            context_parts.append(f"Injuries/Limitations: {user_data['injuries']}")
        if user_data.get('available_equipment'):
            context_parts.append(f"Available Equipment: {', '.join(user_data['available_equipment'])}")

        return "\n".join(context_parts)

    def generate_personalized_workout(
            self,
            user_data: Dict[str, Any],
            workout_request: Dict[str, Any]
    ) -> Dict[str, Any]:
        """Generate a truly personalized workout using AI reasoning"""

        user_context = self._build_user_context(user_data)

        prompt = f"""You are an expert personal trainer creating a workout plan.

USER PROFILE & HISTORY:
{user_context}

TODAY'S WORKOUT REQUEST:
- Primary Goal: {workout_request.get('goal', 'general fitness')}
- Focus Areas: {', '.join(workout_request.get('focus_areas', ['full body']))}
- Available Time: {workout_request.get('duration_minutes', 45)} minutes
- Energy Level: {workout_request.get('energy_level', 'moderate')}

Return a JSON workout plan with this structure:
{{
  "workout_analysis": "Brief analysis of why this workout suits them today",
  "exercises": [
    {{
      "exercise_id": "exercise_id_from_database",
      "name": "Exercise Name",
      "sets": 3,
      "reps": "8-12",
      "weight_recommendation": "specific weight in lbs based on their history",
      "rest_seconds": 60,
      "form_cues": ["cue 1", "cue 2"],
      "reasoning": "why this exercise for this user"
    }}
  ],
  "progressive_overload_notes": "How this progresses from last workout",
  "recovery_recommendations": "Recovery advice"
}}"""

        try:
            response = self.client.chat.completions.create(
                model=self.model_id,
                messages=[
                    {
                        "role": "system",
                        "content": SYSTEM_PROMPT
                    },
                    {
                        "role": "user",
                        "content": prompt
                    }
                ],
                temperature=0.7,
                max_tokens=2500
            )

            content = response.choices[0].message.content.strip()

            # Parse response
            if content.startswith("```json"):
                content = content[7:]
            elif content.startswith("```"):
                content = content[3:]
            if content.endswith("```"):
                content = content[:-3]
            content = content.strip()

            workout_plan = json.loads(content)

            if 'exercises' in workout_plan:
                enriched = []
                for exercise in workout_plan['exercises']:
                    exercise_id = exercise.get('exercise_id')
                    full_ex = next(
                        (ex for ex in self.exercises if ex['id'] == exercise_id),
                        None
                    )

                    if full_ex:
                        exercise.update({
                            'instructions': full_ex.get('instructions', []),
                            'images': full_ex.get('images', []),
                            'primary_muscles': full_ex.get('primaryMuscles', []),
                            'category': full_ex.get('category', '')
                        })

                    enriched.append(exercise)

                workout_plan['exercises'] = enriched

            return {
                "success": True,
                "workout": workout_plan,
                "generated_at": datetime.now().isoformat(),
                "model_used": self.model_id
            }

        except Exception as e:
            print(f"Error generating personalized workout: {e}")
            import traceback
            traceback.print_exc()
            return {
                "success": False,
                "error": str(e)
            }

    def analyze_workout_completion(
            self,
            user_data: Dict[str, Any],
            completed_workout: Dict[str, Any]
    ) -> Dict[str, Any]:

        prompt = f"""Analyze this completed workout:

USER: {user_data.get('name', 'User')}
FITNESS LEVEL: {user_data.get('fitness_level', 'intermediate')}

COMPLETED WORKOUT:
{json.dumps(completed_workout, indent=2)}

Provide analysis as JSON:
{{
  "performance_rating": "excellent/good/moderate/needs_adjustment",
  "strengths": ["what went well"],
  "areas_for_improvement": ["what to work on"],
  "next_session_recommendations": {{
    "exercises_to_increase": ["exercise names"],
    "focus_areas": ["areas to emphasize"]
  }},
  "motivation_message": "personalized encouraging message"
}}"""

        try:
            response = self.client.chat.completions.create(
                model=self.model_id,
                messages=[
                    {"role": "system", "content": SYSTEM_PROMPT},
                    {"role": "user", "content": prompt}
                ],
                temperature=0.6,
                max_tokens=1000
            )

            content = response.choices[0].message.content.strip()
            if content.startswith("```json"):
                content = content[7:]
            if content.endswith("```"):
                content = content[:-3]

            analysis = json.loads(content.strip())

            return {
                "success": True,
                "analysis": analysis
            }

        except Exception as e:
            return {"success": False, "error": str(e)}

    def is_safety_question(self, message: str) -> bool:
        keywords = [
            "lbs", "kg", "heavy", "max", "tired",
            "bench", "squat", "deadlift",
            "safe", "dangerous", "too much", "pb", "personal best"
        ]
        msg = message.lower()
        return any(k in msg for k in keywords)

    def chat_with_trainer(
            self,
            user_data: Dict[str, Any],
            message: str,
            conversation_history: Optional[List[Dict[str, str]]] = None
    ) -> Dict[str, Any]:

        user_context = self._build_user_context(user_data)

        messages = [
            {"role": "system", "content": SYSTEM_PROMPT},
            {"role": "system", "content": APP_CONTEXT},
            {"role": "system", "content": f"USER CONTEXT:\n{user_context}"}
        ]

        if conversation_history:
            messages.extend(conversation_history)
        if self.is_safety_question(message):
            message += """

        Format a response regarding the concern:
        {
          "label": "Safe | Optimal | Caution | Dangerous",
          "reasoning": "Why this label applies based on the user's experience",
          "recommendation": "What the user should do instead or how to proceed safely",
          "safer_alternatives": ["alternative 1", "alternative 2"],
        }
        """

        messages.append({"role": "user", "content": message})

        try:
            response = self.client.chat.completions.create(
                model=self.model_id,
                messages=messages,
                temperature=0.7,
                max_tokens=800
            )

            return {
                "success": True,
                "response": response.choices[0].message.content
            }

        except Exception as e:
            return {"success": False, "error": str(e)}

    def suggest_deload_week(self, user_data: Dict[str, Any]) -> Dict[str, Any]:

        prompt = f"""Analyze if this user needs a deload week:

{self._build_user_context(user_data)}

Return JSON:
{{
  "needs_deload": true/false,
  "confidence": "high/medium/low",
  "reasoning": "explanation"
}}"""

        try:
            response = self.client.chat.completions.create(
                model=self.model_id,
                messages=[
                    {"role": "system", "content": "You are an expert in recovery management."},
                    {"role": "user", "content": prompt}
                ],
                temperature=0.6,
                max_tokens=600
            )

            content = response.choices[0].message.content.strip()
            if content.startswith("```json"):
                content = content[7:]
            if content.endswith("```"):
                content = content[:-3]

            analysis = json.loads(content.strip())

            return {"success": True, "deload_analysis": analysis}

        except Exception as e:
            return {"success": False, "error": str(e)}


# ==================== DATABASE HELPER FUNCTIONS ====================

def get_user_profile(user_id: int, cur) -> Dict[str, Any]:
    """Get complete user profile"""
    query = load_sql_query('select_full_user_profile.sql')
    cur.execute(query, (user_id,))

    profile = cur.fetchone()
    return dict(profile) if profile else {}


def get_user_workout_history(user_id: int, cur, limit: int = 10) -> List[Dict[str, Any]]:
    query = load_sql_query('select_ai_user_workout_history.sql')
    cur.execute(query, (user_id, limit))

    return [dict(w) for w in cur.fetchall()]


def get_user_strength_progress(user_id: int, cur) -> Dict[str, Dict[str, Any]]:
    query = load_sql_query('select_user_strength_progress_ai.sql')
    cur.execute(query, (user_id,))

    result = {}
    for row in cur.fetchall():
        result[row['name']] = {
            'current_weight': float(row['current_weight']) if row['current_weight'] else 0,
            'current_reps': int(row['current_reps']) if row['current_reps'] else 0,
            'progress_percent': 0
        }

    return result


def save_ai_workout_plan(user_id: int, goal: str, workout_data: Dict, cur) -> int:
    query = load_sql_query('insert_ai_workout_plan.sql')
    cur.execute(query, (user_id, goal, psycopg2.extras.Json(workout_data)))

    return cur.fetchone()['id']


def get_recent_soreness_data(user_id: int, cur) -> List[str]:
    query = load_sql_query('select_recent_soreness.sql')
    cur.execute(query, (user_id,))

    return [c['category'] for c in cur.fetchall() if c.get('category')]


def save_ai_conversation(user_id: int, message: str, response: str, cur, save_to_history: bool = True):
    """Save AI conversation to history.
    
    Args:
        user_id: The user's ID
        message: The user's message
        response: The AI's response
        cur: Database cursor
        save_to_history: If False, conversation won't be saved (e.g., for system prompts like motivational messages)
    """
    if save_to_history:
        query = load_sql_query('insert_ai_conversation.sql')
        cur.execute(query, (user_id, message, response))


def update_workout_plan_feedback(plan_id: int, rating: int, notes: str, cur):
    query = load_sql_query('update_ai_workout_plan_feedback.sql')
    cur.execute(query, (rating, notes, plan_id))



fitness_ai_agent = FitnessAIAgent()