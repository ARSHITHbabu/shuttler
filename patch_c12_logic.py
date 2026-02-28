import re
from pathlib import Path

def setup_audit_logging(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    audit_code = '''
def emit_audit_log(db, user_id, role, action, resource_type, resource_id=None, old_values=None, new_values=None, ip_address=None):
    from datetime import datetime
    try:
        log = AuditLogDB(
            user_id=user_id,
            role=role,
            action=action,
            resource_type=resource_type,
            resource_id=resource_id,
            old_values=old_values,
            new_values=new_values,
            ip_address=ip_address
        )
        db.add(log)
        db.commit()
    except Exception as e:
        print(f"[AuditLog] Err: {e}")
        db.rollback()

def record_login_history(db, user_id, user_type, ip_address, user_agent, status):
    from datetime import datetime
    try:
        log = LoginHistoryDB(
            user_id=user_id,
            user_type=user_type,
            ip_address=ip_address,
            user_agent=user_agent,
            status=status
        )
        db.add(log)
        db.commit()
    except Exception as e:
        print(f"[LoginHistory] Err: {e}")
        db.rollback()

def check_account_lock(user):
    from datetime import datetime
    if hasattr(user, 'locked_until') and user.locked_until is not None:
        if user.locked_until.replace(tzinfo=None) > datetime.utcnow():
            raise HTTPException(status_code=403, detail="Account is locked due to multiple failed login attempts. Please contact admin.")

def handle_failed_login(db, user, user_type, ip_address, user_agent):
    from datetime import datetime, timedelta
    if hasattr(user, 'failed_login_attempts'):
        user.failed_login_attempts = (user.failed_login_attempts or 0) + 1
        if user.failed_login_attempts >= 10:
            user.locked_until = datetime.utcnow() + timedelta(hours=24)
            print(f"[Security] Account locked for {user_type} {user.id}")
            # Could trigger an email to owner here
        db.commit()
    record_login_history(db, user.id, user_type, ip_address, user_agent, "failed")
    raise HTTPException(status_code=401, detail="Invalid email or password")

def handle_successful_login(db, user, user_type, ip_address, user_agent):
    if hasattr(user, 'failed_login_attempts') and (user.failed_login_attempts or 0) > 0:
        user.failed_login_attempts = 0
        user.locked_until = None
        db.commit()
    record_login_history(db, user.id, user_type, ip_address, user_agent, "success")

'''
    if 'def emit_audit_log(' not in content:
        content = content.replace('def get_current_user(', audit_code + '\ndef get_current_user(')

    endpoints_code = '''
@app.get("/login-history/", dependencies=[Depends(require_owner)])
def get_login_history(db: Session = Depends(get_db)):
    # Returns last 90 days logins for coaches/students
    logs = db.query(LoginHistoryDB).order_by(LoginHistoryDB.created_at.desc()).limit(200).all()
    return logs
'''
    if '/login-history/' not in content:
        content = content.replace('@app.get("/health")', endpoints_code + '\n@app.get("/health")')

    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)

if __name__ == '__main__':
    setup_audit_logging('Backend/main.py')
