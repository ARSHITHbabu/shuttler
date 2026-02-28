import re

def update_fee_audit(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # 1. Update FeePaymentDB with is_cancelled and cancel_reason
    if 'is_cancelled = Column(Boolean' not in content:
        content = content.replace(
            'collected_by = Column(String, nullable=True)',
            'collected_by = Column(String, nullable=True)\n    is_cancelled = Column(Boolean, default=False)\n    cancel_reason = Column(String, nullable=True)'
        )

    # 2. Add migration columns for fee_payments
    mig_target = "check_and_add_column(engine, 'fee_payments', 'collected_by', 'VARCHAR(255)', nullable=True)"
    mig_insert = "            check_and_add_column(engine, 'fee_payments', 'is_cancelled', 'BOOLEAN', nullable=True, default_value='FALSE')\n            check_and_add_column(engine, 'fee_payments', 'cancel_reason', 'VARCHAR(500)', nullable=True)"
    if mig_target in content and 'is_cancelled' not in content:
        content = content.replace(mig_target, mig_target + '\n' + mig_insert)

    # 3. Modify calculate_total_paid to exclude cancelled payments
    total_paid_orig = 'query = db.query(func.sum(FeePaymentDB.amount)).filter(FeePaymentDB.fee_id == fee_id)'
    total_paid_new = 'query = db.query(func.sum(FeePaymentDB.amount)).filter(FeePaymentDB.fee_id == fee_id, FeePaymentDB.is_cancelled == False)'
    if total_paid_orig in content:
        content = content.replace(total_paid_orig, total_paid_new)

    # 4. Modify delete_fee_payment to soft-cancel
    delete_func_orig = '''def delete_fee_payment(fee_id: int, payment_id: int):'''
    # I'll replace the body instead.
    
    # Actually, I should find the specific implementation of delete_fee_payment.
    # It starts around line 6931.
    
    soft_close_code = '''def delete_fee_payment(fee_id: int, payment_id: int, cancel_reason: str = Body(..., embed=True), current_user: dict = Depends(require_owner)):
    """Soft cancel a payment and recalculate fee status (C12 requirement)"""
    db = SessionLocal()
    try:
        payment = db.query(FeePaymentDB).filter(
            FeePaymentDB.id == payment_id,
            FeePaymentDB.fee_id == fee_id
        ).first()
        if not payment:
            raise HTTPException(status_code=404, detail="Payment not found")
        
        # Lock check: Prevent cancellation after 24 hours
        time_diff = datetime.utcnow() - payment.created_at.replace(tzinfo=None)
        if time_diff.total_seconds() > 86400: # 24 hours
            raise HTTPException(status_code=403, detail="Payments cannot be cancelled after 24 hours.")

        payment.is_cancelled = True
        payment.cancel_reason = cancel_reason
        db.commit()
        
        # Recalculate fee status
        fee = db.query(FeeDB).filter(FeeDB.id == fee_id).first()
        if fee:
            query = db.query(func.sum(FeePaymentDB.amount)).filter(FeePaymentDB.fee_id == fee_id, FeePaymentDB.is_cancelled == False)
            total_paid = query.scalar() or 0.0
            new_status = calculate_fee_status(fee.amount, total_paid, fee.due_date)
            fee.status = new_status
            db.commit()
        
        # Audit log
        emit_audit_log(db, int(current_user["sub"]), current_user["role"], "CANCEL_PAYMENT", "fee_payment", payment_id, {"amount": payment.amount}, {"is_cancelled": True, "reason": cancel_reason})
        
        return {"message": "Payment cancelled successfully"}
    finally:
        db.close()'''
    
    # Use re to find and replace the whole function
    content = re.sub(r'def delete_fee_payment\(fee_id: int, payment_id: int\):.*?finally:.*?db\.close\(\)', soft_close_code, content, flags=re.DOTALL)

    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)

if __name__ == '__main__':
    update_fee_audit('Backend/main.py')
