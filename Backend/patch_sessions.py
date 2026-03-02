import re
import os

file_path = r"d:\laptop new\f\Personal Projects\badminton\abhi_colab\Cursor1\shuttler\Backend\main.py"
with open(file_path, "r", encoding="utf-8") as f:
    content = f.read()

# 1. Add ActiveSessionDB Model
active_session_model = """class ActiveSessionDB(Base):
    __tablename__ = "active_sessions"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, nullable=False, index=True)
    user_type = Column(String(20), nullable=False)
    jti = Column(String(255), unique=True, nullable=False, index=True) # Access token JTI
    refresh_jti = Column(String(255), unique=True, nullable=False, index=True) # Refresh token JTI
    ip_address = Column(String(100), nullable=True)
    user_agent = Column(String(500), nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    expires_at = Column(DateTime(timezone=True), nullable=False)
    is_revoked = Column(Boolean, default=False)

"""
if "class ActiveSessionDB" not in content:
    content = content.replace("class PasswordResetTokenDB(Base):", active_session_model + "class PasswordResetTokenDB(Base):")

# 2. Schema Migration for active_sessions
active_session_create = """        if 'active_sessions' not in tables:
            print("  active_sessions table not found. Creating...")
            try:
                ActiveSessionDB.__table__.create(bind=engine)
                print(" active_sessions table created!")
            except Exception as e:
                pass
                
"""
if "ActiveSessionDB.__table__.create" not in content:
    content = content.replace("        if 'password_reset_tokens' not in tables:", active_session_create + "        if 'password_reset_tokens' not in tables:")

# 3. Update create_access_token & create_refresh_token
if "def create_access_token(data: dict) -> str:" in content:
    content = content.replace("def create_access_token(data: dict) -> str:", "def create_access_token(data: dict, jti: str = None) -> str:")
    content = content.replace("jti = str(uuid.uuid4())\n    to_encode.update({\"exp\": expire, \"type\": \"access\", \"jti\": jti})", "token_jti = jti if jti else str(uuid.uuid4())\n    to_encode.update({\"exp\": expire, \"type\": \"access\", \"jti\": token_jti})")
if "def create_refresh_token(data: dict) -> str:" in content:
    content = content.replace("def create_refresh_token(data: dict) -> str:", "def create_refresh_token(data: dict, jti: str = None) -> str:")
    content = content.replace("jti = str(uuid.uuid4())\n    to_encode.update({\"exp\": expire, \"type\": \"refresh\", \"jti\": jti})", "token_jti = jti if jti else str(uuid.uuid4())\n    to_encode.update({\"exp\": expire, \"type\": \"refresh\", \"jti\": token_jti})")

# 4. _make_tokens update in unified_login
make_tokens_old = """        def _make_tokens(user_id: int, user_type: str, email: str, role: str):
            payload = {"sub": str(user_id), "user_type": user_type, "email": email, "role": role}
            return create_access_token(payload), create_refresh_token(payload)"""
make_tokens_new = """        def _make_tokens(user_id: int, user_type: str, email: str, role: str):
            payload = {"sub": str(user_id), "user_type": user_type, "email": email, "role": role}
            access_jti = str(uuid.uuid4())
            refresh_jti = str(uuid.uuid4())
            access_token = create_access_token(payload, jti=access_jti)
            refresh_token = create_refresh_token(payload, jti=refresh_jti)
            
            # Record active session
            expires_at = datetime.utcnow() + timedelta(days=REFRESH_TOKEN_EXPIRE_DAYS)
            client_ip = request.client.host if request and request.client else None
            user_agent = request.headers.get("user-agent", None) if request else None
            
            new_session = ActiveSessionDB(
                user_id=user_id,
                user_type=user_type,
                jti=access_jti,
                refresh_jti=refresh_jti,
                ip_address=client_ip,
                user_agent=user_agent,
                expires_at=expires_at
            )
            db.add(new_session)
            db.commit()
            
            return access_token, refresh_token"""
if make_tokens_old in content:
    content = content.replace(make_tokens_old, make_tokens_new)

# 5. refresh_access_token
refresh_sign_old = "def refresh_access_token(body: TokenRefreshRequest):"
refresh_sign_new = "def refresh_access_token(request: Request, body: TokenRefreshRequest):"
if refresh_sign_old in content:
    content = content.replace(refresh_sign_old, refresh_sign_new)

refresh_tokens_old = """    # Issue new token pair
    token_data = {
        "sub": user_id,
        "user_type": user_type,
        "email": payload.get("email", ""),
        "role": payload.get("role", user_type),
    }
    new_access = create_access_token(token_data)
    new_refresh = create_refresh_token(token_data)

    return {
        "access_token": new_access,
        "refresh_token": new_refresh,
        "token_type": "bearer",
    }"""
