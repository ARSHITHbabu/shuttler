import { useState } from 'react';
import { ArrowLeft, Plus, ChevronLeft, ChevronRight } from 'lucide-react';

interface CalendarViewProps {
  onBack: () => void;
}

export default function CalendarView({ onBack }: CalendarViewProps) {
  const [currentDate, setCurrentDate] = useState(new Date());
  const [showAddHoliday, setShowAddHoliday] = useState(false);

  const holidays = [
    { date: '2026-01-26', name: 'Republic Day', type: 'national' },
    { date: '2026-03-08', name: 'Holi', type: 'national' },
  ];

  const batches = [
    { date: '2026-01-06', name: 'Morning Batch A', time: '6:00 AM' },
    { date: '2026-01-06', name: 'Evening Batch B', time: '5:00 PM' },
    { date: '2026-01-07', name: 'Morning Batch A', time: '6:00 AM' },
  ];

  const getDaysInMonth = (date: Date) => {
    const year = date.getFullYear();
    const month = date.getMonth();
    const firstDay = new Date(year, month, 1);
    const lastDay = new Date(year, month + 1, 0);
    const daysInMonth = lastDay.getDate();
    const startingDayOfWeek = firstDay.getDay();

    return { daysInMonth, startingDayOfWeek };
  };

  const { daysInMonth, startingDayOfWeek } = getDaysInMonth(currentDate);

  const previousMonth = () => {
    setCurrentDate(new Date(currentDate.getFullYear(), currentDate.getMonth() - 1, 1));
  };

  const nextMonth = () => {
    setCurrentDate(new Date(currentDate.getFullYear(), currentDate.getMonth() + 1, 1));
  };

  const isToday = (day: number) => {
    const today = new Date();
    return (
      day === today.getDate() &&
      currentDate.getMonth() === today.getMonth() &&
      currentDate.getFullYear() === today.getFullYear()
    );
  };

  const getEventsForDate = (day: number) => {
    const dateStr = `${currentDate.getFullYear()}-${String(currentDate.getMonth() + 1).padStart(2, '0')}-${String(day).padStart(2, '0')}`;
    return {
      holidays: holidays.filter(h => h.date === dateStr),
      batches: batches.filter(b => b.date === dateStr),
    };
  };

  if (showAddHoliday) {
    return (
      <div className="min-h-screen pt-6">
        <div className="px-6 mb-6">
          <button
            onClick={() => setShowAddHoliday(false)}
            className="mb-4 text-sm text-[#888888]"
          >
            ← Back
          </button>
          <h1 className="text-2xl text-[#e8e8e8]">Add Holiday</h1>
        </div>

        <div className="px-6 space-y-4 pb-6">
          <div className="p-6 rounded-2xl bg-[#242424] shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)]">
            <input
              type="text"
              placeholder="Holiday Name *"
              className="w-full bg-transparent text-[#e8e8e8] placeholder-[#666666] outline-none"
            />
          </div>

          <div className="p-6 rounded-2xl bg-[#242424] shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)]">
            <p className="text-xs text-[#888888] mb-2">Date *</p>
            <input
              type="date"
              className="w-full bg-transparent text-[#e8e8e8] outline-none"
            />
          </div>

          <div className="p-5 rounded-2xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)]">
            <p className="text-sm text-[#888888] mb-3">Type *</p>
            <div className="flex gap-2">
              {['National', 'Academy', 'No Class'].map((type) => (
                <button
                  key={type}
                  className="flex-1 p-3 rounded-xl bg-[#1a1a1a] shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)] hover:bg-[#2a2a2a] transition-all text-sm text-[#888888]"
                >
                  {type}
                </button>
              ))}
            </div>
          </div>

          <button className="w-full p-4 rounded-xl bg-[#2a2a2a] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] hover:shadow-[4px_4px_8px_rgba(0,0,0,0.5),-4px_-4px_8px_rgba(40,40,40,0.1)] transition-all duration-200 active:shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)]">
            <span className="text-[#e8e8e8]">Add Holiday</span>
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
          <h1 className="text-2xl text-[#e8e8e8]">Calendar</h1>
          <button
            onClick={() => setShowAddHoliday(true)}
            className="w-10 h-10 rounded-xl bg-[#2a2a2a] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] active:shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)] flex items-center justify-center"
          >
            <Plus className="w-5 h-5 text-[#c0c0c0]" />
          </button>
        </div>
      </div>

      <div className="px-6 mb-6">
        {/* Month Navigation */}
        <div className="p-4 rounded-xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] mb-4">
          <div className="flex items-center justify-between">
            <button
              onClick={previousMonth}
              className="w-10 h-10 rounded-xl bg-[#1a1a1a] shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)] flex items-center justify-center"
            >
              <ChevronLeft className="w-5 h-5 text-[#a0a0a0]" />
            </button>
            <h2 className="text-lg text-[#e8e8e8]">
              {currentDate.toLocaleDateString('en-US', { month: 'long', year: 'numeric' })}
            </h2>
            <button
              onClick={nextMonth}
              className="w-10 h-10 rounded-xl bg-[#1a1a1a] shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)] flex items-center justify-center"
            >
              <ChevronRight className="w-5 h-5 text-[#a0a0a0]" />
            </button>
          </div>
        </div>

        {/* Calendar Grid */}
        <div className="p-4 rounded-2xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)]">
          {/* Day Headers */}
          <div className="grid grid-cols-7 gap-2 mb-2">
            {['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((day, i) => (
              <div key={i} className="text-center">
                <span className="text-xs text-[#888888]">{day}</span>
              </div>
            ))}
          </div>

          {/* Calendar Days */}
          <div className="grid grid-cols-7 gap-2">
            {/* Empty cells for days before month starts */}
            {Array.from({ length: startingDayOfWeek }).map((_, i) => (
              <div key={`empty-${i}`} className="aspect-square" />
            ))}

            {/* Actual days */}
            {Array.from({ length: daysInMonth }).map((_, i) => {
              const day = i + 1;
              const events = getEventsForDate(day);
              const hasHoliday = events.holidays.length > 0;
              const hasBatches = events.batches.length > 0;

              return (
                <div
                  key={day}
                  className={`aspect-square p-1 rounded-lg ${
                    isToday(day)
                      ? 'bg-[#2a2a2a] shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)]'
                      : hasHoliday
                      ? 'bg-[#2a1a1a]'
                      : ''
                  }`}
                >
                  <div className="flex flex-col h-full">
                    <span className={`text-xs ${
                      isToday(day) ? 'text-[#e8e8e8]' :
                      hasHoliday ? 'text-[#c08080]' :
                      'text-[#a0a0a0]'
                    }`}>
                      {day}
                    </span>
                    <div className="flex-1 flex flex-col gap-1 justify-end">
                      {hasHoliday && (
                        <div className="w-full h-1 rounded-full bg-[#c08080]" />
                      )}
                      {hasBatches && (
                        <div className="w-full h-1 rounded-full bg-[#80c080]" />
                      )}
                    </div>
                  </div>
                </div>
              );
            })}
          </div>
        </div>

        {/* Legend */}
        <div className="flex items-center gap-4 mt-4 text-xs">
          <div className="flex items-center gap-2">
            <div className="w-3 h-3 rounded-full bg-[#c08080]" />
            <span className="text-[#888888]">Holidays</span>
          </div>
          <div className="flex items-center gap-2">
            <div className="w-3 h-3 rounded-full bg-[#80c080]" />
            <span className="text-[#888888]">Batches</span>
          </div>
        </div>
      </div>

      {/* Upcoming Events */}
      <div className="px-6 pb-6">
        <h2 className="text-lg text-[#e8e8e8] mb-4">Upcoming Events</h2>
        <div className="space-y-3">
          {holidays.map((holiday, i) => (
            <div
              key={i}
              className="p-4 rounded-xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)]"
            >
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm text-[#e8e8e8] mb-1">{holiday.name}</p>
                  <p className="text-xs text-[#888888]">
                    {new Date(holiday.date).toLocaleDateString('en-US', { month: 'long', day: 'numeric', year: 'numeric' })}
                  </p>
                </div>
                <div className="px-3 py-1 rounded-lg bg-[#2a1a1a] shadow-[inset_2px_2px_4px_rgba(0,0,0,0.5)]">
                  <p className="text-xs text-[#c08080]">Holiday</p>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
