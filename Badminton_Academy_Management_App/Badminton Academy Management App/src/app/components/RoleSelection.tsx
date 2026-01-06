import { UserCircle, Users, GraduationCap } from 'lucide-react';
import { UserRole } from '../App';

interface RoleSelectionProps {
  onRoleSelect: (role: UserRole) => void;
}

export default function RoleSelection({ onRoleSelect }: RoleSelectionProps) {
  const roles = [
    {
      id: 'owner' as UserRole,
      icon: UserCircle,
      title: 'Owner',
      description: 'Manage academy operations'
    },
    {
      id: 'coach' as UserRole,
      icon: Users,
      title: 'Coach',
      description: 'Track student progress'
    },
    {
      id: 'student' as UserRole,
      icon: GraduationCap,
      title: 'Student',
      description: 'View your schedule & stats'
    }
  ];

  return (
    <div className="min-h-screen flex flex-col items-center justify-center px-6 py-8">
      <div className="w-full max-w-md">
        {/* Header */}
        <div className="text-center mb-12">
          <div className="w-20 h-20 mx-auto mb-6 rounded-full bg-[#242424] flex items-center justify-center shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)]">
            <div className="text-4xl">🏸</div>
          </div>
          <h1 className="text-3xl mb-2 text-[#e8e8e8]">Badminton Academy</h1>
          <p className="text-[#888888]">Select your role to continue</p>
        </div>

        {/* Role Cards */}
        <div className="space-y-4">
          {roles.map((role) => (
            <button
              key={role.id}
              onClick={() => onRoleSelect(role.id)}
              className="w-full p-6 rounded-2xl bg-[#242424] shadow-[8px_8px_16px_rgba(0,0,0,0.5),-8px_-8px_16px_rgba(40,40,40,0.1)] hover:shadow-[4px_4px_8px_rgba(0,0,0,0.5),-4px_-4px_8px_rgba(40,40,40,0.1)] transition-all duration-200 active:shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)]"
            >
              <div className="flex items-center gap-4">
                <div className="w-14 h-14 rounded-xl bg-[#1a1a1a] flex items-center justify-center shadow-[inset_4px_4px_8px_rgba(0,0,0,0.5),inset_-4px_-4px_8px_rgba(40,40,40,0.1)]">
                  <role.icon className="w-7 h-7 text-[#a0a0a0]" />
                </div>
                <div className="flex-1 text-left">
                  <h3 className="text-xl text-[#e8e8e8] mb-1">{role.title}</h3>
                  <p className="text-sm text-[#888888]">{role.description}</p>
                </div>
              </div>
            </button>
          ))}
        </div>
      </div>
    </div>
  );
}
