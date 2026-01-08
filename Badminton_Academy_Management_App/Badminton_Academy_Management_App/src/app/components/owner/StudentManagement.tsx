import { useState, useEffect } from 'react';
import { ArrowLeft, Plus, Search, Phone, Mail, User, Calendar, TrendingUp, Activity, MoreVertical } from 'lucide-react';
import PerformanceTracking from './PerformanceTracking';
import BMITracking from './BMITracking';

interface StudentManagementProps {
  onBack: () => void;
  initialShowAddForm?: boolean;
}

export default function StudentManagement({ onBack, initialShowAddForm = false }: StudentManagementProps) {
  const [searchQuery, setSearchQuery] = useState('');
  const [showAddForm, setShowAddForm] = useState(initialShowAddForm);
  const [selectedStudent, setSelectedStudent] = useState<any>(null);
  const [showPerformance, setShowPerformance] = useState(false);
  const [showBMI, setShowBMI] = useState(false);

  useEffect(() => {
    setShowAddForm(initialShowAddForm);
  }, [initialShowAddForm]);

  const students = [
    { id: 1, name: 'Arjun Mehta', guardianName: 'Mr. Vijay Mehta', phone: '+91 98765 43210', email: 'arjun@example.com', batch: 'Morning Batch A', feePending: 2500, status: 'active' },
    { id: 2, name: 'Kavya Sharma', guardianName: 'Mrs. Anjali Sharma', phone: '+91 98765 43211', email: 'kavya@example.com', batch: 'Evening Batch B', feePending: 0, status: 'active' },
    { id: 3, name: 'Rohan Patel', guardianName: 'Mr. Ashok Patel', phone: '+91 98765 43212', email: 'rohan@example.com', batch: 'Morning Batch A', feePending: 5000, status: 'active' },
  ];

  if (showPerformance && selectedStudent) {
    return <PerformanceTracking student={selectedStudent} onBack={() => setShowPerformance(false)} />;
  }

  if (showBMI && selectedStudent) {
    return <BMITracking student={selectedStudent} onBack={() => setShowBMI(false)} />;
  }

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
          <h1 className="text-xl text-[#e8e8e8] flex-1">Student Details</h1>
          <button className="w-10 h-10 rounded-xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] active:shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)] flex items-center justify-center">
            <MoreVertical className="w-5 h-5 text-[#a0a0a0]" />
          </button>
        </div>

        <div className="p-6">
          {/* Profile Section */}
          <div className="p-6 rounded-2xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] mb-6">
            <div className="flex items-center gap-4 mb-6">
              <div className="w-16 h-16 rounded-full bg-[#1a1a1a] flex items-center justify-center shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)]">
                <span className="text-2xl text-[#a0a0a0]">{selectedStudent.name[0]}</span>
              </div>
              <div className="flex-1">
                <h2 className="text-xl text-[#e8e8e8] mb-1">{selectedStudent.name}</h2>
                <p className="text-sm text-[#888888]">{selectedStudent.batch}</p>
              </div>
            </div>

            <div className="space-y-3">
              <div className="flex items-center gap-3">
                <User className="w-4 h-4 text-[#888888]" />
                <span className="text-sm text-[#a0a0a0]">{selectedStudent.guardianName}</span>
              </div>
              <div className="flex items-center gap-3">
                <Phone className="w-4 h-4 text-[#888888]" />
                <span className="text-sm text-[#a0a0a0]">{selectedStudent.phone}</span>
              </div>
              <div className="flex items-center gap-3">
                <Mail className="w-4 h-4 text-[#888888]" />
                <span className="text-sm text-[#a0a0a0]">{selectedStudent.email}</span>
              </div>
            </div>
          </div>

          {/* Fee Summary */}
          <div className="p-5 rounded-2xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] mb-6">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-sm text-[#888888]">Fee Status</h3>
              <div className={`px-3 py-1 rounded-lg ${selectedStudent.feePending > 0 ? 'bg-[#2a1a1a]' : 'bg-[#1a2a1a]'} shadow-[inset_2px_2px_4px_rgba(0,0,0,0.5)]`}>
                <p className={`text-xs ${selectedStudent.feePending > 0 ? 'text-[#c08080]' : 'text-[#80c080]'}`}>
                  {selectedStudent.feePending > 0 ? 'Pending' : 'Paid'}
                </p>
              </div>
            </div>
            <div className="flex items-baseline gap-2">
              <span className="text-2xl text-[#e8e8e8]">₹{selectedStudent.feePending > 0 ? selectedStudent.feePending : '0'}</span>
              <span className="text-sm text-[#888888]">pending</span>
            </div>
          </div>

          {/* Quick Actions */}
          <div className="grid grid-cols-2 gap-3 mb-6">
            <button className="p-4 rounded-xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] active:shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)] transition-all duration-200">
              <div className="flex flex-col items-center gap-2">
                <Calendar className="w-6 h-6 text-[#a0a0a0]" />
                <p className="text-xs text-[#e8e8e8]">Attendance</p>
              </div>
            </button>
            <button
              onClick={() => setShowPerformance(true)}
              className="p-4 rounded-xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] active:shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)] transition-all duration-200"
            >
              <div className="flex flex-col items-center gap-2">
                <TrendingUp className="w-6 h-6 text-[#a0a0a0]" />
                <p className="text-xs text-[#e8e8e8]">Performance</p>
              </div>
            </button>
            <button
              onClick={() => setShowBMI(true)}
              className="p-4 rounded-xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] active:shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)] transition-all duration-200"
            >
              <div className="flex flex-col items-center gap-2">
                <Activity className="w-6 h-6 text-[#a0a0a0]" />
                <p className="text-xs text-[#e8e8e8]">BMI</p>
              </div>
            </button>
            <button className="p-4 rounded-xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] active:shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)] transition-all duration-200">
              <div className="flex flex-col items-center gap-2">
                <span className="text-xl">💰</span>
                <p className="text-xs text-[#e8e8e8]">Fee Details</p>
              </div>
            </button>
          </div>

          {/* Action Buttons */}
          <div className="space-y-3">
            <button className="w-full p-4 rounded-xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] active:shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)] transition-all duration-200">
              <span className="text-[#e8e8e8]">Edit Details</span>
            </button>
            <button className="w-full p-4 rounded-xl bg-[#1a1a1a] border border-[#2a2a2a] active:shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)] transition-all duration-200">
              <span className="text-[#888888]">Deactivate Student</span>
            </button>
          </div>
        </div>
      </div>
    );
  }

  if (showAddForm) {
    return (
      <div className="min-h-screen">
        {/* Header */}
        <div className="sticky top-0 bg-[#1a1a1a] border-b border-[#2a2a2a] px-6 py-4 flex items-center gap-4 shadow-[0_4px_16px_rgba(0,0,0,0.5)]">
          <button
            onClick={() => setShowAddForm(false)}
            className="w-10 h-10 rounded-xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] active:shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)] flex items-center justify-center"
          >
            <ArrowLeft className="w-5 h-5 text-[#a0a0a0]" />
          </button>
          <h1 className="text-xl text-[#e8e8e8]">Add New Student</h1>
        </div>

        <div className="p-6 space-y-4">
          <p className="text-sm text-[#888888] mb-4">Student Details</p>
          
          <div className="p-6 rounded-2xl bg-[#242424] shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)]">
            <input
              type="text"
              placeholder="Student Name *"
              className="w-full bg-transparent text-[#e8e8e8] placeholder-[#666666] outline-none"
            />
          </div>

          <p className="text-sm text-[#888888] mb-4 mt-6">Guardian Details</p>

          <div className="p-6 rounded-2xl bg-[#242424] shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)]">
            <input
              type="text"
              placeholder="Guardian Name *"
              className="w-full bg-transparent text-[#e8e8e8] placeholder-[#666666] outline-none"
            />
          </div>

          <div className="p-6 rounded-2xl bg-[#242424] shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)]">
            <input
              type="tel"
              placeholder="Phone Number *"
              className="w-full bg-transparent text-[#e8e8e8] placeholder-[#666666] outline-none"
            />
          </div>

          <div className="p-6 rounded-2xl bg-[#242424] shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)]">
            <input
              type="email"
              placeholder="Email Address"
              className="w-full bg-transparent text-[#e8e8e8] placeholder-[#666666] outline-none"
            />
          </div>

          <p className="text-sm text-[#888888] mb-4 mt-6">Batch Assignment</p>

          <div className="p-6 rounded-2xl bg-[#242424] shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)]">
            <select className="w-full bg-transparent text-[#e8e8e8] outline-none">
              <option value="">Select Batch *</option>
              <option value="1">Morning Batch A</option>
              <option value="2">Evening Batch B</option>
              <option value="3">Weekend Batch</option>
            </select>
          </div>

          <button className="w-full p-4 rounded-xl bg-[#2a2a2a] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] hover:shadow-[4px_4px_8px_rgba(0,0,0,0.5),-4px_-4px_8px_rgba(40,40,40,0.1)] transition-all duration-200 active:shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)] mt-6">
            <span className="text-[#e8e8e8]">Add Student</span>
          </button>
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
          <h1 className="text-xl text-[#e8e8e8] flex-1">Students</h1>
          <button
            onClick={() => setShowAddForm(true)}
            className="w-10 h-10 rounded-xl bg-[#2a2a2a] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] active:shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)] flex items-center justify-center"
          >
            <Plus className="w-5 h-5 text-[#c0c0c0]" />
          </button>
        </div>

        {/* Search Bar */}
        <div className="p-4 rounded-xl bg-[#242424] shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)]">
          <div className="flex items-center gap-3">
            <Search className="w-5 h-5 text-[#888888]" />
            <input
              type="text"
              placeholder="Search students..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="flex-1 bg-transparent text-[#e8e8e8] placeholder-[#666666] outline-none"
            />
          </div>
        </div>
      </div>

      {/* Student List */}
      <div className="p-6 space-y-3">
        {students.map((student) => (
          <button
            key={student.id}
            onClick={() => setSelectedStudent(student)}
            className="w-full p-5 rounded-2xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] active:shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)] transition-all duration-200 text-left"
          >
            <div className="flex items-center gap-4">
              <div className="w-12 h-12 rounded-full bg-[#1a1a1a] flex items-center justify-center shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)]">
                <span className="text-lg text-[#a0a0a0]">{student.name[0]}</span>
              </div>
              <div className="flex-1">
                <p className="text-sm text-[#e8e8e8] mb-1">{student.name}</p>
                <p className="text-xs text-[#888888]">{student.batch}</p>
              </div>
              <div className="text-right">
                {student.feePending > 0 && (
                  <p className="text-xs text-[#c08080] mb-1">₹{student.feePending}</p>
                )}
                <div className={`px-2 py-1 rounded ${student.feePending > 0 ? 'bg-[#2a1a1a]' : 'bg-[#1a1a1a]'} shadow-[inset_2px_2px_4px_rgba(0,0,0,0.5)]`}>
                  <p className="text-xs text-[#a0a0a0]">Active</p>
                </div>
              </div>
            </div>
          </button>
        ))}
      </div>
    </div>
  );
}
