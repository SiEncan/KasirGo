import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin(BuildContext context) async {
    final authService = context.read<AuthService>();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    final success = await authService.login(email, password);

    if (success && mounted) {
      if (!context.mounted) return;
      Navigator.of(context).pushReplacementNamed('/pos');
    }
  }

  @override

  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.orange[900],
              ),
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.only(top: 20, left: 20),
              width: MediaQuery.of(context).size.width * 0.5,
              height: double.infinity,
              child: const Column(
                children: [
                  Text('Transform Your Business with KasirGo',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.normal,
                      color: Colors.white,
                    ),
                  ),  
                ] 
              ),
            ),
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              width: MediaQuery.of(context).size.width * 0.4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.orange[900],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.local_cafe,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Cashier Login', 
                    style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Handle transactions effortlessly with the Kasio cashier system.', 
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w400
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: 'Email',
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    obscureText: _obscurePassword,
                  )
                  , const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => _handleLogin(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[900],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
            
          ],
        )
        


      //   decoration: BoxDecoration(
      //     gradient: LinearGradient(
      //       begin: Alignment.topLeft,
      //       end: Alignment.bottomRight,
      //       colors: [
      //         Theme.of(context).colorScheme.primary,
      //         Theme.of(context).colorScheme.primary.withOpacity(0.7),
      //       ],
      //     ),
      //   ),
      //   child: Center(
      //     child: SingleChildScrollView(
      //       child: Padding(
      //         padding: const EdgeInsets.all(24.0),
      //         child: Consumer<AuthService>(
      //           builder: (context, authService, _) {
      //             return Column(
      //               mainAxisAlignment: MainAxisAlignment.center,
      //               children: [
      //                 // Logo/Title
      //                 Container(
      //                   padding: const EdgeInsets.all(24),
      //                   decoration: BoxDecoration(
      //                     color: Colors.white,
      //                     borderRadius: BorderRadius.circular(20),
      //                     boxShadow: [
      //                       BoxShadow(
      //                         color: Colors.black.withOpacity(0.1),
      //                         blurRadius: 20,
      //                         offset: const Offset(0, 10),
      //                       ),
      //                     ],
      //                   ),
      //                   child: Column(
      //                     children: [
      //                       Icon(
      //                         Icons.local_cafe,
      //                         size: 80,
      //                         color: Theme.of(context).colorScheme.primary,
      //                       ),
      //                       const SizedBox(height: 24),
      //                       Text(
      //                         'CAFE POS',
      //                         style: Theme.of(context)
      //                             .textTheme
      //                             .headlineLarge
      //                             ?.copyWith(
      //                               fontWeight: FontWeight.bold,
      //                               color: Theme.of(context)
      //                                   .colorScheme
      //                                   .primary,
      //                             ),
      //                       ),
      //                       const SizedBox(height: 8),
      //                       Text(
      //                         'Point of Sale System',
      //                         style: Theme.of(context).textTheme.titleMedium
      //                             ?.copyWith(
      //                               color: Colors.grey[600],
      //                             ),
      //                       ),
      //                       const SizedBox(height: 32),
      //                       // Email Field
      //                       TextField(
      //                         controller: _emailController,
      //                         decoration: InputDecoration(
      //                           hintText: 'Email',
      //                           prefixIcon: const Icon(Icons.email),
      //                           border: OutlineInputBorder(
      //                             borderRadius: BorderRadius.circular(12),
      //                           ),
      //                         ),
      //                         keyboardType: TextInputType.emailAddress,
      //                         enabled: !authService.isLoading,
      //                       ),
      //                       const SizedBox(height: 16),
      //                       // Password Field
      //                       TextField(
      //                         controller: _passwordController,
      //                         decoration: InputDecoration(
      //                           hintText: 'Password',
      //                           prefixIcon: const Icon(Icons.lock),
      //                           suffixIcon: IconButton(
      //                             icon: Icon(
      //                               _obscurePassword
      //                                   ? Icons.visibility_off
      //                                   : Icons.visibility,
      //                             ),
      //                             onPressed: () {
      //                               setState(() {
      //                                 _obscurePassword = !_obscurePassword;
      //                               });
      //                             },
      //                           ),
      //                           border: OutlineInputBorder(
      //                             borderRadius: BorderRadius.circular(12),
      //                           ),
      //                         ),
      //                         obscureText: _obscurePassword,
      //                         enabled: !authService.isLoading,
      //                       ),
      //                       const SizedBox(height: 8),
      //                       // Error Message
      //                       if (authService.error != null)
      //                         Padding(
      //                           padding: const EdgeInsets.only(top: 8),
      //                           child: Text(
      //                             authService.error!,
      //                             style: TextStyle(
      //                               color: Colors.red[600],
      //                               fontSize: 13,
      //                             ),
      //                             textAlign: TextAlign.center,
      //                           ),
      //                         ),
      //                       const SizedBox(height: 24),
      //                       // Login Button
      //                       SizedBox(
      //                         width: double.infinity,
      //                         height: 50,
      //                         child: ElevatedButton(
      //                           onPressed: authService.isLoading
      //                               ? null
      //                               : () => _handleLogin(context),
      //                           style: ElevatedButton.styleFrom(
      //                             backgroundColor:
      //                                 Theme.of(context).colorScheme.primary,
      //                             shape: RoundedRectangleBorder(
      //                               borderRadius: BorderRadius.circular(12),
      //                             ),
      //                           ),
      //                           child: authService.isLoading
      //                               ? const SizedBox(
      //                                   height: 24,
      //                                   width: 24,
      //                                   child: CircularProgressIndicator(
      //                                     strokeWidth: 2,
      //                                     valueColor:
      //                                         AlwaysStoppedAnimation<Color>(
      //                                       Colors.white,
      //                                     ),
      //                                   ),
      //                                 )
      //                               : const Text(
      //                                   'Login',
      //                                   style: TextStyle(
      //                                     fontSize: 16,
      //                                     fontWeight: FontWeight.bold,
      //                                     color: Colors.white,
      //                                   ),
      //                                 ),
      //                         ),
      //                       ),
      //                       const SizedBox(height: 16),
      //                       // Demo Credentials
      //                       Container(
      //                         padding: const EdgeInsets.all(12),
      //                         decoration: BoxDecoration(
      //                           color: Colors.blue[50],
      //                           borderRadius: BorderRadius.circular(8),
      //                           border: Border.all(color: Colors.blue[200]!),
      //                         ),
      //                         child: Column(
      //                           children: [
      //                             Text(
      //                               'Demo Credentials',
      //                               style: TextStyle(
      //                                 fontWeight: FontWeight.bold,
      //                                 color: Colors.blue[900],
      //                               ),
      //                             ),
      //                             const SizedBox(height: 8),
      //                             Text(
      //                               'admin@cafe.com / admin123\ncashier@cafe.com / cashier123',
      //                               style: TextStyle(
      //                                 fontSize: 12,
      //                                 color: Colors.blue[700],
      //                               ),
      //                               textAlign: TextAlign.center,
      //                             ),
      //                           ],
      //                         ),
      //                       ),
      //                     ],
      //                   ),
      //                 ),
      //               ],
      //             );
      //           },
      //         ),
      //       ),
      //     ),
      //   ),
      // ),
      
    );
  }
}
