import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../screen/login_screen.dart';
import 'snackbar_helper.dart';

/// Helper function untuk handle session expired dengan informasi ke user
/// Digunakan untuk operasi CREATE/UPDATE/DELETE
Future<void> handleSessionExpired(
  BuildContext context,
  WidgetRef ref, {
  String? customMessage,
}) async {
  if (!context.mounted) return;
  
  // Tampilkan pesan ke user
  showErrorSnackBar(
    context,
    customMessage ?? 'Your session has expired. Please login again.',
  );
  
  // Logout user
  await ref.read(authProvider.notifier).logout();
  
  if (!context.mounted) return;
  
  // Redirect ke login screen
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => const LoginScreen()),
    (route) => false,
  );
}

/// Helper function untuk check apakah error adalah session expired
bool isSessionExpiredError(dynamic error) {
  final errorString = error.toString();
  return errorString.contains('REFRESH_TOKEN_EXPIRED') || 
         errorString.contains('Session expired') || 
         errorString.contains('User not logged in');
}
