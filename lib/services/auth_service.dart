import 'package:flutter/foundation.dart';
import '../models/user.dart';

class AuthService extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Mock user credentials (in production, use real backend)
  final _validUsers = {
    'adnan@cafe.com': {
      'password': 'adnan123',
      'name': 'adnan',
      'role': 'admin',
    },
    'cashier@cafe.com': {
      'password': 'cashier123d',
      'name': 'Cashier User',
      'role': 'cashier',
    },
    'barista@cafe.com': {
      'password': 'barista123',
      'name': 'Barista User',
      'role': 'barista',
    },
  };

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));

      if (_validUsers.containsKey(email)) {
        final userData = _validUsers[email]!;
        if (userData['password'] == password) {
          _currentUser = User(
            id: email.split('@').first,
            email: email,
            name: userData['name'] as String,
            role: userData['role'] as String,
          );
          _isLoading = false;
          notifyListeners();
          return true;
        }
      }

      _error = 'Invalid email or password';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Login failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
