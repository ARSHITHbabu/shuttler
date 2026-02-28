import re

def create_c12_models(main_file_path):
    with open(main_file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # 1. Add AuditLogDB and LoginHistoryDB
    models_code = '''
class AuditLogDB(Base):
    __tablename__ = "audit_logs"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, index=True)
    role = Column(String(50))
    action = Column(String(255))
    resource_type = Column(String(50))
    resource_id = Column(Integer)
    old_values = Column(JSON, nullable=True)
    new_values = Column(JSON, nullable=True)
    ip_address = Column(String(100))
    created_at = Column(DateTime(timezone=True), server_default=func.now())

class LoginHistoryDB(Base):
    __tablename__ = "login_history"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, index=True)
    user_type = Column(String(50))
    ip_address = Column(String(100))
    user_agent = Column(String(500))
    status = Column(String(50))  # "success" or "failed"
    created_at = Column(DateTime(timezone=True), server_default=func.now())
'''
    if 'class AuditLogDB' not in content:
        content = content.replace('class ActiveSessionDB(Base):', models_code + '\nclass ActiveSessionDB(Base):')

    # 2. Add failed_login_attempts + locked_until
    for tbl in ['coaches', 'owners', 'students']:
        mig_target = f"check_and_add_column(engine, '{tbl}', 'fcm_token', 'VARCHAR(500)', nullable=True)"
        mig_insert = f"            check_and_add_column(engine, '{tbl}', 'failed_login_attempts', 'INTEGER', nullable=True, default_value='0')\n            check_and_add_column(engine, '{tbl}', 'locked_until', 'TIMESTAMP WITH TIME ZONE', nullable=True)"
        if mig_target in content and 'failed_login_attempts' not in content:
            content = content.replace(mig_target, mig_target + '\n' + mig_insert)

    if 'failed_login_attempts =' not in content:
        content = content.replace(
            'jwt_invalidated_at = Column(DateTime(timezone=True), nullable=True)',
            'jwt_invalidated_at = Column(DateTime(timezone=True), nullable=True)\n    failed_login_attempts = Column(Integer, default=0)\n    locked_until = Column(DateTime(timezone=True), nullable=True)'
        )

    with open(main_file_path, 'w', encoding='utf-8') as f:
        f.write(content)

if __name__ == '__main__':
    create_c12_models('Backend/main.py')
