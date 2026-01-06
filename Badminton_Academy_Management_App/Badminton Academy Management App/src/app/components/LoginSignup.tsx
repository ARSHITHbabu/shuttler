import { useState } from 'react';
import { UserRole } from '../App';
import { Phone, Mail } from 'lucide-react';

interface LoginSignupProps {
  role: UserRole;
  onLoginComplete: () => void;
}

export default function LoginSignup({ role, onLoginComplete }: LoginSignupProps) {
  const [phoneNumber, setPhoneNumber] = useState('');
  const [otp, setOtp] = useState('');
  const [showOtp, setShowOtp] = useState(false);

  const handleSendOtp = () => {
    if (phoneNumber.length >= 10) {
      setShowOtp(true);
    }
  };

  const handleVerifyOtp = () => {
    if (otp.length === 6) {
      onLoginComplete();
    }
  };

  const handleSocialLogin = (provider: string) => {
    // Mock social login
    onLoginComplete();
  };

  return (
    <div className="min-h-screen flex flex-col items-center justify-center px-6 py-8">
      <div className="w-full max-w-md">
        {/* Header */}
        <div className="text-center mb-12">
          <div className="w-20 h-20 mx-auto mb-6 rounded-full bg-[#242424] flex items-center justify-center shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)]">
            <div className="text-4xl">🏸</div>
          </div>
          <h1 className="text-3xl mb-2 text-[#e8e8e8]">Badminton Academy</h1>
          <p className="text-[#888888]">
            {role === 'owner' ? 'Owner Login' : role === 'coach' ? 'Coach Login' : 'Student Login'}
          </p>
        </div>

        {/* Social Login Buttons */}
        <div className="space-y-3 mb-8">
          <button
            onClick={() => handleSocialLogin('google')}
            className="w-full p-4 rounded-xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] hover:shadow-[4px_4px_8px_rgba(0,0,0,0.5),-4px_-4px_8px_rgba(40,40,40,0.1)] transition-all duration-200 active:shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)]"
          >
            <div className="flex items-center justify-center gap-3">
              <Mail className="w-5 h-5 text-[#a0a0a0]" />
              <span className="text-[#e8e8e8]">Continue with Google</span>
            </div>
          </button>
          <button
            onClick={() => handleSocialLogin('apple')}
            className="w-full p-4 rounded-xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] hover:shadow-[4px_4px_8px_rgba(0,0,0,0.5),-4px_-4px_8px_rgba(40,40,40,0.1)] transition-all duration-200 active:shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)]"
          >
            <div className="flex items-center justify-center gap-3">
              <span className="text-xl">🍎</span>
              <span className="text-[#e8e8e8]">Continue with Apple</span>
            </div>
          </button>
          <button
            onClick={() => handleSocialLogin('facebook')}
            className="w-full p-4 rounded-xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] hover:shadow-[4px_4px_8px_rgba(0,0,0,0.5),-4px_-4px_8px_rgba(40,40,40,0.1)] transition-all duration-200 active:shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)]"
          >
            <div className="flex items-center justify-center gap-3">
              <span className="text-xl">📘</span>
              <span className="text-[#e8e8e8]">Continue with Facebook</span>
            </div>
          </button>
        </div>

        {/* Divider */}
        <div className="flex items-center gap-4 mb-8">
          <div className="flex-1 h-px bg-[#333333]"></div>
          <span className="text-sm text-[#888888]">OR</span>
          <div className="flex-1 h-px bg-[#333333]"></div>
        </div>

        {/* Phone Login */}
        {!showOtp ? (
          <div className="space-y-4">
            <div className="p-6 rounded-2xl bg-[#242424] shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)]">
              <div className="flex items-center gap-3">
                <Phone className="w-5 h-5 text-[#888888]" />
                <input
                  type="tel"
                  placeholder="Enter mobile number"
                  value={phoneNumber}
                  onChange={(e) => setPhoneNumber(e.target.value)}
                  className="flex-1 bg-transparent text-[#e8e8e8] placeholder-[#666666] outline-none"
                />
              </div>
            </div>
            <button
              onClick={handleSendOtp}
              disabled={phoneNumber.length < 10}
              className="w-full p-4 rounded-xl bg-[#2a2a2a] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] hover:shadow-[4px_4px_8px_rgba(0,0,0,0.5),-4px_-4px_8px_rgba(40,40,40,0.1)] transition-all duration-200 active:shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)] disabled:opacity-50"
            >
              <span className="text-[#e8e8e8]">Send OTP</span>
            </button>
          </div>
        ) : (
          <div className="space-y-4">
            <p className="text-sm text-[#888888] text-center mb-4">
              Enter the 6-digit code sent to {phoneNumber}
            </p>
            <div className="p-6 rounded-2xl bg-[#242424] shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)]">
              <input
                type="text"
                placeholder="000000"
                maxLength={6}
                value={otp}
                onChange={(e) => setOtp(e.target.value)}
                className="w-full bg-transparent text-[#e8e8e8] text-center text-2xl tracking-widest placeholder-[#666666] outline-none"
              />
            </div>
            <button
              onClick={handleVerifyOtp}
              disabled={otp.length !== 6}
              className="w-full p-4 rounded-xl bg-[#2a2a2a] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] hover:shadow-[4px_4px_8px_rgba(0,0,0,0.5),-4px_-4px_8px_rgba(40,40,40,0.1)] transition-all duration-200 active:shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)] disabled:opacity-50"
            >
              <span className="text-[#e8e8e8]">Verify & Continue</span>
            </button>
            <button
              onClick={() => setShowOtp(false)}
              className="w-full text-sm text-[#888888] underline"
            >
              Change number
            </button>
          </div>
        )}
      </div>
    </div>
  );
}
