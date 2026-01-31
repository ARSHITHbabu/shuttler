/// Legal content for Privacy Policy, Terms & Conditions, and Help & Support
/// This content is shared across all portals (Owner, Coach, Student)

class LegalContent {
  // App name used in legal documents
  static const String appName = 'Shuttler';
  static const String companyName = 'Shuttler Technologies';
  static const String supportEmail = 'support@shuttler.app';
  static const String supportPhone = '+91 1234567890';
  static const String websiteUrl = 'https://shuttler.app';
  static const String lastUpdated = 'January 25, 2026';

  // ============================================
  // PRIVACY POLICY CONTENT
  // ============================================

  static const String privacyPolicyTitle = 'Privacy Policy';

  static const String privacyPolicyIntro = '''
Welcome to $appName. We are committed to protecting your privacy and ensuring the security of your personal information. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our badminton academy management application.

Please read this privacy policy carefully. By using $appName, you agree to the collection and use of information in accordance with this policy.''';

  static const List<Map<String, dynamic>> privacyPolicySections = [
    {
      'title': '1. Information We Collect',
      'content': '''We collect information that you provide directly to us when registering and using the app:

Personal Information:
- Full name
- Email address
- Phone number
- Date of birth
- Profile photograph
- Physical address

Student-Specific Information:
- Guardian/parent name and contact details
- T-shirt size (for academy uniforms)

Coach-Specific Information:
- Professional specialization
- Years of experience
- Certifications (if provided)

Academy Owner Information:
- Academy name and address
- Business contact details

Health & Performance Data:
- Height and weight (for BMI tracking)
- Attendance records
- Performance metrics (skill ratings for serve, smash, footwork, defense, stamina)
- Training progress data

Financial Information:
- Fee payment records
- Payment history and methods
- Due dates and payment status

Technical Information:
- Device information (device type, operating system)
- FCM tokens for push notifications
- App usage data and preferences
- Login timestamps'''
    },
    {
      'title': '2. How We Use Your Information',
      'content': '''We use the information we collect to:

Academy Management:
- Facilitate batch enrollment and management
- Track student attendance and coach presence
- Monitor and record performance progress
- Manage fee collection and payment records
- Send important announcements and notifications

Communication:
- Send push notifications about schedules, events, and updates
- Notify about fee due dates and payment reminders
- Alert about attendance and session reminders
- Share academy announcements and important notices

Health Monitoring:
- Calculate and track BMI for health awareness
- Provide health status insights based on BMI data
- Enable coaches to monitor student physical development

Performance Tracking:
- Record skill assessments and ratings
- Generate performance reports
- Track improvement over time
- Provide insights to coaches and students

Administrative Purposes:
- Generate reports for academy operations
- Maintain accurate records
- Ensure smooth functioning of the academy
- Customer support and issue resolution'''
    },
    {
      'title': '3. Information Sharing and Disclosure',
      'content': '''We do not sell, trade, or rent your personal information to third parties. We may share your information in the following circumstances:

Within the Academy:
- Coaches can view information of students assigned to their batches
- Academy owners have access to all student and coach data for management purposes
- Students can only view their own personal data

With Your Consent:
- When you explicitly authorize us to share your information

Legal Requirements:
- To comply with applicable laws, regulations, or legal processes
- To respond to lawful requests from government authorities
- To protect our rights, privacy, safety, or property

Service Providers:
- With trusted third-party services that help us operate the app (e.g., cloud hosting, notification services)
- These providers are bound by confidentiality agreements'''
    },
    {
      'title': '4. Data Storage and Security',
      'content': '''Data Storage:
- Your data is stored on secure servers using PostgreSQL database
- Profile photos and documents are stored securely
- We maintain regular backups to prevent data loss

Security Measures:
- Passwords are encrypted using bcrypt hashing
- API communications are secured with JWT authentication
- HTTPS encryption for all data transmission
- Regular security audits and updates
- Access controls to limit data exposure

Data Retention:
- We retain your data for as long as your account is active
- Fee and attendance records are maintained as per legal requirements
- You can request data deletion by contacting us
- Some data may be retained for legal or administrative purposes'''
    },
    {
      'title': '5. Your Rights and Choices',
      'content': '''You have the following rights regarding your personal information:

Access:
- View your personal data through the app's profile section
- Request a copy of all data we hold about you

Correction:
- Update your profile information at any time
- Request corrections to inaccurate data

Deletion:
- Request deletion of your account and associated data
- Note: Some data may be retained for legal purposes

Notifications:
- Control push notification preferences in settings
- Opt out of non-essential communications

Data Portability:
- Request your data in a portable format
- Export reports and records where available'''
    },
    {
      'title': '6. Children\'s Privacy',
      'content': '''$appName is used by badminton academies that may include minors:

- For users under 18, parental/guardian consent is required
- Guardian contact information is collected for minor students
- Parents/guardians can access their child's data
- We take extra precautions to protect minor's data
- Parents/guardians can request data modification or deletion'''
    },
    {
      'title': '7. Push Notifications',
      'content': '''We use Firebase Cloud Messaging (FCM) to send push notifications:

- Notifications about session schedules and changes
- Fee payment reminders and confirmations
- Academy announcements and updates
- Attendance and performance updates

You can disable notifications:
- Through the app settings
- Through your device settings'''
    },
    {
      'title': '8. Changes to This Policy',
      'content': '''We may update this Privacy Policy from time to time:

- We will notify you of significant changes through the app
- Continued use of the app after changes constitutes acceptance
- The "Last Updated" date indicates when changes were made
- We encourage you to review this policy periodically'''
    },
    {
      'title': '9. Contact Us',
      'content': '''If you have questions about this Privacy Policy or our data practices, please contact us:

Email: $supportEmail
Phone: $supportPhone
Website: $websiteUrl

You can also reach out through the Help & Support section in the app.'''
    },
  ];

