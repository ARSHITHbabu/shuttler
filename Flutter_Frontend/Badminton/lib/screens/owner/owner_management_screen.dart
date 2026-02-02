import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/theme/neumorphic_styles.dart';
import '../../widgets/common/neumorphic_container.dart';
import '../../widgets/common/success_snackbar.dart';
import '../../widgets/common/confirmation_dialog.dart';
import '../../providers/auth_provider.dart';
import '../../providers/service_providers.dart';
import '../../core/services/api_service.dart';

class OwnerManagementScreen extends ConsumerStatefulWidget {
  const OwnerManagementScreen({super.key});

  @override
  ConsumerState<OwnerManagementScreen> createState() => _OwnerManagementScreenState();
}

class _OwnerManagementScreenState extends ConsumerState<OwnerManagementScreen> {
  bool _isLoading = true;
  List<dynamic> _owners = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchOwners();
  }

  Future<void> _fetchOwners() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.get('/owners/');
      
      if (response.statusCode == 200) {
        setState(() {
          _owners = response.data;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load owners: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _inviteCoOwner() async {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final passwordController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        
        return AlertDialog(
          backgroundColor: isDark ? AppColors.background : AppColorsLight.background,
          title: Text(
            'Invite Co-Owner',
            style: TextStyle(color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  style: TextStyle(color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary),
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  style: TextStyle(color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary),
                ),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Phone'),
                  style: TextStyle(color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary),
                ),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(labelText: 'Temporary Password'),
                  obscureText: true,
                  style: TextStyle(color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Invite'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      try {
        final apiService = ref.read(apiServiceProvider);
        await apiService.post('/owners/', data: {
          'name': nameController.text,
          'email': emailController.text,
          'phone': phoneController.text,
          'password': passwordController.text,
          'role': 'co_owner',
        });
        
        if (mounted) {
          SuccessSnackbar.show(context, 'Co-owner invited successfully');
          _fetchOwners();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to invite co-owner: $e')),
          );
        }
      }
    }
  }

  Future<void> _transferOwnership(int newOwnerId, String name) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      'Transfer Ownership',
      'Are you sure you want to transfer primary ownership to $name? You will become a co-owner.',
      confirmText: 'Transfer',
      isDestructive: true,
    );

    if (confirmed == true) {
      try {
        final authState = ref.read(authProvider).value;
        if (authState is! Authenticated) return;
        
        final apiService = ref.read(apiServiceProvider);
        await apiService.post('/owners/${authState.userId}/transfer-ownership', data: {
          'new_owner_id': newOwnerId,
        });
        
        if (mounted) {
          SuccessSnackbar.show(context, 'Ownership transferred successfully. Please log in again to refresh your role.');
          ref.read(authProvider.notifier).logout();
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to transfer ownership: $e')),
          );
        }
      }
    }
  }

  Future<void> _deleteOwner(int ownerId, String name, bool isSelf) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      isSelf ? 'Leave Academy' : 'Remove Co-Owner',
      isSelf 
          ? 'Are you sure you want to leave the academy? This action cannot be undone.'
          : 'Are you sure you want to remove $name from the academy?',
      confirmText: isSelf ? 'Leave' : 'Remove',
      isDestructive: true,
    );

    if (confirmed == true) {
      try {
        final apiService = ref.read(apiServiceProvider);
        await apiService.delete('/owners/$ownerId');
        
        if (mounted) {
          SuccessSnackbar.show(context, isSelf ? 'You have left the academy' : 'Co-owner removed');
          if (isSelf) {
            ref.read(authProvider.notifier).logout();
            Navigator.of(context).popUntil((route) => route.isFirst);
          } else {
            _fetchOwners();
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Action failed: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authState = ref.watch(authProvider).value;
    
    if (authState is! Authenticated) {
      return const Scaffold(body: Center(child: Text('Not authenticated')));
    }

    final isPrimaryOwner = authState.userRole == 'owner';

    return Scaffold(
      backgroundColor: isDark ? AppColors.background : AppColorsLight.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Owner Management',
          style: TextStyle(color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          if (isPrimaryOwner)
            IconButton(
              icon: Icon(Icons.person_add_outlined, color: isDark ? AppColors.accent : AppColorsLight.accent),
              onPressed: _inviteCoOwner,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)))
              : _owners.isEmpty
                  ? const Center(child: Text('No other owners found'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(AppDimensions.paddingL),
                      itemCount: _owners.length,
                      itemBuilder: (context, index) {
                        final owner = _owners[index];
                        final isSelf = owner['id'] == authState.userId;
                        final role = owner['role'] ?? 'owner';
                        final isOwnerRole = role == 'owner';

                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppDimensions.spacingM),
                          child: NeumorphicContainer(
                            padding: const EdgeInsets.all(AppDimensions.paddingM),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: isOwnerRole ? AppColors.accent : Colors.grey,
                                  child: Text(
                                    owner['name']?[0]?.toUpperCase() ?? '?',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: AppDimensions.spacingM),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${owner['name']}${isSelf ? ' (You)' : ''}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        isOwnerRole ? 'Primary Owner' : 'Co-Owner',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isOwnerRole ? AppColors.accent : (isDark ? AppColors.textSecondary : AppColorsLight.textSecondary),
                                        ),
                                      ),
                                      Text(
                                        owner['email'] ?? '',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isPrimaryOwner && !isSelf && !isOwnerRole)
                                  PopupMenuButton<String>(
                                    icon: Icon(Icons.more_vert, color: isDark ? AppColors.textPrimary : AppColorsLight.textPrimary),
                                    onSelected: (value) {
                                      if (value == 'transfer') {
                                        _transferOwnership(owner['id'], owner['name']);
                                      } else if (value == 'delete') {
                                        _deleteOwner(owner['id'], owner['name'], false);
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'transfer',
                                        child: Text('Make Primary Owner'),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Text('Remove', style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                if (!isPrimaryOwner && isSelf)
                                  IconButton(
                                    icon: const Icon(Icons.exit_to_app, color: Colors.red),
                                    onPressed: () => _deleteOwner(owner['id'], owner['name'], true),
                                    tooltip: 'Leave Academy',
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