refresh_tokens_new = """    # Issue new token pair
    token_data = {
        "sub": user_id,
        "user_type": user_type,
        "email": payload.get("email", ""),
        "role": payload.get("role", user_type),
    }
    new_access_jti = str(uuid.uuid4())
    new_refresh_jti = str(uuid.uuid4())
    new_access = create_access_token(token_data, jti=new_access_jti)
    new_refresh = create_refresh_token(token_data, jti=new_refresh_jti)
    
    db_sess = SessionLocal()
    try:
        expires_at = datetime.utcnow() + timedelta(days=REFRESH_TOKEN_EXPIRE_DAYS)
        client_ip = request.client.host if request and hasattr(request, 'client') and request.client else None
        user_agent = request.headers.get("user-agent", None) if request else None
        
        new_session = ActiveSessionDB(
            user_id=int(user_id),
            user_type=user_type,
            jti=new_access_jti,
            refresh_jti=new_refresh_jti,
            ip_address=client_ip,
            user_agent=user_agent,
            expires_at=expires_at
        )
        db_sess.add(new_session)
        
        old_session = db_sess.query(ActiveSessionDB).filter(ActiveSessionDB.refresh_jti == jti).first()
        if old_session:
            old_session.is_revoked = True
            
        db_sess.commit()
    except Exception as e:
        print(f"Error recording rotated session: {e}")
    finally:
        db_sess.close()

    return {
        "access_token": new_access,
        "refresh_token": new_refresh,
        "token_type": "bearer",
    }"""
if "new_access = create_access_token(token_data)" in content and "db_sess = SessionLocal()" not in content:
    content = content.replace(refresh_tokens_old, refresh_tokens_new)

# 6. Logout cleanup
logout_old = """        if body.refresh_token:
            try:
                rt_payload = decode_token(body.refresh_token)
                rt_jti = rt_payload.get("jti")
                if rt_jti:
                    db.add(RevokedTokenDB(
                        jti=rt_jti,
                        user_id=int(user_id),
                        user_type=user_type,
                        expires_at=expires_dt,
                    ))
            except Exception:
                pass"""

logout_new = """        if body.refresh_token:
            try:
                rt_payload = decode_token(body.refresh_token)
                rt_jti = rt_payload.get("jti")
                if rt_jti:
                    db.add(RevokedTokenDB(
                        jti=rt_jti,
                        user_id=int(user_id),
                        user_type=user_type,
                        expires_at=expires_dt,
                    ))
                    active_rt = db.query(ActiveSessionDB).filter(ActiveSessionDB.refresh_jti == rt_jti).first()
                    if active_rt:
                        active_rt.is_revoked = True
            except Exception:
                pass
                
        # Also mark access token session as revoked
        if jti:
            active_session = db.query(ActiveSessionDB).filter(ActiveSessionDB.jti == jti).first()
            if active_session:
                active_session.is_revoked = True"""
if logout_old in content and "active_rt.is_revoked = True" not in content:
    content = content.replace(logout_old, logout_new)

# 7. Add endpoints for Session Management
session_apis = """
@app.get("/auth/sessions")
def get_active_sessions(request: Request, current_user: dict = Depends(get_current_user)):
    \"\"\"Get all active sessions for the current user.\"\"\"
    db = SessionLocal()
    try:
        user_id = current_user.get("sub")
        user_type = current_user.get("user_type")
        current_jti = current_user.get("jti")
        
        # Cleanup expired sessions
        db.query(ActiveSessionDB).filter(
            ActiveSessionDB.expires_at < datetime.utcnow()
        ).delete()
        db.commit()
        
        sessions = db.query(ActiveSessionDB).filter(
            ActiveSessionDB.user_id == int(user_id),
            ActiveSessionDB.user_type == user_type,
            ActiveSessionDB.is_revoked == False
        ).order_by(ActiveSessionDB.created_at.desc()).all()
        
        result = []
        for s in sessions:
            result.append({
                "id": s.id,
                "ip_address": s.ip_address,
                "user_agent": s.user_agent,
                "created_at": s.created_at.isoformat() if s.created_at else None,
                "is_current": s.jti == current_jti
            })
        return {"success": True, "sessions": result}
    finally:
        db.close()

@app.delete("/auth/sessions/{session_id}")
def revoke_session(session_id: int, current_user: dict = Depends(get_current_user)):
    \"\"\"Revoke a specific active session.\"\"\"
    db = SessionLocal()
    try:
        user_id = current_user.get("sub")
        user_type = current_user.get("user_type")
        
        session = db.query(ActiveSessionDB).filter(
            ActiveSessionDB.id == session_id,
            ActiveSessionDB.user_id == int(user_id),
            ActiveSessionDB.user_type == user_type
        ).first()
        
        if not session:
            raise HTTPException(status_code=404, detail="Session not found")
        
        if session.is_revoked:
            return {"success": True, "message": "Session already revoked"}
            
        # Revoke the tokens explicitly
        db.add(RevokedTokenDB(
            jti=session.jti,
            user_id=int(user_id),
            user_type=user_type,
            expires_at=session.expires_at
        ))
        db.add(RevokedTokenDB(
            jti=session.refresh_jti,
            user_id=int(user_id),
            user_type=user_type,
            expires_at=session.expires_at
        ))
        
        session.is_revoked = True
        db.commit()
        
        return {"success": True, "message": "Session revoked successfully"}
    finally:
        db.close()

"""
if "@app.get(\"/auth/sessions\")" not in content:
    content = content.replace("@app.post(\"/auth/logout_all\")", session_apis + "@app.post(\"/auth/logout_all\")")

with open(file_path, "w", encoding="utf-8") as f:
    f.write(content)

print("Patch active sessions applied.")
