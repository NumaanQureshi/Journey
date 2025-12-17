import os
import time
import json
from openai import OpenAI


# Initialize OpenAI client
client = OpenAI(api_key=os.environ.get("OPENAI_API_KEY"))


def upload_training_file(file_path):
    """Upload the training data file to OpenAI"""
    print(f"Uploading training file: {file_path}")

    with open(file_path, 'rb') as f:
        response = client.files.create(
            file=f,
            purpose='fine-tune'
        )

    print(f"File uploaded successfully. File ID: {response.id}")
    return response.id


def create_fine_tune_job(training_file_id, model="gpt-4o-mini-2024-07-18"):
    """Create a fine-tuning job"""
    print(f"Creating fine-tune job with model: {model}")

    response = client.fine_tuning.jobs.create(
        training_file=training_file_id,
        model=model,
        hyperparameters={
            "n_epochs": 3
        }
    )

    print(f"Fine-tune job created successfully. Job ID: {response.id}")
    return response.id


def check_job_status(job_id):
    """Check the status of a fine-tuning job"""
    response = client.fine_tuning.jobs.retrieve(job_id)
    return response


def monitor_fine_tune_job(job_id, check_interval=60):
    """Monitor the fine-tuning job until completion"""
    print(f"Monitoring fine-tune job: {job_id}")
    print("This may take a while...")

    while True:
        job_status = check_job_status(job_id)
        status = job_status.status

        print(f"Status: {status}")

        if status == "succeeded":
            print(f"\n✓ Fine-tuning completed successfully!")
            print(f"Fine-tuned model ID: {job_status.fine_tuned_model}")
            return job_status.fine_tuned_model

        elif status == "failed":
            print(f"\n✗ Fine-tuning failed.")
            if hasattr(job_status, 'error'):
                print(f"Error: {job_status.error}")
            return None

        elif status == "cancelled":
            print(f"\n✗ Fine-tuning was cancelled.")
            return None

        else:
            print(f"Waiting {check_interval} seconds before next check...")
            time.sleep(check_interval)


def list_fine_tune_jobs(limit=10):
    """List recent fine-tuning jobs"""
    print(f"Listing last {limit} fine-tuning jobs:")

    response = client.fine_tuning.jobs.list(limit=limit)

    for job in response.data:
        print(f"\nJob ID: {job.id}")
        print(f"Status: {job.status}")
        print(f"Model: {job.model}")
        if job.fine_tuned_model:
            print(f"Fine-tuned Model: {job.fine_tuned_model}")
        print(f"Created at: {job.created_at}")


def test_fine_tuned_model(model_id, test_prompt):
    """Test the fine-tuned model with a sample prompt"""
    print(f"\nTesting fine-tuned model: {model_id}")
    print(f"Prompt: {test_prompt}")

    response = client.chat.completions.create(
        model=model_id,
        messages=[
            {
                "role": "system",
                "content": "You are a fitness expert. Create personalized workout plans based on user goals and available equipment."
            },
            {
                "role": "user",
                "content": test_prompt
            }
        ],
        temperature=0.7,
        max_tokens=500
    )

    print("\nResponse:")
    print(response.choices[0].message.content)
    return response.choices[0].message.content


def validate_training_file(file_path):
    """Validate the training file format before uploading"""
    print(f"Validating training file: {file_path}")

    try:
        with open(file_path, 'r') as f:
            lines = f.readlines()

        print(f"Total examples: {len(lines)}")

        for i, line in enumerate(lines[:3]):
            data = json.loads(line)
            assert "messages" in data, f"Line {i + 1}: Missing 'messages' key"
            messages = data["messages"]
            assert len(messages) >= 2, f"Line {i + 1}: Need at least 2 messages"

            for msg in messages:
                assert "role" in msg, f"Line {i + 1}: Message missing 'role'"
                assert "content" in msg, f"Line {i + 1}: Message missing 'content'"

        print("✓ Training file format is valid")
        return True

    except Exception as e:
        print(f"✗ Validation failed: {e}")
        return False


def main():
    print("=== OpenAI Fine-Tuning Script ===\n")

    training_file_path = "fitness_training_data.jsonl"
    model_to_finetune = "gpt-4o-mini-2024-07-18"

    if not validate_training_file(training_file_path):
        print("Please fix the training file before proceeding.")
        return

    training_file_id = upload_training_file(training_file_path)
    job_id = create_fine_tune_job(training_file_id, model=model_to_finetune)
    fine_tuned_model_id = monitor_fine_tune_job(job_id, check_interval=60)

    if fine_tuned_model_id:
        test_prompt = "Create a workout plan for: build muscle. Available equipment: ['dumbbell', 'body only']"
        test_fine_tuned_model(fine_tuned_model_id, test_prompt)

        with open("fine_tuned_model_id.txt", "w") as f:
            f.write(fine_tuned_model_id)
        print(f"\n✓ Model ID saved to fine_tuned_model_id.txt")
    else:
        print("\nFine-tuning did not complete successfully.")


if __name__ == "__main__":
        main()
