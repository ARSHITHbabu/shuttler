import { useState } from 'react';
import { Home, Users, ClipboardCheck, FileText, MoreHorizontal } from 'lucide-react';
import HomeScreen from './owner/HomeScreen';
import BatchesScreen from './owner/BatchesScreen';
import AttendanceScreen from './owner/AttendanceScreen';
import ReportsScreen from './owner/ReportsScreen';
import MoreScreen from './owner/MoreScreen';

type OwnerTab = 'home' | 'batches' | 'attendance' | 'reports' | 'more';

export default function OwnerDashboard() {
  const [activeTab, setActiveTab] = useState<OwnerTab>('home');

  const tabs = [
    { id: 'home' as OwnerTab, icon: Home, label: 'Home' },
    { id: 'batches' as OwnerTab, icon: Users, label: 'Batches' },
    { id: 'attendance' as OwnerTab, icon: ClipboardCheck, label: 'Attendance' },
    { id: 'reports' as OwnerTab, icon: FileText, label: 'Reports' },
    { id: 'more' as OwnerTab, icon: MoreHorizontal, label: 'More' },
  ];

  return (
    <div className="min-h-screen flex flex-col max-w-md mx-auto bg-gradient-to-b from-[#1a1a1a] to-[#0f0f0f]">
      {/* Content Area */}
      <div className="flex-1 pb-20">
        {activeTab === 'home' && <HomeScreen />}
        {activeTab === 'batches' && <BatchesScreen />}
        {activeTab === 'attendance' && <AttendanceScreen />}
        {activeTab === 'reports' && <ReportsScreen />}
        {activeTab === 'more' && <MoreScreen />}
      </div>

      {/* Bottom Navigation */}
      <div className="fixed bottom-0 left-0 right-0 max-w-md mx-auto bg-[#1a1a1a] border-t border-[#2a2a2a] shadow-[0_-4px_16px_rgba(0,0,0,0.5)]">
        <div className="flex items-center justify-around px-2 py-3">
          {tabs.map((tab) => (
            <button
              key={tab.id}
              onClick={() => setActiveTab(tab.id)}
              className={`flex flex-col items-center gap-1 px-4 py-2 rounded-xl transition-all duration-200 ${
                activeTab === tab.id
                  ? 'bg-[#242424] shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)]'
                  : ''
              }`}
            >
              <tab.icon
                className={`w-5 h-5 ${
                  activeTab === tab.id ? 'text-[#c0c0c0]' : 'text-[#707070]'
                }`}
              />
              <span
                className={`text-xs ${
                  activeTab === tab.id ? 'text-[#c0c0c0]' : 'text-[#707070]'
                }`}
              >
                {tab.label}
              </span>
            </button>
          ))}
        </div>
      </div>
    </div>
  );
}
