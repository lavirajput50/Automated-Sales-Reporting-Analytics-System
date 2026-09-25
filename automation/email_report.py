"""
email_report.py
A Streamlit interface to send the latest generated sales report PDF 
via email using Gmail SMTP.
"""

import streamlit as st
import smtplib
import os

from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.base import MIMEBase
from email import encoders


# ---------- Core email sending logic (same as before, unchanged) ----------

def send_email(sender_email, sender_password, receiver_email, subject, body, attachment_path):
    """Builds the email message and sends it through Gmail's SMTP server."""

    msg = MIMEMultipart()
    msg['From'] = sender_email
    msg['To'] = receiver_email
    msg['Subject'] = subject

    msg.attach(MIMEText(body, 'plain'))

    try:
        with open(attachment_path, "rb") as f:
            part = MIMEBase('application', 'octet-stream')
            part.set_payload(f.read())

        encoders.encode_base64(part)

        filename = os.path.basename(attachment_path)
        part.add_header('Content-Disposition', f'attachment; filename={filename}')
        msg.attach(part)

    except FileNotFoundError:
        st.warning(f"Attachment not found at {attachment_path}. Sending without attachment.")

    try:
        server = smtplib.SMTP('smtp.gmail.com', 587)
        server.starttls()
        server.login(sender_email, sender_password)
        server.send_message(msg)
        server.quit()
        return True, f"Email sent successfully to {receiver_email}"

    except Exception as e:
        return False, f"Failed to send email: {e}"


def get_latest_report(folder_path):
    """Finds the most recently created PDF in the given folder."""
    if not os.path.exists(folder_path):
        return None

    pdf_files = [f for f in os.listdir(folder_path) if f.endswith('.pdf')]

    if not pdf_files:
        return None

    pdf_files.sort(key=lambda f: os.path.getmtime(os.path.join(folder_path, f)))
    latest_file = pdf_files[-1]

    return os.path.join(folder_path, latest_file)


# ---------- Initialize session_state ----------
if "page" not in st.session_state:
    st.session_state.page = "home"
if "users" not in st.session_state:
    st.session_state.users = {}   # only ever holds ONE active user: {email: password}
if "current_user" not in st.session_state:
    st.session_state.current_user = None


# ---------- Navigation Functions ----------
def go_signup():
    st.session_state.page = "signup"

def go_login():
    st.session_state.page = "login"

def go_receiver(email):
    st.session_state.page = "receiver"
    st.session_state.current_user = email

def go_home():
    st.session_state.page = "home"


# ---------- Home Page ----------
if st.session_state.page == "home":
    st.title("Automated Sales Report - Email System")
    st.caption("New user → Signup | Existing user → Login")
    col1, col2 = st.columns(2)
    with col1:
        st.button("Signup", on_click=go_signup, use_container_width=True)
    with col2:
        st.button("Login", on_click=go_login, use_container_width=True)


# ---------- Signup Page ----------
elif st.session_state.page == "signup":
    st.header("Signup Page")
    email = st.text_input("Enter Email")
    password = st.text_input("Enter App Password (16-digit)", type="password")

    if st.button("Register"):
        if not email or "@" not in email:
            st.warning("Please enter a valid email address.")
        elif len(password.replace(" ", "")) != 16:
            st.warning("Password must be exactly 16 characters.")
        else:
            # only one user allowed at a time — new signup replaces the old one
            st.session_state.users = {}
            st.session_state.users[email] = password.replace(" ", "")
            st.success("Signup successful!")
            go_receiver(email)
            st.rerun()

    st.button("Back to Home", on_click=go_home)


# ---------- Login Page ----------
elif st.session_state.page == "login":
    st.header("Login Page")
    email = st.text_input("Enter Email")

    if st.button("Login"):
        if email in st.session_state.users:
            st.success("Login successful!")
            go_receiver(email)
            st.rerun()
        else:
            st.error("Email not found. Please Signup first.")
            st.button("Go to Signup", on_click=go_signup)

    st.button("Back to Home", on_click=go_home)


# ---------- Receiver Details Page ----------
elif st.session_state.page == "receiver":
    st.header("Receiver Details")

    base_dir = os.path.dirname(os.path.dirname(__file__))
    reports_folder = os.path.join(base_dir, "reports", "generated")
    latest_report = get_latest_report(reports_folder)

    if latest_report:
        st.info(f"Latest report found: **{os.path.basename(latest_report)}**")
    else:
        st.error("No report found in reports/generated. Please generate a report first.")

    manager_name = st.text_input("Manager Name")
    receiver_email = st.text_input("Receiver Email")
    sender_name = st.text_input("Your Name (for sign-off)")

    if st.button("Send Report"):
        if not all([manager_name, receiver_email, sender_name]):
            st.warning("Please fill all fields.")
        elif "@" not in receiver_email:
            st.warning("Please enter a valid receiver email.")
        elif latest_report is None:
            st.error("No report available to send.")
        else:
            sender_email = st.session_state.current_user
            sender_password = st.session_state.users[sender_email]

            subject = "Weekly Sales Performance Report"
            body = (
                f"Hi {manager_name},\n\n"
                "Please find attached this Sales Performance Report, covering key "
                "business metrics.\n"
                "It includes the overall KPI summary along with the full Power BI dashboard.\n\n"
                "Highlights:\n"
                "- Total Revenue and Profit summary\n"
                "- City and restaurant-wise performance\n"
                "- Customer segment insights\n\n"
                "Please let me know if you'd like a deeper breakdown on any specific metric.\n\n"
                "Best regards,\n"
                f"{sender_name}"
            )

            with st.spinner("Sending email..."):
                success, message = send_email(
                    sender_email=sender_email,
                    sender_password=sender_password,
                    receiver_email=receiver_email,
                    subject=subject,
                    body=body,
                    attachment_path=latest_report
                )

            if success:
                st.success(message)
            else:
                st.error(message)

    st.button("Back to Home", on_click=go_home)