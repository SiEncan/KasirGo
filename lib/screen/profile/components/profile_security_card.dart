import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kasir_go/screen/profile/components/profile_text_field.dart';

class ProfileSecurityCard extends StatefulWidget {
  final bool isChangingPassword;
  final VoidCallback onTogglePressed;
  final VoidCallback onCancelPressed;
  final VoidCallback onUpdatePressed;
  final TextEditingController oldPasswordController;
  final TextEditingController newPasswordController;
  final TextEditingController confirmPasswordController;

  const ProfileSecurityCard({
    super.key,
    required this.isChangingPassword,
    required this.onTogglePressed,
    required this.onCancelPressed,
    required this.onUpdatePressed,
    required this.oldPasswordController,
    required this.newPasswordController,
    required this.confirmPasswordController,
  });

  @override
  State<ProfileSecurityCard> createState() => _ProfileSecurityCardState();
}

class _ProfileSecurityCardState extends State<ProfileSecurityCard> {
  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void didUpdateWidget(covariant ProfileSecurityCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset visibility when the form is closed/reset externally
    if (oldWidget.isChangingPassword && !widget.isChangingPassword) {
      setState(() {
        _obscureOldPassword = true;
        _obscureNewPassword = true;
        _obscureConfirmPassword = true;
      });
    }
  }

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
                  widget.isChangingPassword ? 'Change Password' : 'Security',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade900,
                  ),
                ),
                if (!widget.isChangingPassword)
                  IconButton(
                    icon: Icon(Iconsax.lock, color: Colors.deepOrange.shade400),
                    onPressed: widget.onTogglePressed,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            _buildContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (!widget.isChangingPassword) {
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
                  child: Icon(Iconsax.lock,
                      color: Colors.deepOrange.shade400, size: 24),
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
      children: [
        ProfileTextField(
          label: 'Current Password',
          controller: widget.oldPasswordController,
          hintText: 'Enter current password',
          prefixIcon: Iconsax.lock,
          obscureText: _obscureOldPassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscureOldPassword ? Iconsax.eye_slash : Iconsax.eye,
              color: Colors.grey.shade500,
            ),
            onPressed: () => setState(() {
              _obscureOldPassword = !_obscureOldPassword;
            }),
          ),
        ),
        const SizedBox(height: 16),
        ProfileTextField(
          label: 'New Password',
          controller: widget.newPasswordController,
          hintText: 'Enter new password',
          prefixIcon: Iconsax.lock_1,
          obscureText: _obscureNewPassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscureNewPassword ? Iconsax.eye_slash : Iconsax.eye,
              color: Colors.grey.shade500,
            ),
            onPressed: () => setState(() {
              _obscureNewPassword = !_obscureNewPassword;
            }),
          ),
        ),
        const SizedBox(height: 16),
        ProfileTextField(
          label: 'Confirm New Password',
          controller: widget.confirmPasswordController,
          hintText: 'Confirm new password',
          prefixIcon: Iconsax.lock_1,
          obscureText: _obscureConfirmPassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscureConfirmPassword ? Iconsax.eye_slash : Iconsax.eye,
              color: Colors.grey.shade500,
            ),
            onPressed: () => setState(() {
              _obscureConfirmPassword = !_obscureConfirmPassword;
            }),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: widget.onCancelPressed,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: Colors.grey.shade400),
                  foregroundColor: Colors.grey.shade700,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
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
                onPressed: widget.onUpdatePressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange.shade400,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Update Password',
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
    );
  }
}
