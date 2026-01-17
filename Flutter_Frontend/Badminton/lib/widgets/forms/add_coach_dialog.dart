import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/neumorphic_button.dart';
import '../../providers/auth_provider.dart';
import '../../providers/service_providers.dart';

/// Dialog for inviting a new coach
class AddCoachDialog extends ConsumerStatefulWidget {
  final Function(Map<String, dynamic>)? onSubmit;

  const AddCoachDialog({
    super.key,
    this.onSubmit,
  });

  @override
  ConsumerState<AddCoachDialog> createState() => _AddCoachDialogState();
}

class _AddCoachDialogState extends ConsumerState<AddCoachDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _experienceController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  bool _hasPhoneOrEmail() {
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    return phone.isNotEmpty || email.isNotEmpty;
  }

  Future<void> _handleSendInvite() async {
    if (!_hasPhoneOrEmail()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide at least phone number or email address'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Get current user info
    final authState = ref.read(authProvider);
    await authState.when(
      data: (authValue) async {
        if (authValue is! Authenticated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please login to send invitations'),
              backgroundColor: AppColors.error,
            ),
          );
          return;
        }

        // Only owners can send coach invitations
        if (authValue.userType != 'owner') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Only owners can invite coaches'),
              backgroundColor: AppColors.error,
            ),
          );
          return;
        }

        setState(() {
          _isLoading = true;
        });

        try {
          final invitationService = ref.read(invitationServiceProvider);
          final phone = _phoneController.text.trim();
          final email = _emailController.text.trim();

          // Create coach invitation via backend
          final invitation = await invitationService.createCoachInvitation(
            ownerId: authValue.userId,
            ownerName: authValue.userName,
            coachName: _nameController.text.trim().isNotEmpty
                ? _nameController.text.trim()
                : null,
            coachPhone: phone.isNotEmpty ? phone : null,
            coachEmail: email.isNotEmpty ? email : null,
            experienceYears: _experienceController.text.trim().isNotEmpty
                ? int.tryParse(_experienceController.text.trim())
                : null,
          );

          // Get invite link from response
          final inviteLink = invitation['invite_link'] as String? ??
              'https://academy.app/invite/coach/${invitation['invite_token']}';

          if (mounted) {
            setState(() {
              _isLoading = false;
            });
            // Show invite link options with real link
            _showInviteOptions(inviteLink);
          }
        } catch (e) {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Failed to create invitation: ${e.toString().replaceFirst('Exception: ', '')}'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      },
      loading: () {},
      error: (error, stack) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${error.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      },
    );
  }

  void _showInviteOptions(String inviteLink) {
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final hasPhone = phone.isNotEmpty;
    final hasEmail = email.isNotEmpty;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          'Send Invite Link',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasPhone && hasEmail) ...[
              _InviteOption(
                icon: Icons.chat,
                label: 'Send via WhatsApp',
                onTap: () => _sendViaWhatsApp(phone, inviteLink),
              ),
              const SizedBox(height: AppDimensions.spacingS),
              _InviteOption(
                icon: Icons.message,
                label: 'Send via Text Message',
                onTap: () => _sendViaSMS(phone, inviteLink),
              ),
              const SizedBox(height: AppDimensions.spacingS),
              _InviteOption(
                icon: Icons.email,
                label: 'Send via Email',
                onTap: () => _sendViaEmail(email, inviteLink),
              ),
              const SizedBox(height: AppDimensions.spacingS),
              _InviteOption(
                icon: Icons.copy,
                label: 'Copy Link',
                onTap: () => _copyLink(inviteLink),
              ),
            ] else if (hasPhone) ...[
              _InviteOption(
                icon: Icons.chat,
                label: 'Send via WhatsApp',
                onTap: () => _sendViaWhatsApp(phone, inviteLink),
              ),
              const SizedBox(height: AppDimensions.spacingS),
              _InviteOption(
                icon: Icons.message,
                label: 'Send via Text Message',
                onTap: () => _sendViaSMS(phone, inviteLink),
              ),
              const SizedBox(height: AppDimensions.spacingS),
              _InviteOption(
                icon: Icons.copy,
                label: 'Copy Link',
                onTap: () => _copyLink(inviteLink),
              ),
            ] else if (hasEmail) ...[
              _InviteOption(
                icon: Icons.email,
                label: 'Send via Email',
                onTap: () => _sendViaEmail(email, inviteLink),
              ),
              const SizedBox(height: AppDimensions.spacingS),
              _InviteOption(
                icon: Icons.copy,
                label: 'Copy Link',
                onTap: () => _copyLink(inviteLink),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }

  Future<void> _sendViaWhatsApp(String phone, String link) async {
    final url =
        'https://wa.me/$phone?text=${Uri.encodeComponent('Join our academy as a coach! $link')}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
      Navigator.of(context).pop(); // Close invite options
      Navigator.of(context).pop(); // Close main dialog
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open WhatsApp'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _sendViaSMS(String phone, String link) async {
    final url =
        'sms:$phone?body=${Uri.encodeComponent('Join our academy as a coach! $link')}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
      Navigator.of(context).pop(); // Close invite options
      Navigator.of(context).pop(); // Close main dialog
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open SMS'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _sendViaEmail(String email, String link) async {
    final url =
        'mailto:$email?subject=${Uri.encodeComponent('Join our academy as a coach!')}&body=${Uri.encodeComponent('Join our academy as a coach! $link')}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
      Navigator.of(context).pop(); // Close invite options
      Navigator.of(context).pop(); // Close main dialog
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open email'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _copyLink(String link) {
    Clipboard.setData(ClipboardData(text: link));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Invite link copied to clipboard'),
        backgroundColor: AppColors.success,
      ),
    );
    Navigator.of(context).pop(); // Close invite options
    Navigator.of(context).pop(); // Close main dialog
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: NeumorphicContainer(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Invite Coach',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close,
                          color: AppColors.textSecondary),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacingL),
                _buildTextField(
                  controller: _nameController,
                  label: 'Coach Name (Optional)',
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: AppDimensions.spacingM),
                _buildTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    final phone = value?.trim() ?? '';
                    final email = _emailController.text.trim();
                    if (phone.isEmpty && email.isEmpty) {
                      return 'Please provide phone number or email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.spacingM),
                _buildTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    final email = value?.trim() ?? '';
                    final phone = _phoneController.text.trim();
                    if (email.isEmpty && phone.isEmpty) {
                      return 'Please provide phone number or email address';
                    }
                    if (email.isNotEmpty && !email.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.spacingM),
                _buildTextField(
                  controller: _experienceController,
                  label: 'Experience Years (Optional)',
                  icon: Icons.calendar_today_outlined,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: AppDimensions.spacingL),
                NeumorphicButton(
                  text: _isLoading ? 'Sending...' : 'Invite Coach',
                  onPressed: _isLoading ? null : _handleSendInvite,
                  isAccent: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return NeumorphicInsetContainer(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingM),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.textSecondary),
          prefixIcon: Icon(icon, color: AppColors.iconPrimary, size: 20),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

class _InviteOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _InviteOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.spacingM),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.iconPrimary),
            const SizedBox(width: AppDimensions.spacingM),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
