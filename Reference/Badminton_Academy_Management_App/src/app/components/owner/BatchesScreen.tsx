import { useState } from 'react';
import { Plus, Search, Users, Clock, MapPin, User, Calendar, MoreVertical, Edit, X, Save, XCircle } from 'lucide-react';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from '../ui/dropdown-menu';

export default function BatchesScreen() {
  const [searchQuery, setSearchQuery] = useState('');
  const [showAddForm, setShowAddForm] = useState(false);
  const [selectedBatch, setSelectedBatch] = useState<any>(null);
  const [isEditMode, setIsEditMode] = useState(false);
  const [editedBatch, setEditedBatch] = useState<any>(null);
  const [enrolledStudents, setEnrolledStudents] = useState<string[]>([]);
  const [studentSearchQuery, setStudentSearchQuery] = useState('');

  const batches = [
    { 
      id: 1, 
      name: 'Morning Batch A', 
      capacity: 20, 
      enrolled: 18, 
      time: '6:00 AM - 7:30 AM',
      startTime: '06:00',
      endTime: '07:30',
      days: ['Mon', 'Wed', 'Fri'], 
      coach: 'Rajesh Kumar',
      coachId: '1',
      location: 'Court 1',
      status: 'active'
    },
    { 
      id: 2, 
      name: 'Evening Batch B', 
      capacity: 25, 
      enrolled: 22, 
      time: '5:00 PM - 6:30 PM',
      startTime: '17:00',
      endTime: '18:30',
      days: ['Tue', 'Thu', 'Sat'], 
      coach: 'Priya Singh',
      coachId: '2',
      location: 'Court 2',
      status: 'active'
    },
    { 
      id: 3, 
      name: 'Weekend Batch', 
      capacity: 15, 
      enrolled: 12, 
      time: '8:00 AM - 9:30 AM',
      startTime: '08:00',
      endTime: '09:30',
      days: ['Sat', 'Sun'], 
      coach: 'Amit Sharma',
      coachId: '3',
      location: 'Court 1',
      status: 'active'
    },
  ];

  const coaches = [
    { id: '1', name: 'Rajesh Kumar' },
    { id: '2', name: 'Priya Singh' },
    { id: '3', name: 'Amit Sharma' },
  ];

  const allAvailableStudents = [
    'Arjun Mehta', 'Kavya Sharma', 'Rohan Patel', 'Priya Singh',
    'Aryan Verma', 'Sneha Reddy', 'Vikram Nair', 'Ananya Das',
    'Rahul Joshi', 'Meera Iyer', 'Aditya Rao', 'Divya Menon'
  ];

  const handleEditClick = () => {
    if (selectedBatch) {
      const initialStudents = ['Arjun Mehta', 'Kavya Sharma', 'Rohan Patel', 'Priya Singh'];
      setEnrolledStudents([...initialStudents]);
      setEditedBatch({
        ...selectedBatch,
        startTime: selectedBatch.startTime || '06:00',
        endTime: selectedBatch.endTime || '07:30',
      });
      setIsEditMode(true);
    }
  };

  const handleCancelEdit = () => {
    setIsEditMode(false);
    setEditedBatch(null);
    setEnrolledStudents([]);
    setStudentSearchQuery('');
  };

  const handleSaveEdit = () => {
    if (editedBatch) {
      // Update the batch in the batches array (in real app, this would be an API call)
      const updatedBatch = {
        ...editedBatch,
        enrolled: enrolledStudents.length,
        time: `${formatTime(editedBatch.startTime)} - ${formatTime(editedBatch.endTime)}`,
      };
      setSelectedBatch(updatedBatch);
      setIsEditMode(false);
      setEditedBatch(null);
      setStudentSearchQuery('');
    }
  };

  const formatTime = (time: string) => {
    const [hours, minutes] = time.split(':');
    const hour = parseInt(hours);
    const ampm = hour >= 12 ? 'PM' : 'AM';
    const displayHour = hour % 12 || 12;
    return `${displayHour}:${minutes} ${ampm}`;
  };

  const handleRemoveStudent = (studentName: string) => {
    setEnrolledStudents(enrolledStudents.filter(s => s !== studentName));
  };

  const handleAddStudent = (studentName: string) => {
    if (!enrolledStudents.includes(studentName) && enrolledStudents.length < (editedBatch?.capacity || 20)) {
      setEnrolledStudents([...enrolledStudents, studentName]);
      setStudentSearchQuery('');
    }
  };

  const availableStudentsToAdd = allAvailableStudents.filter(
    student => !enrolledStudents.includes(student) && 
    student.toLowerCase().includes(studentSearchQuery.toLowerCase())
  );

  if (selectedBatch) {
    const displayBatch = isEditMode ? editedBatch : selectedBatch;
    const displayStudents = isEditMode ? enrolledStudents : ['Arjun Mehta', 'Kavya Sharma', 'Rohan Patel', 'Priya Singh'];

    return (
      <div className="min-h-screen pt-6">
        {/* Header */}
        <div className="px-6 mb-6">
          <button
            onClick={() => {
              if (isEditMode) {
                handleCancelEdit();
              } else {
                setSelectedBatch(null);
              }
            }}
            className="mb-4 text-sm text-[#888888]"
          >
            ← Back
          </button>
          <div className="flex items-center justify-between">
            <h1 className="text-2xl text-[#e8e8e8]">{displayBatch?.name || selectedBatch.name}</h1>
            {!isEditMode && (
              <DropdownMenu>
                <DropdownMenuTrigger asChild>
                  <button className="w-10 h-10 rounded-xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] active:shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)] flex items-center justify-center">
                    <MoreVertical className="w-5 h-5 text-[#a0a0a0]" />
                  </button>
                </DropdownMenuTrigger>
                <DropdownMenuContent align="end" className="bg-[#242424] border-[#2a2a2a] text-[#e8e8e8] min-w-[150px]">
                  <DropdownMenuItem 
                    onClick={handleEditClick}
                    className="cursor-pointer focus:bg-[#2a2a2a] focus:text-[#e8e8e8]"
                  >
                    <Edit className="w-4 h-4 mr-2" />
                    Edit
                  </DropdownMenuItem>
                </DropdownMenuContent>
              </DropdownMenu>
            )}
          </div>
        </div>

        <div className="px-6 space-y-4">
          {/* Batch Info */}
          <div className="p-6 rounded-2xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)]">
            <div className="space-y-4">
              {isEditMode ? (
                <>
                  {/* Batch Name */}
                  <div>
                    <p className="text-xs text-[#888888] mb-2">Batch Name</p>
                    <input
                      type="text"
                      value={editedBatch?.name || ''}
                      onChange={(e) => setEditedBatch({ ...editedBatch, name: e.target.value })}
                      className="w-full p-3 rounded-lg bg-[#1a1a1a] text-[#e8e8e8] placeholder-[#666666] outline-none border border-[#2a2a2a]"
                      placeholder="Batch Name"
                    />
                  </div>

                  {/* Schedule */}
                  <div className="flex items-center gap-3">
                    <Clock className="w-5 h-5 text-[#888888]" />
                    <div className="flex-1">
                      <p className="text-xs text-[#888888] mb-2">Schedule</p>
                      <div className="flex gap-2">
                        <input
                          type="time"
                          value={editedBatch?.startTime || ''}
                          onChange={(e) => setEditedBatch({ ...editedBatch, startTime: e.target.value })}
                          className="flex-1 p-2 rounded-lg bg-[#1a1a1a] text-[#e8e8e8] outline-none border border-[#2a2a2a]"
                        />
                        <span className="text-[#888888] self-end pb-2">to</span>
                        <input
                          type="time"
                          value={editedBatch?.endTime || ''}
                          onChange={(e) => setEditedBatch({ ...editedBatch, endTime: e.target.value })}
                          className="flex-1 p-2 rounded-lg bg-[#1a1a1a] text-[#e8e8e8] outline-none border border-[#2a2a2a]"
                        />
                      </div>
                    </div>
                  </div>

                  {/* Days */}
                  <div className="flex items-center gap-3">
                    <Calendar className="w-5 h-5 text-[#888888]" />
                    <div className="flex-1">
                      <p className="text-xs text-[#888888] mb-2">Days</p>
                      <div className="flex gap-2 flex-wrap">
                        {['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].map((day) => (
                          <button
                            key={day}
                            onClick={() => {
                              const currentDays = editedBatch?.days || [];
                              const newDays = currentDays.includes(day)
                                ? currentDays.filter((d: string) => d !== day)
                                : [...currentDays, day];
                              setEditedBatch({ ...editedBatch, days: newDays });
                            }}
                            className={`px-3 py-1.5 rounded-lg text-xs transition-all ${
                              editedBatch?.days?.includes(day)
                                ? 'bg-[#2a2a2a] text-[#e8e8e8] shadow-[inset_2px_2px_4px_rgba(0,0,0,0.5)]'
                                : 'bg-[#1a1a1a] text-[#888888] hover:bg-[#2a2a2a]'
                            }`}
                          >
                            {day}
                          </button>
                        ))}
                      </div>
                    </div>
                  </div>

                  {/* Coach */}
                  <div className="flex items-center gap-3">
                    <User className="w-5 h-5 text-[#888888]" />
                    <div className="flex-1">
                      <p className="text-xs text-[#888888] mb-2">Coach</p>
                      <select
                        value={editedBatch?.coachId || ''}
                        onChange={(e) => {
                          const selectedCoach = coaches.find(c => c.id === e.target.value);
                          setEditedBatch({ 
                            ...editedBatch, 
                            coachId: e.target.value,
                            coach: selectedCoach?.name || ''
                          });
                        }}
                        className="w-full p-2 rounded-lg bg-[#1a1a1a] text-[#e8e8e8] outline-none border border-[#2a2a2a]"
                      >
                        {coaches.map((coach) => (
                          <option key={coach.id} value={coach.id}>
                            {coach.name}
                          </option>
                        ))}
                      </select>
                    </div>
                  </div>

                  {/* Location */}
                  <div className="flex items-center gap-3">
                    <MapPin className="w-5 h-5 text-[#888888]" />
                    <div className="flex-1">
                      <p className="text-xs text-[#888888] mb-2">Location</p>
                      <input
                        type="text"
                        value={editedBatch?.location || ''}
                        onChange={(e) => setEditedBatch({ ...editedBatch, location: e.target.value })}
                        className="w-full p-2 rounded-lg bg-[#1a1a1a] text-[#e8e8e8] placeholder-[#666666] outline-none border border-[#2a2a2a]"
                        placeholder="Location"
                      />
                    </div>
                  </div>

                  {/* Capacity */}
                  <div className="flex items-center gap-3">
                    <Users className="w-5 h-5 text-[#888888]" />
                    <div className="flex-1">
                      <p className="text-xs text-[#888888] mb-2">Capacity</p>
                      <input
                        type="number"
                        value={editedBatch?.capacity || ''}
                        onChange={(e) => setEditedBatch({ ...editedBatch, capacity: parseInt(e.target.value) || 0 })}
                        className="w-full p-2 rounded-lg bg-[#1a1a1a] text-[#e8e8e8] placeholder-[#666666] outline-none border border-[#2a2a2a]"
                        placeholder="Capacity"
                        min="1"
                      />
                      <div className="flex items-center gap-2 mt-2">
                        <div className="flex-1 h-2 rounded-full bg-[#1a1a1a] shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5)]">
                          <div 
                            className="h-full rounded-full bg-[#505050]"
                            style={{ width: `${((enrolledStudents.length) / (editedBatch?.capacity || 1)) * 100}%` }}
                          />
                        </div>
                        <span className="text-sm text-[#a0a0a0]">{enrolledStudents.length}/{editedBatch?.capacity || 0}</span>
                      </div>
                    </div>
                  </div>
                </>
              ) : (
                <>
                  <div className="flex items-center gap-3">
                    <Clock className="w-5 h-5 text-[#888888]" />
                    <div>
                      <p className="text-xs text-[#888888]">Schedule</p>
                      <p className="text-sm text-[#e8e8e8]">{selectedBatch.time}</p>
                    </div>
                  </div>

                  <div className="flex items-center gap-3">
                    <Calendar className="w-5 h-5 text-[#888888]" />
                    <div>
                      <p className="text-xs text-[#888888]">Days</p>
                      <p className="text-sm text-[#e8e8e8]">{selectedBatch.days.join(', ')}</p>
                    </div>
                  </div>

                  <div className="flex items-center gap-3">
                    <User className="w-5 h-5 text-[#888888]" />
                    <div>
                      <p className="text-xs text-[#888888]">Coach</p>
                      <p className="text-sm text-[#e8e8e8]">{selectedBatch.coach}</p>
                    </div>
                  </div>

                  <div className="flex items-center gap-3">
                    <MapPin className="w-5 h-5 text-[#888888]" />
                    <div>
                      <p className="text-xs text-[#888888]">Location</p>
                      <p className="text-sm text-[#e8e8e8]">{selectedBatch.location}</p>
                    </div>
                  </div>

                  <div className="flex items-center gap-3">
                    <Users className="w-5 h-5 text-[#888888]" />
                    <div className="flex-1">
                      <p className="text-xs text-[#888888] mb-2">Capacity</p>
                      <div className="flex items-center gap-2">
                        <div className="flex-1 h-2 rounded-full bg-[#1a1a1a] shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5)]">
                          <div 
                            className="h-full rounded-full bg-[#505050]"
                            style={{ width: `${(selectedBatch.enrolled / selectedBatch.capacity) * 100}%` }}
                          />
                        </div>
                        <span className="text-sm text-[#a0a0a0]">{selectedBatch.enrolled}/{selectedBatch.capacity}</span>
                      </div>
                    </div>
                  </div>
                </>
              )}
            </div>
          </div>

          {/* Enrolled Students */}
          <div>
            <h3 className="text-lg text-[#e8e8e8] mb-3">Enrolled Students</h3>
            <div className="space-y-2">
              {displayStudents.length > 0 ? (
                displayStudents.map((student, i) => (
                  <div
                    key={i}
                    className="p-4 rounded-xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)]"
                  >
                    <div className="flex items-center justify-between">
                      <div className="flex items-center gap-3">
                        <div className="w-10 h-10 rounded-full bg-[#1a1a1a] flex items-center justify-center shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)]">
                          <span className="text-sm text-[#a0a0a0]">{student[0]}</span>
                        </div>
                        <p className="text-sm text-[#e8e8e8]">{student}</p>
                      </div>
                      {isEditMode && (
                        <button
                          onClick={() => handleRemoveStudent(student)}
                          className="w-8 h-8 rounded-lg bg-[#1a1a1a] flex items-center justify-center hover:bg-[#2a2a2a] transition-all"
                        >
                          <X className="w-4 h-4 text-[#888888]" />
                        </button>
                      )}
                    </div>
                  </div>
                ))
              ) : (
                <div className="p-4 rounded-xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)]">
                  <p className="text-sm text-[#888888] text-center">No students enrolled</p>
                </div>
              )}
            </div>
          </div>

          {/* Add Students Section (Edit Mode Only) */}
          {isEditMode && (
            <div>
              <h3 className="text-lg text-[#e8e8e8] mb-3">Add Students</h3>
              <div className="p-4 rounded-xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] mb-3">
                <div className="flex items-center gap-3 mb-3">
                  <Search className="w-5 h-5 text-[#888888]" />
                  <input
                    type="text"
                    placeholder="Search students..."
                    value={studentSearchQuery}
                    onChange={(e) => setStudentSearchQuery(e.target.value)}
                    className="flex-1 bg-transparent text-[#e8e8e8] placeholder-[#666666] outline-none"
                  />
                </div>
                {enrolledStudents.length >= (editedBatch?.capacity || 20) && (
                  <p className="text-xs text-[#888888] mb-2">Capacity reached</p>
                )}
              </div>
              <div className="space-y-2 max-h-48 overflow-y-auto">
                {availableStudentsToAdd.length > 0 ? (
                  availableStudentsToAdd.map((student, i) => (
                    <div
                      key={i}
                      className="p-4 rounded-xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)]"
                    >
                      <div className="flex items-center justify-between">
                        <div className="flex items-center gap-3">
                          <div className="w-10 h-10 rounded-full bg-[#1a1a1a] flex items-center justify-center shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)]">
                            <span className="text-sm text-[#a0a0a0]">{student[0]}</span>
                          </div>
                          <p className="text-sm text-[#e8e8e8]">{student}</p>
                        </div>
                        <button
                          onClick={() => handleAddStudent(student)}
                          disabled={enrolledStudents.length >= (editedBatch?.capacity || 20)}
                          className="px-4 py-2 rounded-lg bg-[#2a2a2a] text-[#e8e8e8] text-xs hover:bg-[#3a3a3a] transition-all disabled:opacity-50 disabled:cursor-not-allowed"
                        >
                          Add
                        </button>
                      </div>
                    </div>
                  ))
                ) : (
                  <div className="p-4 rounded-xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)]">
                    <p className="text-sm text-[#888888] text-center">
                      {studentSearchQuery ? 'No students found' : 'No available students'}
                    </p>
                  </div>
                )}
              </div>
            </div>
          )}

          {/* Actions */}
          {isEditMode && (
            <div className="space-y-3 pb-6">
              <button
                onClick={handleSaveEdit}
                className="w-full p-4 rounded-xl bg-[#2a2a2a] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] active:shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)] transition-all duration-200 flex items-center justify-center gap-2"
              >
                <Save className="w-5 h-5 text-[#e8e8e8]" />
                <span className="text-[#e8e8e8]">Save Changes</span>
              </button>
              <button
                onClick={handleCancelEdit}
                className="w-full p-4 rounded-xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] active:shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)] transition-all duration-200 flex items-center justify-center gap-2"
              >
                <XCircle className="w-5 h-5 text-[#888888]" />
                <span className="text-[#888888]">Cancel</span>
              </button>
            </div>
          )}
        </div>
      </div>
    );
  }

  if (showAddForm) {
    return (
      <div className="min-h-screen pt-6">
        <div className="px-6 mb-6">
          <button
            onClick={() => setShowAddForm(false)}
            className="mb-4 text-sm text-[#888888]"
          >
            ← Back
          </button>
          <h1 className="text-2xl text-[#e8e8e8]">Create New Batch</h1>
        </div>

        <div className="px-6 space-y-4 pb-6">
          <div className="p-6 rounded-2xl bg-[#242424] shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)]">
            <input
              type="text"
              placeholder="Batch Name *"
              className="w-full bg-transparent text-[#e8e8e8] placeholder-[#666666] outline-none"
            />
          </div>

          <div className="p-6 rounded-2xl bg-[#242424] shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)]">
            <input
              type="number"
              placeholder="Capacity *"
              className="w-full bg-transparent text-[#e8e8e8] placeholder-[#666666] outline-none"
            />
          </div>

          <div className="p-6 rounded-2xl bg-[#242424] shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)]">
            <input
              type="time"
              placeholder="Start Time *"
              className="w-full bg-transparent text-[#e8e8e8] placeholder-[#666666] outline-none"
            />
          </div>

          <div className="p-6 rounded-2xl bg-[#242424] shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)]">
            <input
              type="time"
              placeholder="End Time *"
              className="w-full bg-transparent text-[#e8e8e8] placeholder-[#666666] outline-none"
            />
          </div>

          <div className="p-5 rounded-2xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)]">
            <p className="text-sm text-[#888888] mb-3">Operating Days *</p>
            <div className="flex gap-2">
              {['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].map((day) => (
                <button
                  key={day}
                  className="flex-1 p-2 rounded-lg bg-[#1a1a1a] shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)] text-xs text-[#888888] hover:bg-[#2a2a2a] transition-all"
                >
                  {day}
                </button>
              ))}
            </div>
          </div>

          <div className="p-6 rounded-2xl bg-[#242424] shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)]">
            <select className="w-full bg-transparent text-[#e8e8e8] outline-none">
              <option value="">Assign Coach *</option>
              <option value="1">Rajesh Kumar</option>
              <option value="2">Priya Singh</option>
              <option value="3">Amit Sharma</option>
            </select>
          </div>

          <div className="p-6 rounded-2xl bg-[#242424] shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)]">
            <input
              type="text"
              placeholder="Location *"
              className="w-full bg-transparent text-[#e8e8e8] placeholder-[#666666] outline-none"
            />
          </div>

          <button className="w-full p-4 rounded-xl bg-[#2a2a2a] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] hover:shadow-[4px_4px_8px_rgba(0,0,0,0.5),-4px_-4px_8px_rgba(40,40,40,0.1)] transition-all duration-200 active:shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)]">
            <span className="text-[#e8e8e8]">Create Batch</span>
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen pt-6">
      {/* Header */}
      <div className="px-6 mb-6">
        <div className="flex items-center justify-between mb-4">
          <h1 className="text-2xl text-[#e8e8e8]">Batches</h1>
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
              placeholder="Search batches..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="flex-1 bg-transparent text-[#e8e8e8] placeholder-[#666666] outline-none"
            />
          </div>
        </div>
      </div>

      {/* Batch List */}
      <div className="px-6 space-y-3 pb-6">
        {batches.map((batch) => (
          <button
            key={batch.id}
            onClick={() => setSelectedBatch(batch)}
            className="w-full p-5 rounded-2xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] active:shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)] transition-all duration-200 text-left"
          >
            <div className="flex items-start justify-between mb-3">
              <div>
                <h3 className="text-lg text-[#e8e8e8] mb-1">{batch.name}</h3>
                <p className="text-xs text-[#888888]">{batch.time}</p>
              </div>
              <div className="px-3 py-1 rounded-lg bg-[#1a2a1a] shadow-[inset_2px_2px_4px_rgba(0,0,0,0.5)]">
                <p className="text-xs text-[#80c080]">Active</p>
              </div>
            </div>

            <div className="flex items-center gap-4 text-xs text-[#888888]">
              <span>{batch.days.join(', ')}</span>
              <span>•</span>
              <span>{batch.enrolled}/{batch.capacity} students</span>
            </div>

            <div className="mt-3">
              <div className="w-full h-1 rounded-full bg-[#1a1a1a] shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5)]">
                <div 
                  className="h-full rounded-full bg-[#505050]"
                  style={{ width: `${(batch.enrolled / batch.capacity) * 100}%` }}
                />
              </div>
            </div>
          </button>
        ))}
      </div>
    </div>
  );
}
