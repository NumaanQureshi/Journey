import datetime

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