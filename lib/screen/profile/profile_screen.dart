import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kasir_go/screen/profile/components/profile_header.dart';
import 'package:kasir_go/screen/profile/components/profile_avatar.dart';
import 'package:kasir_go/screen/profile/components/profile_info_card.dart';
import 'package:kasir_go/screen/profile/components/profile_security_card.dart';
import 'package:kasir_go/screen/profile/components/profile_logout_button.dart';
import 'package:kasir_go/utils/dialog_helper.dart';
import 'package:kasir_go/utils/session_helper.dart';

import '../../providers/auth_provider.dart';
import '../login_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isEditing = false;
  bool _isChangingPassword = false;
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _profile;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() => _refreshData());
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    // Errors are captured by provider and displayed via ref.listen in build()
    final profile = await ref.read(authProvider.notifier).getProfile();

    // If mounted check to ensure we don't set state on unmounted widget
    if (!mounted) return;

    if (profile != null) {
      setState(() {
        _profile = profile;
        _isLoading = false;
        _usernameController.text = profile['username'] ?? '';
        _firstNameController.text = profile['first_name'] ?? '';
        _lastNameController.text = profile['last_name'] ?? '';
        _emailController.text = profile['email'] ?? '';
        _phoneController.text = profile['phone'] ?? '';
      });
    } else {
      // Profile fetch failed (provider state has error)
      setState(() {
        _isLoading = false;
        _errorMessage = ref.read(authProvider).errorMessage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authProvider, (previous, next) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        if (isSessionExpiredError(next.errorMessage)) {
          handleSessionExpired(context, ref);
          return;
        }
        showErrorDialog(context, next.errorMessage!, title: "Action Failed");
      }
    });

    final isSubmitting =
        ref.watch(authProvider.select((state) => state.isLoading));

    // Handle loading state
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.deepOrange.shade400),
              const SizedBox(height: 16),
              Text(
                'Loading profile...',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }

    // Handle error state
    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Iconsax.warning_2,
                      size: 64, color: Colors.red.shade400),
                ),
                const SizedBox(height: 24),
                Text(
                  "Failed to Load Profile",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade900,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Iconsax.refresh),
                      label: const Text("Retry"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange.shade400,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        setState(() {
                          _isLoading = true;
                          _errorMessage = null;
                        });
                        // Trigger initState logic again
                        _refreshData();
                      },
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      icon: const Icon(Iconsax.logout),
                      label: const Text("Logout"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red.shade600,
                        side: BorderSide(color: Colors.red.shade300),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        await ref.read(authProvider.notifier).logout();
                        if (!context.mounted) return;
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen()),
                          (route) => false,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    final profile = _profile!;
    final username = profile['username'] ?? '-';
    final firstName = profile['first_name'] ?? '-';
    final lastName = profile['last_name'] ?? '-';
    final role = profile['role'] ?? '-';

    return Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: Column(
          children: [
            const ProfileHeader(),
            Divider(height: 1, color: Colors.grey.shade200),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Avatar
                      ProfileAvatar(
                        username: username,
                        firstName: firstName,
                        lastName: lastName,
                        role: role,
                      ),
                      const SizedBox(height: 32),

                      // Info Card
                      ProfileInfoCard(
                        isEditing: _isEditing,
                        isLoading: isSubmitting,
                        usernameController: _usernameController,
                        firstNameController: _firstNameController,
                        lastNameController: _lastNameController,
                        emailController: _emailController,
                        phoneController: _phoneController,
                        onEditPressed: () {
                          setState(() {
                            _isEditing = true;
                          });
                        },
                        onCancelPressed: () {
                          setState(() {
                            _isEditing = false;
                          });
                        },
                        onSavePressed: _saveProfile,
                      ),

                      const SizedBox(height: 16),

                      // Security Card
                      ProfileSecurityCard(
                        isChangingPassword: _isChangingPassword,
                        isLoading: isSubmitting,
                        oldPasswordController: _oldPasswordController,
                        newPasswordController: _newPasswordController,
                        confirmPasswordController: _confirmPasswordController,
                        onTogglePressed: () {
                          setState(() {
                            _isChangingPassword = true;
                          });
                        },
                        onCancelPressed: () {
                          setState(() {
                            _isChangingPassword = false;
                            _oldPasswordController.clear();
                            _newPasswordController.clear();
                            _confirmPasswordController.clear();
                          });
                        },
                        onUpdatePressed: _updatePassword,
                      ),

                      const SizedBox(height: 16),

                      // Logout Button
                      ProfileLogoutButton(
                        onTap: () async {
                          await ref.read(authProvider.notifier).logout();
                          if (!context.mounted) return;
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LoginScreen()),
                            (route) => false,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ));
  }

  Future<void> _saveProfile() async {
    // Validation
    if (_usernameController.text.trim().isEmpty) {
      showErrorDialog(context, 'Please enter a username',
          title: 'Username Required');
      return;
    }
    if (_firstNameController.text.trim().isEmpty ||
        _lastNameController.text.trim().isEmpty) {
      showErrorDialog(context, 'Please enter your first name and last name',
          title: 'Name Required');
      return;
    }

    if (_emailController.text.trim().isEmpty) {
      showErrorDialog(context, 'Please enter an email address',
          title: 'Email Required');
      return;
    }
    if (!_emailController.text.contains('@')) {
      showErrorDialog(context, 'Please enter a valid email address',
          title: 'Invalid Email');
      return;
    }

    await ref.read(authProvider.notifier).updateProfile(
          username: _usernameController.text.trim(),
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
        );

    if (!mounted) return;

    // Check Success locally for flow control
    if (ref.read(authProvider).isSuccess) {
      setState(() {
        _isEditing = false;
      });

      showSuccessDialog(context, 'Your profile has been updated successfully',
          title: 'Profile Updated');
    }
  }

  Future<void> _updatePassword() async {
    // Validation
    if (_oldPasswordController.text.trim().isEmpty) {
      showErrorDialog(context, 'Please enter your current password',
          title: 'Current Password Required');
      return;
    }
    if (_newPasswordController.text.trim().isEmpty) {
      showErrorDialog(context, 'Please enter a new password',
          title: 'New Password Required');
      return;
    }
    if (_newPasswordController.text.trim().length < 8) {
      showErrorDialog(context, 'Password must be at least 8 characters',
          title: 'Weak Password');
      return;
    }
    if (_newPasswordController.text != _confirmPasswordController.text) {
      showErrorDialog(context, 'New password and confirmation do not match',
          title: 'Password Mismatch');
      return;
    }

    await ref.read(authProvider.notifier).changePassword(
          oldPassword: _oldPasswordController.text.trim(),
          newPassword: _newPasswordController.text.trim(),
        );

    if (!mounted) return;

    if (ref.read(authProvider).isSuccess) {
      setState(() {
        _isChangingPassword = false;
        _oldPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      });

      showSuccessDialog(context, 'Your password has been changed successfully',
          title: 'Password Updated');
    }
  }
}
