import { useState } from 'react';
import { ArrowLeft, Plus, AlertCircle } from 'lucide-react';

interface AnnouncementManagementProps {
  onBack: () => void;
}

export default function AnnouncementManagement({ onBack }: AnnouncementManagementProps) {
  const [showAddForm, setShowAddForm] = useState(false);

  const announcements = [
    {
      id: 1,
      title: 'Academy Closed - Republic Day',
      description: 'The academy will remain closed on January 26th for Republic Day.',
      priority: 'high',
      targetAudience: 'All',
      publishDate: '2026-01-06',
      expiryDate: '2026-01-27',
    },
    {
      id: 2,
      title: 'New Batch Starting',
      description: 'A new morning batch will start from February 1st. Limited seats available.',
      priority: 'medium',
      targetAudience: 'Students',
      publishDate: '2026-01-05',
      expiryDate: '2026-02-01',
    },
    {
      id: 3,
      title: 'Fee Payment Reminder',
      description: 'Please clear pending fees before January 15th to avoid late charges.',
      priority: 'medium',
      targetAudience: 'Students',
      publishDate: '2026-01-01',
      expiryDate: '2026-01-15',
    },
  ];

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
          <h1 className="text-2xl text-[#e8e8e8]">Create Announcement</h1>
        </div>

        <div className="px-6 space-y-4 pb-6">
          <div className="p-6 rounded-2xl bg-[#242424] shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)]">
            <input
              type="text"
              placeholder="Title *"
              className="w-full bg-transparent text-[#e8e8e8] placeholder-[#666666] outline-none"
            />
          </div>

          <div className="p-6 rounded-2xl bg-[#242424] shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)]">
            <textarea
              placeholder="Description *"
              rows={4}
              className="w-full bg-transparent text-[#e8e8e8] placeholder-[#666666] outline-none resize-none"
            />
          </div>

          <div className="p-5 rounded-2xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)]">
            <p className="text-sm text-[#888888] mb-3">Priority *</p>
            <div className="flex gap-2">
              {['Low', 'Medium', 'High'].map((priority) => (
                <button
                  key={priority}
                  className="flex-1 p-3 rounded-xl bg-[#1a1a1a] shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)] hover:bg-[#2a2a2a] transition-all text-sm text-[#888888]"
                >
                  {priority}
                </button>
              ))}
            </div>
          </div>

          <div className="p-6 rounded-2xl bg-[#242424] shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)]">
            <p className="text-xs text-[#888888] mb-2">Target Audience *</p>
            <select className="w-full bg-transparent text-[#e8e8e8] outline-none">
              <option value="all">All</option>
              <option value="students">Students Only</option>
              <option value="coaches">Coaches Only</option>
              <option value="specific">Specific Batch</option>
            </select>
          </div>

          <div className="p-6 rounded-2xl bg-[#242424] shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)]">
            <p className="text-xs text-[#888888] mb-2">Publish Date *</p>
            <input
              type="date"
              defaultValue={new Date().toISOString().split('T')[0]}
              className="w-full bg-transparent text-[#e8e8e8] outline-none"
            />
          </div>

          <div className="p-6 rounded-2xl bg-[#242424] shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)]">
            <p className="text-xs text-[#888888] mb-2">Expiry Date *</p>
            <input
              type="date"
              className="w-full bg-transparent text-[#e8e8e8] outline-none"
            />
          </div>

          <button className="w-full p-4 rounded-xl bg-[#2a2a2a] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] hover:shadow-[4px_4px_8px_rgba(0,0,0,0.5),-4px_-4px_8px_rgba(40,40,40,0.1)] transition-all duration-200 active:shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)]">
            <span className="text-[#e8e8e8]">Publish Announcement</span>
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
          <h1 className="text-2xl text-[#e8e8e8]">Announcements</h1>
          <button
            onClick={() => setShowAddForm(true)}
            className="w-10 h-10 rounded-xl bg-[#2a2a2a] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] active:shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)] flex items-center justify-center"
          >
            <Plus className="w-5 h-5 text-[#c0c0c0]" />
          </button>
        </div>
      </div>

      <div className="px-6 space-y-4 pb-6">
        {announcements.map((announcement) => (
          <div
            key={announcement.id}
            className="p-5 rounded-2xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)]"
          >
            <div className="flex items-start justify-between mb-3">
              <div className="flex-1">
                <div className="flex items-center gap-2 mb-2">
                  {announcement.priority === 'high' && (
                    <AlertCircle className="w-4 h-4 text-[#c08080]" />
                  )}
                  <h3 className="text-sm text-[#e8e8e8]">{announcement.title}</h3>
                </div>
                <p className="text-xs text-[#888888] mb-3">{announcement.description}</p>
              </div>
            </div>

            <div className="flex items-center justify-between">
              <div className="flex items-center gap-2">
                <div className={`px-2 py-1 rounded ${
                  announcement.priority === 'high' ? 'bg-[#2a1a1a]' :
                  announcement.priority === 'medium' ? 'bg-[#2a2a1a]' :
                  'bg-[#1a1a1a]'
                } shadow-[inset_2px_2px_4px_rgba(0,0,0,0.5)]`}>
                  <p className={`text-xs ${
                    announcement.priority === 'high' ? 'text-[#c08080]' :
                    announcement.priority === 'medium' ? 'text-[#c0c080]' :
                    'text-[#888888]'
                  }`}>
                    {announcement.priority}
                  </p>
                </div>
                <div className="px-2 py-1 rounded bg-[#1a1a1a] shadow-[inset_2px_2px_4px_rgba(0,0,0,0.5)]">
                  <p className="text-xs text-[#888888]">{announcement.targetAudience}</p>
                </div>
              </div>
              <p className="text-xs text-[#666666]">
                Expires: {new Date(announcement.expiryDate).toLocaleDateString()}
              </p>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
