import { useState } from 'react';
import { ArrowLeft, Search, DollarSign, Check, Clock, AlertCircle } from 'lucide-react';

interface FeeManagementProps {
  onBack: () => void;
}

export default function FeeManagement({ onBack }: FeeManagementProps) {
  const [selectedStudent, setSelectedStudent] = useState<any>(null);
  const [filterStatus, setFilterStatus] = useState<'all' | 'pending' | 'paid' | 'overdue'>('all');

  const feeData = [
    { id: 1, studentName: 'Arjun Mehta', totalAmount: 5000, paidAmount: 2500, status: 'pending', dueDate: '2026-01-15' },
    { id: 2, studentName: 'Kavya Sharma', totalAmount: 5000, paidAmount: 5000, status: 'paid', dueDate: '2026-01-10' },
    { id: 3, studentName: 'Rohan Patel', totalAmount: 5000, paidAmount: 0, status: 'overdue', dueDate: '2025-12-31' },
    { id: 4, studentName: 'Priya Singh', totalAmount: 5000, paidAmount: 2500, status: 'pending', dueDate: '2026-01-20' },
  ];

  const stats = {
    pending: 38500,
    paid: 156000,
    overdue: 15000,
  };

  const filteredData = filterStatus === 'all' 
    ? feeData 
    : feeData.filter(f => f.status === filterStatus);

  if (selectedStudent) {
    return (
      <div className="min-h-screen">
        {/* Header */}
        <div className="sticky top-0 bg-[#1a1a1a] border-b border-[#2a2a2a] px-6 py-4 flex items-center gap-4 shadow-[0_4px_16px_rgba(0,0,0,0.5)]">
          <button
            onClick={() => setSelectedStudent(null)}
            className="w-10 h-10 rounded-xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] active:shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)] flex items-center justify-center"
          >
            <ArrowLeft className="w-5 h-5 text-[#a0a0a0]" />
          </button>
          <h1 className="text-xl text-[#e8e8e8]">Fee Details</h1>
        </div>

        <div className="p-6">
          <div className="p-4 rounded-xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] mb-6">
            <p className="text-sm text-[#888888] mb-1">Student</p>
            <p className="text-lg text-[#e8e8e8]">{selectedStudent.studentName}</p>
          </div>

          {/* Amount Summary */}
          <div className="p-6 rounded-2xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] mb-6">
            <div className="space-y-4">
              <div className="flex items-center justify-between pb-3 border-b border-[#2a2a2a]">
                <span className="text-sm text-[#888888]">Total Amount</span>
                <span className="text-lg text-[#e8e8e8]">₹{selectedStudent.totalAmount}</span>
              </div>
              <div className="flex items-center justify-between pb-3 border-b border-[#2a2a2a]">
                <span className="text-sm text-[#888888]">Paid Amount</span>
                <span className="text-lg text-[#80c080]">₹{selectedStudent.paidAmount}</span>
              </div>
              <div className="flex items-center justify-between">
                <span className="text-sm text-[#888888]">Remaining Balance</span>
                <span className="text-xl text-[#c08080]">₹{selectedStudent.totalAmount - selectedStudent.paidAmount}</span>
              </div>
            </div>
          </div>

          {/* Status */}
          <div className="p-5 rounded-2xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] mb-6">
            <div className="flex items-center justify-between mb-3">
              <span className="text-sm text-[#888888]">Status</span>
              <div className={`px-3 py-1 rounded-lg ${
                selectedStudent.status === 'paid' ? 'bg-[#1a2a1a]' :
                selectedStudent.status === 'overdue' ? 'bg-[#2a1a1a]' :
                'bg-[#2a2a1a]'
              } shadow-[inset_2px_2px_4px_rgba(0,0,0,0.5)]`}>
                <p className={`text-xs ${
                  selectedStudent.status === 'paid' ? 'text-[#80c080]' :
                  selectedStudent.status === 'overdue' ? 'text-[#c08080]' :
                  'text-[#c0c080]'
                }`}>
                  {selectedStudent.status.charAt(0).toUpperCase() + selectedStudent.status.slice(1)}
                </p>
              </div>
            </div>
            <div className="flex items-center justify-between">
              <span className="text-sm text-[#888888]">Due Date</span>
              <span className="text-sm text-[#a0a0a0]">{new Date(selectedStudent.dueDate).toLocaleDateString()}</span>
            </div>
          </div>

          {/* Payment Methods */}
          {selectedStudent.status !== 'paid' && (
            <div className="space-y-3">
              <p className="text-sm text-[#888888]">Record Payment</p>
              <div className="p-6 rounded-2xl bg-[#242424] shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)]">
                <input
                  type="number"
                  placeholder="Enter amount"
                  className="w-full bg-transparent text-[#e8e8e8] text-xl placeholder-[#666666] outline-none mb-4"
                />
                <div className="flex gap-2">
                  <button className="flex-1 p-3 rounded-xl bg-[#2a2a2a] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] active:shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)] transition-all duration-200">
                    <span className="text-sm text-[#e8e8e8]">Cash</span>
                  </button>
                  <button className="flex-1 p-3 rounded-xl bg-[#2a2a2a] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] active:shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)] transition-all duration-200">
                    <span className="text-sm text-[#e8e8e8]">Card</span>
                  </button>
                  <button className="flex-1 p-3 rounded-xl bg-[#2a2a2a] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] active:shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)] transition-all duration-200">
                    <span className="text-sm text-[#e8e8e8]">UPI</span>
                  </button>
                </div>
              </div>
              <button className="w-full p-4 rounded-xl bg-[#2a2a2a] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] hover:shadow-[4px_4px_8px_rgba(0,0,0,0.5),-4px_-4px_8px_rgba(40,40,40,0.1)] transition-all duration-200 active:shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)]">
                <span className="text-[#e8e8e8]">Record Payment</span>
              </button>
            </div>
          )}
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen">
      {/* Header */}
      <div className="sticky top-0 bg-[#1a1a1a] border-b border-[#2a2a2a] px-6 py-4 shadow-[0_4px_16px_rgba(0,0,0,0.5)]">
        <div className="flex items-center gap-4 mb-4">
          <button
            onClick={onBack}
            className="w-10 h-10 rounded-xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] active:shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)] flex items-center justify-center"
          >
            <ArrowLeft className="w-5 h-5 text-[#a0a0a0]" />
          </button>
          <h1 className="text-xl text-[#e8e8e8] flex-1">Fee Management</h1>
        </div>
      </div>

      <div className="p-6">
        {/* Stats */}
        <div className="grid grid-cols-3 gap-3 mb-6">
          <div className="p-4 rounded-xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)]">
            <div className="flex items-center gap-2 mb-2">
              <Clock className="w-4 h-4 text-[#c0c080]" />
            </div>
            <p className="text-lg text-[#e8e8e8] mb-1">₹{stats.pending.toLocaleString()}</p>
            <p className="text-xs text-[#888888]">Pending</p>
          </div>

          <div className="p-4 rounded-xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)]">
            <div className="flex items-center gap-2 mb-2">
              <Check className="w-4 h-4 text-[#80c080]" />
            </div>
            <p className="text-lg text-[#e8e8e8] mb-1">₹{stats.paid.toLocaleString()}</p>
            <p className="text-xs text-[#888888]">Paid</p>
          </div>

          <div className="p-4 rounded-xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)]">
            <div className="flex items-center gap-2 mb-2">
              <AlertCircle className="w-4 h-4 text-[#c08080]" />
            </div>
            <p className="text-lg text-[#e8e8e8] mb-1">₹{stats.overdue.toLocaleString()}</p>
            <p className="text-xs text-[#888888]">Overdue</p>
          </div>
        </div>

        {/* Filter */}
        <div className="flex gap-2 mb-6 overflow-x-auto">
          {['all', 'pending', 'paid', 'overdue'].map((status) => (
            <button
              key={status}
              onClick={() => setFilterStatus(status as any)}
              className={`px-4 py-2 rounded-xl whitespace-nowrap transition-all duration-200 ${
                filterStatus === status
                  ? 'bg-[#2a2a2a] shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)] text-[#e8e8e8]'
                  : 'bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] text-[#888888]'
              }`}
            >
              {status.charAt(0).toUpperCase() + status.slice(1)}
            </button>
          ))}
        </div>

        {/* Fee List */}
        <div className="space-y-3">
          {filteredData.map((fee) => (
            <button
              key={fee.id}
              onClick={() => setSelectedStudent(fee)}
              className="w-full p-5 rounded-2xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] active:shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)] transition-all duration-200 text-left"
            >
              <div className="flex items-center justify-between mb-2">
                <p className="text-sm text-[#e8e8e8]">{fee.studentName}</p>
                <div className={`px-2 py-1 rounded ${
                  fee.status === 'paid' ? 'bg-[#1a2a1a]' :
                  fee.status === 'overdue' ? 'bg-[#2a1a1a]' :
                  'bg-[#2a2a1a]'
                } shadow-[inset_2px_2px_4px_rgba(0,0,0,0.5)]`}>
                  <p className={`text-xs ${
                    fee.status === 'paid' ? 'text-[#80c080]' :
                    fee.status === 'overdue' ? 'text-[#c08080]' :
                    'text-[#c0c080]'
                  }`}>
                    {fee.status}
                  </p>
                </div>
              </div>
              <div className="flex items-center justify-between text-xs text-[#888888]">
                <span>Due: {new Date(fee.dueDate).toLocaleDateString()}</span>
                <span className="text-[#a0a0a0]">₹{fee.totalAmount - fee.paidAmount} pending</span>
              </div>
            </button>
          ))}
        </div>
      </div>
    </div>
  );
}
