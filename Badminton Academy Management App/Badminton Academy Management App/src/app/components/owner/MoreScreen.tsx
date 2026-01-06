import { useState } from 'react';
import { 
  User, Building2, Calendar, Bell, Settings, LogOut, 
  ChevronRight, Clock, Megaphone
} from 'lucide-react';
import SessionManagement from './SessionManagement';
import AnnouncementManagement from './AnnouncementManagement';
import CalendarView from './CalendarView';

export default function MoreScreen() {
  const [currentView, setCurrentView] = useState<string | null>(null);

  if (currentView === 'sessions') {
    return <SessionManagement onBack={() => setCurrentView(null)} />;
  }

  if (currentView === 'announcements') {
    return <AnnouncementManagement onBack={() => setCurrentView(null)} />;
  }

  if (currentView === 'calendar') {
    return <CalendarView onBack={() => setCurrentView(null)} />;
  }

  if (currentView === 'profile') {
    return (
      <div className="min-h-screen pt-6">
        <div className="px-6 mb-6">
          <button
            onClick={() => setCurrentView(null)}
            className="mb-4 text-sm text-[#888888]"
          >
            ← Back
          </button>
          <h1 className="text-2xl text-[#e8e8e8]">Profile</h1>
        </div>

        <div className="px-6 space-y-4 pb-6">
          <div className="p-6 rounded-2xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] mb-6">
            <div className="flex items-center gap-4 mb-6">
              <div className="w-20 h-20 rounded-full bg-[#1a1a1a] flex items-center justify-center shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)]">
                <span className="text-3xl text-[#a0a0a0]">A</span>
              </div>
              <div>
                <h2 className="text-xl text-[#e8e8e8] mb-1">Admin Owner</h2>
                <p className="text-sm text-[#888888]">Owner</p>
              </div>
            </div>
          </div>

          <div className="p-6 rounded-2xl bg-[#242424] shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)]">
            <input
              type="text"
              placeholder="Full Name"
              defaultValue="Admin Owner"
              className="w-full bg-transparent text-[#e8e8e8] placeholder-[#666666] outline-none"
            />
          </div>

          <div className="p-6 rounded-2xl bg-[#242424] shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)]">
            <input
              type="email"
              placeholder="Email"
              defaultValue="owner@academy.com"
              className="w-full bg-transparent text-[#e8e8e8] placeholder-[#666666] outline-none"
            />
          </div>

          <div className="p-6 rounded-2xl bg-[#242424] shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)]">
            <input
              type="tel"
              placeholder="Phone"
              defaultValue="+91 98765 43210"
              className="w-full bg-transparent text-[#e8e8e8] placeholder-[#666666] outline-none"
            />
          </div>

          <button className="w-full p-4 rounded-xl bg-[#2a2a2a] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] hover:shadow-[4px_4px_8px_rgba(0,0,0,0.5),-4px_-4px_8px_rgba(40,40,40,0.1)] transition-all duration-200 active:shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)]">
            <span className="text-[#e8e8e8]">Save Changes</span>
          </button>
        </div>
      </div>
    );
  }

  if (currentView === 'academy') {
    return (
      <div className="min-h-screen pt-6">
        <div className="px-6 mb-6">
          <button
            onClick={() => setCurrentView(null)}
            className="mb-4 text-sm text-[#888888]"
          >
            ← Back
          </button>
          <h1 className="text-2xl text-[#e8e8e8]">Academy Details</h1>
        </div>

        <div className="px-6 space-y-4 pb-6">
          <div className="p-6 rounded-2xl bg-[#242424] shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)]">
            <input
              type="text"
              placeholder="Academy Name"
              defaultValue="Ace Badminton Academy"
              className="w-full bg-transparent text-[#e8e8e8] placeholder-[#666666] outline-none"
            />
          </div>

          <div className="p-6 rounded-2xl bg-[#242424] shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)]">
            <textarea
              placeholder="Address"
              defaultValue="123 Sports Complex, City Center"
              rows={3}
              className="w-full bg-transparent text-[#e8e8e8] placeholder-[#666666] outline-none resize-none"
            />
          </div>

          <div className="grid grid-cols-2 gap-3">
            <div className="p-6 rounded-2xl bg-[#242424] shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)]">
              <input
                type="text"
                placeholder="City"
                defaultValue="Mumbai"
                className="w-full bg-transparent text-[#e8e8e8] placeholder-[#666666] outline-none"
              />
            </div>

            <div className="p-6 rounded-2xl bg-[#242424] shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)]">
              <input
                type="text"
                placeholder="State"
                defaultValue="Maharashtra"
                className="w-full bg-transparent text-[#e8e8e8] placeholder-[#666666] outline-none"
              />
            </div>
          </div>

          <button className="w-full p-4 rounded-xl bg-[#2a2a2a] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] hover:shadow-[4px_4px_8px_rgba(0,0,0,0.5),-4px_-4px_8px_rgba(40,40,40,0.1)] transition-all duration-200 active:shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)]">
            <span className="text-[#e8e8e8]">Save Changes</span>
          </button>
        </div>
      </div>
    );
  }

  if (currentView === 'settings') {
    return (
      <div className="min-h-screen pt-6">
        <div className="px-6 mb-6">
          <button
            onClick={() => setCurrentView(null)}
            className="mb-4 text-sm text-[#888888]"
          >
            ← Back
          </button>
          <h1 className="text-2xl text-[#e8e8e8]">Settings</h1>
        </div>

        <div className="px-6 space-y-6 pb-6">
          <div>
            <h3 className="text-sm text-[#888888] mb-3">Notifications</h3>
            <div className="space-y-3">
              {[
                { label: 'Fee Reminders', enabled: true },
                { label: 'Attendance Alerts', enabled: true },
                { label: 'New Student Notifications', enabled: false },
              ].map((setting, i) => (
                <div
                  key={i}
                  className="p-4 rounded-xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] flex items-center justify-between"
                >
                  <span className="text-sm text-[#e8e8e8]">{setting.label}</span>
                  <div
                    className={`w-12 h-6 rounded-full p-1 transition-all duration-200 ${
                      setting.enabled
                        ? 'bg-[#2a3a2a] shadow-[inset_2px_2px_4px_rgba(0,0,0,0.5)]'
                        : 'bg-[#1a1a1a] shadow-[inset_2px_2px_4px_rgba(0,0,0,0.5)]'
                    }`}
                  >
                    <div
                      className={`w-4 h-4 rounded-full transition-all duration-200 ${
                        setting.enabled
                          ? 'bg-[#80c080] ml-auto shadow-[2px_2px_4px_rgba(0,0,0,0.3)]'
                          : 'bg-[#505050] shadow-[2px_2px_4px_rgba(0,0,0,0.3)]'
                      }`}
                    />
                  </div>
                </div>
              ))}
            </div>
          </div>

          <div>
            <h3 className="text-sm text-[#888888] mb-3">App Preferences</h3>
            <div className="space-y-3">
              <div className="p-4 rounded-xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)]">
                <p className="text-sm text-[#888888] mb-2">Currency</p>
                <select className="w-full bg-[#1a1a1a] text-[#e8e8e8] p-3 rounded-xl shadow-[inset_2px_2px_4px_rgba(0,0,0,0.5)] outline-none">
                  <option value="INR">INR (₹)</option>
                  <option value="USD">USD ($)</option>
                  <option value="EUR">EUR (€)</option>
                </select>
              </div>
            </div>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen pt-6">
      <div className="px-6 mb-6">
        <h1 className="text-2xl text-[#e8e8e8]">More</h1>
      </div>

      <div className="px-6 space-y-6 pb-6">
        {/* Account Section */}
        <div>
          <h3 className="text-sm text-[#888888] mb-3">Account</h3>
          <div className="space-y-2">
            <button
              onClick={() => setCurrentView('profile')}
              className="w-full p-4 rounded-xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] active:shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)] transition-all duration-200"
            >
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <User className="w-5 h-5 text-[#a0a0a0]" />
                  <span className="text-sm text-[#e8e8e8]">Profile</span>
                </div>
                <ChevronRight className="w-5 h-5 text-[#707070]" />
              </div>
            </button>

            <button
              onClick={() => setCurrentView('academy')}
              className="w-full p-4 rounded-xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] active:shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)] transition-all duration-200"
            >
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <Building2 className="w-5 h-5 text-[#a0a0a0]" />
                  <span className="text-sm text-[#e8e8e8]">Academy Details</span>
                </div>
                <ChevronRight className="w-5 h-5 text-[#707070]" />
              </div>
            </button>
          </div>
        </div>

        {/* Management Section */}
        <div>
          <h3 className="text-sm text-[#888888] mb-3">Management</h3>
          <div className="space-y-2">
            <button
              onClick={() => setCurrentView('sessions')}
              className="w-full p-4 rounded-xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] active:shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)] transition-all duration-200"
            >
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <Clock className="w-5 h-5 text-[#a0a0a0]" />
                  <span className="text-sm text-[#e8e8e8]">Sessions</span>
                </div>
                <ChevronRight className="w-5 h-5 text-[#707070]" />
              </div>
            </button>

            <button
              onClick={() => setCurrentView('announcements')}
              className="w-full p-4 rounded-xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] active:shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)] transition-all duration-200"
            >
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <Megaphone className="w-5 h-5 text-[#a0a0a0]" />
                  <span className="text-sm text-[#e8e8e8]">Announcements</span>
                </div>
                <ChevronRight className="w-5 h-5 text-[#707070]" />
              </div>
            </button>

            <button
              onClick={() => setCurrentView('calendar')}
              className="w-full p-4 rounded-xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] active:shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)] transition-all duration-200"
            >
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <Calendar className="w-5 h-5 text-[#a0a0a0]" />
                  <span className="text-sm text-[#e8e8e8]">Calendar & Holidays</span>
                </div>
                <ChevronRight className="w-5 h-5 text-[#707070]" />
              </div>
            </button>
          </div>
        </div>

        {/* App Section */}
        <div>
          <h3 className="text-sm text-[#888888] mb-3">App</h3>
          <div className="space-y-2">
            <button
              onClick={() => setCurrentView('settings')}
              className="w-full p-4 rounded-xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] active:shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)] transition-all duration-200"
            >
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <Settings className="w-5 h-5 text-[#a0a0a0]" />
                  <span className="text-sm text-[#e8e8e8]">Settings</span>
                </div>
                <ChevronRight className="w-5 h-5 text-[#707070]" />
              </div>
            </button>

            <button className="w-full p-4 rounded-xl bg-[#2a1a1a] border border-[#3a2a2a] active:shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)] transition-all duration-200">
              <div className="flex items-center gap-3">
                <LogOut className="w-5 h-5 text-[#c08080]" />
                <span className="text-sm text-[#c08080]">Logout</span>
              </div>
            </button>
          </div>
        </div>

        {/* App Version */}
        <div className="text-center pt-4">
          <p className="text-xs text-[#666666]">Version 1.0.0</p>
        </div>
      </div>
    </div>
  );
}
