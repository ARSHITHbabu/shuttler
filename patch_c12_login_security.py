import re

def patch_login_security(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Define the security logic block to inject
    security_logic = """
        check_account_lock(owner)
        if password_valid:
            handle_successful_login(db, owner, "owner", request.client.host if request.client else None, request.headers.get("user-agent"))
"""
    # Actually, unified_login is complex. I'll modify the specific sections.

    # Modify unified_login for Owner
    owner_pattern = r'(owner = db\.query\(OwnerDB\)\.filter\(OwnerDB\.email == login_data\.email\)\.first\(\))\n\s+(if owner:)'
    def owner_repl(m):
        return f'{m.group(1)}\n    if owner:\n        check_account_lock(owner)'
    content = re.sub(owner_pattern, owner_repl, content)

    # Success/Fail for Owner
    content = content.replace(
        'access_token, refresh_token = _make_tokens(owner.id, "owner", owner.email, owner.role or "owner")',
        'handle_successful_login(db, owner, "owner", request.client.host if request.client else None, request.headers.get("user-agent"))\n                access_token, refresh_token = _make_tokens(owner.id, "owner", owner.email, owner.role or "owner")'
    )

    # Modify unified_login for Coach
    coach_pattern = r'(coach = db\.query\(CoachDB\)\.filter\(CoachDB\.email == login_data\.email\)\.first\(\))\n\s+(if coach:)'
    def coach_repl(m):
        return f'{m.group(1)}\n    if coach:\n        check_account_lock(coach)'
    content = re.sub(coach_pattern, coach_repl, content)

    content = content.replace(
        'access_token, refresh_token = _make_tokens(coach.id, "coach", coach.email, "coach")',
        'handle_successful_login(db, coach, "coach", request.client.host if request.client else None, request.headers.get("user-agent"))\n                access_token, refresh_token = _make_tokens(coach.id, "coach", coach.email, "coach")'
    )

    # Modify unified_login for Student
    student_pattern = r'(student = db\.query\(StudentDB\)\.filter\(StudentDB\.email == login_data\.email\)\.first\(\))\n\s+(if student:)'
    def student_repl(m):
        return f'{m.group(1)}\n    if student:\n        check_account_lock(student)'
    content = re.sub(student_pattern, student_repl, content)

    content = content.replace(
        'access_token, refresh_token = _make_tokens(student.id, "student", student.email, "student")',
        'handle_successful_login(db, student, "student", request.client.host if request.client else None, request.headers.get("user-agent"))\n                access_token, refresh_token = _make_tokens(student.id, "student", student.email, "student")'
    )

    # Handle the end of unified_login (all failed)
    # Actually it's more complex since it currently just doesn't return anything or throws 401?
    # I'll add handle_failed_login where the 401 is thrown.

    # Need to find where the 401 is for unified login.
    # Looking at the code in view_file 296, it doesn't show the final fallback.

    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)

if __name__ == '__main__':
    patch_login_security('Backend/main.py')
