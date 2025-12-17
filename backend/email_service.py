import smtplib
import ssl
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import os
from dotenv import load_dotenv

load_dotenv()

def send_email(receiver_email, subject, body):
    # Retrieve credentials from environment variables
    sender_email = os.getenv("GMAIL_USER")
    password = os.getenv("GMAIL_APP_PASS")
    smtp_server = os.getenv("SMTP_HOST")
    smtp_port = int(os.getenv("SMTP_PORT")) # 587 for TLS

    if not all([sender_email, password, smtp_server, smtp_port]):
        print("ERROR: SMTP environment variables are not set.")
        return False

    # Create the email content
    message = MIMEMultipart()
    message["From"] = sender_email
    message["To"] = receiver_email
    message["Subject"] = subject
    
    # Attach the email body (can be 'plain' or 'html')
    message.attach(MIMEText(body, "plain"))

    # Connect to the SMTP server and send the email
    context = ssl.create_default_context()
    
    try:
        # Use smtplib.SMTP for port 587 (TLS encryption starts after connection)
        with smtplib.SMTP(smtp_server, smtp_port) as server:
            # Start TLS encryption
            server.starttls(context=context) 
            # Login using the Gmail email and the App Password
            server.login(sender_email, password)
            # Send the mail
            server.sendmail(sender_email, receiver_email, message.as_string())
            print(f"Email sent successfully to {receiver_email}")
            return True
            
    except Exception as e:
        print(f"Failed to send email: {e}")
        return False

# --- Example of how you would call this function ---
# if __name__ == "__main__":
#     # Replace with the user's email address
#     test_receiver = "user_to_reset_password@example.com" 
#     test_subject = "Password Reset Request"
#     test_body = "Click the link to reset your password: [RESET LINK HERE]"
    
#     send_email(test_receiver, test_subject, test_body)