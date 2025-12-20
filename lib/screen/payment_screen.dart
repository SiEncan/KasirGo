import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kasir_go/providers/payment_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class PaymentScreen extends ConsumerWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentState = ref.watch(paymentProvider);
    final paymentData = paymentState.currentPayment;

    // Listen to status changes to close screen on success
    ref.listen(paymentProvider, (previous, next) {
      if (next.isPaymentSuccess) {
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    });

    if (paymentData == null &&
        !paymentState.isLoading &&
        paymentState.errorMessage == null) {
      return const Scaffold(
        body: Center(child: Text('No active payment')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Payment',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.x, color: Colors.black),
          onPressed: () {
            ref.read(paymentProvider.notifier).reset();
            Navigator.of(context).pop(false);
          },
        ),
      ),
      body: SafeArea(
        child: paymentState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : paymentState.errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          paymentState.errorMessage!,
                          style:
                              const TextStyle(fontSize: 18, color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Close'),
                        )
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2)),
                              SizedBox(width: 8),
                              Text(
                                'Awaiting Payment...',
                                style: TextStyle(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Virtual Account Display
                        if (paymentData?['va_number'] != null) ...[
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.shade200,
                                  blurRadius: 20,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              border: Border.all(color: Colors.grey.shade100),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  'BCA Virtual Account',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      paymentData!['va_number'],
                                      style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    IconButton(
                                      onPressed: () {
                                        Clipboard.setData(ClipboardData(
                                            text: paymentData['va_number']));
                                      },
                                      icon: const Icon(LucideIcons.copy,
                                          size: 20),
                                      tooltip: "Copy",
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Salin nomor VA ini ke m-BCA atau ATM BCA',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ] else if (paymentData?['qr_string'] != null) ...[
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.shade200,
                                  blurRadius: 20,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              border: Border.all(color: Colors.grey.shade100),
                            ),
                            child: Column(
                              children: [
                                QrImageView(
                                  data: paymentData!['qr_string'],
                                  version: QrVersions.auto,
                                  size: 260.0,
                                ),
                                const SizedBox(height: 24),
                                const Text(
                                  'Scan QRIS to Pay',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'NMID: ${paymentData['reference'] ?? '-'}',
                                  style: TextStyle(color: Colors.grey.shade500),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 40),

                        // Total Amount
                        Text(
                          'Total Amount',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Rp ${paymentData != null ? paymentData['amount'] : '0'}', // Format this better if helper available
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrange,
                          ),
                        ),

                        const SizedBox(height: 40),

                        const Text(
                          'Open any e-wallet or banking app\nand scan the QR code above.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
