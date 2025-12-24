import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingState {
  final bool isLoading;
  final String storeName;
  final String storeAddress;
  final String storePhone;
  final int taxRate;
  final double takeAwayCharge;
  final String receiptFooter;

  SettingState({
    this.isLoading = true, // Start loading
    this.storeName = 'Warung Kopi Nusantara',
    this.storeAddress = 'Jl. Merdeka No. 123, Jakarta',
    this.storePhone = '021-12345678',
    this.taxRate = 11,
    this.takeAwayCharge = 2000.0,
    this.receiptFooter = 'Terima kasih atas kunjungan Anda!',
  });

  SettingState copyWith({
    bool? isLoading,
    String? storeName,
    String? storeAddress,
    String? storePhone,
    int? taxRate,
    double? takeAwayCharge,
    String? receiptFooter,
  }) {
    return SettingState(
      isLoading: isLoading ?? this.isLoading,
      storeName: storeName ?? this.storeName,
      storeAddress: storeAddress ?? this.storeAddress,
      storePhone: storePhone ?? this.storePhone,
      taxRate: taxRate ?? this.taxRate,
      takeAwayCharge: takeAwayCharge ?? this.takeAwayCharge,
      receiptFooter: receiptFooter ?? this.receiptFooter,
    );
  }
}

class SettingNotifier extends StateNotifier<SettingState> {
  SettingNotifier() : super(SettingState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    state = state.copyWith(
      isLoading: false,
      storeName: prefs.getString('storeName'),
      storeAddress: prefs.getString('storeAddress'),
      storePhone: prefs.getString('storePhone'),
      taxRate: prefs.getInt('taxRate'),
      takeAwayCharge: prefs.getDouble('takeAwayCharge'),
      receiptFooter: prefs.getString('receiptFooter'),
    );
  }

  Future<void> saveSettings({
    String? storeName,
    String? storeAddress,
    String? storePhone,
    int? taxRate,
    double? takeAwayCharge,
    String? receiptFooter,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    if (storeName != null) await prefs.setString('storeName', storeName);
    if (storeAddress != null) {
      await prefs.setString('storeAddress', storeAddress);
    }
    if (storePhone != null) await prefs.setString('storePhone', storePhone);
    if (taxRate != null) await prefs.setInt('taxRate', taxRate);
    if (takeAwayCharge != null) {
      await prefs.setDouble('takeAwayCharge', takeAwayCharge);
    }
    if (receiptFooter != null) {
      await prefs.setString('receiptFooter', receiptFooter);
    }

    // Update state
    state = state.copyWith(
      storeName: storeName,
      storeAddress: storeAddress,
      storePhone: storePhone,
      taxRate: taxRate,
      takeAwayCharge: takeAwayCharge,
      receiptFooter: receiptFooter,
    );
  }

  Future<void> resetToDefault() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // Reset state to default values (defined in constructor)
    state = SettingState(isLoading: false);
  }
}

final settingProvider =
    StateNotifierProvider<SettingNotifier, SettingState>((ref) {
  return SettingNotifier();
});
