import { useState } from 'react';
import { Plus, Search, Users, Clock, MapPin, User, Calendar, MoreVertical } from 'lucide-react';

export default function BatchesScreen() {
  const [searchQuery, setSearchQuery] = useState('');
  const [showAddForm, setShowAddForm] = useState(false);
  const [selectedBatch, setSelectedBatch] = useState<any>(null);

  const batches = [
    { 
      id: 1, 
      name: 'Morning Batch A', 
      capacity: 20, 
      enrolled: 18, 
      time: '6:00 AM - 7:30 AM', 
      days: ['Mon', 'Wed', 'Fri'], 
      coach: 'Rajesh Kumar',
      location: 'Court 1',
      status: 'active'
    },
    { 
      id: 2, 
      name: 'Evening Batch B', 
      capacity: 25, 
      enrolled: 22, 
      time: '5:00 PM - 6:30 PM', 
      days: ['Tue', 'Thu', 'Sat'], 
      coach: 'Priya Singh',
      location: 'Court 2',
      status: 'active'
    },
    { 
      id: 3, 
      name: 'Weekend Batch', 
      capacity: 15, 
      enrolled: 12, 
      time: '8:00 AM - 9:30 AM', 
      days: ['Sat', 'Sun'], 
      coach: 'Amit Sharma',
      location: 'Court 1',
      status: 'active'
    },
  ];

  if (selectedBatch) {
    return (
      <div className="min-h-screen pt-6">
        {/* Header */}
        <div className="px-6 mb-6">
          <button
            onClick={() => setSelectedBatch(null)}
            className="mb-4 text-sm text-[#888888]"
          >
            ← Back
          </button>
          <div className="flex items-center justify-between">
            <h1 className="text-2xl text-[#e8e8e8]">{selectedBatch.name}</h1>
            <button className="w-10 h-10 rounded-xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] active:shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)] flex items-center justify-center">
              <MoreVertical className="w-5 h-5 text-[#a0a0a0]" />
            </button>
          </div>
        </div>

        <div className="px-6 space-y-4">
          {/* Batch Info */}
          <div className="p-6 rounded-2xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)]">
            <div className="space-y-4">
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
            </div>
          </div>

          {/* Enrolled Students */}
          <div>
            <h3 className="text-lg text-[#e8e8e8] mb-3">Enrolled Students</h3>
            <div className="space-y-2">
              {['Arjun Mehta', 'Kavya Sharma', 'Rohan Patel', 'Priya Singh'].map((student, i) => (
                <div
                  key={i}
                  className="p-4 rounded-xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)]"
                >
                  <div className="flex items-center gap-3">
                    <div className="w-10 h-10 rounded-full bg-[#1a1a1a] flex items-center justify-center shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)]">
                      <span className="text-sm text-[#a0a0a0]">{student[0]}</span>
                    </div>
                    <p className="text-sm text-[#e8e8e8]">{student}</p>
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Actions */}
          <div className="space-y-3 pb-6">
            <button className="w-full p-4 rounded-xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] active:shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)] transition-all duration-200">
              <span className="text-[#e8e8e8]">Edit Batch</span>
            </button>
          </div>
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
