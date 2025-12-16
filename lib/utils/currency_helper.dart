import 'package:intl/intl.dart';

class CurrencyHelper {
  // Format currency ke IDR (tanpa symbol)
  static String formatIDR(dynamic price) {
    double priceValue = double.tryParse(price.toString()) ?? 0.0;
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return formatter.format(priceValue);
  }
}