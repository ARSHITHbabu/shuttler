import { useState } from 'react';
import { FileText, Download, Calendar, Users, DollarSign, TrendingUp } from 'lucide-react';

export default function ReportsScreen() {
  const [selectedType, setSelectedType] = useState<'attendance' | 'fee' | 'performance' | null>(null);
  const [dateRange, setDateRange] = useState({ start: '', end: '' });

  const reportTypes = [
    { id: 'attendance', icon: Users, title: 'Attendance Report', description: 'Student attendance summary' },
    { id: 'fee', icon: DollarSign, title: 'Fee Report', description: 'Fee collection & pending' },
    { id: 'performance', icon: TrendingUp, title: 'Performance Report', description: 'Student skill progress' },
  ];

  const generatedReports = [
    { id: 1, type: 'Attendance Report', period: 'Dec 2025', generatedOn: '2026-01-01' },
    { id: 2, type: 'Fee Report', period: 'Dec 2025', generatedOn: '2026-01-01' },
    { id: 3, type: 'Performance Report', period: 'Q4 2025', generatedOn: '2025-12-30' },
  ];

  if (selectedType) {
    return (
      <div className="min-h-screen pt-6">
        <div className="px-6 mb-6">
          <button
            onClick={() => setSelectedType(null)}
            className="mb-4 text-sm text-[#888888]"
          >
            ← Back
          </button>
          <h1 className="text-2xl text-[#e8e8e8] mb-2">
            {reportTypes.find(r => r.id === selectedType)?.title}
          </h1>
          <p className="text-sm text-[#888888]">Configure and generate report</p>
        </div>

        <div className="px-6 space-y-4 pb-6">
          {/* Date Range */}
          <div className="p-5 rounded-2xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)]">
            <p className="text-sm text-[#888888] mb-4">Select Date Range</p>
            <div className="space-y-3">
              <div className="p-4 rounded-xl bg-[#1a1a1a] shadow-[inset_2px_2px_4px_rgba(0,0,0,0.5)]">
                <p className="text-xs text-[#888888] mb-2">Start Date</p>
                <input
                  type="date"
                  value={dateRange.start}
                  onChange={(e) => setDateRange(prev => ({ ...prev, start: e.target.value }))}
                  className="w-full bg-transparent text-[#e8e8e8] outline-none"
                />
              </div>
              <div className="p-4 rounded-xl bg-[#1a1a1a] shadow-[inset_2px_2px_4px_rgba(0,0,0,0.5)]">
                <p className="text-xs text-[#888888] mb-2">End Date</p>
                <input
                  type="date"
                  value={dateRange.end}
                  onChange={(e) => setDateRange(prev => ({ ...prev, end: e.target.value }))}
                  className="w-full bg-transparent text-[#e8e8e8] outline-none"
                />
              </div>
            </div>
          </div>

          {/* Filters */}
          {selectedType === 'attendance' && (
            <div className="p-5 rounded-2xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)]">
              <p className="text-sm text-[#888888] mb-3">Select Batch</p>
              <select className="w-full p-4 rounded-xl bg-[#1a1a1a] text-[#e8e8e8] shadow-[inset_2px_2px_4px_rgba(0,0,0,0.5)] outline-none">
                <option value="all">All Batches</option>
                <option value="1">Morning Batch A</option>
                <option value="2">Evening Batch B</option>
                <option value="3">Weekend Batch</option>
              </select>
            </div>
          )}

          {selectedType === 'fee' && (
            <div className="p-5 rounded-2xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)]">
              <p className="text-sm text-[#888888] mb-3">Status Filter</p>
              <div className="space-y-2">
                {['All', 'Paid', 'Pending', 'Overdue'].map((status) => (
                  <label key={status} className="flex items-center gap-3 p-3 rounded-xl bg-[#1a1a1a] cursor-pointer">
                    <input type="checkbox" className="w-4 h-4" defaultChecked={status === 'All'} />
                    <span className="text-sm text-[#e8e8e8]">{status}</span>
                  </label>
                ))}
              </div>
            </div>
          )}

          {/* Generate Button */}
          <button className="w-full p-4 rounded-xl bg-[#2a2a2a] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] hover:shadow-[4px_4px_8px_rgba(0,0,0,0.5),-4px_-4px_8px_rgba(40,40,40,0.1)] transition-all duration-200 active:shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)]">
            <div className="flex items-center justify-center gap-2">
              <FileText className="w-5 h-5 text-[#c0c0c0]" />
              <span className="text-[#e8e8e8]">Generate Report</span>
            </div>
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen pt-6">
      <div className="px-6 mb-6">
        <h1 className="text-2xl text-[#e8e8e8] mb-2">Reports</h1>
        <p className="text-sm text-[#888888]">Generate and download reports</p>
      </div>

      {/* Report Types */}
      <div className="px-6 mb-8">
        <h2 className="text-lg text-[#e8e8e8] mb-4">Generate New Report</h2>
        <div className="space-y-3">
          {reportTypes.map((type) => (
            <button
              key={type.id}
              onClick={() => setSelectedType(type.id as any)}
              className="w-full p-5 rounded-2xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] active:shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)] transition-all duration-200 text-left"
            >
              <div className="flex items-center gap-4">
                <div className="w-12 h-12 rounded-xl bg-[#1a1a1a] flex items-center justify-center shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)]">
                  <type.icon className="w-6 h-6 text-[#a0a0a0]" />
                </div>
                <div className="flex-1">
                  <h3 className="text-sm text-[#e8e8e8] mb-1">{type.title}</h3>
                  <p className="text-xs text-[#888888]">{type.description}</p>
                </div>
              </div>
            </button>
          ))}
        </div>
      </div>

      {/* Recent Reports */}
      <div className="px-6 pb-6">
        <h2 className="text-lg text-[#e8e8e8] mb-4">Recent Reports</h2>
        <div className="space-y-3">
          {generatedReports.map((report) => (
            <div
              key={report.id}
              className="p-5 rounded-2xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)]"
            >
              <div className="flex items-start justify-between mb-3">
                <div>
                  <h3 className="text-sm text-[#e8e8e8] mb-1">{report.type}</h3>
                  <p className="text-xs text-[#888888]">{report.period}</p>
                </div>
                <button className="w-10 h-10 rounded-xl bg-[#1a1a1a] shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)] flex items-center justify-center">
                  <Download className="w-4 h-4 text-[#a0a0a0]" />
                </button>
              </div>
              <div className="flex items-center gap-2 text-xs text-[#888888]">
                <Calendar className="w-3 h-3" />
                <span>Generated on {new Date(report.generatedOn).toLocaleDateString()}</span>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
