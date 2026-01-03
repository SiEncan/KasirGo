import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kasir_go/providers/cart_provider.dart';
import 'package:kasir_go/providers/payment_provider.dart';
import 'package:kasir_go/providers/setting_provider.dart';
import 'package:kasir_go/providers/transaction_provider.dart';
import 'package:kasir_go/screen/checkout/components/checkout_left_panel.dart';
import 'package:kasir_go/screen/checkout/components/checkout_right_panel.dart';
import 'package:kasir_go/screen/checkout/components/customer_name_dialog.dart';
import 'package:kasir_go/screen/checkout/components/payment_success_dialog.dart';
import 'package:kasir_go/screen/checkout/components/cash_payment_dialog.dart';
import 'package:kasir_go/screen/payment_screen.dart';
import 'package:kasir_go/utils/dialog_helper.dart';
import 'package:kasir_go/utils/session_helper.dart';

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

  void _showSuccessDialog({
    String? trxId,
    double? total,
    double? paid,
    double? change,
    String? paymentMethod,
    bool isKdsError = false,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PaymentSuccessDialog(
        trxId: trxId,
        paid: paid,
        change: change,
        total: total,
        paymentMethod: paymentMethod ?? 'Cash',
        isKdsError: isKdsError,
      ),
    );
  }

  Future<void> _handleConfirmPayment() async {
    final cartItems = ref.read(cartProvider);
    final settings = ref.read(settingProvider);
    final subtotal = ref.read(cartProvider.notifier).getTotalCartPrice();

    final tax = subtotal * (settings.taxRate / 100);
    // Apply Take Away Charge only for Take Away orders
    final takeAwayCharge =
        selectedOrderType == 'Take Away' ? settings.takeAwayCharge : 0.0;
    final total = subtotal + tax + takeAwayCharge;

    // 1. Prepare Transaction Data Variables
    double paidAmount = total;
    double changeAmount = 0;

    // Handle Cash Payment Input
    if (selectedPaymentMethod == 'Cash') {
      final double? cashResult = await showDialog<double>(
        context: context,
        builder: (context) => CashPaymentDialog(totalAmount: total),
      );

      if (cashResult == null) return; // User cancelled
      paidAmount = cashResult;
      changeAmount = paidAmount - total;
    }

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

    // 1.5 Smart KDS Logic
    bool needsKitchen =
        cartItems.any((item) => item.product['needs_preparation'] == true);

    // Status Logic
    String initialStatus = 'pending';
    if (selectedPaymentMethod == 'Cash') {
      initialStatus = needsKitchen ? 'processing' : 'completed';
    }

    // Determine Payment Code for Atomic Backend
    String? paymentMethodCode;
    if (selectedPaymentMethod == 'QRIS') paymentMethodCode = 'SP';
    if (selectedPaymentMethod == 'BCA VA') paymentMethodCode = 'BC';

    final transactionPayload = {
      "customer_name": customerName.isNotEmpty ? customerName : "Guest",
      "order_type": selectedOrderType == 'Dine In' ? "dine_in" : "take_away",
      "payment_method": selectedPaymentMethod.toLowerCase(),
      "payment_method_code": paymentMethodCode,
      "status": initialStatus,
      "paid_amount": paidAmount,
      "subtotal": subtotal,
      "tax_percentage": settings.taxRate,
      "discount": 0,
      "total": total,
      "change_amount": changeAmount,
      "notes": orderNotes,
      "items": transactionItems,
      "takeaway_charge": takeAwayCharge,
    };

    // 2. Create Transaction (Atomic)
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
          child: CircularProgressIndicator(color: Colors.orange.shade600)),
    );

    final transaction = await ref
        .read(transactionProvider.notifier)
        .createTransaction(transactionPayload);

    if (!mounted) return;
    Navigator.pop(context); // Close loading

    if (transaction != null) {
      final bool isKdsError = transaction['_kds_sent'] == false;

      // 3. Handle Atomic Payment Response
      if (transaction.containsKey('payment_info')) {
        // Inject Atomic Payment Data into Provider
        ref
            .read(paymentProvider.notifier)
            .setPaymentFromAtomic(transaction['payment_info']);

        final paymentResult = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) => const PaymentScreen(),
          ),
        );

        if (paymentResult == true) {
          if (mounted) {
            _showSuccessDialog(
                total: total,
                paid: paidAmount,
                change: changeAmount,
                paymentMethod: selectedPaymentMethod,
                isKdsError: isKdsError);
          }
        }
      } else {
        // Cash or Standard Transaction
        if (mounted) {
          _showSuccessDialog(
              trxId: transaction['transaction_number'],
              total: total,
              paid: paidAmount,
              change: changeAmount,
              paymentMethod: selectedPaymentMethod,
              isKdsError: isKdsError);
        }
      }
    } else {
      // Failure Flow
      if (mounted) {
        final errorMessage = ref.read(transactionProvider).errorMessage;
        if (errorMessage != null) {
          if (isSessionExpiredError(errorMessage)) {
            await handleSessionExpired(context, ref);
            return;
          }
          showErrorDialog(context, errorMessage, title: 'Transaction Failed');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listeners for Transaction/Payment errors are handled locally in _handleConfirmPayment
    // to avoid conflict with the imperative loading dialog.

    final cartItems = ref.read(cartProvider);
    final settings = ref.read(settingProvider);
    final subtotal = ref.read(cartProvider.notifier).getTotalCartPrice();
    final tax = subtotal * (settings.taxRate / 100);
    final takeAwayCharge =
        selectedOrderType == 'Take Away' ? settings.takeAwayCharge : 0.0;
    final total = subtotal + tax + takeAwayCharge;

    return Scaffold(
      resizeToAvoidBottomInset: false,
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
              taxRate: settings.taxRate,
              takeAwayCharge: takeAwayCharge,
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
