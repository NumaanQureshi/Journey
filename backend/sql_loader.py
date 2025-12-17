# Loads SQL files from '/sql_queries

import os

SQL_DIR = 'sql_queries'
def load_sql_query(filename):
    """Loads a SQL query from a file in the SQL_DIR."""
    filepath = os.path.join(os.path.dirname(__file__), SQL_DIR, filename)
    try:
        with open(filepath, 'r') as f:
            return f.read().strip()
    except FileNotFoundError: # if file not found
        print(f"Error: SQL file not found at {filepath}")
        return None
