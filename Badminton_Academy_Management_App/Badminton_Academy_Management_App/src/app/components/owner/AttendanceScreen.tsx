import { useState } from 'react';
import { Calendar, ChevronRight, Check, X, History, Users, UserCheck } from 'lucide-react';

type AttendanceType = 'students' | 'coaches';

export default function AttendanceScreen() {
  const [attendanceType, setAttendanceType] = useState<AttendanceType>('students');
  const [selectedBatch, setSelectedBatch] = useState<any>(null);
  const [selectedCoach, setSelectedCoach] = useState<any>(null);
  const [selectedDate, setSelectedDate] = useState(new Date().toISOString().split('T')[0]);
  const [attendance, setAttendance] = useState<Record<number, 'present' | 'absent'>>({});
  const [remarks, setRemarks] = useState<Record<number, string>>({});
  const [showHistory, setShowHistory] = useState(false);
  
  // Coach attendance state
  const [coachAttendance, setCoachAttendance] = useState<Record<string, 'present' | 'absent'>>({});
  const [coachRemarks, setCoachRemarks] = useState<Record<string, string>>({});
  const [showCoachHistory, setShowCoachHistory] = useState(false);

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

  const coaches = [
    { id: 1, name: 'Rajesh Kumar', specialization: 'Singles', batches: 3, status: 'active' },
    { id: 2, name: 'Priya Singh', specialization: 'Doubles', batches: 2, status: 'active' },
    { id: 3, name: 'Amit Sharma', specialization: 'Junior Training', batches: 4, status: 'active' },
    { id: 4, name: 'Sneha Patel', specialization: 'Advanced', batches: 2, status: 'active' },
  ];

  const toggleAttendance = (studentId: number) => {
    setAttendance(prev => ({
      ...prev,
      [studentId]: prev[studentId] === 'present' ? 'absent' : 'present'
    }));
  };

  // Get coach attendance key for the selected date
  const getCoachAttendanceKey = (coachId: number, date: string) => `${coachId}-${date}`;

  // Helper function to get dynamic subtitle
  const getSubtitle = () => {
    if (showCoachHistory) return 'Coaches Attendance History';
    if (showHistory && selectedBatch) return `${selectedBatch.name} - Attendance History`;
    if (attendanceType === 'coaches') return 'Mark attendance for all coaches';
    if (selectedBatch) return `${selectedBatch.name} - ${selectedBatch.time}`;
    return 'Select a batch to mark attendance';
  };

  // Calculate summary for coaches
  const coachPresentCount = coaches.filter(coach => {
    const key = getCoachAttendanceKey(coach.id, selectedDate);
    return coachAttendance[key] === 'present';
  }).length;

  const coachAbsentCount = coaches.filter(coach => {
    const key = getCoachAttendanceKey(coach.id, selectedDate);
    return coachAttendance[key] === 'absent';
  }).length;

  const coachTotalCount = coaches.length;
  const coachPercentage = coachTotalCount > 0 ? Math.round((coachPresentCount / coachTotalCount) * 100) : 0;

  // Calculate summary for students
  const studentPresentCount = Object.values(attendance).filter(a => a === 'present').length;
  const studentTotalCount = students.length;
  const studentPercentage = studentTotalCount > 0 ? Math.round((studentPresentCount / studentTotalCount) * 100) : 0;

  // History data
  const coachHistoryData = [
    { date: '2026-01-09', present: 3, absent: 1, percentage: 75 },
    { date: '2026-01-08', present: 4, absent: 0, percentage: 100 },
    { date: '2026-01-07', present: 3, absent: 1, percentage: 75 },
    { date: '2026-01-06', present: 4, absent: 0, percentage: 100 },
    { date: '2026-01-05', present: 4, absent: 0, percentage: 100 },
  ];

  const studentHistoryData = [
    { date: '2026-01-05', present: 17, absent: 1, percentage: 94 },
    { date: '2026-01-03', present: 16, absent: 2, percentage: 89 },
    { date: '2026-01-01', present: 18, absent: 0, percentage: 100 },
  ];

  return (
    <div className="min-h-screen pt-6">
      {/* Header - Always Visible */}
      <div className="px-6 mb-6">
        <h1 className="text-2xl text-[#e8e8e8] mb-4">Attendance</h1>
        
        {/* Type Selector - Always Visible */}
        <div className="flex gap-3 mb-6">
          <button
            onClick={() => {
              setAttendanceType('students');
              setSelectedBatch(null);
              setShowHistory(false);
              setShowCoachHistory(false);
            }}
            className={`flex-1 p-4 rounded-xl transition-all duration-200 ${
              attendanceType === 'students'
                ? 'bg-[#242424] shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)] border-2 border-[#505050]'
                : 'bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] border-2 border-transparent'
            }`}
          >
            <div className="flex items-center justify-center gap-2">
              <Users className={`w-5 h-5 ${attendanceType === 'students' ? 'text-[#e8e8e8]' : 'text-[#888888]'}`} />
              <span className={`font-medium ${attendanceType === 'students' ? 'text-[#e8e8e8]' : 'text-[#888888]'}`}>
                Students
              </span>
            </div>
          </button>
          <button
            onClick={() => {
              setAttendanceType('coaches');
              setSelectedBatch(null);
              setShowHistory(false);
              setShowCoachHistory(false);
            }}
            className={`flex-1 p-4 rounded-xl transition-all duration-200 ${
              attendanceType === 'coaches'
                ? 'bg-[#242424] shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)] border-2 border-[#505050]'
                : 'bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] border-2 border-transparent'
            }`}
          >
            <div className="flex items-center justify-center gap-2">
              <UserCheck className={`w-5 h-5 ${attendanceType === 'coaches' ? 'text-[#e8e8e8]' : 'text-[#888888]'}`} />
              <span className={`font-medium ${attendanceType === 'coaches' ? 'text-[#e8e8e8]' : 'text-[#888888]'}`}>
                Coaches
              </span>
            </div>
          </button>
        </div>

        {/* Dynamic Subtitle */}
        <div className="flex items-center justify-between">
          <p className="text-sm text-[#888888]">{getSubtitle()}</p>
          {/* Action buttons for non-history views */}
          {!showCoachHistory && !showHistory && attendanceType === 'coaches' && (
            <button
              onClick={() => setShowCoachHistory(true)}
              className="w-10 h-10 rounded-xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] active:shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)] flex items-center justify-center"
            >
              <History className="w-5 h-5 text-[#a0a0a0]" />
            </button>
          )}
          {!showCoachHistory && !showHistory && selectedBatch && (
            <button
              onClick={() => setShowHistory(true)}
              className="w-10 h-10 rounded-xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] active:shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)] flex items-center justify-center"
            >
              <History className="w-5 h-5 text-[#a0a0a0]" />
            </button>
          )}
        </div>
      </div>

      {/* Content - Conditional Rendering */}
      {showCoachHistory ? (
        // Coach History View
        <div className="px-6 space-y-3 pb-6">
          <button
            onClick={() => setShowCoachHistory(false)}
            className="mb-4 text-sm text-[#888888]"
          >
            ← Back
          </button>
          {coachHistoryData.map((record, i) => (
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
      ) : showHistory && selectedBatch ? (
        // Student History View
        <div className="px-6 space-y-3 pb-6">
          <button
            onClick={() => setShowHistory(false)}
            className="mb-4 text-sm text-[#888888]"
          >
            ← Back
          </button>
          {studentHistoryData.map((record, i) => (
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
      ) : attendanceType === 'coaches' ? (
        // Coaches Attendance Marking View
        <div>
          {/* Date Selector */}
          <div className="px-6 mb-6">
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
                <span className="text-2xl text-[#e8e8e8]">{coachPercentage}%</span>
              </div>
              <div className="flex items-center gap-4 text-sm text-[#888888] mb-3">
                <span className="text-[#80c080]">{coachPresentCount} Present</span>
                <span className="text-[#c08080]">{coachAbsentCount} Absent</span>
              </div>
              <div className="w-full h-2 rounded-full bg-[#1a1a1a] shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5)]">
                <div 
                  className="h-full rounded-full bg-[#505050]"
                  style={{ width: `${coachPercentage}%` }}
                />
              </div>
            </div>
          </div>

          {/* Coach List */}
          <div className="px-6 space-y-3 pb-6">
            <h2 className="text-lg text-[#e8e8e8] mb-3">Mark Attendance</h2>
            {coaches.map((coach) => {
              const coachKey = getCoachAttendanceKey(coach.id, selectedDate);
              const coachStatus = coachAttendance[coachKey];

              return (
                <div
                  key={coach.id}
                  className="p-5 rounded-2xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)]"
                >
                  <div className="flex items-center gap-4 mb-3">
                    <div className="w-10 h-10 rounded-full bg-[#1a1a1a] flex items-center justify-center shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)]">
                      <span className="text-sm text-[#a0a0a0]">{coach.name[0]}</span>
                    </div>
                    <div className="flex-1">
                      <p className="text-sm text-[#e8e8e8]">{coach.name}</p>
                    </div>
                    <div className="flex gap-2">
                      <button
                        onClick={() => {
                          const key = getCoachAttendanceKey(coach.id, selectedDate);
                          setCoachAttendance(prev => ({ ...prev, [key]: 'present' }));
                        }}
                        className={`px-4 py-2 rounded-xl transition-all duration-200 ${
                          coachStatus === 'present'
                            ? 'bg-[#1a2a1a] shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)] text-[#80c080]'
                            : 'bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] text-[#888888]'
                        }`}
                      >
                        <Check className="w-4 h-4" />
                      </button>
                      <button
                        onClick={() => {
                          const key = getCoachAttendanceKey(coach.id, selectedDate);
                          setCoachAttendance(prev => ({ ...prev, [key]: 'absent' }));
                        }}
                        className={`px-4 py-2 rounded-xl transition-all duration-200 ${
                          coachStatus === 'absent'
                            ? 'bg-[#2a1a1a] shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)] text-[#c08080]'
                            : 'bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] text-[#888888]'
                        }`}
                      >
                        <X className="w-4 h-4" />
                      </button>
                    </div>
                  </div>

                  {coachStatus === 'absent' && (
                    <div className="p-3 rounded-xl bg-[#1a1a1a] shadow-[inset_2px_2px_4px_rgba(0,0,0,0.5)]">
                      <input
                        type="text"
                        placeholder="Add remarks (optional)"
                        value={coachRemarks[coachKey] || ''}
                        onChange={(e) => {
                          const key = getCoachAttendanceKey(coach.id, selectedDate);
                          setCoachRemarks(prev => ({ ...prev, [key]: e.target.value }));
                        }}
                        className="w-full bg-transparent text-sm text-[#e8e8e8] placeholder-[#666666] outline-none"
                      />
                    </div>
                  )}
                </div>
              );
            })}

            <button className="w-full p-4 rounded-xl bg-[#2a2a2a] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] hover:shadow-[4px_4px_8px_rgba(0,0,0,0.5),-4px_-4px_8px_rgba(40,40,40,0.1)] transition-all duration-200 active:shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)] mt-6">
              <span className="text-[#e8e8e8]">Save Attendance</span>
            </button>
          </div>
        </div>
      ) : selectedBatch ? (
        // Student Batch Attendance Marking View
        <div>
          <div className="px-6 mb-6">
            <button
              onClick={() => setSelectedBatch(null)}
              className="mb-4 text-sm text-[#888888]"
            >
              ← Back
            </button>

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
                <span className="text-2xl text-[#e8e8e8]">{studentPercentage}%</span>
              </div>
              <div className="flex items-center gap-4 text-sm text-[#888888] mb-3">
                <span className="text-[#80c080]">{studentPresentCount} Present</span>
                <span className="text-[#c08080]">{studentTotalCount - studentPresentCount} Absent</span>
              </div>
              <div className="w-full h-2 rounded-full bg-[#1a1a1a] shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5)]">
                <div 
                  className="h-full rounded-full bg-[#505050]"
                  style={{ width: `${studentPercentage}%` }}
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
      ) : (
        // Batch List View (Students mode, no batch selected)
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
      )}
    </div>
  );
}