  // ============================================
  // TERMS AND CONDITIONS CONTENT
  // ============================================

  static const String termsTitle = 'Terms and Conditions';

  static const String termsIntro = '''
Welcome to $appName! These Terms and Conditions govern your use of our badminton academy management application. By downloading, installing, or using $appName, you agree to be bound by these terms.

Please read these terms carefully before using the application.''';

  static const List<Map<String, dynamic>> termsSections = [
    {
      'title': '1. Acceptance of Terms',
      'content': '''By accessing or using $appName, you agree to:

- Be bound by these Terms and Conditions
- Comply with all applicable laws and regulations
- Accept our Privacy Policy
- Be at least 18 years old, or have parental/guardian consent if a minor

If you do not agree with any part of these terms, you must not use the application.'''
    },
    {
      'title': '2. User Accounts',
      'content': '''Account Creation:
- You must provide accurate and complete information during registration
- You are responsible for maintaining the confidentiality of your credentials
- You must notify us immediately of any unauthorized account access
- One person may not have multiple accounts

Account Types:
- Owner Account: For academy administrators with full management access
- Coach Account: For coaches with access to assigned batches and students
- Student Account: For students/parents with view access to their own data

Account Responsibility:
- You are responsible for all activities under your account
- You must not share your login credentials
- You must update your information if it changes'''
    },
    {
      'title': '3. Acceptable Use',
      'content': '''You agree to use $appName only for its intended purpose. You must NOT:

- Use the app for any illegal or unauthorized purpose
- Attempt to gain unauthorized access to any part of the system
- Upload malicious code, viruses, or harmful content
- Harass, abuse, or harm other users
- Impersonate another person or entity
- Share false or misleading information
- Use the app to spam or send unsolicited messages
- Attempt to reverse engineer or modify the application
- Use automated systems to access the app
- Violate any applicable laws or regulations'''
    },
    {
      'title': '4. Data Accuracy',
      'content': '''Users are responsible for:

- Providing accurate personal information
- Keeping their profile information up to date
- Ensuring attendance records are marked correctly (Coaches/Owners)
- Recording accurate fee payments and amounts
- Entering correct performance assessments
- Updating student health data accurately (BMI)

Academy owners and coaches should:
- Verify student information before enrollment
- Maintain accurate batch and schedule information
- Record attendance and fees promptly and accurately'''
    },
    {
      'title': '5. Fees and Payments',
      'content': '''Fee Management:
- Academy owners set batch fees and payment schedules
- Fee records in the app are for tracking purposes
- Actual payment transactions occur outside the app
- The app tracks payment status (paid, pending, overdue)

Payment Recording:
- Owners/coaches record payments received
- Students can view their fee status and history
- Payment reminders are sent based on due dates

Disputes:
- Fee disputes should be resolved directly with the academy
- We are not responsible for payment disputes between users and academies'''
    },
    {
      'title': '6. Intellectual Property',
      'content': '''Ownership:
- $appName and its content are owned by $companyName
- The app's design, features, and functionality are our property
- You may not copy, modify, or distribute any part of the app

User Content:
- You retain ownership of content you upload (e.g., profile photos)
- You grant us a license to use this content to provide our services
- You must have the right to upload any content you share

Trademarks:
- "$appName" and our logo are trademarks of $companyName
- You may not use our trademarks without permission'''
    },
    {
      'title': '7. Limitation of Liability',
      'content': '''$appName is provided "as is" without warranties of any kind.

We are not liable for:
- Any indirect, incidental, or consequential damages
- Loss of data or unauthorized access to your data
- Interruptions or errors in the service
- Actions taken by other users
- Decisions made based on app data

Maximum Liability:
- Our liability is limited to the amount paid for the service
- We do not guarantee uninterrupted or error-free service

Academy Responsibility:
- Academies are responsible for their operations
- We are a platform and not responsible for academy decisions'''
    },
    {
      'title': '8. Service Availability',
      'content': '''We strive to maintain consistent service but:

- We may perform maintenance that temporarily affects access
- Service may be interrupted due to technical issues
- We reserve the right to modify or discontinue features
- We will try to notify users of significant changes

Offline Functionality:
- Some features require an internet connection
- Data may be cached locally for offline access
- Sync occurs when connection is restored'''
    },
    {
      'title': '9. Termination',
      'content': '''Account Termination by User:
- You may stop using the app at any time
- You can request account deletion through settings or support
- Some data may be retained as required by law

Termination by Us:
- We may suspend or terminate accounts that violate these terms
- We may terminate accounts for extended inactivity
- We will notify you of termination when possible

Effect of Termination:
- Your access to the app will be revoked
- Your data may be deleted after a retention period
- Certain provisions of these terms survive termination'''
    },
    {
      'title': '10. Modifications to Terms',
      'content': '''We may update these Terms and Conditions:

- Changes will be posted in the app
- Material changes will be notified through the app
- Continued use after changes indicates acceptance
- If you disagree with changes, you should stop using the app

We encourage you to review these terms periodically.'''
    },
    {
      'title': '11. Governing Law',
      'content': '''These Terms and Conditions are governed by:

- The laws of India
- Any disputes will be resolved in courts of competent jurisdiction
- You agree to submit to the jurisdiction of these courts

Dispute Resolution:
- We encourage resolving disputes through communication first
- Contact our support team for any concerns
- Legal action should be a last resort'''
    },
    {
      'title': '12. Contact Information',
      'content': '''For questions about these Terms and Conditions:

Email: $supportEmail
Phone: $supportPhone
Website: $websiteUrl

You can also use the Help & Support section in the app for assistance.'''
    },
  ];

