import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kasir_go/utils/dialog_helper.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isEditing = false;
  bool _isChangingPassword = false;
  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  late TextEditingController _usernameController;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

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

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: profileAsync.when(
        data: (profile) {
          final username = profile['username'] ?? '-';
          final firstName = profile['first_name'] ?? '-';
          final lastName = profile['last_name'] ?? '-';
          final email = profile['email'] ?? '-';
          final phone = profile['phone'] ?? '-';
          final role = profile['role'] ?? '-';

          if (!_isEditing) {
            _usernameController = TextEditingController(text: username);
            _firstNameController = TextEditingController(text: firstName);
            _lastNameController = TextEditingController(text: lastName);
            _emailController = TextEditingController(text: email);
            _phoneController = TextEditingController(text: phone);
          }

          return Column(
            children: [
              // Simple AppBar
              Container(
                color: Colors.white,
                child: const SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Profile',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Divider(height: 1, color: Colors.grey.shade200),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Simple Avatar Section
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.deepOrange.shade100,
                          child: Text(
                            username.isNotEmpty ? username[0].toUpperCase() : 'U',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrange.shade700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '$firstName $lastName',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          role.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 32),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade200,
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _isEditing ? 'Edit Profile' : 'Profile Information',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade900,
                                    ),
                                  ),
                                  if (!_isEditing)
                                    IconButton(
                                      icon: Icon(Iconsax.edit, color: Colors.deepOrange.shade400),
                                      onPressed: () {
                                        setState(() {
                                          _isEditing = true;
                                        });
                                      },
                                    ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              _buildForm()
                            ],
                          ),
                        ),
                      ),

                        const SizedBox(height: 16),

                        // Change Password Card
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade200,
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _isChangingPassword ? 'Change Password' : 'Security',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade900,
                                      ),
                                    ),
                                    if (!_isChangingPassword)
                                      IconButton(
                                        icon: Icon(Iconsax.lock, color: Colors.deepOrange.shade400),
                                        onPressed: () {
                                          setState(() {
                                            _isChangingPassword = true;
                                          });
                                        },
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                _buildPasswordForm(),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Logout Button
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () async {
                                await ref.read(authProvider.notifier).logout();
                                if (!context.mounted) return;
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                                  (route) => false,
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade500,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(Iconsax.logout, color: Colors.white, size: 24),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Logout',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red.shade700,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Sign out from your account',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(Icons.arrow_forward_ios, color: Colors.red.shade400, size: 16),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => Scaffold(
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
        ),
        error: (error, stack) {
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
                      child: Icon(Iconsax.info_circle, size: 64, color: Colors.red.shade400),
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
                      error.toString(),
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
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            ref.invalidate(userProfileProvider);
                          },
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          icon: const Icon(Iconsax.logout),
                          label: const Text("Logout"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red.shade600,
                            side: BorderSide(color: Colors.red.shade300),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () async {
                            await ref.read(authProvider.notifier).logout();
                            if (!context.mounted) return;
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (_) => const LoginScreen()),
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
        },
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Username',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _usernameController,
          enabled: _isEditing,
          decoration: InputDecoration(
            hintText: 'Enter username',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
            prefixIcon: Icon(Iconsax.user, color: Colors.grey.shade500),
            filled: true,
            fillColor: Colors.grey.shade50,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.deepOrange.shade400, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          style: TextStyle(
            fontSize: 15,
            color: _isEditing ? Colors.black87 : Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'First Name',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _firstNameController,
                    enabled: _isEditing,
                    decoration: InputDecoration(
                      hintText: 'First name',
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
                      prefixIcon: Icon(Iconsax.profile_circle, color: Colors.grey.shade500),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.deepOrange.shade400, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    style: TextStyle(
                      fontSize: 15,
                      color: _isEditing ? Colors.black87 : Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Last Name',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _lastNameController,
                    enabled: _isEditing,
                    decoration: InputDecoration(
                      hintText: 'Last name',
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
                      prefixIcon: Icon(Iconsax.profile_circle, color: Colors.grey.shade500),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.deepOrange.shade400, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    style: TextStyle(
                      fontSize: 15,
                      color: _isEditing ? Colors.black87 : Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Email',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _emailController,
          enabled: _isEditing,
          decoration: InputDecoration(
            hintText: 'Enter email',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
            prefixIcon: Icon(Iconsax.sms, color: Colors.grey.shade500),
            filled: true,
            fillColor: Colors.grey.shade50,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.deepOrange.shade400, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          keyboardType: TextInputType.emailAddress,
          style: TextStyle(
            fontSize: 15,
            color: _isEditing ? Colors.black87 : Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Phone',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _phoneController,
          enabled: _isEditing,
          decoration: InputDecoration(
            hintText: 'Enter phone number',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
            prefixIcon: Icon(Iconsax.call, color: Colors.grey.shade500),
            filled: true,
            fillColor: Colors.grey.shade50,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.deepOrange.shade400, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          keyboardType: TextInputType.phone,
          style: TextStyle(
            fontSize: 15,
            color: _isEditing ? Colors.black87 : Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 24),
        if (_isEditing)
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _isEditing = false;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: Colors.grey.shade400),
                    foregroundColor: Colors.grey.shade700,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                  // Validation
                  if (_usernameController.text.trim().isEmpty) {
                    showErrorDialog(context, 'Please enter a username', title:'Username Required');
                    return;
                  }
                  if (_firstNameController.text.trim().isEmpty || _lastNameController.text.trim().isEmpty) {
                    showErrorDialog(context, 'Please enter your first name and last name', title:'Name Required');
                    return;
                  }

                  if (_emailController.text.trim().isEmpty) {
                    showErrorDialog(context, 'Please enter an email address', title:'Email Required');
                    return;
                  }
                  if (!_emailController.text.contains('@')) {
                    showErrorDialog(context, 'Please enter a valid email address', title:'Invalid Email');
                    return;
                  }

                  try {
                    await ref.read(authProvider.notifier).updateProfile(
                      username: _usernameController.text.trim(),
                      firstName: _firstNameController.text.trim(),
                      lastName: _lastNameController.text.trim(),
                      email: _emailController.text.trim(),
                      phone: _phoneController.text.trim(),
                    );
                    
                    if (!context.mounted) return;
                    
                    setState(() {
                      _isEditing = false;
                    });
                    
                    ref.invalidate(userProfileProvider);
                    
                    if (!context.mounted) return;
                    showSuccessDialog(context, 'Your profile has been updated successfully', title: 'Profile Updated');
                  } catch (e) {
                    if (!context.mounted) return;
                    showErrorDialog(context, e.toString(), title: 'Update Failed');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange.shade400,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPasswordForm() {
    if (!_isChangingPassword) {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.deepOrange.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Iconsax.lock, color: Colors.deepOrange.shade400, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Password',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '••••••••',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Current Password',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _oldPasswordController,
          obscureText: _obscureOldPassword,
          decoration: InputDecoration(
            hintText: 'Enter current password',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
            prefixIcon: Icon(Iconsax.lock, color: Colors.grey.shade500),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureOldPassword ? Iconsax.eye_slash : Iconsax.eye,
                color: Colors.grey.shade500,
              ),
              onPressed: () {
                setState(() {
                  _obscureOldPassword = !_obscureOldPassword;
                });
              },
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.deepOrange.shade400, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          style: const TextStyle(fontSize: 15),
        ),
        const SizedBox(height: 16),
        Text(
          'New Password',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _newPasswordController,
          obscureText: _obscureNewPassword,
          decoration: InputDecoration(
            hintText: 'Enter new password',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
            prefixIcon: Icon(Iconsax.lock_1, color: Colors.grey.shade500),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureNewPassword ? Iconsax.eye_slash : Iconsax.eye,
                color: Colors.grey.shade500,
              ),
              onPressed: () {
                setState(() {
                  _obscureNewPassword = !_obscureNewPassword;
                });
              },
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.deepOrange.shade400, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          style: const TextStyle(fontSize: 15),
        ),
        const SizedBox(height: 16),
        Text(
          'Confirm New Password',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _confirmPasswordController,
          obscureText: _obscureConfirmPassword,
          decoration: InputDecoration(
            hintText: 'Confirm new password',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
            prefixIcon: Icon(Iconsax.lock_1, color: Colors.grey.shade500),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword ? Iconsax.eye_slash : Iconsax.eye,
                color: Colors.grey.shade500,
              ),
              onPressed: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.deepOrange.shade400, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          style: const TextStyle(fontSize: 15),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _isChangingPassword = false;
                    _oldPasswordController.clear();
                    _newPasswordController.clear();
                    _confirmPasswordController.clear();
                    _obscureOldPassword = true;
                    _obscureNewPassword = true;
                    _obscureConfirmPassword = true;
                  });
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: Colors.grey.shade400),
                  foregroundColor: Colors.grey.shade700,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  // Validation
                  if (_oldPasswordController.text.trim().isEmpty) {
                    showErrorDialog(context, 'Please enter your current password', title:'Current Password Required');
                    return;
                  }
                  if (_newPasswordController.text.trim().isEmpty) {
                    showErrorDialog(context, 'Please enter a new password', title:'New Password Required');
                    return;
                  }
                  if (_newPasswordController.text.trim().length < 8) {
                    showErrorDialog(context, 'Password must be at least 8 characters', title:'Weak Password');
                    return;
                  }
                  if (_newPasswordController.text != _confirmPasswordController.text) {
                    showErrorDialog(context, 'New password and confirmation do not match', title:'Password Mismatch');
                    return;
                  }

                  try {
                    await ref.read(authProvider.notifier).changePassword(
                      oldPassword: _oldPasswordController.text.trim(),
                      newPassword: _newPasswordController.text.trim(),
                    );
                    
                    if (!context.mounted) return;
                    setState(() {
                      _isChangingPassword = false;
                      _oldPasswordController.clear();
                      _newPasswordController.clear();
                      _confirmPasswordController.clear();
                      _obscureOldPassword = true;
                      _obscureNewPassword = true;
                      _obscureConfirmPassword = true;
                    });
                      
                    if (!context.mounted) return;
                    showSuccessDialog(context, 'Your password has been changed successfully', title: 'Password Updated');
                  
                  } catch (e) {
                    if (!context.mounted) return;
                    showErrorDialog(
                      context,
                      e.toString(),
                      title: 'Update Failed',
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange.shade400,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Update Password',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
