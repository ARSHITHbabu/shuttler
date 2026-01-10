import { useState } from 'react';
import { Building2, User, Phone, Mail, MapPin, Camera } from 'lucide-react';

interface AcademySetupProps {
  onSetupComplete: () => void;
}

export default function AcademySetup({ onSetupComplete }: AcademySetupProps) {
  const [step, setStep] = useState(1);
  const [formData, setFormData] = useState({
    academyName: '',
    ownerName: '',
    phone: '',
    email: '',
    address: '',
    city: '',
    state: '',
  });

  const handleNext = () => {
    if (step < 3) {
      setStep(step + 1);
    } else {
      onSetupComplete();
    }
  };

  const updateField = (field: string, value: string) => {
    setFormData({ ...formData, [field]: value });
  };

  return (
    <div className="min-h-screen flex flex-col px-6 py-8">
      {/* Header */}
      <div className="text-center mb-8">
        <h1 className="text-2xl text-[#e8e8e8] mb-2">Academy Setup</h1>
        <p className="text-sm text-[#888888]">Step {step} of 3</p>
      </div>

      {/* Progress Indicator */}
      <div className="flex gap-2 mb-8">
        {[1, 2, 3].map((s) => (
          <div
            key={s}
            className={`flex-1 h-1 rounded-full ${
              s <= step ? 'bg-[#505050]' : 'bg-[#2a2a2a]'
            }`}
          />
        ))}
      </div>

      {/* Form Content */}
      <div className="flex-1 mb-6">
        {step === 1 && (
          <div className="space-y-6">
            <div className="text-center mb-8">
              <div className="w-24 h-24 mx-auto mb-4 rounded-2xl bg-[#242424] flex items-center justify-center shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)]">
                <Camera className="w-10 h-10 text-[#888888]" />
              </div>
              <p className="text-sm text-[#888888]">Upload academy logo (optional)</p>
            </div>

            <div className="space-y-4">
              <div className="p-6 rounded-2xl bg-[#242424] shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)]">
                <div className="flex items-center gap-3">
                  <Building2 className="w-5 h-5 text-[#888888]" />
                  <input
                    type="text"
                    placeholder="Academy Name *"
                    value={formData.academyName}
                    onChange={(e) => updateField('academyName', e.target.value)}
                    className="flex-1 bg-transparent text-[#e8e8e8] placeholder-[#666666] outline-none"
                  />
                </div>
              </div>
            </div>
          </div>
        )}

        {step === 2 && (
          <div className="space-y-4">
            <div className="p-6 rounded-2xl bg-[#242424] shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)]">
              <div className="flex items-center gap-3">
                <User className="w-5 h-5 text-[#888888]" />
                <input
                  type="text"
                  placeholder="Owner Name *"
                  value={formData.ownerName}
                  onChange={(e) => updateField('ownerName', e.target.value)}
                  className="flex-1 bg-transparent text-[#e8e8e8] placeholder-[#666666] outline-none"
                />
              </div>
            </div>

            <div className="p-6 rounded-2xl bg-[#242424] shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)]">
              <div className="flex items-center gap-3">
                <Phone className="w-5 h-5 text-[#888888]" />
                <input
                  type="tel"
                  placeholder="Phone Number *"
                  value={formData.phone}
                  onChange={(e) => updateField('phone', e.target.value)}
                  className="flex-1 bg-transparent text-[#e8e8e8] placeholder-[#666666] outline-none"
                />
              </div>
            </div>

            <div className="p-6 rounded-2xl bg-[#242424] shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)]">
              <div className="flex items-center gap-3">
                <Mail className="w-5 h-5 text-[#888888]" />
                <input
                  type="email"
                  placeholder="Email Address *"
                  value={formData.email}
                  onChange={(e) => updateField('email', e.target.value)}
                  className="flex-1 bg-transparent text-[#e8e8e8] placeholder-[#666666] outline-none"
                />
              </div>
            </div>
          </div>
        )}

        {step === 3 && (
          <div className="space-y-4">
            <div className="p-6 rounded-2xl bg-[#242424] shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)]">
              <div className="flex items-start gap-3">
                <MapPin className="w-5 h-5 text-[#888888] mt-1" />
                <textarea
                  placeholder="Academy Address *"
                  value={formData.address}
                  onChange={(e) => updateField('address', e.target.value)}
                  rows={3}
                  className="flex-1 bg-transparent text-[#e8e8e8] placeholder-[#666666] outline-none resize-none"
                />
              </div>
            </div>

            <div className="grid grid-cols-2 gap-4">
              <div className="p-6 rounded-2xl bg-[#242424] shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)]">
                <input
                  type="text"
                  placeholder="City *"
                  value={formData.city}
                  onChange={(e) => updateField('city', e.target.value)}
                  className="w-full bg-transparent text-[#e8e8e8] placeholder-[#666666] outline-none"
                />
              </div>

              <div className="p-6 rounded-2xl bg-[#242424] shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)]">
                <input
                  type="text"
                  placeholder="State *"
                  value={formData.state}
                  onChange={(e) => updateField('state', e.target.value)}
                  className="w-full bg-transparent text-[#e8e8e8] placeholder-[#666666] outline-none"
                />
              </div>
            </div>

            <div className="p-4 rounded-xl bg-[#1a1a1a] border border-[#2a2a2a]">
              <p className="text-xs text-[#888888] text-center">
                📍 You can add a map pin location later from settings
              </p>
            </div>
          </div>
        )}
      </div>

      {/* Bottom Buttons */}
      <div className="space-y-3">
        <button
          onClick={handleNext}
          className="w-full p-4 rounded-xl bg-[#2a2a2a] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] hover:shadow-[4px_4px_8px_rgba(0,0,0,0.5),-4px_-4px_8px_rgba(40,40,40,0.1)] transition-all duration-200 active:shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)]"
        >
          <span className="text-[#e8e8e8]">
            {step === 3 ? 'Complete Setup' : 'Continue'}
          </span>
        </button>
        {step > 1 && (
          <button
            onClick={() => setStep(step - 1)}
            className="w-full p-4 text-[#888888]"
          >
            Back
          </button>
        )}
      </div>
    </div>
  );
}
