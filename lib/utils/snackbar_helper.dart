import 'package:flutter/material.dart';

enum SnackBarType { success, error, warning, info }

/// Helper function untuk menampilkan styled snackbar
/// 
/// Usage:
/// ```dart
/// showStyledSnackBar(
///   context,
///   message: 'Data berhasil disimpan',
///   type: SnackBarType.success,
/// );
/// ```
void showStyledSnackBar(
  BuildContext context, {
  required String message,
  required SnackBarType type,
  String? title,
  Duration? duration,
}) {
  IconData icon;
  Color backgroundColor;
  String defaultTitle;

  switch (type) {
    case SnackBarType.success:
      icon = Icons.check_circle;
      backgroundColor = Colors.green.shade700;
      defaultTitle = 'Success!';
      break;
    case SnackBarType.error:
      icon = Icons.error_outline;
      backgroundColor = Colors.red.shade700;
      defaultTitle = 'Error!';
      break;
    case SnackBarType.warning:
      icon = Icons.warning_amber_rounded;
      backgroundColor = Colors.orange.shade700;
      defaultTitle = 'Warning!';
      break;
    case SnackBarType.info:
      icon = Icons.info_outline;
      backgroundColor = Colors.blue.shade700;
      defaultTitle = 'Info';
      break;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      width: MediaQuery.of(context).size.width * 0.25,
      content: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title ?? defaultTitle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      duration: duration ?? const Duration(seconds: 3),
      elevation: 6,
    ),
  );
}

/// Shortcut functions untuk kemudahan penggunaan
void showSuccessSnackBar(BuildContext context, String message, {String? title}) {
  showStyledSnackBar(context, message: message, type: SnackBarType.success, title: title);
}

void showErrorSnackBar(BuildContext context, String message, {String? title}) {
  showStyledSnackBar(context, message: message, type: SnackBarType.error, title: title);
}

void showWarningSnackBar(BuildContext context, String message, {String? title}) {
  showStyledSnackBar(context, message: message, type: SnackBarType.warning, title: title);
}

void showInfoSnackBar(BuildContext context, String message, {String? title}) {
  showStyledSnackBar(context, message: message, type: SnackBarType.info, title: title);
}
