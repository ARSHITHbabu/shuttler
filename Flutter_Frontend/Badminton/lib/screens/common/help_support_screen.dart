import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/constants/legal_content.dart';
import '../../widgets/common/neumorphic_container.dart';

/// Help & Support Screen - FAQ and contact options
/// This screen is shared across all portals (Owner, Coach, Student)
class HelpSupportScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final String? userRole; // 'owner', 'coach', 'student'

  const HelpSupportScreen({
    super.key,
    this.onBack,
    this.userRole,
  });

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final Map<int, bool> _expandedSections = {};
  final Map<String, bool> _expandedQuestions = {};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = theme.scaffoldBackgroundColor;
    final textPrimaryColor = isDark ? AppColors.textPrimary : AppColorsLight.textPrimary;
    final textSecondaryColor = isDark ? AppColors.textSecondary : AppColorsLight.textSecondary;
    final accentColor = isDark ? AppColors.accent : AppColorsLight.accent;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textPrimaryColor),
          onPressed: widget.onBack ?? () => Navigator.of(context).pop(),
        ),
        title: Text(
          LegalContent.helpTitle,
          style: TextStyle(
            color: textPrimaryColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              NeumorphicContainer(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                      ),
                      child: Icon(
                        Icons.help_outline,
                        size: 32,
                        color: accentColor,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingM),
                    Text(
                      'How can we help you?',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingS),
                    Text(
                      'Find answers to common questions or contact our support team',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.spacingL),

              // Contact Options
              Text(
                'Contact Us',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textPrimaryColor,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingM),

              Row(
                children: [
                  Expanded(
                    child: _buildContactCard(
                      icon: Icons.email_outlined,
                      title: 'Email',
                      value: LegalContent.supportEmail,
                      isDark: isDark,
                      accentColor: accentColor,
                      textPrimaryColor: textPrimaryColor,
                      textSecondaryColor: textSecondaryColor,
                      onTap: () => _launchEmail(),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingM),
                  Expanded(
                    child: _buildContactCard(
                      icon: Icons.phone_outlined,
                      title: 'Phone',
                      value: LegalContent.supportPhone,
                      isDark: isDark,
                      accentColor: accentColor,
                      textPrimaryColor: textPrimaryColor,
                      textSecondaryColor: textSecondaryColor,
                      onTap: () => _launchPhone(),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppDimensions.spacingXl),

              // FAQ Section
              Text(
                'Frequently Asked Questions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textPrimaryColor,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingM),

              // FAQ Categories
              ...LegalContent.faqSections.asMap().entries.map((entry) {
                final index = entry.key;
                final section = entry.value;
                final isRelevant = _isSectionRelevant(section['title'] as String);

                if (!isRelevant && widget.userRole != null) return const SizedBox.shrink();

                return _buildFaqSection(
                  index: index,
                  title: section['title'] as String,
                  questions: section['questions'] as List<Map<String, String>>,
                  isDark: isDark,
                  accentColor: accentColor,
                  textPrimaryColor: textPrimaryColor,
                  textSecondaryColor: textSecondaryColor,
                );
              }),

              const SizedBox(height: AppDimensions.spacingL),

              // Still need help card
              NeumorphicContainer(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                child: Column(
                  children: [
                    Icon(
                      Icons.support_agent,
                      size: 48,
                      color: accentColor,
                    ),
                    const SizedBox(height: AppDimensions.spacingM),
                    Text(
                      'Still need help?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingS),
                    Text(
                      'Our support team is here to assist you with any questions or issues.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: textSecondaryColor,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingL),
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            icon: Icons.email_outlined,
                            label: 'Email Us',
                            isDark: isDark,
                            accentColor: accentColor,
                            onTap: () => _launchEmail(),
                          ),
                        ),
                        const SizedBox(width: AppDimensions.spacingM),
                        Expanded(
                          child: _buildActionButton(
                            icon: Icons.phone_outlined,
                            label: 'Call Us',
                            isDark: isDark,
                            accentColor: accentColor,
                            onTap: () => _launchPhone(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  bool _isSectionRelevant(String sectionTitle) {
    if (widget.userRole == null) return true;

    switch (widget.userRole) {
      case 'student':
        return sectionTitle == 'Getting Started' ||
               sectionTitle == 'For Students' ||
               sectionTitle == 'Technical Issues';
      case 'coach':
        return sectionTitle == 'Getting Started' ||
               sectionTitle == 'For Coaches' ||
               sectionTitle == 'Technical Issues';
      case 'owner':
        return true; // Owners see all sections
      default:
        return true;
    }
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String value,
    required bool isDark,
    required Color accentColor,
    required Color textPrimaryColor,
    required Color textSecondaryColor,
    required VoidCallback onTap,
  }) {
    return NeumorphicContainer(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
            child: Icon(
              icon,
              size: 24,
              color: accentColor,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingS),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textPrimaryColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              color: textSecondaryColor,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFaqSection({
    required int index,
    required String title,
    required List<Map<String, String>> questions,
    required bool isDark,
    required Color accentColor,
    required Color textPrimaryColor,
    required Color textSecondaryColor,
  }) {
    final isExpanded = _expandedSections[index] ?? false;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingM),
      child: NeumorphicContainer(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Column(
          children: [
            // Section Header
            InkWell(
              onTap: () {
                setState(() {
                  _expandedSections[index] = !isExpanded;
                });
              },
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                    ),
                    child: Icon(
                      _getSectionIcon(title),
                      size: 20,
                      color: accentColor,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingM),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: textPrimaryColor,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),

            // Questions
            if (isExpanded) ...[
              const SizedBox(height: AppDimensions.spacingM),
              const Divider(height: 1),
              const SizedBox(height: AppDimensions.spacingS),
              ...questions.asMap().entries.map((entry) {
                final questionKey = '${index}_${entry.key}';
                final question = entry.value;
                final isQuestionExpanded = _expandedQuestions[questionKey] ?? false;

                return _buildQuestionItem(
                  questionKey: questionKey,
                  question: question['question']!,
                  answer: question['answer']!,
                  isExpanded: isQuestionExpanded,
                  isDark: isDark,
                  textPrimaryColor: textPrimaryColor,
                  textSecondaryColor: textSecondaryColor,
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getSectionIcon(String title) {
    switch (title) {
      case 'Getting Started':
        return Icons.rocket_launch_outlined;
      case 'For Students':
        return Icons.school_outlined;
      case 'For Coaches':
        return Icons.sports_outlined;
      case 'For Academy Owners':
        return Icons.business_outlined;
      case 'Technical Issues':
        return Icons.build_outlined;
      default:
        return Icons.help_outline;
    }
  }

  Widget _buildQuestionItem({
    required String questionKey,
    required String question,
    required String answer,
    required bool isExpanded,
    required bool isDark,
    required Color textPrimaryColor,
    required Color textSecondaryColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingXs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _expandedQuestions[questionKey] = !isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppDimensions.spacingS,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    isExpanded ? Icons.remove_circle_outline : Icons.add_circle_outline,
                    size: 20,
                    color: textSecondaryColor,
                  ),
                  const SizedBox(width: AppDimensions.spacingS),
                  Expanded(
                    child: Text(
                      question,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: textPrimaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.only(
                left: 28,
                bottom: AppDimensions.spacingS,
              ),
              child: Container(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                decoration: BoxDecoration(
                  color: (isDark ? AppColors.background : AppColorsLight.background),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                ),
                child: Text(
                  answer,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: textSecondaryColor,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required bool isDark,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingM,
          vertical: AppDimensions.paddingS,
        ),
        decoration: BoxDecoration(
          color: accentColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          border: Border.all(
            color: accentColor.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: accentColor,
            ),
            const SizedBox(width: AppDimensions.spacingS),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: accentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: LegalContent.supportEmail,
      queryParameters: {
        'subject': '${LegalContent.appName} Support Request',
      },
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _launchPhone() async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: LegalContent.supportPhone,
    );

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }
}
