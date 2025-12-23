import 'package:flutter/material.dart';

enum DialogType { success, error, warning, info }

/// Helper function untuk menampilkan styled dialog
///
/// Usage:
/// ```dart
/// showStyledDialog(
///   context,
///   title: 'Error',
///   message: 'Product name is required',
///   type: DialogType.error,
/// );
/// ```
void showStyledDialog(
  BuildContext context, {
  required String message,
  required DialogType type,
  String? title,
  String? buttonText,
  VoidCallback? onPressed,
}) {
  IconData icon;
  List<Color> gradientColors;
  String defaultTitle;

  switch (type) {
    case DialogType.success:
      icon = Icons.check_circle_outline_rounded;
      gradientColors = [Colors.green.shade400, Colors.green.shade600];
      defaultTitle = 'Success!';
      break;
    case DialogType.error:
      icon = Icons.error_outline_rounded;
      gradientColors = [Colors.red.shade400, Colors.red.shade600];
      defaultTitle = 'Error!';
      break;
    case DialogType.warning:
      icon = Icons.warning_amber_rounded;
      gradientColors = [Colors.orange.shade400, Colors.orange.shade600];
      defaultTitle = 'Warning!';
      break;
    case DialogType.info:
      icon = Icons.info_outline_rounded;
      gradientColors = [Colors.blue.shade400, Colors.blue.shade600];
      defaultTitle = 'Information';
      break;
  }

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon with gradient background
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: gradientColors[0].withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 38,
                ),
              ),
              const SizedBox(height: 20),
              // Title
              Text(
                title ?? defaultTitle,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              // Message
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              // Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onPressed ?? () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: gradientColors[1],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    buttonText ?? 'Got it',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// Show confirmation dialog with Yes/No buttons
/// Returns true if user confirms, false if cancels
Future<bool?> showConfirmDialog(
  BuildContext context, {
  required String message,
  String? title,
  String? confirmText,
  String? cancelText,
  DialogType type = DialogType.warning,
}) async {
  IconData icon;
  List<Color> gradientColors;
  String defaultTitle;

  switch (type) {
    case DialogType.success:
      icon = Icons.check_circle_outline_rounded;
      gradientColors = [Colors.green.shade400, Colors.green.shade600];
      defaultTitle = 'Confirm';
      break;
    case DialogType.error:
      icon = Icons.error_outline_rounded;
      gradientColors = [Colors.red.shade400, Colors.red.shade600];
      defaultTitle = 'Confirm Delete';
      break;
    case DialogType.warning:
      icon = Icons.warning_amber_rounded;
      gradientColors = [Colors.orange.shade400, Colors.orange.shade600];
      defaultTitle = 'Confirm Action';
      break;
    case DialogType.info:
      icon = Icons.info_outline_rounded;
      gradientColors = [Colors.blue.shade400, Colors.blue.shade600];
      defaultTitle = 'Confirm';
      break;
  }

  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: gradientColors[0].withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 38,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                title ?? defaultTitle,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey.shade400),
                        foregroundColor: Colors.grey.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        cancelText ?? 'Cancel',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: gradientColors[1],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        confirmText ?? 'Confirm',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// Shortcut functions untuk kemudahan penggunaan
void showSuccessDialog(BuildContext context, String message, {String? title}) {
  showStyledDialog(context,
      message: message, type: DialogType.success, title: title);
}

void showErrorDialog(BuildContext context, String message, {String? title}) {
  showStyledDialog(context,
      message: message, type: DialogType.error, title: title);
}

void showWarningDialog(BuildContext context, String message, {String? title}) {
  showStyledDialog(context,
      message: message, type: DialogType.warning, title: title);
}

void showInfoDialog(BuildContext context, String message, {String? title}) {
  showStyledDialog(context,
      message: message, type: DialogType.info, title: title);
}

/// Shortcut for delete confirmation
Future<bool?> showDeleteConfirmDialog(
  BuildContext context, {
  required String message,
  String? title,
}) {
  return showConfirmDialog(
    context,
    message: message,
    title: title ?? 'Delete Confirmation',
    type: DialogType.error,
    confirmText: 'Delete',
    cancelText: 'Cancel',
  );
}
