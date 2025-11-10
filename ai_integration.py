import openai
import os
import json
from typing import List, Dict, Optional
from dotenv import load_dotenv

load_dotenv()

openai.api_key = os.getenv('OPENAI_API_KEY')