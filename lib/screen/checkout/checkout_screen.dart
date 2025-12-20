import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kasir_go/providers/cart_provider.dart';
import 'package:kasir_go/providers/payment_provider.dart';
import 'package:kasir_go/providers/transaction_provider.dart';
import 'package:kasir_go/screen/checkout/components/checkout_left_panel.dart';
import 'package:kasir_go/screen/checkout/components/checkout_right_panel.dart';
import 'package:kasir_go/screen/checkout/components/customer_name_dialog.dart';
import 'package:kasir_go/screen/checkout/components/payment_success_dialog.dart';
import 'package:kasir_go/screen/payment_screen.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  String selectedOrderType = 'Dine In';
  String selectedPaymentMethod = 'Cash';
  String customerName = '';
  String orderNotes = '';

  Future<void> _showCustomerNameDialog() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => CustomerNameDialog(initialName: customerName),
    );

    if (result != null) {
      setState(() => customerName = result);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const PaymentSuccessDialog(),
    );
  }

  Future<void> _handleConfirmPayment() async {
    final cartItems = ref.read(cartProvider);
    final subtotal = ref.read(cartProvider.notifier).getTotalCartPrice();
    final tax = subtotal * 0.1;
    final serviceCharge = cartItems.isEmpty ? 0.0 : 2000.0;
    final total = subtotal + tax + serviceCharge;

    // 1. Prepare Transaction Data
    final transactionItems = cartItems.map((item) {
      return {
        "product": item.product['id'],
        "product_name": item.product['name'],
        "quantity": item.quantity,
        "price": double.parse(item.product['price'].toString()),
        "subtotal": item.totalPrice,
        "notes": item.notes ?? "",
      };
    }).toList();

    final transactionPayload = {
      "customer_name": customerName.isNotEmpty ? customerName : "Guest",
      "order_type": selectedOrderType == 'Dine In' ? "dine_in" : "take_away",
      "payment_method": selectedPaymentMethod.toLowerCase(),
      "status": selectedPaymentMethod == 'Cash' ? 'completed' : 'pending',
      "paid_amount": total,
      "subtotal": subtotal,
      "tax": tax,
      "discount": 0,
      "total": total,
      "change_amount": 0,
      "notes": orderNotes,
      "items": transactionItems,
    };

    // 2. Create Transaction
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final transaction = await ref
        .read(transactionProvider.notifier)
        .createTransaction(transactionPayload);

    if (mounted) Navigator.pop(context); // Close loading

    if (transaction == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ref.read(transactionProvider).errorMessage ??
                'Transaction creation failed'),
          ),
        );
      }
      return;
    }

    final transactionId = transaction['id'];

    // 3. Handle Payment
    if (selectedPaymentMethod == 'QRIS' || selectedPaymentMethod == 'BCA VA') {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(child: CircularProgressIndicator()),
        );
      }
      final paymentMethod = selectedPaymentMethod == 'QRIS' ? 'SP' : 'BC';
      final success = await ref.read(paymentProvider.notifier).createPayment({
        'transaction_id': transactionId,
        'payment_method': paymentMethod,
      });

      if (mounted) Navigator.pop(context); // Close loading

      if (success) {
        if (!mounted) return;
        final paymentResult = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) => const PaymentScreen(),
          ),
        );

        if (paymentResult == true) {
          if (mounted) _showSuccessDialog();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(ref.read(paymentProvider).errorMessage ??
                  'Payment creation failed'),
            ),
          );
        }
      }
    } else {
      if (mounted) _showSuccessDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    final subtotal = ref.read(cartProvider.notifier).getTotalCartPrice();
    final tax = subtotal * 0.1;
    final serviceCharge = cartItems.isEmpty ? 0.0 : 2000.0;
    final total = subtotal + tax + serviceCharge;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        bottom: false,
        child: Row(
          children: [
            const CheckoutLeftPanel(),
            VerticalDivider(
              color: Colors.grey.shade300,
              thickness: 1,
              width: 1,
            ),
            CheckoutRightPanel(
              selectedOrderType: selectedOrderType,
              onOrderTypeChanged: (val) =>
                  setState(() => selectedOrderType = val),
              customerName: customerName,
              onCustomerNameTap: _showCustomerNameDialog,
              selectedPaymentMethod: selectedPaymentMethod,
              onPaymentMethodChanged: (val) =>
                  setState(() => selectedPaymentMethod = val),
              orderNotes: orderNotes,
              onNotesChanged: (val) => setState(() => orderNotes = val),
              subtotal: subtotal,
              tax: tax,
              serviceCharge: serviceCharge,
              total: total,
              isCartEmpty: cartItems.isEmpty,
              onConfirm: () => _handleConfirmPayment(),
            ),
          ],
        ),
      ),
    );
  }
}
