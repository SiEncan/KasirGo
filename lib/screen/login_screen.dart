import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kasir_go/providers/auth_provider.dart';
import 'package:kasir_go/screen/pos_screen.dart';
import 'package:kasir_go/utils/dialog_helper.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}
class _LoginScreenState extends ConsumerState<LoginScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
          children: [
            Expanded(
              flex: 5,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.deepOrange.shade400,
                      Colors.deepOrange.shade600,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                margin: const EdgeInsets.all(24),
                padding: const EdgeInsets.all(48),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Iconsax.shop,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 32),
                    RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: 'Welcome to ',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w300,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                          TextSpan(
                            text: 'Kasir',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                          TextSpan(
                            text: 'Go',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Transform Your Business with Modern Point of Sale',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withOpacity(0.95),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 48),
                    _buildFeatureItem(
                      Iconsax.chart,
                      'Real-time Analytics',
                      'Monitor your sales and inventory in real-time',
                    ),
                    const SizedBox(height: 20),
                    _buildFeatureItem(
                      Iconsax.security_user,
                      'Secure & Reliable',
                      'Your data is encrypted and backed up automatically',
                    ),
                    const SizedBox(height: 20),
                    _buildFeatureItem(
                      Iconsax.mobile,
                      'Multi-platform',
                      'Access from anywhere, on any device',
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
                padding: const EdgeInsets.all(48),
                // decoration: BoxDecoration(
                //   color: Colors.white,
                //   borderRadius: BorderRadius.circular(24),
                //   boxShadow: [
                //     BoxShadow(
                //       color: Colors.grey.shade200,
                //       blurRadius: 20,
                //       offset: const Offset(0, 10),
                //     ),
                //   ],
                // ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Welcome back! Please enter your credentials',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 40),
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
                      controller: usernameController,
                      decoration: InputDecoration(
                        hintText: 'Enter your username',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 15,
                        ),
                        prefixIcon: Icon(
                          Iconsax.user,
                          color: Colors.grey.shade500,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.deepOrange.shade400,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      keyboardType: TextInputType.text,
                      style: const TextStyle(fontSize: 15),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Password',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        hintText: 'Enter your password',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 15,
                        ),
                        prefixIcon: Icon(
                          Iconsax.lock,
                          color: Colors.grey.shade500,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Iconsax.eye_slash
                                : Iconsax.eye,
                            color: Colors.grey.shade500,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.deepOrange.shade400,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      obscureText: _obscurePassword,
                      style: const TextStyle(fontSize: 15),
                    ),
                    const SizedBox(height: 32),
                    if (authState.isLoading)
                      Center(
                        child: CircularProgressIndicator(
                          color: Colors.deepOrange.shade400,
                        ),
                      )
                    else
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (usernameController.text.trim().isEmpty) {
                              showErrorDialog(context, 'Please enter your username to continue', title: 'Username Required');
                              return;
                            }

                            if (passwordController.text.trim().isEmpty) {
                              showErrorDialog(context, 'Please enter your password to continue', title: 'Password Required');
                              return;
                            }

                            try {
                              await ref.read(authProvider.notifier).login(
                                usernameController.text.trim(),
                                passwordController.text.trim(),
                              );

                              if (!context.mounted) return;
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const POSScreen()),
                              );
                            } catch (e) {
                              if (!context.mounted) return;
                              final errorMessage = e.toString();
                              String title = 'Login Failed';
                              String message = 'Invalid username or password. Please try again.';

                              if (errorMessage.contains('network') ||
                                  errorMessage.contains('SocketException')) {
                                title = 'Connection Error';
                                message = 'Unable to connect to server. Please check your internet connection.';
                              } else if (errorMessage.contains('timeout')) {
                                title = 'Request Timeout';
                                message = 'Server is taking too long to respond. Please try again.';
                              } else if (errorMessage.contains('401') ||
                                  errorMessage.contains('Invalid credentials') ||
                                  errorMessage.contains('Invalid')) {
                                title = 'Invalid Credentials';
                                message = errorMessage; // Tampilkan message dari backend
                              } else if (errorMessage.contains('500')) {
                                title = 'Server Error';
                                message = 'Server is experiencing issues. Please try again later.';
                              } else {
                                // Default: tampilkan error message dari backend
                                title = 'Login Failed';
                                message = errorMessage;
                              }

                              showErrorDialog(context, message, title: title);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrange.shade400,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            shadowColor: Colors.deepOrange.shade200,
                          ),
                          child: const Text(
                            'Sign In',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            )
          ],
        ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 24,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.85),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
