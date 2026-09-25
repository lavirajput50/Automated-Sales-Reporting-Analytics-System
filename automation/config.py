from getpass import getpass
import sys

SENDER_EMAIL=str(input("-Enter Sender Email- "))
while True:
    SENDER_PASSWORD=getpass("-Enter 16 Digit Password - ")
    cleaned_pass=SENDER_PASSWORD.replace(" ","")
    if len(cleaned_pass)==16:
        SENDER_PASSWORD=cleaned_pass
        break
    else:
         print(f"Invalid password length ({len(cleaned_pass)} characters). "
              f"App Password must be exactly 16 characters. Please try again.\n")
    

RECEIVER_EMAIL=str(input("-Enter Receiver Email- "))
print("\n ALL credentials collected successfully.")

