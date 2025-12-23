import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingState {
  final int taxRate;
  final double takeAwayCharge;

  SettingState({
    this.taxRate = 11,
    this.takeAwayCharge = 2000.0,
  });

  SettingState copyWith({
    int? taxRate,
    double? takeAwayCharge,
  }) {
    return SettingState(
      taxRate: taxRate ?? this.taxRate,
      takeAwayCharge: takeAwayCharge ?? this.takeAwayCharge,
    );
  }
}

class SettingNotifier extends StateNotifier<SettingState> {
  SettingNotifier() : super(SettingState());

  void updateTaxRate(int rate) {
    state = state.copyWith(taxRate: rate);
  }

  void updateTakeAwayCharge(double amount) {
    state = state.copyWith(takeAwayCharge: amount);
  }
}

final settingProvider =
    StateNotifierProvider<SettingNotifier, SettingState>((ref) {
  return SettingNotifier();
});
