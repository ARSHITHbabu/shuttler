import re
import os

file_path = r"d:\laptop new\f\Personal Projects\badminton\abhi_colab\Cursor1\shuttler\Backend\main.py"
with open(file_path, "r", encoding="utf-8") as f:
    content = f.read()

# 1. Add PasswordResetTokenDB
token_model = """class PasswordResetTokenDB(Base):
    __tablename__ = "password_reset_tokens"
    id = Column(Integer, primary_key=True, index=True)
    token_hash = Column(String(255), unique=True, nullable=False, index=True)
    email = Column(String, nullable=False)
    user_type = Column(String(20), nullable=False)
    expires_at = Column(DateTime(timezone=True), nullable=False)

"""
if "class PasswordResetTokenDB" not in content:
    content = content.replace("class RevokedTokenDB(Base):", token_model + "class RevokedTokenDB(Base):")

# 2. Add table creation
table_create = """        if 'password_reset_tokens' not in tables:
            print("  password_reset_tokens table not found. Creating...")
            try:
                PasswordResetTokenDB.__table__.create(bind=engine)
                print(" password_reset_tokens table created!")
            except Exception as e:
                pass
                
"""
if "PasswordResetTokenDB.__table__.create" not in content:
    content = content.replace("        # Check if leave_requests table exists", table_create + "        # Check if leave_requests table exists")

# 3. Modify forgot_password
forgot_pass_old = """        # Generate secure reset token
        reset_token = secrets.token_urlsafe(32)
        
        # Store token with expiration (1 hour)
        password_reset_tokens[reset_token] = {
            "email": request_data.email,
            "user_type": user_type, # Use the detected type
            "expires_at": datetime.now() + timedelta(hours=1)
        }
        
        # In production, send email with reset link
        # For now, return token (in production, don't return token, send via email)
        return {
            "success": True,
            "message": "Password reset token generated. Use this token to reset your password.",
            "reset_token": reset_token,  # Remove this in production, send via email instead
            "expires_in": 3600  # seconds
        }"""
forgot_pass_new = """        import hashlib
        # Generate secure reset token
        reset_token = secrets.token_urlsafe(32)
        token_hash = hashlib.sha256(reset_token.encode()).hexdigest()
        
        # Store token with expiration (15 mins)
        new_token = PasswordResetTokenDB(
            token_hash=token_hash,
            email=request_data.email,
            user_type=user_type,
            expires_at=datetime.now() + timedelta(minutes=15)
        )
        db.add(new_token)
        db.commit()
        
        # Prevent account enumeration: return uniform message whether email was found or not
        return {
            "success": True,
            "message": "If your email is registered, you will receive a password reset token.",
            "reset_token": reset_token,  # Remove this in production, but needed for development right now
            "expires_in": 900
        }"""
if forgot_pass_old in content:
    content = content.replace(
        "return {\"success\": False, \"message\": \"Email not found\"}", 
        "return {\"success\": True, \"message\": \"If your email is registered, you will receive a password reset token.\"}"
    )
    content = content.replace(forgot_pass_old, forgot_pass_new)

# 4. Modify reset_password
reset_pass_old = """        # Validate token
        if request.reset_token not in password_reset_tokens:
            return {
                "success": False,
                "message": "Invalid or expired reset token"
            }
        
        token_data = password_reset_tokens[request.reset_token]
        
        # Check expiration
        if datetime.now() > token_data["expires_at"]:
            del password_reset_tokens[request.reset_token]
            return {
                "success": False,
                "message": "Reset token has expired. Please request a new one."
            }
        
        # Verify email matches
        if token_data["email"] != request.email or token_data["user_type"] != request.user_type:
            return {
                "success": False,
                "message": "Invalid reset token"
            }"""
