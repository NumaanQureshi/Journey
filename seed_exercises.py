import requests
import json
import os
from supabase import create_client, Client

# =================CONFIGURATION =================
SUPABASE_URL = "https://rcaarjwdvappjimwmadh.supabase.co"
# Use SERVICE_ROLE key to bypass RLS policies for admin uploads
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJjYWFyandkdmFwcGppbXdtYWRoIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1OTQ1OTg5OSwiZXhwIjoyMDc1MDM1ODk5fQ.4jD5miAVgGBCYFbGK15zbdy5RIhgZgRcqBiYHUPGvTE" 
BUCKET_NAME = "exercise-images"

# The source of the data
GITHUB_BASE_URL = "https://raw.githubusercontent.com/yuhonas/free-exercise-db/main"
JSON_URL = f"{GITHUB_BASE_URL}/dist/exercises.json"

# Initialize Supabase
supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

def seed_exercises():
    print(f"Fetching exercises from {JSON_URL}...")
    response = requests.get(JSON_URL)
    exercises_data = response.json()
    
    print(f"Found {len(exercises_data)} exercises. Starting import...")

    success_count = 0
    failed_count = 0
    
    for idx, exercise in enumerate(exercises_data, 1):
        try:
            # Image URL formatting
            stored_image_urls = []
            folder_name = exercise.get('id', exercise['name'].replace(' ', '_'))
            images_to_process = exercise.get('images', [])[:2] 

            for img_filename in images_to_process:
                filename_only = img_filename.split('/')[-1]
                
                # Pull raw github URL
                github_img_url = f"{GITHUB_BASE_URL}/exercises/{folder_name}/{filename_only}"
                
                img_resp = requests.get(github_img_url)
                if img_resp.status_code == 200:
                    clean_name = exercise['name'].lower().replace(' ', '_').replace('/', '-')
                    storage_path = f"{clean_name}/{img_filename}"
                    
                    # Upload image to Supabase Storage Bucket
                    try:
                        supabase.storage.from_(BUCKET_NAME).upload(
                            path=storage_path,
                            file=img_resp.content,
                            file_options={"content-type": "image/jpeg", "upsert": "true"}
                        )
                        
                        public_url = supabase.storage.from_(BUCKET_NAME).get_public_url(storage_path)
                        stored_image_urls.append(public_url)
                        print(f"   -> Uploaded image: {storage_path}")
                    except Exception as e:
                        print(f"   -> Image upload failed for {exercise['name']}: {e}")
                        failed_count += 1
                else:
                    print(f"   -> Could not find image on GitHub: {github_img_url}")

            # Mapping JSON to Supabase Schema
            db_record = {
                "name": exercise['name'],
                "description": " ".join(exercise.get('instructions', [])), # Combine steps into description
                "category": exercise.get('force'),           # 'push', 'pull'
                "category_major": exercise.get('category'),  # 'strength', 'plyometrics'
                "difficulty_level": exercise.get('level'),   # 'beginner'
                "mechanic": exercise.get('mechanic'),        # 'compound'
                "equipment": exercise.get('equipment'),
                "primary_muscles": exercise.get('primaryMuscles', []),
                "secondary_muscles": exercise.get('secondaryMuscles', []),
                "instructions": exercise.get('instructions', []),
                "images": stored_image_urls
            }

            # Insert into DB
            data = supabase.table("exercises").upsert(db_record, on_conflict="name").execute()
            
            success_count += 1
            print(f"[{success_count}] Processed images for: {exercise['name']}")

        except Exception as e:
            print(f"[{idx}] FAILED to process {exercise.get('name', 'Unknown')}: {e}")
            failed_count += 1

    print(f"\nMigration Complete! Successfully processed {success_count} exercises.")
    if failed_count > 0:
        print(f"Failed to process {failed_count} exercises. You can run the script again to retry.")

if __name__ == "__main__":
    seed_exercises()