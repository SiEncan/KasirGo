import 'package:flutter/material.dart';
import 'package:kasir_go/utils/currency_helper.dart';
import 'package:kasir_go/utils/dialog_helper.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';

class CashPaymentDialog extends StatefulWidget {
  final double totalAmount;

  const CashPaymentDialog({super.key, required this.totalAmount});

  @override
  State<CashPaymentDialog> createState() => _CashPaymentDialogState();
}

class _CashPaymentDialogState extends State<CashPaymentDialog> {
  late TextEditingController _amountController;
  final NumberFormat _currencyFormat = NumberFormat.decimalPattern('id');

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    final input = _amountController.text.replaceAll('.', '');
    final amount = double.tryParse(input) ?? 0.0;

    if (amount < widget.totalAmount) {
      showErrorDialog(context, 'Jumlah uang kurang dari total pembayaran',
          title: 'Gagal');
      return;
    }

    Navigator.pop(context, amount);
  }

  void _addAmount(double amount) {
    _amountController.text = _currencyFormat.format(amount);
  }

  void _onKeypadTap(String value) {
    String currentText = _amountController.text.replaceAll('.', '');
    if (value == 'clear') {
      currentText = '';
    } else if (value == 'backspace') {
      if (currentText.isNotEmpty) {
        currentText = currentText.substring(0, currentText.length - 1);
      }
    } else if (value == '000') {
      if (currentText.isNotEmpty) currentText += '000';
    } else {
      currentText += value;
    }

    if (currentText.isEmpty) {
      _amountController.text = '';
      return;
    }

    final number = double.tryParse(currentText);
    if (number != null) {
      _amountController.text = _currencyFormat.format(number);
    }
  }

  @override
  Widget build(BuildContext context) {
    final suggestions = {
      widget.totalAmount,
      (widget.totalAmount / 10000).ceil() * 10000.0,
      (widget.totalAmount / 50000).ceil() * 50000.0,
      100000.0,
    }.where((s) => s >= widget.totalAmount).toList();
    suggestions.sort();

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Pembayaran Tunai',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(LucideIcons.x),
                ),
              ],
            ),
            Text(
              'Total Tagihan',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              CurrencyHelper.formatIDR(widget.totalAmount.toString()),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _amountController,
              readOnly: true,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                prefixText: 'Rp ',
                hintText: '0',
                filled: true,
                fillColor: Colors.grey.shade50,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: Colors.orange.shade700, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: suggestions.take(4).map((amount) {
                return ActionChip(
                  label: Text(CurrencyHelper.formatIDR(amount.toString())),
                  backgroundColor: Colors.orange.shade50,
                  labelStyle: TextStyle(color: Colors.deepOrange.shade700),
                  onPressed: () => _addAmount(amount),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.deepOrange.shade100),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            _buildKeypad(),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Bayar Sekarang',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    return Column(
      children: [
        Row(
          children: [
            _keypadButton('1'),
            _keypadButton('2'),
            _keypadButton('3'),
          ],
        ),
        Row(
          children: [
            _keypadButton('4'),
            _keypadButton('5'),
            _keypadButton('6'),
          ],
        ),
        Row(
          children: [
            _keypadButton('7'),
            _keypadButton('8'),
            _keypadButton('9'),
          ],
        ),
        Row(
          children: [
            _keypadButton('000', fontSize: 16),
            _keypadButton('0'),
            _keypadButton('backspace', icon: LucideIcons.delete),
          ],
        ),
      ],
    );
  }

  Widget _keypadButton(String value, {double fontSize = 20, IconData? icon}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Material(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: () => _onKeypadTap(value),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 50,
              alignment: Alignment.center,
              child: icon != null
                  ? Icon(icon, size: 20, color: Colors.black87)
                  : Text(
                      value,
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
