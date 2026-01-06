import { useState } from 'react';
import { ArrowLeft, Plus, Search, Phone, Mail, Users, MoreVertical } from 'lucide-react';

interface CoachManagementProps {
  onBack: () => void;
}

export default function CoachManagement({ onBack }: CoachManagementProps) {
  const [searchQuery, setSearchQuery] = useState('');
  const [showAddForm, setShowAddForm] = useState(false);
  const [selectedCoach, setSelectedCoach] = useState<any>(null);

  const coaches = [
    { id: 1, name: 'Rajesh Kumar', phone: '+91 98765 43210', email: 'rajesh@academy.com', specialization: 'Singles', batches: 3, status: 'active' },
    { id: 2, name: 'Priya Singh', phone: '+91 98765 43211', email: 'priya@academy.com', specialization: 'Doubles', batches: 2, status: 'active' },
    { id: 3, name: 'Amit Sharma', phone: '+91 98765 43212', email: 'amit@academy.com', specialization: 'Junior Training', batches: 4, status: 'active' },
    { id: 4, name: 'Sneha Patel', phone: '+91 98765 43213', email: 'sneha@academy.com', specialization: 'Advanced', batches: 2, status: 'active' },
  ];

  if (selectedCoach) {
    return (
      <div className="min-h-screen">
        {/* Header */}
        <div className="sticky top-0 bg-[#1a1a1a] border-b border-[#2a2a2a] px-6 py-4 flex items-center gap-4 shadow-[0_4px_16px_rgba(0,0,0,0.5)]">
          <button
            onClick={() => setSelectedCoach(null)}
            className="w-10 h-10 rounded-xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] active:shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)] flex items-center justify-center"
          >
            <ArrowLeft className="w-5 h-5 text-[#a0a0a0]" />
          </button>
          <h1 className="text-xl text-[#e8e8e8] flex-1">Coach Details</h1>
          <button className="w-10 h-10 rounded-xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] active:shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)] flex items-center justify-center">
            <MoreVertical className="w-5 h-5 text-[#a0a0a0]" />
          </button>
        </div>

        <div className="p-6">
          {/* Profile Section */}
          <div className="p-6 rounded-2xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] mb-6">
            <div className="flex items-center gap-4 mb-6">
              <div className="w-16 h-16 rounded-full bg-[#1a1a1a] flex items-center justify-center shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)]">
                <span className="text-2xl text-[#a0a0a0]">{selectedCoach.name[0]}</span>
              </div>
              <div className="flex-1">
                <h2 className="text-xl text-[#e8e8e8] mb-1">{selectedCoach.name}</h2>
                <p className="text-sm text-[#888888]">{selectedCoach.specialization}</p>
              </div>
            </div>

            <div className="space-y-3">
              <div className="flex items-center gap-3">
                <Phone className="w-4 h-4 text-[#888888]" />
                <span className="text-sm text-[#a0a0a0]">{selectedCoach.phone}</span>
              </div>
              <div className="flex items-center gap-3">
                <Mail className="w-4 h-4 text-[#888888]" />
                <span className="text-sm text-[#a0a0a0]">{selectedCoach.email}</span>
              </div>
              <div className="flex items-center gap-3">
                <Users className="w-4 h-4 text-[#888888]" />
                <span className="text-sm text-[#a0a0a0]">{selectedCoach.batches} Batches Assigned</span>
              </div>
            </div>
          </div>

          {/* Assigned Batches */}
          <div className="mb-6">
            <h3 className="text-lg text-[#e8e8e8] mb-4">Assigned Batches</h3>
            <div className="space-y-3">
              {['Morning Batch A', 'Evening Batch B', 'Weekend Batch'].map((batch, i) => (
                <div
                  key={i}
                  className="p-4 rounded-xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)]"
                >
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="text-sm text-[#e8e8e8] mb-1">{batch}</p>
                      <p className="text-xs text-[#888888]">18 students</p>
                    </div>
                    <div className="px-3 py-1 rounded-lg bg-[#1a1a1a] shadow-[inset_2px_2px_4px_rgba(0,0,0,0.5)]">
                      <p className="text-xs text-[#a0a0a0]">Active</p>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Action Buttons */}
          <div className="space-y-3">
            <button className="w-full p-4 rounded-xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] active:shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)] transition-all duration-200">
              <span className="text-[#e8e8e8]">Edit Details</span>
            </button>
            <button className="w-full p-4 rounded-xl bg-[#1a1a1a] border border-[#2a2a2a] active:shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)] transition-all duration-200">
              <span className="text-[#888888]">Deactivate Coach</span>
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
          <h1 className="text-xl text-[#e8e8e8]">Add New Coach</h1>
        </div>

        <div className="p-6 space-y-4">
          <div className="p-6 rounded-2xl bg-[#242424] shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)]">
            <input
              type="text"
              placeholder="Coach Name *"
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
              placeholder="Email Address *"
              className="w-full bg-transparent text-[#e8e8e8] placeholder-[#666666] outline-none"
            />
          </div>

          <div className="p-6 rounded-2xl bg-[#242424] shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)]">
            <input
              type="text"
              placeholder="Specialization"
              className="w-full bg-transparent text-[#e8e8e8] placeholder-[#666666] outline-none"
            />
          </div>

          <button className="w-full p-4 rounded-xl bg-[#2a2a2a] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] hover:shadow-[4px_4px_8px_rgba(0,0,0,0.5),-4px_-4px_8px_rgba(40,40,40,0.1)] transition-all duration-200 active:shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)]">
            <span className="text-[#e8e8e8]">Add Coach</span>
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
          <h1 className="text-xl text-[#e8e8e8] flex-1">Coaches</h1>
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
              placeholder="Search coaches..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="flex-1 bg-transparent text-[#e8e8e8] placeholder-[#666666] outline-none"
            />
          </div>
        </div>
      </div>

      {/* Coach List */}
      <div className="p-6 space-y-3">
        {coaches.map((coach) => (
          <button
            key={coach.id}
            onClick={() => setSelectedCoach(coach)}
            className="w-full p-5 rounded-2xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] active:shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)] transition-all duration-200 text-left"
          >
            <div className="flex items-center gap-4">
              <div className="w-12 h-12 rounded-full bg-[#1a1a1a] flex items-center justify-center shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)]">
                <span className="text-lg text-[#a0a0a0]">{coach.name[0]}</span>
              </div>
              <div className="flex-1">
                <p className="text-sm text-[#e8e8e8] mb-1">{coach.name}</p>
                <p className="text-xs text-[#888888]">{coach.specialization}</p>
              </div>
              <div className="text-right">
                <p className="text-xs text-[#a0a0a0] mb-1">{coach.batches} batches</p>
                <div className="px-2 py-1 rounded bg-[#1a1a1a] shadow-[inset_2px_2px_4px_rgba(0,0,0,0.5)]">
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