reset_pass_new = """        import hashlib
        token_hash = hashlib.sha256(request.reset_token.encode()).hexdigest()
        
        # Validate token
        token_entry = db.query(PasswordResetTokenDB).filter(PasswordResetTokenDB.token_hash == token_hash).first()
        if not token_entry:
            return {"success": False, "message": "Invalid or expired reset token"}
        
        # Check expiration
        if datetime.now() > token_entry.expires_at.replace(tzinfo=None):
            db.delete(token_entry)
            db.commit()
            return {"success": False, "message": "Reset token has expired. Please request a new one."}
        
        # Verify email matches
        if token_entry.email != request.email or token_entry.user_type != request.user_type:
            return {"success": False, "message": "Invalid reset token"}
"""
if reset_pass_old in content:
    content = content.replace(reset_pass_old, reset_pass_new)
    content = content.replace("del password_reset_tokens[request.reset_token]", "db.delete(token_entry)\n        db.commit()")

# 5. Add Logout All API
logout_all_api = """@app.post("/auth/logout_all")
def logout_all_devices(current_user: dict = Depends(get_current_user)):
    \"\"\"Logs out the user from all devices by invalidating all previously issued tokens.\"\"\"
    db = SessionLocal()
    try:
        user_id = current_user.get("sub")
        user_type = current_user.get("user_type")
        
        user = None
        if user_type == "owner":
            user = db.query(OwnerDB).filter(OwnerDB.id == int(user_id)).first()
        elif user_type == "coach":
            user = db.query(CoachDB).filter(CoachDB.id == int(user_id)).first()
        elif user_type == "student":
            user = db.query(StudentDB).filter(StudentDB.id == int(user_id)).first()
            
        if not user:
            raise HTTPException(status_code=404, detail="User not found")
            
        from sqlalchemy.sql import func
        user.jwt_invalidated_at = func.now()
        db.commit()
        
        return {"success": True, "message": "Successfully logged out from all devices"}
    finally:
        db.close()

"""
if "def logout_all_devices" not in content:
    content = content.replace("@app.post(\"/auth/logout\")", logout_all_api + "@app.post(\"/auth/logout\")")

# 6. Add Password Validation Pydantic
pydantic_validator = """
def validate_password_complexity(v: str) -> str:
    if len(v) < 8:
        raise ValueError("Password must be at least 8 characters long")
    if len(v.encode('utf-8')) > 72:
        raise ValueError("Password cannot be longer than 72 bytes")
    if not re.search(r"[A-Z]", v):
        raise ValueError("Password must contain at least one uppercase letter")
    if not re.search(r"[a-z]", v):
        raise ValueError("Password must contain at least one lowercase letter")
    if not re.search(r"[0-9]", v):
        raise ValueError("Password must contain at least one number")
    return v
"""
if "def validate_password_complexity" not in content:
    content = content.replace("class CoachCreate(BaseModel):", pydantic_validator + "\nclass CoachCreate(BaseModel):")

# Helper to inject validator into class
def inject_validator(cls_name, field_name):
    global content
    class_def_start = content.find(f"class {cls_name}(BaseModel):")
    if class_def_start == -1: return
    # Find the next class definition or end of file
    next_class = content.find("class ", class_def_start + 10)
    if next_class == -1: next_class = len(content)
    
    class_body = content[class_def_start:next_class]
    if f"def check_pwd_{cls_name}" not in class_body:
        validator_str = f'''

    @field_validator('{field_name}')
    @classmethod
    def check_pwd_{cls_name}(cls, v):
        return validate_password_complexity(v)
'''
        # Insert before the class_body ends or next class starts
        content = content[:class_def_start] + class_body.rstrip() + validator_str + "\\n\\n" + content[next_class:]

inject_validator("CoachCreate", "password")
inject_validator("OwnerCreate", "password")
inject_validator("StudentCreate", "password")
inject_validator("ResetPasswordRequest", "new_password")
inject_validator("ChangePasswordRequest", "new_password")

with open(file_path, "w", encoding="utf-8") as f:
    f.write(content)

print("Patch applied.")
