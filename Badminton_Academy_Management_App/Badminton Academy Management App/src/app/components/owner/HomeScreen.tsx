import { useState } from 'react';
import { Plus, Users, UserCheck, DollarSign, Calendar, TrendingUp, ChevronRight } from 'lucide-react';
import CoachManagement from './CoachManagement';
import StudentManagement from './StudentManagement';
import FeeManagement from './FeeManagement';

type SubScreen = 'main' | 'coaches' | 'students' | 'fees';

export default function HomeScreen() {
  const [currentScreen, setCurrentScreen] = useState<SubScreen>('main');

  if (currentScreen === 'coaches') {
    return <CoachManagement onBack={() => setCurrentScreen('main')} />;
  }

  if (currentScreen === 'students') {
    return <StudentManagement onBack={() => setCurrentScreen('main')} />;
  }

  if (currentScreen === 'fees') {
    return <FeeManagement onBack={() => setCurrentScreen('main')} />;
  }

  return (
    <div className="min-h-screen">
      {/* Header */}
      <div className="p-6 pb-4">
        <div className="mb-1">
          <p className="text-sm text-[#888888]">Welcome back,</p>
          <h1 className="text-2xl text-[#e8e8e8]">Ace Badminton Academy</h1>
        </div>
        <p className="text-sm text-[#888888]">Tuesday, January 6, 2026</p>
      </div>

      {/* Stats Grid */}
      <div className="px-6 mb-6">
        <div className="grid grid-cols-2 gap-4">
          <button
            onClick={() => setCurrentScreen('students')}
            className="p-5 rounded-2xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] active:shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)] transition-all duration-200"
          >
            <div className="flex items-start justify-between mb-3">
              <div className="w-10 h-10 rounded-xl bg-[#1a1a1a] flex items-center justify-center shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)]">
                <Users className="w-5 h-5 text-[#a0a0a0]" />
              </div>
              <ChevronRight className="w-4 h-4 text-[#707070]" />
            </div>
            <p className="text-2xl text-[#e8e8e8] mb-1">142</p>
            <p className="text-sm text-[#888888]">Total Students</p>
          </button>

          <button
            onClick={() => setCurrentScreen('coaches')}
            className="p-5 rounded-2xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] active:shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)] transition-all duration-200"
          >
            <div className="flex items-start justify-between mb-3">
              <div className="w-10 h-10 rounded-xl bg-[#1a1a1a] flex items-center justify-center shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)]">
                <UserCheck className="w-5 h-5 text-[#a0a0a0]" />
              </div>
              <ChevronRight className="w-4 h-4 text-[#707070]" />
            </div>
            <p className="text-2xl text-[#e8e8e8] mb-1">8</p>
            <p className="text-sm text-[#888888]">Total Coaches</p>
          </button>

          <div className="p-5 rounded-2xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)]">
            <div className="flex items-start justify-between mb-3">
              <div className="w-10 h-10 rounded-xl bg-[#1a1a1a] flex items-center justify-center shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)]">
                <Calendar className="w-5 h-5 text-[#a0a0a0]" />
              </div>
            </div>
            <p className="text-2xl text-[#e8e8e8] mb-1">12</p>
            <p className="text-sm text-[#888888]">Active Batches</p>
          </div>

          <button
            onClick={() => setCurrentScreen('fees')}
            className="p-5 rounded-2xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] active:shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)] transition-all duration-200"
          >
            <div className="flex items-start justify-between mb-3">
              <div className="w-10 h-10 rounded-xl bg-[#1a1a1a] flex items-center justify-center shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)]">
                <DollarSign className="w-5 h-5 text-[#a0a0a0]" />
              </div>
              <ChevronRight className="w-4 h-4 text-[#707070]" />
            </div>
            <p className="text-2xl text-[#e8e8e8] mb-1">₹38,500</p>
            <p className="text-sm text-[#888888]">Pending Fees</p>
          </button>
        </div>
      </div>

      {/* Today's Insights */}
      <div className="px-6 mb-6">
        <h2 className="text-lg text-[#e8e8e8] mb-4">Today's Insights</h2>
        <div className="p-5 rounded-2xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] mb-4">
          <div className="flex items-center gap-3 mb-3">
            <div className="w-10 h-10 rounded-xl bg-[#1a1a1a] flex items-center justify-center shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)]">
              <TrendingUp className="w-5 h-5 text-[#a0a0a0]" />
            </div>
            <div className="flex-1">
              <p className="text-sm text-[#888888]">Attendance Rate</p>
              <p className="text-xl text-[#e8e8e8]">87%</p>
            </div>
          </div>
          <div className="w-full h-2 rounded-full bg-[#1a1a1a] shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5)]">
            <div className="w-[87%] h-full rounded-full bg-[#505050]"></div>
          </div>
        </div>

        <div className="p-5 rounded-2xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)]">
          <p className="text-sm text-[#888888] mb-3">Upcoming Batches</p>
          <div className="space-y-3">
            {[
              { name: 'Morning Batch A', time: '6:00 AM - 7:30 AM', students: 18 },
              { name: 'Evening Batch B', time: '5:00 PM - 6:30 PM', students: 22 },
            ].map((batch, i) => (
              <div key={i} className="flex items-center justify-between">
                <div>
                  <p className="text-sm text-[#e8e8e8]">{batch.name}</p>
                  <p className="text-xs text-[#888888]">{batch.time}</p>
                </div>
                <div className="px-3 py-1 rounded-lg bg-[#1a1a1a] shadow-[inset_2px_2px_4px_rgba(0,0,0,0.5)]">
                  <p className="text-xs text-[#a0a0a0]">{batch.students} students</p>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Quick Actions */}
      <div className="px-6 mb-6">
        <h2 className="text-lg text-[#e8e8e8] mb-4">Quick Actions</h2>
        <div className="grid grid-cols-2 gap-3">
          <button className="p-4 rounded-xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] active:shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)] transition-all duration-200">
            <div className="flex flex-col items-center gap-2">
              <Plus className="w-6 h-6 text-[#a0a0a0]" />
              <p className="text-sm text-[#e8e8e8]">Add Student</p>
            </div>
          </button>
          <button className="p-4 rounded-xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] active:shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)] transition-all duration-200">
            <div className="flex flex-col items-center gap-2">
              <Plus className="w-6 h-6 text-[#a0a0a0]" />
              <p className="text-sm text-[#e8e8e8]">Add Coach</p>
            </div>
          </button>
        </div>
      </div>

      {/* FAB */}
      <button className="fixed bottom-24 right-6 w-14 h-14 rounded-full bg-[#2a2a2a] shadow-[8px_8px_16px_rgba(0,0,0,0.6),-4px_-4px_12px_rgba(50,50,50,0.1)] active:shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)] transition-all duration-200 flex items-center justify-center">
        <Plus className="w-6 h-6 text-[#c0c0c0]" />
      </button>
    </div>
  );
}
