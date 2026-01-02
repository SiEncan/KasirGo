import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kasir_go/screen/profile/components/profile_text_field.dart';

class ProfileInfoCard extends StatelessWidget {
  final bool isEditing;
  final VoidCallback onEditPressed;
  final VoidCallback onCancelPressed;
  final VoidCallback onSavePressed;
  final TextEditingController usernameController;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final bool isLoading;

  const ProfileInfoCard({
    super.key,
    required this.isEditing,
    required this.onEditPressed,
    required this.onCancelPressed,
    required this.onSavePressed,
    required this.usernameController,
    required this.firstNameController,
    required this.lastNameController,
    required this.emailController,
    required this.phoneController,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  isEditing ? 'Edit Profile' : 'Profile Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade900,
                  ),
                ),
                if (!isEditing)
                  IconButton(
                    icon: Icon(Iconsax.edit, color: Colors.deepOrange.shade400),
                    onPressed: onEditPressed,
                  ),
              ],
            ),
            const SizedBox(height: 24),
            ProfileTextField(
              label: 'Username',
              controller: usernameController,
              hintText: 'Enter username',
              prefixIcon: Iconsax.user,
              enabled: isEditing,
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ProfileTextField(
                    label: 'First Name',
                    controller: firstNameController,
                    hintText: 'First name',
                    prefixIcon: Iconsax.profile_circle,
                    enabled: isEditing,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ProfileTextField(
                    label: 'Last Name',
                    controller: lastNameController,
                    hintText: 'Last name',
                    prefixIcon: Iconsax.profile_circle,
                    enabled: isEditing,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ProfileTextField(
              label: 'Email',
              controller: emailController,
              hintText: 'Enter email',
              prefixIcon: Iconsax.sms,
              keyboardType: TextInputType.emailAddress,
              enabled: isEditing,
            ),
            const SizedBox(height: 16),
            ProfileTextField(
              label: 'Phone',
              controller: phoneController,
              hintText: 'Enter phone number',
              prefixIcon: Iconsax.call,
              keyboardType: TextInputType.phone,
              enabled: isEditing,
            ),
            const SizedBox(height: 24),
            if (isEditing)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isLoading ? null : onCancelPressed,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey.shade400),
                        foregroundColor: Colors.grey.shade700,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isLoading ? null : onSavePressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange.shade400,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade200,
                        disabledForegroundColor: Colors.grey,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.grey,
                              ),
                            )
                          : const Text(
                              'Save Changes',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5),
                            ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