  // ============================================
  // HELP AND SUPPORT CONTENT
  // ============================================

  static const String helpTitle = 'Help & Support';

  static const List<Map<String, dynamic>> faqSections = [
    {
      'title': 'Getting Started',
      'questions': [
        {
          'question': 'How do I create an account?',
          'answer': 'You can create an account by tapping "Sign Up" on the login screen. Select your role (Student, Coach, or Owner), fill in your details, and verify your email to get started.'
        },
        {
          'question': 'I forgot my password. How do I reset it?',
          'answer': 'On the login screen, tap "Forgot Password" and enter your registered email address. You will receive a link to reset your password.'
        },
        {
          'question': 'How do I update my profile information?',
          'answer': 'Go to Settings > Profile or tap on your profile icon. You can edit your name, contact details, and profile photo from there.'
        },
      ],
    },
    {
      'title': 'For Students',
      'questions': [
        {
          'question': 'How can I view my attendance?',
          'answer': 'Go to the Attendance screen from the bottom navigation. You can see your attendance history for each batch you are enrolled in.'
        },
        {
          'question': 'How do I check my fee status?',
          'answer': 'Navigate to More > Fee Status to view your pending fees, payment history, and due dates.'
        },
        {
          'question': 'Where can I see my performance ratings?',
          'answer': 'Go to the Performance screen to view your skill ratings across different areas like serve, smash, footwork, defense, and stamina.'
        },
        {
          'question': 'How do I view my BMI records?',
          'answer': 'Access More > BMI Tracker to see your BMI history, current health status, and track your progress over time.'
        },
      ],
    },
    {
      'title': 'For Coaches',
      'questions': [
        {
          'question': 'How do I mark attendance for my batch?',
          'answer': 'Go to the Attendance screen, select your batch and date, then mark each student as present or absent. Don\'t forget to tap Save.'
        },
        {
          'question': 'How do I record student performance?',
          'answer': 'Navigate to More > Performance Tracking, select a batch and student, then rate their skills on a scale of 1-5 and add any comments.'
        },
        {
          'question': 'Can I view the academy calendar?',
          'answer': 'Yes, go to More > Calendar to view holidays, events, and tournaments scheduled by the academy.'
        },
        {
          'question': 'How do I update my schedule?',
          'answer': 'Go to More > Schedule to view your assigned batches and their operating days. Contact the academy owner to make changes to your schedule.'
        },
      ],
    },
    {
      'title': 'For Academy Owners',
      'questions': [
        {
          'question': 'How do I add a new student?',
          'answer': 'Go to the Students screen and tap the + button. Fill in the student details and assign them to a batch.'
        },
        {
          'question': 'How do I create a new batch?',
          'answer': 'Navigate to the Batches screen, tap + to create a new batch. Set the name, timing, fees, capacity, and assign a coach.'
        },
        {
          'question': 'How do I record fee payments?',
          'answer': 'Go to the student\'s profile or the Fees section, select the student, and record the payment with the amount and method.'
        },
        {
          'question': 'How do I send announcements?',
          'answer': 'Go to More > Announcements, tap + to create a new announcement. Set the title, message, and target audience (all, students, or coaches).'
        },
        {
          'question': 'How do I generate reports?',
          'answer': 'Navigate to More > Reports to generate attendance, fee, or performance reports. You can filter by date range and export as PDF.'
        },
      ],
    },
    {
      'title': 'Technical Issues',
      'questions': [
        {
          'question': 'The app is running slow. What should I do?',
          'answer': 'Try clearing the cache from Settings > Clear Cache. Also ensure you have a stable internet connection and your app is updated to the latest version.'
        },
        {
          'question': 'I\'m not receiving push notifications.',
          'answer': 'Check that notifications are enabled in the app Settings and in your device settings. Make sure the app has permission to send notifications.'
        },
        {
          'question': 'My data is not syncing.',
          'answer': 'Ensure you have an active internet connection. Try refreshing the screen by pulling down. If the issue persists, try logging out and back in.'
        },
      ],
    },
  ];

  static const List<Map<String, String>> contactOptions = [
    {
      'type': 'email',
      'title': 'Email Support',
      'value': supportEmail,
      'description': 'Get a response within 24-48 hours',
    },
    {
      'type': 'phone',
      'title': 'Phone Support',
      'value': supportPhone,
      'description': 'Available Mon-Sat, 9 AM - 6 PM',
    },
  ];
}
