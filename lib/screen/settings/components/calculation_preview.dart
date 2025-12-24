import 'package:flutter/material.dart';
import 'package:kasir_go/utils/currency_helper.dart';

class CalculationPreview extends StatelessWidget {
  final TextEditingController taxController;
  final TextEditingController takeAwayChargeController;

  const CalculationPreview({
    super.key,
    required this.taxController,
    required this.takeAwayChargeController,
  });

  @override
  Widget build(BuildContext context) {
    // Current values from controllers for live preview
    final taxRate = int.tryParse(taxController.text) ?? 0;
    final takeAwayCharge = double.tryParse(
            takeAwayChargeController.text.replaceAll(RegExp(r'[^0-9]'), '')) ??
        0.0;

    const dummySubtotal = 100000.0;
    final taxAmount = dummySubtotal * (taxRate / 100);
    final total = dummySubtotal + taxAmount + takeAwayCharge;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Preview Kalkulasi",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _buildPreviewRow("Contoh Subtotal:", dummySubtotal, isBold: false),
          _buildPreviewRow("Pajak ($taxRate%):", taxAmount, isBold: false),
          _buildPreviewRow("Biaya Take Away:", takeAwayCharge, isBold: false),
          const Divider(height: 24),
          _buildPreviewRow("Total (Take Away):", total,
              isBold: true, color: Colors.deepOrange),
        ],
      ),
    );
  }

  Widget _buildPreviewRow(String label, double amount,
      {bool isBold = false, Color? color}) {
    final formatted = CurrencyHelper.formatIDR(amount);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                  fontSize: isBold ? 16 : 14,
                  color: isBold ? Colors.black87 : Colors.grey.shade600)),
          Text(formatted,
              style: TextStyle(
                  fontFamily: 'Monospace', // Courier like font for numbers
                  fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                  fontSize: isBold ? 16 : 14,
                  color: color ?? Colors.black87)),
        ],
      ),
    );
  }
}
