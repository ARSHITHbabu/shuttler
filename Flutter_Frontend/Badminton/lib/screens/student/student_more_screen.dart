import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../providers/auth_provider.dart';
import '../../providers/service_providers.dart';

/// Student More Screen - Navigation hub for additional features
/// All features are READ-ONLY for students
class StudentMoreScreen extends ConsumerStatefulWidget {
  const StudentMoreScreen({super.key});

  @override
  ConsumerState<StudentMoreScreen> createState() => _StudentMoreScreenState();
}

class _StudentMoreScreenState extends ConsumerState<StudentMoreScreen> {
  String? _currentView;
  Map<String, dynamic> _studentData = {};

  @override
  void initState() {
    super.initState();
    _loadStudentData();
  }

  Future<void> _loadStudentData() async {
    try {
      final storageService = ref.read(storageServiceProvider);
      final apiService = ref.read(apiServiceProvider);
      final userId = storageService.getUserId();

      if (userId != null) {
        final response = await apiService.get('/api/students/$userId');
        if (response.statusCode == 200 && mounted) {
          setState(() {
            _studentData = Map<String, dynamic>.from(response.data);
          });
        }
      }
    } catch (e) {
      // Ignore errors for now
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_currentView != null) {
      return _buildSubScreen(isDark);
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'More',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingL),

            // Profile Section
            _SectionTitle(title: 'Account', isDark: isDark),
            const SizedBox(height: AppDimensions.spacingM),
            _MenuItem(
              icon: Icons.person_outline,
              title: 'My Profile',
              subtitle: 'View and edit your profile',
              isDark: isDark,
              onTap: () => setState(() => _currentView = 'profile'),
            ),

            const SizedBox(height: AppDimensions.spacingL),

            // Information Section (READ-ONLY)
            _SectionTitle(title: 'Information', isDark: isDark),
            const SizedBox(height: AppDimensions.spacingM),
            _MenuItem(
              icon: Icons.payments_outlined,
              title: 'Fee Status',
              subtitle: 'View your fee records',
              isDark: isDark,
              onTap: () => setState(() => _currentView = 'fees'),
            ),
            const SizedBox(height: AppDimensions.spacingS),
            _MenuItem(
              icon: Icons.monitor_weight_outlined,
              title: 'BMI Records',
              subtitle: 'View your BMI history',
              isDark: isDark,
              onTap: () => setState(() => _currentView = 'bmi'),
            ),
            const SizedBox(height: AppDimensions.spacingS),
            _MenuItem(
              icon: Icons.campaign_outlined,
              title: 'Announcements',
              subtitle: 'View academy announcements',
              isDark: isDark,
              onTap: () => setState(() => _currentView = 'announcements'),
            ),
            const SizedBox(height: AppDimensions.spacingS),
            _MenuItem(
              icon: Icons.calendar_today_outlined,
              title: 'Schedule',
              subtitle: 'View your session schedule',
              isDark: isDark,
              onTap: () => setState(() => _currentView = 'schedule'),
            ),

            const SizedBox(height: AppDimensions.spacingL),

            // App Section
            _SectionTitle(title: 'App', isDark: isDark),
            const SizedBox(height: AppDimensions.spacingM),
            _MenuItem(
              icon: Icons.settings_outlined,
              title: 'Settings',
              subtitle: 'App preferences',
              isDark: isDark,
              onTap: () => setState(() => _currentView = 'settings'),
            ),
            const SizedBox(height: AppDimensions.spacingS),
            _MenuItem(
              icon: Icons.logout,
              title: 'Logout',
              subtitle: 'Sign out of your account',
              isDark: isDark,
              isDestructive: true,
              onTap: () => _showLogoutConfirmation(isDark),
            ),

            const SizedBox(height: 100), // Space for bottom nav
          ],
        ),
      ),
    );
  }

  Widget _buildSubScreen(bool isDark) {
    switch (_currentView) {
      case 'profile':
        return _StudentProfileView(
          isDark: isDark,
          studentData: _studentData,
          onBack: () => setState(() => _currentView = null),
        );
      case 'fees':
        return _StudentFeesView(
          isDark: isDark,
          onBack: () => setState(() => _currentView = null),
        );
      case 'bmi':
        return _StudentBMIView(
          isDark: isDark,
          onBack: () => setState(() => _currentView = null),
        );
      case 'announcements':
        return _StudentAnnouncementsView(
          isDark: isDark,
          onBack: () => setState(() => _currentView = null),
        );
      case 'schedule':
        return _StudentScheduleView(
          isDark: isDark,
          onBack: () => setState(() => _currentView = null),
        );
      case 'settings':
        return _StudentSettingsView(
          isDark: isDark,
          onBack: () => setState(() => _currentView = null),
        );
      default:
        return const SizedBox();
    }
  }

  void _showLogoutConfirmation(bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.cardBackground : AppColorsLight.cardBackground,
        title: Text(
          'Logout',
          style: TextStyle(
            color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(
            color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await ref.read(authProvider.notifier).logout();
              if (mounted) {
                context.go('/');
              }
            },
            child: Text(
              'Logout',
              style: TextStyle(
                color: isDark ? AppColors.error : AppColorsLight.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final bool isDark;

  const _SectionTitle({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDark;
  final VoidCallback onTap;
  final bool isDestructive;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDark,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return NeumorphicContainer(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDestructive
                  ? (isDark ? AppColors.error : AppColorsLight.error).withValues(alpha: 0.1)
                  : (isDark ? AppColors.accent : AppColorsLight.accent).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
            child: Icon(
              icon,
              color: isDestructive
                  ? (isDark ? AppColors.error : AppColorsLight.error)
                  : (isDark ? AppColors.iconPrimary : AppColorsLight.iconPrimary),
              size: 20,
            ),
          ),
          const SizedBox(width: AppDimensions.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDestructive
                        ? (isDark ? AppColors.error : AppColorsLight.error)
                        : (isDark ? AppColors.textPrimary : AppColorsLight.textPrimary),
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: isDark ? AppColors.textTertiary : AppColorsLight.textTertiary,
            size: 20,
          ),
        ],
      ),
    );
  }
}

// Sub-views for the More screen

class _StudentProfileView extends StatelessWidget {
  final bool isDark;
  final Map<String, dynamic> studentData;
  final VoidCallback onBack;

  const _StudentProfileView({
    required this.isDark,
    required this.studentData,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final name = studentData['name']?.toString() ?? 'Student';
    final email = studentData['email']?.toString() ?? '';
    final phone = studentData['phone']?.toString() ?? '';
    final guardianName = studentData['guardian_name']?.toString() ?? '';
    final address = studentData['address']?.toString() ?? '';

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _BackButton(isDark: isDark, onBack: onBack),
            const SizedBox(height: AppDimensions.spacingM),
            Text(
              'My Profile',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingL),

            // Profile Avatar
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.accent : AppColorsLight.accent,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'S',
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingL),

            // Profile Info Cards
            _ProfileInfoCard(label: 'Name', value: name, isDark: isDark),
            _ProfileInfoCard(label: 'Email', value: email, isDark: isDark),
            _ProfileInfoCard(label: 'Phone', value: phone.isEmpty ? 'Not set' : phone, isDark: isDark),
            _ProfileInfoCard(label: 'Guardian Name', value: guardianName.isEmpty ? 'Not set' : guardianName, isDark: isDark),
            _ProfileInfoCard(label: 'Address', value: address.isEmpty ? 'Not set' : address, isDark: isDark),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

class _ProfileInfoCard extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;

  const _ProfileInfoCard({
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingM),
      child: NeumorphicContainer(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudentFeesView extends ConsumerStatefulWidget {
  final bool isDark;
  final VoidCallback onBack;

  const _StudentFeesView({required this.isDark, required this.onBack});

  @override
  ConsumerState<_StudentFeesView> createState() => _StudentFeesViewState();
}

class _StudentFeesViewState extends ConsumerState<_StudentFeesView> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _feeRecords = [];

  @override
  void initState() {
    super.initState();
    _loadFees();
  }

  Future<void> _loadFees() async {
    try {
      final storageService = ref.read(storageServiceProvider);
      final apiService = ref.read(apiServiceProvider);
      final userId = storageService.getUserId();

      if (userId != null) {
        final response = await apiService.get('/api/students/$userId/fees');
        if (response.statusCode == 200) {
          _feeRecords = List<Map<String, dynamic>>.from(response.data['records'] ?? []);
        }
      }
    } catch (e) {
      // Use empty data
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _BackButton(isDark: widget.isDark, onBack: widget.onBack),
            const SizedBox(height: AppDimensions.spacingM),
            Text(
              'Fee Status',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: widget.isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingL),

            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_feeRecords.isEmpty)
              _EmptyStateWidget(
                icon: Icons.payments_outlined,
                message: 'No fee records found',
                isDark: widget.isDark,
              )
            else
              ..._feeRecords.map((fee) => _FeeCard(fee: fee, isDark: widget.isDark)),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

class _FeeCard extends StatelessWidget {
  final Map<String, dynamic> fee;
  final bool isDark;

  const _FeeCard({required this.fee, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final month = fee['month']?.toString() ?? 'Unknown';
    final amount = (fee['amount'] ?? 0).toDouble();
    final status = fee['status']?.toString() ?? 'pending';
    final isPaid = status.toLowerCase() == 'paid';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingM),
      child: NeumorphicContainer(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  month,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                  ),
                ),
                Text(
                  '₹${amount.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingM,
                vertical: AppDimensions.spacingS,
              ),
              decoration: BoxDecoration(
                color: isPaid
                    ? (isDark ? AppColors.success : AppColorsLight.success).withValues(alpha: 0.1)
                    : (isDark ? AppColors.error : AppColorsLight.error).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              ),
              child: Text(
                isPaid ? 'Paid' : 'Pending',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isPaid
                      ? (isDark ? AppColors.success : AppColorsLight.success)
                      : (isDark ? AppColors.error : AppColorsLight.error),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudentBMIView extends ConsumerStatefulWidget {
  final bool isDark;
  final VoidCallback onBack;

  const _StudentBMIView({required this.isDark, required this.onBack});

  @override
  ConsumerState<_StudentBMIView> createState() => _StudentBMIViewState();
}

class _StudentBMIViewState extends ConsumerState<_StudentBMIView> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _bmiRecords = [];

  @override
  void initState() {
    super.initState();
    _loadBMI();
  }

  Future<void> _loadBMI() async {
    try {
      final storageService = ref.read(storageServiceProvider);
      final apiService = ref.read(apiServiceProvider);
      final userId = storageService.getUserId();

      if (userId != null) {
        final response = await apiService.get('/api/students/$userId/bmi');
        if (response.statusCode == 200) {
          _bmiRecords = List<Map<String, dynamic>>.from(response.data['records'] ?? []);
        }
      }
    } catch (e) {
      // Use empty data
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _BackButton(isDark: widget.isDark, onBack: widget.onBack),
            const SizedBox(height: AppDimensions.spacingM),
            Text(
              'BMI Records',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: widget.isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingL),

            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_bmiRecords.isEmpty)
              _EmptyStateWidget(
                icon: Icons.monitor_weight_outlined,
                message: 'No BMI records found',
                isDark: widget.isDark,
              )
            else
              ..._bmiRecords.map((bmi) => _BMICard(bmi: bmi, isDark: widget.isDark)),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

class _BMICard extends StatelessWidget {
  final Map<String, dynamic> bmi;
  final bool isDark;

  const _BMICard({required this.bmi, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final date = bmi['date']?.toString() ?? '';
    final bmiValue = (bmi['bmi'] ?? 0).toDouble();
    final height = (bmi['height'] ?? 0).toDouble();
    final weight = (bmi['weight'] ?? 0).toDouble();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingM),
      child: NeumorphicContainer(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                  ),
                ),
                Text(
                  'BMI: ${bmiValue.toStringAsFixed(1)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _getBMIColor(bmiValue, isDark),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingS),
            Row(
              children: [
                Text(
                  'Height: ${height.toStringAsFixed(1)} cm',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingL),
                Text(
                  'Weight: ${weight.toStringAsFixed(1)} kg',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getBMIColor(double bmi, bool isDark) {
    if (bmi < 18.5) return Colors.orange; // Underweight
    if (bmi < 25) return isDark ? AppColors.success : AppColorsLight.success; // Normal
    if (bmi < 30) return Colors.orange; // Overweight
    return isDark ? AppColors.error : AppColorsLight.error; // Obese
  }
}

class _StudentAnnouncementsView extends ConsumerStatefulWidget {
  final bool isDark;
  final VoidCallback onBack;

  const _StudentAnnouncementsView({required this.isDark, required this.onBack});

  @override
  ConsumerState<_StudentAnnouncementsView> createState() => _StudentAnnouncementsViewState();
}

class _StudentAnnouncementsViewState extends ConsumerState<_StudentAnnouncementsView> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _announcements = [];

  @override
  void initState() {
    super.initState();
    _loadAnnouncements();
  }

  Future<void> _loadAnnouncements() async {
    try {
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.get('/api/announcements', queryParameters: {
        'target_audience': 'students',
      });
      if (response.statusCode == 200) {
        _announcements = List<Map<String, dynamic>>.from(response.data['announcements'] ?? response.data ?? []);
      }
    } catch (e) {
      // Use empty data
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _BackButton(isDark: widget.isDark, onBack: widget.onBack),
            const SizedBox(height: AppDimensions.spacingM),
            Text(
              'Announcements',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: widget.isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingL),

            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_announcements.isEmpty)
              _EmptyStateWidget(
                icon: Icons.campaign_outlined,
                message: 'No announcements',
                isDark: widget.isDark,
              )
            else
              ..._announcements.map((announcement) => _AnnouncementCard(
                    announcement: announcement,
                    isDark: widget.isDark,
                  )),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  final Map<String, dynamic> announcement;
  final bool isDark;

  const _AnnouncementCard({required this.announcement, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final title = announcement['title']?.toString() ?? 'Announcement';
    final message = announcement['message']?.toString() ?? '';
    final priority = announcement['priority']?.toString() ?? 'low';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingM),
      child: NeumorphicContainer(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (priority == 'high')
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(right: AppDimensions.spacingS),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.error : AppColorsLight.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingS),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudentScheduleView extends ConsumerStatefulWidget {
  final bool isDark;
  final VoidCallback onBack;

  const _StudentScheduleView({required this.isDark, required this.onBack});

  @override
  ConsumerState<_StudentScheduleView> createState() => _StudentScheduleViewState();
}

class _StudentScheduleViewState extends ConsumerState<_StudentScheduleView> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _schedules = [];

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    try {
      final storageService = ref.read(storageServiceProvider);
      final apiService = ref.read(apiServiceProvider);
      final userId = storageService.getUserId();

      if (userId != null) {
        final response = await apiService.get('/api/students/$userId/schedule');
        if (response.statusCode == 200) {
          _schedules = List<Map<String, dynamic>>.from(response.data['schedules'] ?? []);
        }
      }
    } catch (e) {
      // Use empty data
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _BackButton(isDark: widget.isDark, onBack: widget.onBack),
            const SizedBox(height: AppDimensions.spacingM),
            Text(
              'My Schedule',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: widget.isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingL),

            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_schedules.isEmpty)
              _EmptyStateWidget(
                icon: Icons.calendar_today_outlined,
                message: 'No scheduled sessions',
                isDark: widget.isDark,
              )
            else
              ..._schedules.map((schedule) => _ScheduleCard(
                    schedule: schedule,
                    isDark: widget.isDark,
                  )),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final Map<String, dynamic> schedule;
  final bool isDark;

  const _ScheduleCard({required this.schedule, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final batchName = schedule['batch_name']?.toString() ?? 'Session';
    final date = schedule['date']?.toString() ?? '';
    final time = schedule['time']?.toString() ?? '';
    final location = schedule['location']?.toString() ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingM),
      child: NeumorphicContainer(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: (isDark ? AppColors.accent : AppColorsLight.accent).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              ),
              child: Icon(
                Icons.sports_tennis,
                color: isDark ? AppColors.accent : AppColorsLight.accent,
                size: 24,
              ),
            ),
            const SizedBox(width: AppDimensions.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    batchName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                    ),
                  ),
                  Text(
                    '$date • $time',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                    ),
                  ),
                  if (location.isNotEmpty)
                    Text(
                      location,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.textTertiary : AppColorsLight.textTertiary,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudentSettingsView extends StatelessWidget {
  final bool isDark;
  final VoidCallback onBack;

  const _StudentSettingsView({required this.isDark, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _BackButton(isDark: isDark, onBack: onBack),
            const SizedBox(height: AppDimensions.spacingM),
            Text(
              'Settings',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingL),

            NeumorphicContainer(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Dark Mode',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                    ),
                  ),
                  Switch(
                    value: isDark,
                    onChanged: null, // Theme is controlled by system
                    activeColor: isDark ? AppColors.accent : AppColorsLight.accent,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.spacingL),

            // App Info
            Center(
              child: Column(
                children: [
                  Text(
                    'Shuttler',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                    ),
                  ),
                  Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  final bool isDark;
  final VoidCallback onBack;

  const _BackButton({required this.isDark, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onBack,
      icon: Icon(
        Icons.arrow_back,
        size: 18,
        color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
      ),
      label: Text(
        'Back',
        style: TextStyle(
          fontSize: 14,
          color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
        ),
      ),
    );
  }
}

class _EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String message;
  final bool isDark;

  const _EmptyStateWidget({
    required this.icon,
    required this.message,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: AppDimensions.spacingXxl),
          Icon(
            icon,
            size: 64,
            color: isDark ? AppColors.textTertiary : AppColorsLight.textTertiary,
          ),
          const SizedBox(height: AppDimensions.spacingM),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
