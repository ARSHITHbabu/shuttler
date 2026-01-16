import { useState } from 'react';
import { ArrowLeft, Plus, ChevronLeft, ChevronRight, X } from 'lucide-react';

interface CalendarViewProps {
  onBack: () => void;
}

type EventType = 'holiday' | 'tournament' | 'in-house-event';

interface Event {
  date: string; // YYYY-MM-DD format
  name: string;
  type: EventType;
}

// Color scheme for event types
const EVENT_COLORS = {
  holiday: {
    bg: '#2a1a1a',
    indicator: '#c08080',
    text: '#c08080',
    badgeBg: '#2a1a1a',
  },
  tournament: {
    bg: '#1a1a2a',
    indicator: '#8080c0',
    text: '#8080c0',
    badgeBg: '#1a1a2a',
  },
  'in-house-event': {
    bg: '#1a2a2a',
    indicator: '#80c0c0',
    text: '#80c0c0',
    badgeBg: '#1a2a2a',
  },
};

export default function CalendarView({ onBack }: CalendarViewProps) {
  const [currentDate, setCurrentDate] = useState(new Date());
  const [showAddEvent, setShowAddEvent] = useState(false);
  const [eventName, setEventName] = useState('');
  const [eventDate, setEventDate] = useState('');
  const [eventType, setEventType] = useState<EventType | null>(null);
  const [selectedDate, setSelectedDate] = useState<string | null>(null);

  const [events, setEvents] = useState<Event[]>([
    { date: '2026-01-26', name: 'Republic Day', type: 'holiday' },
    { date: '2026-03-08', name: 'Holi', type: 'holiday' },
  ]);

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
    setSelectedDate(null); // Clear selection when month changes
  };

  const nextMonth = () => {
    setCurrentDate(new Date(currentDate.getFullYear(), currentDate.getMonth() + 1, 1));
    setSelectedDate(null); // Clear selection when month changes
  };

  const isToday = (day: number) => {
    const today = new Date();
    return (
      day === today.getDate() &&
      currentDate.getMonth() === today.getMonth() &&
      currentDate.getFullYear() === today.getFullYear()
    );
  };

  const getDateString = (day: number) => {
    return `${currentDate.getFullYear()}-${String(currentDate.getMonth() + 1).padStart(2, '0')}-${String(day).padStart(2, '0')}`;
  };

  const getEventsForDate = (day: number) => {
    const dateStr = getDateString(day);
    const dateEvents = events.filter(e => e.date === dateStr);
    return {
      holiday: dateEvents.filter(e => e.type === 'holiday'),
      tournament: dateEvents.filter(e => e.type === 'tournament'),
      'in-house-event': dateEvents.filter(e => e.type === 'in-house-event'),
      batches: batches.filter(b => b.date === dateStr),
    };
  };

  const handleDateClick = (day: number) => {
    const dateStr = getDateString(day);
    setSelectedDate(selectedDate === dateStr ? null : dateStr);
  };

  const getSelectedDateDetails = (dateStr: string) => {
    const dateEvents = events.filter(e => e.date === dateStr);
    const dateBatches = batches.filter(b => b.date === dateStr);
    
    return {
      date: dateStr,
      formattedDate: new Date(dateStr).toLocaleDateString('en-US', { 
        weekday: 'long', 
        month: 'long', 
        day: 'numeric', 
        year: 'numeric' 
      }),
      events: {
        holiday: dateEvents.filter(e => e.type === 'holiday'),
        tournament: dateEvents.filter(e => e.type === 'tournament'),
        'in-house-event': dateEvents.filter(e => e.type === 'in-house-event'),
      },
      batches: dateBatches,
      hasContent: dateEvents.length > 0 || dateBatches.length > 0,
    };
  };

  const handleAddEvent = () => {
    if (!eventName || !eventDate || !eventType) {
      return; // Basic validation
    }
    
    const newEvent: Event = {
      date: eventDate,
      name: eventName,
      type: eventType,
    };
    
    setEvents([...events, newEvent]);
    setEventName('');
    setEventDate('');
    setEventType(null);
    setShowAddEvent(false);
  };

  const eventTypeOptions: { label: string; value: EventType }[] = [
    { label: 'Holiday', value: 'holiday' },
    { label: 'Tournament', value: 'tournament' },
    { label: 'In-house Event', value: 'in-house-event' },
  ];

  if (showAddEvent) {
    return (
      <div className="min-h-screen pt-6">
        <div className="px-6 mb-6">
          <button
            onClick={() => {
              setShowAddEvent(false);
              setEventName('');
              setEventDate('');
              setEventType(null);
            }}
            className="mb-4 text-sm text-[#888888]"
          >
            ← Back
          </button>
          <h1 className="text-2xl text-[#e8e8e8]">Add Event</h1>
        </div>

        <div className="px-6 space-y-4 pb-6">
          <div className="p-6 rounded-2xl bg-[#242424] shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)]">
            <input
              type="text"
              placeholder="Event Name *"
              value={eventName}
              onChange={(e) => setEventName(e.target.value)}
              className="w-full bg-transparent text-[#e8e8e8] placeholder-[#666666] outline-none"
            />
          </div>

          <div className="p-6 rounded-2xl bg-[#242424] shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)]">
            <p className="text-xs text-[#888888] mb-2">Date *</p>
            <input
              type="date"
              value={eventDate}
              onChange={(e) => setEventDate(e.target.value)}
              className="w-full bg-transparent text-[#e8e8e8] outline-none"
            />
          </div>

          <div className="p-5 rounded-2xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)]">
            <p className="text-sm text-[#888888] mb-3">Type *</p>
            <div className="flex gap-2">
              {eventTypeOptions.map((option) => (
                <button
                  key={option.value}
                  onClick={() => setEventType(option.value)}
                  className={`flex-1 p-3 rounded-xl shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)] hover:bg-[#2a2a2a] transition-all text-sm ${
                    eventType === option.value
                      ? 'bg-[#2a2a2a]'
                      : 'bg-[#1a1a1a] text-[#888888]'
                  }`}
                  style={
                    eventType === option.value
                      ? { color: EVENT_COLORS[option.value].text }
                      : {}
                  }
                >
                  {option.label}
                </button>
              ))}
            </div>
          </div>

          <button
            onClick={handleAddEvent}
            className="w-full p-4 rounded-xl bg-[#2a2a2a] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] hover:shadow-[4px_4px_8px_rgba(0,0,0,0.5),-4px_-4px_8px_rgba(40,40,40,0.1)] transition-all duration-200 active:shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)]"
          >
            <span className="text-[#e8e8e8]">Add Event</span>
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
            onClick={() => setShowAddEvent(true)}
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
              const dateStr = getDateString(day);
              const dateEvents = getEventsForDate(day);
              const hasHoliday = dateEvents.holiday.length > 0;
              const hasTournament = dateEvents.tournament.length > 0;
              const hasInHouseEvent = dateEvents['in-house-event'].length > 0;
              const hasBatches = dateEvents.batches.length > 0;
              const isSelected = selectedDate === dateStr;
              
              // Determine background color based on event types
              let bgColor = '';
              if (hasHoliday) bgColor = EVENT_COLORS.holiday.bg;
              else if (hasTournament) bgColor = EVENT_COLORS.tournament.bg;
              else if (hasInHouseEvent) bgColor = EVENT_COLORS['in-house-event'].bg;

              return (
                <button
                  key={day}
                  onClick={() => handleDateClick(day)}
                  className={`aspect-square p-1 rounded-lg transition-all ${
                    isToday(day)
                      ? 'bg-[#2a2a2a] shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)]'
                      : isSelected
                      ? 'ring-2 ring-[#8080c0] ring-offset-2 ring-offset-[#242424]'
                      : bgColor
                      ? ''
                      : ''
                  }`}
                  style={!isToday(day) && !isSelected && bgColor ? { backgroundColor: bgColor } : {}}
                >
                  <div className="flex flex-col h-full">
                    <span className={`text-xs ${
                      isToday(day) ? 'text-[#e8e8e8]' :
                      hasHoliday ? 'text-[#c08080]' :
                      hasTournament ? 'text-[#8080c0]' :
                      hasInHouseEvent ? 'text-[#80c0c0]' :
                      'text-[#a0a0a0]'
                    }`}>
                      {day}
                    </span>
                    <div className="flex-1 flex flex-col gap-1 justify-end">
                      {hasHoliday && (
                        <div className="w-full h-1 rounded-full bg-[#c08080]" />
                      )}
                      {hasTournament && (
                        <div className="w-full h-1 rounded-full bg-[#8080c0]" />
                      )}
                      {hasInHouseEvent && (
                        <div className="w-full h-1 rounded-full bg-[#80c0c0]" />
                      )}
                      {hasBatches && (
                        <div className="w-full h-1 rounded-full bg-[#80c080]" />
                      )}
                    </div>
                  </div>
                </button>
              );
            })}
          </div>
        </div>

        {/* Legend */}
        <div className="flex items-center gap-4 mt-4 text-xs flex-wrap">
          <div className="flex items-center gap-2">
            <div className="w-3 h-3 rounded-full bg-[#c08080]" />
            <span className="text-[#888888]">Holiday</span>
          </div>
          <div className="flex items-center gap-2">
            <div className="w-3 h-3 rounded-full bg-[#8080c0]" />
            <span className="text-[#888888]">Tournament</span>
          </div>
          <div className="flex items-center gap-2">
            <div className="w-3 h-3 rounded-full bg-[#80c0c0]" />
            <span className="text-[#888888]">In-house Event</span>
          </div>
          <div className="flex items-center gap-2">
            <div className="w-3 h-3 rounded-full bg-[#80c080]" />
            <span className="text-[#888888]">Batches</span>
          </div>
        </div>
      </div>

      {/* Date Details Section */}
      {selectedDate && (() => {
        const details = getSelectedDateDetails(selectedDate);
        return (
          <div className="px-6 mb-6">
            <div className="p-5 rounded-2xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)]">
              {/* Header */}
              <div className="flex items-center justify-between mb-4">
                <div>
                  <h3 className="text-lg text-[#e8e8e8] mb-1">{details.formattedDate}</h3>
                </div>
                <button
                  onClick={() => setSelectedDate(null)}
                  className="w-8 h-8 rounded-lg bg-[#1a1a1a] shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)] flex items-center justify-center hover:bg-[#2a2a2a] transition-all"
                >
                  <X className="w-4 h-4 text-[#888888]" />
                </button>
              </div>

              {details.hasContent ? (
                <div className="space-y-4">
                  {/* Events Section */}
                  {(details.events.holiday.length > 0 || 
                    details.events.tournament.length > 0 || 
                    details.events['in-house-event'].length > 0) && (
                    <div>
                      <h4 className="text-sm text-[#888888] mb-3">Events</h4>
                      <div className="space-y-2">
                        {/* Holiday Events */}
                        {details.events.holiday.map((event, idx) => {
                          const eventColor = EVENT_COLORS.holiday;
                          return (
                            <div
                              key={idx}
                              className="p-3 rounded-xl bg-[#1a1a1a] shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5)]"
                            >
                              <div className="flex items-center justify-between">
                                <p className="text-sm text-[#e8e8e8]">{event.name}</p>
                                <div
                                  className="px-2 py-1 rounded-lg text-xs"
                                  style={{ 
                                    backgroundColor: eventColor.badgeBg,
                                    color: eventColor.text 
                                  }}
                                >
                                  Holiday
                                </div>
                              </div>
                            </div>
                          );
                        })}

                        {/* Tournament Events */}
                        {details.events.tournament.map((event, idx) => {
                          const eventColor = EVENT_COLORS.tournament;
                          return (
                            <div
                              key={idx}
                              className="p-3 rounded-xl bg-[#1a1a1a] shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5)]"
                            >
                              <div className="flex items-center justify-between">
                                <p className="text-sm text-[#e8e8e8]">{event.name}</p>
                                <div
                                  className="px-2 py-1 rounded-lg text-xs"
                                  style={{ 
                                    backgroundColor: eventColor.badgeBg,
                                    color: eventColor.text 
                                  }}
                                >
                                  Tournament
                                </div>
                              </div>
                            </div>
                          );
                        })}

                        {/* In-house Events */}
                        {details.events['in-house-event'].map((event, idx) => {
                          const eventColor = EVENT_COLORS['in-house-event'];
                          return (
                            <div
                              key={idx}
                              className="p-3 rounded-xl bg-[#1a1a1a] shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5)]"
                            >
                              <div className="flex items-center justify-between">
                                <p className="text-sm text-[#e8e8e8]">{event.name}</p>
                                <div
                                  className="px-2 py-1 rounded-lg text-xs"
                                  style={{ 
                                    backgroundColor: eventColor.badgeBg,
                                    color: eventColor.text 
                                  }}
                                >
                                  In-house Event
                                </div>
                              </div>
                            </div>
                          );
                        })}
                      </div>
                    </div>
                  )}

                  {/* Batches Section */}
                  {details.batches.length > 0 && (
                    <div>
                      <h4 className="text-sm text-[#888888] mb-3">Batches</h4>
                      <div className="space-y-2">
                        {details.batches.map((batch, idx) => (
                          <div
                            key={idx}
                            className="p-3 rounded-xl bg-[#1a1a1a] shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5)]"
                          >
                            <div className="flex items-center justify-between">
                              <div>
                                <p className="text-sm text-[#e8e8e8]">{batch.name}</p>
                                <p className="text-xs text-[#888888] mt-1">{batch.time}</p>
                              </div>
                              <div className="px-2 py-1 rounded-lg bg-[#1a2a1a] text-xs text-[#80c080]">
                                Batch
                              </div>
                            </div>
                          </div>
                        ))}
                      </div>
                    </div>
                  )}
                </div>
              ) : (
                <div className="py-6 text-center">
                  <p className="text-sm text-[#888888]">No events or batches scheduled for this date</p>
                </div>
              )}
            </div>
          </div>
        );
      })()}

      {/* Upcoming Events */}
      <div className="px-6 pb-6">
        <h2 className="text-lg text-[#e8e8e8] mb-4">Upcoming Events</h2>
        <div className="space-y-3">
          {events
            .sort((a, b) => new Date(a.date).getTime() - new Date(b.date).getTime())
            .map((event, i) => {
              const eventColor = EVENT_COLORS[event.type];
              const eventTypeLabel = eventTypeOptions.find(opt => opt.value === event.type)?.label || event.type;
              
              return (
                <div
                  key={i}
                  className="p-4 rounded-xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)]"
                >
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="text-sm text-[#e8e8e8] mb-1">{event.name}</p>
                      <p className="text-xs text-[#888888]">
                        {new Date(event.date).toLocaleDateString('en-US', { month: 'long', day: 'numeric', year: 'numeric' })}
                      </p>
                    </div>
                    <div
                      className="px-3 py-1 rounded-lg shadow-[inset_2px_2px_4px_rgba(0,0,0,0.5)]"
                      style={{ backgroundColor: eventColor.badgeBg }}
                    >
                      <p className="text-xs" style={{ color: eventColor.text }}>
                        {eventTypeLabel}
                      </p>
                    </div>
                  </div>
                </div>
              );
            })}
        </div>
      </div>
    </div>
  );
}
