import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppMode {
  pos,
  kitchen,
  customer,
}

class AppModeNotifier extends StateNotifier<AppMode?> {
  AppModeNotifier() : super(null); // Null means no mode selected yet

  static const String _storageKey = 'selected_app_mode';

  Future<void> loadSavedMode() async {
    final prefs = await SharedPreferences.getInstance();
    final modeString = prefs.getString(_storageKey);
    if (modeString != null) {
      if (modeString == 'kitchen') {
        state = AppMode.kitchen;
      } else if (modeString == 'customer') {
        state = AppMode.customer;
      } else {
        state = AppMode.pos;
      }
    } else {
      state = null;
    }
  }

  Future<void> setMode(AppMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, mode.name);
  }

  Future<void> clearMode() async {
    state = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}

final appModeProvider = StateNotifierProvider<AppModeNotifier, AppMode?>((ref) {
  return AppModeNotifier();
});
