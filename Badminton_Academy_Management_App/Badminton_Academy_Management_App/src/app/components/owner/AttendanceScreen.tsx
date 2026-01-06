import { useState } from 'react';
import { Calendar, ChevronRight, Check, X, History } from 'lucide-react';

export default function AttendanceScreen() {
  const [selectedBatch, setSelectedBatch] = useState<any>(null);
  const [selectedDate, setSelectedDate] = useState(new Date().toISOString().split('T')[0]);
  const [attendance, setAttendance] = useState<Record<number, 'present' | 'absent'>>({});
  const [remarks, setRemarks] = useState<Record<number, string>>({});
  const [showHistory, setShowHistory] = useState(false);

  const batches = [
    { id: 1, name: 'Morning Batch A', time: '6:00 AM - 7:30 AM' },
    { id: 2, name: 'Evening Batch B', time: '5:00 PM - 6:30 PM' },
    { id: 3, name: 'Weekend Batch', time: '8:00 AM - 9:30 AM' },
  ];

  const students = [
    { id: 1, name: 'Arjun Mehta' },
    { id: 2, name: 'Kavya Sharma' },
    { id: 3, name: 'Rohan Patel' },
    { id: 4, name: 'Priya Singh' },
    { id: 5, name: 'Amit Kumar' },
  ];

  const toggleAttendance = (studentId: number) => {
    setAttendance(prev => ({
      ...prev,
      [studentId]: prev[studentId] === 'present' ? 'absent' : 'present'
    }));
  };

  if (showHistory) {
    const historyData = [
      { date: '2026-01-05', present: 17, absent: 1, percentage: 94 },
      { date: '2026-01-03', present: 16, absent: 2, percentage: 89 },
      { date: '2026-01-01', present: 18, absent: 0, percentage: 100 },
    ];

    return (
      <div className="min-h-screen pt-6">
        <div className="px-6 mb-6">
          <button
            onClick={() => setShowHistory(false)}
            className="mb-4 text-sm text-[#888888]"
          >
            ← Back
          </button>
          <h1 className="text-2xl text-[#e8e8e8] mb-2">Attendance History</h1>
          <p className="text-sm text-[#888888]">{selectedBatch.name}</p>
        </div>

        <div className="px-6 space-y-3 pb-6">
          {historyData.map((record, i) => (
            <div
              key={i}
              className="p-5 rounded-2xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)]"
            >
              <div className="flex items-center justify-between mb-3">
                <p className="text-sm text-[#e8e8e8]">
                  {new Date(record.date).toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric' })}
                </p>
                <div className="px-3 py-1 rounded-lg bg-[#1a2a1a] shadow-[inset_2px_2px_4px_rgba(0,0,0,0.5)]">
                  <p className="text-xs text-[#80c080]">{record.percentage}%</p>
                </div>
              </div>
              <div className="flex items-center gap-4 text-xs text-[#888888]">
                <span className="flex items-center gap-1">
                  <Check className="w-3 h-3" /> {record.present} Present
                </span>
                <span className="flex items-center gap-1">
                  <X className="w-3 h-3" /> {record.absent} Absent
                </span>
              </div>
            </div>
          ))}
        </div>
      </div>
    );
  }

  if (selectedBatch) {
    const presentCount = Object.values(attendance).filter(a => a === 'present').length;
    const totalCount = students.length;
    const percentage = totalCount > 0 ? Math.round((presentCount / totalCount) * 100) : 0;

    return (
      <div className="min-h-screen pt-6">
        <div className="px-6 mb-6">
          <button
            onClick={() => setSelectedBatch(null)}
            className="mb-4 text-sm text-[#888888]"
          >
            ← Back
          </button>
          <div className="flex items-center justify-between mb-4">
            <div>
              <h1 className="text-2xl text-[#e8e8e8] mb-1">{selectedBatch.name}</h1>
              <p className="text-sm text-[#888888]">{selectedBatch.time}</p>
            </div>
            <button
              onClick={() => setShowHistory(true)}
              className="w-10 h-10 rounded-xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] active:shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)] flex items-center justify-center"
            >
              <History className="w-5 h-5 text-[#a0a0a0]" />
            </button>
          </div>

          {/* Date Selector */}
          <div className="p-4 rounded-xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)]">
            <div className="flex items-center gap-3">
              <Calendar className="w-5 h-5 text-[#888888]" />
              <input
                type="date"
                value={selectedDate}
                onChange={(e) => setSelectedDate(e.target.value)}
                className="flex-1 bg-transparent text-[#e8e8e8] outline-none"
              />
            </div>
          </div>
        </div>

        {/* Summary */}
        <div className="px-6 mb-6">
          <div className="p-5 rounded-2xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)]">
            <div className="flex items-center justify-between mb-3">
              <span className="text-sm text-[#888888]">Today's Attendance</span>
              <span className="text-2xl text-[#e8e8e8]">{percentage}%</span>
            </div>
            <div className="flex items-center gap-4 text-sm text-[#888888] mb-3">
              <span className="text-[#80c080]">{presentCount} Present</span>
              <span className="text-[#c08080]">{totalCount - presentCount} Absent</span>
            </div>
            <div className="w-full h-2 rounded-full bg-[#1a1a1a] shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5)]">
              <div 
                className="h-full rounded-full bg-[#505050]"
                style={{ width: `${percentage}%` }}
              />
            </div>
          </div>
        </div>

        {/* Student List */}
        <div className="px-6 space-y-3 pb-6">
          <h2 className="text-lg text-[#e8e8e8] mb-3">Mark Attendance</h2>
          {students.map((student) => (
            <div
              key={student.id}
              className="p-5 rounded-2xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)]"
            >
              <div className="flex items-center gap-4 mb-3">
                <div className="w-10 h-10 rounded-full bg-[#1a1a1a] flex items-center justify-center shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)]">
                  <span className="text-sm text-[#a0a0a0]">{student.name[0]}</span>
                </div>
                <div className="flex-1">
                  <p className="text-sm text-[#e8e8e8]">{student.name}</p>
                </div>
                <div className="flex gap-2">
                  <button
                    onClick={() => {
                      setAttendance(prev => ({ ...prev, [student.id]: 'present' }));
                    }}
                    className={`px-4 py-2 rounded-xl transition-all duration-200 ${
                      attendance[student.id] === 'present'
                        ? 'bg-[#1a2a1a] shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)] text-[#80c080]'
                        : 'bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] text-[#888888]'
                    }`}
                  >
                    <Check className="w-4 h-4" />
                  </button>
                  <button
                    onClick={() => {
                      setAttendance(prev => ({ ...prev, [student.id]: 'absent' }));
                    }}
                    className={`px-4 py-2 rounded-xl transition-all duration-200 ${
                      attendance[student.id] === 'absent'
                        ? 'bg-[#2a1a1a] shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)] text-[#c08080]'
                        : 'bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] text-[#888888]'
                    }`}
                  >
                    <X className="w-4 h-4" />
                  </button>
                </div>
              </div>

              {attendance[student.id] === 'absent' && (
                <div className="p-3 rounded-xl bg-[#1a1a1a] shadow-[inset_2px_2px_4px_rgba(0,0,0,0.5)]">
                  <input
                    type="text"
                    placeholder="Add remarks (optional)"
                    value={remarks[student.id] || ''}
                    onChange={(e) => setRemarks(prev => ({ ...prev, [student.id]: e.target.value }))}
                    className="w-full bg-transparent text-sm text-[#e8e8e8] placeholder-[#666666] outline-none"
                  />
                </div>
              )}
            </div>
          ))}

          <button className="w-full p-4 rounded-xl bg-[#2a2a2a] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] hover:shadow-[4px_4px_8px_rgba(0,0,0,0.5),-4px_-4px_8px_rgba(40,40,40,0.1)] transition-all duration-200 active:shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)] mt-6">
            <span className="text-[#e8e8e8]">Save Attendance</span>
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen pt-6">
      <div className="px-6 mb-6">
        <h1 className="text-2xl text-[#e8e8e8] mb-2">Attendance</h1>
        <p className="text-sm text-[#888888]">Select a batch to mark attendance</p>
      </div>

      <div className="px-6 space-y-3 pb-6">
        {batches.map((batch) => (
          <button
            key={batch.id}
            onClick={() => setSelectedBatch(batch)}
            className="w-full p-5 rounded-2xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] active:shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)] transition-all duration-200 text-left"
          >
            <div className="flex items-center justify-between">
              <div>
                <h3 className="text-lg text-[#e8e8e8] mb-1">{batch.name}</h3>
                <p className="text-xs text-[#888888]">{batch.time}</p>
              </div>
              <ChevronRight className="w-5 h-5 text-[#707070]" />
            </div>
          </button>
        ))}
      </div>
    </div>
  );
}
