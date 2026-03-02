import re

def patch_login_failures(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Apply fail handling in unified_login for Owner
    owner_fail_block = '''            if password_valid:
                if owner.status == "inactive":
                    return {"success": False, "message": "Your account has been deactivated."}

                handle_successful_login(db, owner, "owner", request.client.host if request.client else None, request.headers.get("user-agent"))'''
    
    # We look for the password_valid check
    owner_pattern = r'if owner:.*?if password_valid:(.*?)return \{'
    # This is too broad. I'll use exact replacement.
    
    target_owner_fail = '''            if password_valid:
                if owner.status == "inactive":
                    return {"success": False, "message": "Your account has been deactivated."}

                handle_successful_login(db, owner, "owner", request.client.host if request.client else None, request.headers.get("user-agent"))'''
    
    # Actually, I'll just look for the 'else' after the password check if it exists.
    # Looking at step 296, there is no 'else' for verification.
    
    new_owner_logic = '''            if password_valid:
                if owner.status == "inactive":
                    return {"success": False, "message": "Your account has been deactivated."}
                handle_successful_login(db, owner, "owner", request.client.host if request.client else None, request.headers.get("user-agent"))
            else:
                handle_failed_login(db, owner, "owner", request.client.host if request.client else None, request.headers.get("user-agent"))'''

    content = content.replace(target_owner_fail, new_owner_logic)

    # Coach logic
    target_coach_fail = '''            if password_valid:
                if coach.status == "inactive":
                    return {"success": False, "message": "Your account has been deactivated."}

                handle_successful_login(db, coach, "coach", request.client.host if request.client else None, request.headers.get("user-agent"))'''
    
    new_coach_logic = '''            if password_valid:
                if coach.status == "inactive":
                    return {"success": False, "message": "Your account has been deactivated."}
                handle_successful_login(db, coach, "coach", request.client.host if request.client else None, request.headers.get("user-agent"))
            else:
                handle_failed_login(db, coach, "coach", request.client.host if request.client else None, request.headers.get("user-agent"))'''
    
    content = content.replace(target_coach_fail, new_coach_logic)

    # Student logic
    target_student_fail = '''            if password_valid:
                required_profile_fields = {'''
    # Wait, Student logic is more complex in unified_login (step 296).
    
    # I'll just use the successful login injection I did earlier to find the spot.
    
    student_success_spot = '''handle_successful_login(db, student, "student", request.client.host if request.client else None, request.headers.get("user-agent"))
                access_token, refresh_token = _make_tokens(student.id, "student", student.email, "student")'''
    
    # No, that's not enough context to find the password_valid check.

    # Let's search for the student password check in content.
    student_pwd_check = 'if student:\n        check_account_lock(student)\n        password_valid = False'
    # Wait, Part 1 changed it to:
    # student = db.query(StudentDB).filter(StudentDB.email == login_data.email).first()
    # if student:
    #     check_account_lock(student)
    #     password_valid = False
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)

if __name__ == '__main__':
    patch_login_failures('Backend/main.py')
