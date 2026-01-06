import { useState } from 'react';
import { ArrowLeft, Plus, Archive, ChevronRight } from 'lucide-react';

interface SessionManagementProps {
  onBack: () => void;
}

export default function SessionManagement({ onBack }: SessionManagementProps) {
  const [showAddForm, setShowAddForm] = useState(false);
  const [selectedSession, setSelectedSession] = useState<any>(null);

  const sessions = [
    { id: 1, name: 'Winter 2026', startDate: '2026-01-01', endDate: '2026-03-31', batches: 12, status: 'active' },
    { id: 2, name: 'Autumn 2025', startDate: '2025-10-01', endDate: '2025-12-31', batches: 10, status: 'archived' },
    { id: 3, name: 'Summer 2025', startDate: '2025-06-01', endDate: '2025-09-30', batches: 8, status: 'archived' },
  ];

  if (selectedSession) {
    return (
      <div className="min-h-screen pt-6">
        <div className="px-6 mb-6">
          <button
            onClick={() => setSelectedSession(null)}
            className="mb-4 text-sm text-[#888888]"
          >
            ← Back
          </button>
          <h1 className="text-2xl text-[#e8e8e8] mb-2">{selectedSession.name}</h1>
          <div className="flex items-center gap-2">
            <div className={`px-3 py-1 rounded-lg ${
              selectedSession.status === 'active' ? 'bg-[#1a2a1a]' : 'bg-[#2a2a1a]'
            } shadow-[inset_2px_2px_4px_rgba(0,0,0,0.5)]`}>
              <p className={`text-xs ${
                selectedSession.status === 'active' ? 'text-[#80c080]' : 'text-[#c0c080]'
              }`}>
                {selectedSession.status.charAt(0).toUpperCase() + selectedSession.status.slice(1)}
              </p>
            </div>
          </div>
        </div>

        <div className="px-6 space-y-4 pb-6">
          <div className="p-6 rounded-2xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)]">
            <div className="space-y-4">
              <div>
                <p className="text-xs text-[#888888] mb-1">Start Date</p>
                <p className="text-sm text-[#e8e8e8]">{new Date(selectedSession.startDate).toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric' })}</p>
              </div>
              <div>
                <p className="text-xs text-[#888888] mb-1">End Date</p>
                <p className="text-sm text-[#e8e8e8]">{new Date(selectedSession.endDate).toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric' })}</p>
              </div>
              <div>
                <p className="text-xs text-[#888888] mb-1">Batches</p>
                <p className="text-sm text-[#e8e8e8]">{selectedSession.batches} batches assigned</p>
              </div>
            </div>
          </div>

          {selectedSession.status === 'active' && (
            <button className="w-full p-4 rounded-xl bg-[#2a1a1a] border border-[#3a2a2a] active:shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)] transition-all duration-200">
              <div className="flex items-center justify-center gap-2">
                <Archive className="w-5 h-5 text-[#c08080]" />
                <span className="text-[#c08080]">Archive Session</span>
              </div>
            </button>
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
          <h1 className="text-2xl text-[#e8e8e8]">Create New Session</h1>
        </div>

        <div className="px-6 space-y-4 pb-6">
          <div className="p-6 rounded-2xl bg-[#242424] shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)]">
            <input
              type="text"
              placeholder="Session Name (e.g., Spring 2026) *"
              className="w-full bg-transparent text-[#e8e8e8] placeholder-[#666666] outline-none"
            />
          </div>

          <div className="p-6 rounded-2xl bg-[#242424] shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)]">
            <p className="text-xs text-[#888888] mb-2">Start Date *</p>
            <input
              type="date"
              className="w-full bg-transparent text-[#e8e8e8] outline-none"
            />
          </div>

          <div className="p-6 rounded-2xl bg-[#242424] shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)]">
            <p className="text-xs text-[#888888] mb-2">End Date *</p>
            <input
              type="date"
              className="w-full bg-transparent text-[#e8e8e8] outline-none"
            />
          </div>

          <button className="w-full p-4 rounded-xl bg-[#2a2a2a] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] hover:shadow-[4px_4px_8px_rgba(0,0,0,0.5),-4px_-4px_8px_rgba(40,40,40,0.1)] transition-all duration-200 active:shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)]">
            <span className="text-[#e8e8e8]">Create Session</span>
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen pt-6">
      <div className="px-6 mb-6">
        <button
          onClick={onBack}
          className="mb-4 text-sm text-[#888888]"
        >
          ← Back
        </button>
        <div className="flex items-center justify-between">
          <h1 className="text-2xl text-[#e8e8e8]">Sessions</h1>
          <button
            onClick={() => setShowAddForm(true)}
            className="w-10 h-10 rounded-xl bg-[#2a2a2a] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] active:shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)] flex items-center justify-center"
          >
            <Plus className="w-5 h-5 text-[#c0c0c0]" />
          </button>
        </div>
      </div>

      <div className="px-6 space-y-3 pb-6">
        {sessions.map((session) => (
          <button
            key={session.id}
            onClick={() => setSelectedSession(session)}
            className="w-full p-5 rounded-2xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] active:shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)] transition-all duration-200 text-left"
          >
            <div className="flex items-start justify-between mb-3">
              <div>
                <h3 className="text-lg text-[#e8e8e8] mb-1">{session.name}</h3>
                <p className="text-xs text-[#888888]">
                  {new Date(session.startDate).toLocaleDateString()} - {new Date(session.endDate).toLocaleDateString()}
                </p>
              </div>
              <div className={`px-3 py-1 rounded-lg ${
                session.status === 'active' ? 'bg-[#1a2a1a]' : 'bg-[#2a2a1a]'
              } shadow-[inset_2px_2px_4px_rgba(0,0,0,0.5)]`}>
                <p className={`text-xs ${
                  session.status === 'active' ? 'text-[#80c080]' : 'text-[#c0c080]'
                }`}>
                  {session.status}
                </p>
              </div>
            </div>
            <div className="flex items-center justify-between">
              <span className="text-xs text-[#888888]">{session.batches} batches</span>
              <ChevronRight className="w-4 h-4 text-[#707070]" />
            </div>
          </button>
        ))}
      </div>
    </div>
  );
}
