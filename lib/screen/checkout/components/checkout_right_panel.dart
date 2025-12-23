import 'package:flutter/material.dart';
import 'package:kasir_go/screen/checkout/components/checkout_widgets.dart';
import 'package:kasir_go/utils/currency_helper.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class CheckoutRightPanel extends StatelessWidget {
  final String selectedOrderType;
  final ValueChanged<String> onOrderTypeChanged;
  final String customerName;
  final VoidCallback onCustomerNameTap;
  final String selectedPaymentMethod;
  final ValueChanged<String> onPaymentMethodChanged;
  final String orderNotes;
  final ValueChanged<String> onNotesChanged;
  final double subtotal;
  final double tax;
  final int taxRate;
  final double takeAwayCharge;
  final double total;
  final bool isCartEmpty;
  final VoidCallback onConfirm;

  const CheckoutRightPanel({
    super.key,
    required this.selectedOrderType,
    required this.onOrderTypeChanged,
    required this.customerName,
    required this.onCustomerNameTap,
    required this.selectedPaymentMethod,
    required this.onPaymentMethodChanged,
    required this.orderNotes,
    required this.onNotesChanged,
    required this.subtotal,
    required this.tax,
    required this.taxRate,
    required this.takeAwayCharge,
    required this.total,
    required this.isCartEmpty,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 4,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        color: Colors.white,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order Type
                    const Text(
                      'Order Type',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OrderTypeButton(
                            icon: LucideIcons.utensils,
                            label: 'Dine In',
                            isSelected: selectedOrderType == 'Dine In',
                            onTap: () => onOrderTypeChanged('Dine In'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OrderTypeButton(
                            icon: LucideIcons.shoppingBag,
                            label: 'Take Away',
                            isSelected: selectedOrderType == 'Take Away',
                            onTap: () => onOrderTypeChanged('Take Away'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Customer Name
                    InkWell(
                      onTap: onCustomerNameTap,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.deepOrange.shade50,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                LucideIcons.user,
                                color: Colors.deepOrange.shade600,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Customer Name',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  Text(
                                    customerName.isEmpty
                                        ? 'Tap to add name'
                                        : customerName,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: customerName.isEmpty
                                          ? Colors.grey.shade400
                                          : Colors.grey.shade800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              LucideIcons.pencil,
                              color: Colors.grey.shade500,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Payment Method
                    const Text(
                      'Payment Method',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: PaymentMethodButton(
                            icon: LucideIcons.banknote,
                            label: 'Cash',
                            isSelected: selectedPaymentMethod == 'Cash',
                            onTap: () => onPaymentMethodChanged('Cash'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: PaymentMethodButton(
                            icon: LucideIcons.landmark,
                            label: 'BCA VA',
                            isSelected: selectedPaymentMethod == 'BCA VA',
                            onTap: () => onPaymentMethodChanged('BCA VA'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: PaymentMethodButton(
                            icon: LucideIcons.qrCode,
                            label: 'QRIS',
                            isSelected: selectedPaymentMethod == 'QRIS',
                            onTap: () => onPaymentMethodChanged('QRIS'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Notes
                    const Text(
                      'Notes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: orderNotes,
                      onChanged: onNotesChanged,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'Add notes for this order...',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: Colors.deepOrange.shade300),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Order Summary
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Order Summary',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SummaryRow(
                            label: 'Subtotal',
                            value:
                                CurrencyHelper.formatIDR(subtotal.toString()),
                          ),
                          const SizedBox(height: 10),
                          SummaryRow(
                            label: 'Tax ($taxRate%)',
                            value: CurrencyHelper.formatIDR(tax.toString()),
                          ),
                          const SizedBox(height: 10),
                          SummaryRow(
                            label: 'Take Away Charge',
                            value: CurrencyHelper.formatIDR(
                                takeAwayCharge.toString()),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Divider(color: Colors.grey.shade300),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              Text(
                                CurrencyHelper.formatIDR(total.toString()),
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepOrange.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Confirm Button
            const Divider(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    disabledBackgroundColor: Colors.grey.shade300,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  onPressed: isCartEmpty ? null : onConfirm,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(LucideIcons.circleCheck, color: Colors.white),
                      const SizedBox(width: 12),
                      Text(
                        'Confirm Payment • ${CurrencyHelper.formatIDR(total.toString())}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
