import os
import time
import json
from openai import OpenAI


BASE_MODEL = "gpt-4o-mini-2024-07-18"
TRAINING_FILE_PATH = "fitness_finetune.jsonl"  # <-- your 380-example file
N_EPOCHS = 3

SYSTEM_PROMPT = (
    "You are a certified personal trainer AI. "
    "You create safe, effective workout plans based on a user's goals, experience, "
    "equipment, and limitations. You emphasize proper form, injury prevention, "
    "ask clarifying questions when information is missing, and refuse unsafe requests."
)

# ==================== CLIENT ====================

client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))
# ==================== VALIDATION ====================

def validate_training_file(file_path: str) -> bool:
    print(f"Validating training file: {file_path}")

    try:
        with open(file_path, "r") as f:
            lines = f.readlines()

        print(f"Total examples: {len(lines)}")

        for i, line in enumerate(lines[:10]):
            data = json.loads(line)

            assert "messages" in data, f"Line {i+1}: missing 'messages'"
            messages = data["messages"]

            assert isinstance(messages, list), f"Line {i+1}: messages must be a list"
            assert len(messages) >= 2, f"Line {i+1}: need at least 2 messages"

            roles = {m.get("role") for m in messages}
            assert {"system", "user", "assistant"}.issubset(roles), (
                f"Line {i+1}: must include system, user, assistant"
            )

            for m in messages:
                assert isinstance(m.get("content"), str), f"Line {i+1}: content must be string"

        print("✓ Training file format is valid")
        return True

    except Exception as e:
        print(f"✗ Validation failed: {e}")
        return False


def upload_training_file(file_path: str) -> str:
    print(f"\nUploading training file: {file_path}")

    with open(file_path, "rb") as f:
        response = client.files.create(
            file=f,
            purpose="fine-tune"
        )

    print(f"✓ File uploaded. File ID: {response.id}")
    return response.id


def create_fine_tune_job(training_file_id: str) -> str:
    print(f"\nCreating fine-tune job on model: {BASE_MODEL}")

    response = client.fine_tuning.jobs.create(
        training_file=training_file_id,
        model=BASE_MODEL,
        hyperparameters={
            "n_epochs": N_EPOCHS
        }
    )

    print(f"✓ Fine-tune job created. Job ID: {response.id}")
    return response.id


def monitor_job(job_id: str, check_interval: int = 60) -> str | None:
    print(f"\nMonitoring fine-tune job: {job_id}")

    while True:
        job = client.fine_tuning.jobs.retrieve(job_id)
        print(f"Status: {job.status}")

        if job.status == "succeeded":
            print("\n✓ Fine-tuning completed successfully!")
            print(f"Fine-tuned model ID: {job.fine_tuned_model}")
            return job.fine_tuned_model

        if job.status in ("failed", "cancelled"):
            print("\n✗ Fine-tuning failed or was cancelled.")
            if job.error:
                print(f"Error: {job.error}")
            return None

        time.sleep(check_interval)

# ==================== TEST ====================

def test_fine_tuned_model(model_id: str):
    """
    This test checks BEHAVIOR, not exercise recall.
    The model should ask clarifying questions or respond conservatively.
    """
    test_prompt = "Create a workout plan to build muscle."

    print("\n=== Testing Fine-Tuned Model ===")
    print(f"Model: {model_id}")
    print(f"Prompt: {test_prompt}\n")

    response = client.chat.completions.create(
        model=model_id,
        messages=[
            {"role": "system", "content": SYSTEM_PROMPT},
            {"role": "user", "content": test_prompt}
        ],
        temperature=0.6,
        max_tokens=500
    )

    print("Response:\n")
    print(response.choices[0].message.content)


def main():
    print("=== OpenAI Fine-Tuning Runner ===\n")

    if not validate_training_file(TRAINING_FILE_PATH):
        print("Fix the training file before proceeding.")
        return

    training_file_id = upload_training_file(TRAINING_FILE_PATH)
    job_id = create_fine_tune_job(training_file_id)
    fine_tuned_model_id = monitor_job(job_id)

    if fine_tuned_model_id:
        with open("fine_tuned_model_id.txt", "w") as f:
            f.write(fine_tuned_model_id)

        print("\n✓ Model ID saved to fine_tuned_model_id.txt")
        test_fine_tuned_model(fine_tuned_model_id)
    else:
        print("\nFine-tuning did not complete successfully.")

if __name__ == "__main__":
    main()
