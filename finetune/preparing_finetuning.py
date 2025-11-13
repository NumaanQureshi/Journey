import requests
import json
import random
dataset = requests.get("https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/dist/exercises.json",timeout=10)
exercises = dataset.json()
training_data = []
# for exercise in exercises[:200] this uses the first 200 exercises but might edit so it includes higher difficulty exercises