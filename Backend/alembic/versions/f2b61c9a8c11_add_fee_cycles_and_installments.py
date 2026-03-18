"""Add fee cycle metadata and installment table

Revision ID: f2b61c9a8c11
Revises: 129feae3beda
Create Date: 2026-03-18 00:00:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'f2b61c9a8c11'
down_revision: Union[str, None] = '129feae3beda'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column('fees', sa.Column('billing_year', sa.Integer(), nullable=True))
    op.add_column('fees', sa.Column('billing_month', sa.Integer(), nullable=True))
    op.add_column('fees', sa.Column('cycle_key', sa.String(), nullable=True))
    op.add_column('fees', sa.Column('grace_days', sa.Integer(), nullable=False, server_default='7'))

    op.create_index('ix_fees_cycle_key', 'fees', ['cycle_key'])
    op.create_index('ix_fees_billing_year_month', 'fees', ['billing_year', 'billing_month'])

    op.create_table(
        'fee_installments',
        sa.Column('id', sa.Integer(), primary_key=True, nullable=False),
        sa.Column('fee_id', sa.Integer(), sa.ForeignKey('fees.id', ondelete='CASCADE'), nullable=False),
        sa.Column('installment_no', sa.Integer(), nullable=False),
        sa.Column('due_date', sa.String(), nullable=False),
        sa.Column('amount', sa.Float(), nullable=False),
        sa.Column('paid_amount', sa.Float(), nullable=False, server_default='0.0'),
        sa.Column('status', sa.String(), nullable=False, server_default='pending'),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=True, server_default=sa.text('now()')),
    )
    op.create_index('ix_fee_installments_fee_id', 'fee_installments', ['fee_id'])
    op.create_index('ix_fee_installments_due_date_status', 'fee_installments', ['due_date', 'status'])


def downgrade() -> None:
    op.drop_index('ix_fee_installments_due_date_status', table_name='fee_installments')
    op.drop_index('ix_fee_installments_fee_id', table_name='fee_installments')
    op.drop_table('fee_installments')

    op.drop_index('ix_fees_billing_year_month', table_name='fees')
    op.drop_index('ix_fees_cycle_key', table_name='fees')

    op.drop_column('fees', 'grace_days')
    op.drop_column('fees', 'cycle_key')
    op.drop_column('fees', 'billing_month')
    op.drop_column('fees', 'billing_year')
