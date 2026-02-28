"""Add core database indexes

Revision ID: 129feae3beda
Revises: c70498d190af
Create Date: 2026-02-28 10:52:48.310095

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '129feae3beda'
down_revision: Union[str, None] = 'c70498d190af'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_index('ix_students_status', 'students', ['status'])
    op.create_index('ix_attendance_batch_id_date', 'attendance', ['batch_id', 'date'])
    op.create_index('ix_attendance_student_id_date', 'attendance', ['student_id', 'date'])
    op.create_index('ix_fees_student_id_status', 'fees', ['student_id', 'status'])
    op.create_index('ix_notifications_user_id_user_type_is_read', 'notifications', ['user_id', 'user_type', 'is_read'])
    op.create_index('ix_batches_session_id_status', 'batches', ['session_id', 'status'])
    op.create_index('ix_performance_student_id_date', 'performance', ['student_id', 'date'])
    op.create_index('ix_bmi_records_student_id_date', 'bmi_records', ['student_id', 'date'])


def downgrade() -> None:
    op.drop_index('ix_bmi_records_student_id_date', table_name='bmi_records')
    op.drop_index('ix_performance_student_id_date', table_name='performance')
    op.drop_index('ix_batches_session_id_status', table_name='batches')
    op.drop_index('ix_notifications_user_id_user_type_is_read', table_name='notifications')
    op.drop_index('ix_fees_student_id_status', table_name='fees')
    op.drop_index('ix_attendance_student_id_date', table_name='attendance')
    op.drop_index('ix_attendance_batch_id_date', table_name='attendance')
    op.drop_index('ix_students_status', table_name='students')
