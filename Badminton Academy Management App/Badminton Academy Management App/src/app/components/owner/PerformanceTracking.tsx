import { useState } from 'react';
import { ArrowLeft, Plus, Star } from 'lucide-react';

interface PerformanceTrackingProps {
  student: any;
  onBack: () => void;
}

export default function PerformanceTracking({ student, onBack }: PerformanceTrackingProps) {
  const [showAddForm, setShowAddForm] = useState(false);

  const skills = [
    'Forehand',
    'Backhand',
    'Serve',
    'Footwork',
    'Net Play',
    'Smash',
    'Drop Shot',
    'Defense',
  ];

  const performanceHistory = [
    { date: '2026-01-01', skills: { Forehand: 4, Backhand: 3, Serve: 4, Footwork: 5 }, comment: 'Great improvement in footwork' },
    { date: '2025-12-15', skills: { Forehand: 3, Backhand: 3, Serve: 3, Footwork: 4 }, comment: 'Consistent performance' },
  ];

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
          <h1 className="text-xl text-[#e8e8e8]">Add Performance</h1>
        </div>

        <div className="p-6 space-y-6">
          <div className="p-4 rounded-xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)]">
            <p className="text-sm text-[#888888] mb-2">Date</p>
            <input
              type="date"
              defaultValue={new Date().toISOString().split('T')[0]}
              className="w-full bg-[#1a1a1a] text-[#e8e8e8] p-3 rounded-xl shadow-[inset_2px_2px_4px_rgba(0,0,0,0.5)] outline-none"
            />
          </div>

          <div className="space-y-4">
            <p className="text-sm text-[#888888]">Rate Skills (1-5)</p>
            {skills.map((skill) => (
              <div key={skill} className="p-5 rounded-2xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)]">
                <p className="text-sm text-[#e8e8e8] mb-3">{skill}</p>
                <div className="flex gap-2">
                  {[1, 2, 3, 4, 5].map((rating) => (
                    <button
                      key={rating}
                      className="flex-1 h-10 rounded-xl bg-[#1a1a1a] shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)] hover:bg-[#2a2a2a] transition-all duration-200 flex items-center justify-center"
                    >
                      <span className="text-[#a0a0a0]">{rating}</span>
                    </button>
                  ))}
                </div>
              </div>
            ))}
          </div>

          <div className="p-6 rounded-2xl bg-[#242424] shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)]">
            <textarea
              placeholder="Add comments..."
              rows={4}
              className="w-full bg-transparent text-[#e8e8e8] placeholder-[#666666] outline-none resize-none"
            />
          </div>

          <button className="w-full p-4 rounded-xl bg-[#2a2a2a] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] hover:shadow-[4px_4px_8px_rgba(0,0,0,0.5),-4px_-4px_8px_rgba(40,40,40,0.1)] transition-all duration-200 active:shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)]">
            <span className="text-[#e8e8e8]">Save Performance</span>
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen">
      {/* Header */}
      <div className="sticky top-0 bg-[#1a1a1a] border-b border-[#2a2a2a] px-6 py-4 flex items-center gap-4 shadow-[0_4px_16px_rgba(0,0,0,0.5)]">
        <button
          onClick={onBack}
          className="w-10 h-10 rounded-xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] active:shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)] flex items-center justify-center"
        >
          <ArrowLeft className="w-5 h-5 text-[#a0a0a0]" />
        </button>
        <h1 className="text-xl text-[#e8e8e8] flex-1">Performance</h1>
        <button
          onClick={() => setShowAddForm(true)}
          className="w-10 h-10 rounded-xl bg-[#2a2a2a] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] active:shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)] flex items-center justify-center"
        >
          <Plus className="w-5 h-5 text-[#c0c0c0]" />
        </button>
      </div>

      <div className="p-6">
        <div className="p-4 rounded-xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] mb-6">
          <p className="text-sm text-[#888888] mb-1">Student</p>
          <p className="text-lg text-[#e8e8e8]">{student.name}</p>
        </div>

        <h2 className="text-lg text-[#e8e8e8] mb-4">Performance History</h2>
        
        <div className="space-y-4">
          {performanceHistory.map((entry, i) => (
            <div
              key={i}
              className="p-5 rounded-2xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)]"
            >
              <p className="text-sm text-[#888888] mb-4">{new Date(entry.date).toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric' })}</p>
              
              <div className="space-y-3 mb-4">
                {Object.entries(entry.skills).map(([skill, rating]) => (
                  <div key={skill} className="flex items-center justify-between">
                    <span className="text-sm text-[#e8e8e8]">{skill}</span>
                    <div className="flex gap-1">
                      {[1, 2, 3, 4, 5].map((r) => (
                        <Star
                          key={r}
                          className={`w-4 h-4 ${r <= (rating as number) ? 'text-[#a0a0a0] fill-[#a0a0a0]' : 'text-[#404040]'}`}
                        />
                      ))}
                    </div>
                  </div>
                ))}
              </div>

              {entry.comment && (
                <div className="p-3 rounded-xl bg-[#1a1a1a] shadow-[inset_2px_2px_4px_rgba(0,0,0,0.5)]">
                  <p className="text-xs text-[#888888]">Comment</p>
                  <p className="text-sm text-[#a0a0a0] mt-1">{entry.comment}</p>
                </div>
              )}
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
