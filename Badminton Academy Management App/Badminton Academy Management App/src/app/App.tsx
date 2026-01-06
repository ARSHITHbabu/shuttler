import { useState } from 'react';
import RoleSelection from './components/RoleSelection';
import LoginSignup from './components/LoginSignup';
import AcademySetup from './components/AcademySetup';
import OwnerDashboard from './components/OwnerDashboard';

export type AppScreen = 
  | 'role-selection'
  | 'login'
  | 'academy-setup'
  | 'owner-dashboard';

export type UserRole = 'owner' | 'coach' | 'student' | null;

function App() {
  const [currentScreen, setCurrentScreen] = useState<AppScreen>('role-selection');
  const [selectedRole, setSelectedRole] = useState<UserRole>(null);

  const handleRoleSelect = (role: UserRole) => {
    setSelectedRole(role);
    setCurrentScreen('login');
  };

  const handleLoginComplete = () => {
    // For owner, check if first time (academy setup needed)
    if (selectedRole === 'owner') {
      // In real app, check if academy is set up
      const isFirstTime = false; // Mock: skip setup for demo, set to true to show setup
      setCurrentScreen(isFirstTime ? 'academy-setup' : 'owner-dashboard');
    }
  };

  const handleAcademySetupComplete = () => {
    setCurrentScreen('owner-dashboard');
  };

  return (
    <div className="min-h-screen bg-gradient-to-b from-[#1a1a1a] to-[#0f0f0f] overflow-x-hidden">
      {currentScreen === 'role-selection' && (
        <RoleSelection onRoleSelect={handleRoleSelect} />
      )}
      {currentScreen === 'login' && (
        <LoginSignup role={selectedRole} onLoginComplete={handleLoginComplete} />
      )}
      {currentScreen === 'academy-setup' && (
        <AcademySetup onSetupComplete={handleAcademySetupComplete} />
      )}
      {currentScreen === 'owner-dashboard' && (
        <OwnerDashboard />
      )}
    </div>
  );
}

export default App;