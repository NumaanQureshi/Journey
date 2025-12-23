import datetime
import jwt
import os
from dotenv import load_dotenv

load_dotenv()
JWT_SECRET_KEY = os.getenv("JWT_SECRET_KEY")

def convert_to_iso8601(dt):
    """Convert datetime object to ISO 8601 format string."""
    if dt is None:
        return None
    if isinstance(dt, str):
        return dt
    if isinstance(dt, datetime.datetime):
        return dt.isoformat() + 'Z' if dt.tzinfo is None else dt.isoformat()
    return str(dt)

def convert_dict_dates_to_iso8601(data):
    """Recursively convert all datetime objects in a dict/list to ISO 8601 format."""
    if isinstance(data, dict):
        return {key: convert_dict_dates_to_iso8601(value) for key, value in data.items()}
    elif isinstance(data, list):
        return [convert_dict_dates_to_iso8601(item) for item in data]
    elif isinstance(data, datetime.datetime):
        return convert_to_iso8601(data)
    else:
        return data

def calculate_age(year, month, day):
    """Calculates age from birth date components."""
    if year is None or month is None or day is None:
        return None
    try:
        birth_date = datetime.date(year, month, day)
        today = datetime.date.today()
        # Calculate age: Subtract birth year from current year. 
        # Then, subtract 1 if the current date is before the birth date in the year.
        age = today.year - birth_date.year - ((today.month, today.day) < (birth_date.month, birth_date.day))
        return age if age >= 0 else None
    except ValueError:
        # Handles invalid dates like Feb 30th
        return None
    
# Helper function to generate a secure, short-lived reset token
def generate_reset_token(user_id):
    """Generates a short-lived JWT for password reset (e.g., 1 hour)."""
    # Create an exp time that is shorter than the main login token (e.g., 1 hour)
    expiration = datetime.datetime.now(datetime.UTC) + datetime.timedelta(hours=1)
    reset_token = jwt.encode(
        {
            'user_id': user_id,
            'exp': expiration.timestamp(),
            'token_type': 'password_reset' # <--- IMPORTANT: Differentiate from login token
        },
        JWT_SECRET_KEY,
        algorithm='HS256'
    )
    return reset_token