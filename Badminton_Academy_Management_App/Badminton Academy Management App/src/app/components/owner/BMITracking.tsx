import { useState } from 'react';
import { ArrowLeft, Plus, TrendingUp } from 'lucide-react';

interface BMITrackingProps {
  student: any;
  onBack: () => void;
}

export default function BMITracking({ student, onBack }: BMITrackingProps) {
  const [showAddForm, setShowAddForm] = useState(false);
  const [height, setHeight] = useState('');
  const [weight, setWeight] = useState('');

  const calculateBMI = () => {
    if (height && weight) {
      const h = parseFloat(height) / 100; // convert cm to m
      const w = parseFloat(weight);
      return (w / (h * h)).toFixed(1);
    }
    return '';
  };

  const bmiHistory = [
    { date: '2026-01-01', height: 165, weight: 58, bmi: 21.3 },
    { date: '2025-12-01', height: 164, weight: 57, bmi: 21.2 },
    { date: '2025-11-01', height: 163, weight: 56, bmi: 21.1 },
  ];

  if (showAddForm) {
    const bmi = calculateBMI();

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
          <h1 className="text-xl text-[#e8e8e8]">Add BMI Record</h1>
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

          <div className="p-6 rounded-2xl bg-[#242424] shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)]">
            <p className="text-sm text-[#888888] mb-3">Height (cm)</p>
            <input
              type="number"
              placeholder="165"
              value={height}
              onChange={(e) => setHeight(e.target.value)}
              className="w-full bg-transparent text-[#e8e8e8] text-2xl placeholder-[#666666] outline-none"
            />
          </div>

          <div className="p-6 rounded-2xl bg-[#242424] shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)]">
            <p className="text-sm text-[#888888] mb-3">Weight (kg)</p>
            <input
              type="number"
              placeholder="58"
              value={weight}
              onChange={(e) => setWeight(e.target.value)}
              className="w-full bg-transparent text-[#e8e8e8] text-2xl placeholder-[#666666] outline-none"
            />
          </div>

          {bmi && (
            <div className="p-6 rounded-2xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)]">
              <p className="text-sm text-[#888888] mb-2">Calculated BMI</p>
              <p className="text-4xl text-[#e8e8e8]">{bmi}</p>
              <p className="text-xs text-[#888888] mt-2">Normal range: 18.5 - 24.9</p>
            </div>
          )}

          <button
            disabled={!height || !weight}
            className="w-full p-4 rounded-xl bg-[#2a2a2a] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] hover:shadow-[4px_4px_8px_rgba(0,0,0,0.5),-4px_-4px_8px_rgba(40,40,40,0.1)] transition-all duration-200 active:shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)] disabled:opacity-50"
          >
            <span className="text-[#e8e8e8]">Save BMI Record</span>
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
        <h1 className="text-xl text-[#e8e8e8] flex-1">BMI Tracking</h1>
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

        {/* Latest BMI */}
        <div className="p-6 rounded-2xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] mb-6">
          <div className="flex items-center gap-3 mb-4">
            <div className="w-12 h-12 rounded-xl bg-[#1a1a1a] flex items-center justify-center shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)]">
              <TrendingUp className="w-6 h-6 text-[#a0a0a0]" />
            </div>
            <div>
              <p className="text-sm text-[#888888]">Latest BMI</p>
              <p className="text-3xl text-[#e8e8e8]">{bmiHistory[0].bmi}</p>
            </div>
          </div>
          <div className="grid grid-cols-2 gap-3">
            <div className="p-3 rounded-xl bg-[#1a1a1a] shadow-[inset_2px_2px_4px_rgba(0,0,0,0.5)]">
              <p className="text-xs text-[#888888]">Height</p>
              <p className="text-lg text-[#a0a0a0]">{bmiHistory[0].height} cm</p>
            </div>
            <div className="p-3 rounded-xl bg-[#1a1a1a] shadow-[inset_2px_2px_4px_rgba(0,0,0,0.5)]">
              <p className="text-xs text-[#888888]">Weight</p>
              <p className="text-lg text-[#a0a0a0]">{bmiHistory[0].weight} kg</p>
            </div>
          </div>
        </div>

        <h2 className="text-lg text-[#e8e8e8] mb-4">BMI History</h2>
        
        <div className="space-y-3">
          {bmiHistory.map((entry, i) => (
            <div
              key={i}
              className="p-5 rounded-2xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)]"
            >
              <div className="flex items-center justify-between mb-3">
                <p className="text-sm text-[#888888]">
                  {new Date(entry.date).toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric' })}
                </p>
                <p className="text-xl text-[#e8e8e8]">{entry.bmi}</p>
              </div>
              <div className="flex items-center gap-4 text-sm text-[#a0a0a0]">
                <span>Height: {entry.height} cm</span>
                <span>Weight: {entry.weight} kg</span>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
