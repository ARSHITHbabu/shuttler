import pytest
from datetime import datetime, timedelta
from unittest.mock import MagicMock
from main import calculate_fee_status, calculate_total_paid

def test_calculate_fee_status_paid():
    assert calculate_fee_status(100.0, 100.0, "2024-01-01") == "paid"
    assert calculate_fee_status(100.0, 120.0, "2024-01-01") == "paid"

def test_calculate_fee_status_overdue():
    # 8 days ago
    due_date = (datetime.now() - timedelta(days=8)).isoformat()
    assert calculate_fee_status(100.0, 0.0, due_date) == "overdue"
    
    # 7 days ago (inclusive)
    due_date = (datetime.now() - timedelta(days=7)).isoformat()
    assert calculate_fee_status(100.0, 0.0, due_date) == "overdue"

def test_calculate_fee_status_partial():
    # Due today, paid 50
    due_date = datetime.now().isoformat()
    assert calculate_fee_status(100.0, 50.0, due_date) == "partial"
    
    # Due in future, paid 50
    due_date = (datetime.now() + timedelta(days=5)).isoformat()
    assert calculate_fee_status(100.0, 50.0, due_date) == "partial"

def test_calculate_fee_status_pending():
    # Due today, paid 0
    due_date = datetime.now().isoformat()
    assert calculate_fee_status(100.0, 0.0, due_date) == "pending"
    
    # Due in future, paid 0
    due_date = (datetime.now() + timedelta(days=5)).isoformat()
    assert calculate_fee_status(100.0, 0.0, due_date) == "pending"

def test_calculate_total_paid():
    mock_db = MagicMock()
    mock_payment1 = MagicMock()
    mock_payment1.amount = 50.0
    mock_payment2 = MagicMock()
    mock_payment2.amount = 30.0
    
    mock_db.query.return_value.filter.return_value.all.return_value = [mock_payment1, mock_payment2]
    
    result = calculate_total_paid(1, mock_db)
    assert result == 80.0
    
def test_calculate_total_paid_no_payments():
    mock_db = MagicMock()
    mock_db.query.return_value.filter.return_value.all.return_value = []
    
    result = calculate_total_paid(1, mock_db)
    assert result == 0.0
