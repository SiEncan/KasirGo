import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kasir_go/providers/cart_provider.dart';
import 'package:kasir_go/screen/checkout/checkout_screen.dart';
import 'package:kasir_go/utils/currency_helper.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class OrderDetails extends ConsumerStatefulWidget {
  const OrderDetails({
    super.key,
  });

  @override
  ConsumerState<OrderDetails> createState() => _OrderDetailsState();
}

class _OrderDetailsState extends ConsumerState<OrderDetails> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  List<String> _trackedIds = [];

  @override
  void initState() {
    super.initState();
    _trackedIds =
        ref.read(cartProvider).map((e) => e.product['id'].toString()).toList();
  }

  void _onCartChanged(List<CartState>? previous, List<CartState> next) {
    if (previous == null) return;

    final previousIds = previous.map((e) => e.product['id'].toString()).toSet();
    final nextIds = next.map((e) => e.product['id'].toString()).toSet();

    // Handle clear cart (all items removed at once)
    if (next.isEmpty && previous.isNotEmpty) {
      for (int i = _trackedIds.length - 1; i >= 0; i--) {
        final removedItem = previous[i];
        _listKey.currentState?.removeItem(
          i,
          (context, animation) => SizeTransition(
            sizeFactor: animation,
            child: FadeTransition(
              opacity: animation,
              child: _buildItemContent(removedItem),
            ),
          ),
          duration: const Duration(milliseconds: 200),
        );
      }
      _trackedIds.clear();
      return;
    }

    // Find new items
    final addedIds = nextIds.difference(previousIds);
    for (final id in addedIds) {
      final index = next.indexWhere((e) => e.product['id'].toString() == id);
      if (index != -1) {
        _trackedIds.insert(index, id);
        _listKey.currentState?.insertItem(
          index,
          duration: const Duration(milliseconds: 500),
        );
      }
    }

    // Find removed items
    final removedIds = previousIds.difference(nextIds);
    for (final id in removedIds) {
      final index = _trackedIds.indexOf(id);
      if (index != -1) {
        final removedItem =
            previous.firstWhere((e) => e.product['id'].toString() == id);
        _trackedIds.removeAt(index);
        _listKey.currentState?.removeItem(
          index,
          (context, animation) => SizeTransition(
            sizeFactor: animation,
            child: FadeTransition(
              opacity: animation,
              child: _buildItemContent(removedItem),
            ),
          ),
          duration: const Duration(milliseconds: 200),
        );
      }
    }
  }

  void _showNotesDialog(CartState item) {
    final controller = TextEditingController(text: item.notes ?? '');

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(LucideIcons.pencil,
                            size: 20, color: Colors.grey.shade700),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Notes for ${item.product['name']}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(LucideIcons.x, color: Colors.grey.shade600),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Text Field
              TextField(
                controller: controller,
                maxLines: 3,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'e.g., Extra spicy, no onion, less ice...',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Colors.deepOrange.shade300, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Quick Tags
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildQuickTag('Extra spicy 🌶️', controller),
                  _buildQuickTag('No ice', controller),
                  _buildQuickTag('Less sugar', controller),
                  _buildQuickTag('No onion', controller),
                  _buildQuickTag('Extra sauce', controller),
                ],
              ),
              const SizedBox(height: 20),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        controller.clear();
                        ref.read(cartProvider.notifier).updateNotes(item, null);
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        'Clear Notes',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final notes = controller.text.trim();
                        ref.read(cartProvider.notifier).updateNotes(
                              item,
                              notes.isEmpty ? null : notes,
                            );
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Save Notes',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickTag(String text, TextEditingController controller) {
    return InkWell(
      onTap: () {
        final current = controller.text;
        if (current.isEmpty) {
          controller.text = text;
        } else {
          controller.text = '$current, $text';
        }
        controller.selection = TextSelection.fromPosition(
          TextPosition(offset: controller.text.length),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  Widget _buildCartItem(CartState item, Animation<double> animation) {
    return SlideTransition(
      position: animation.drive(
        Tween<Offset>(
          begin: const Offset(0, 0.5),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.elasticOut)),
      ),
      child: FadeTransition(
        opacity: animation.drive(
          Tween<double>(begin: 0, end: 1).chain(
            CurveTween(curve: Curves.easeOut),
          ),
        ),
        child: _buildItemContent(item),
      ),
    );
  }

  Widget _buildItemContent(CartState item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          item.product['image'] != null
              ? Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(
                        ("http://10.0.2.2:8000${item.product['image']}"),
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              : Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade200,
                  ),
                  child: Icon(
                    Icons.restaurant,
                    size: 32,
                    color: Colors.grey.shade400,
                  ),
                ),
          const SizedBox(width: 12),
          Expanded(
              child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product['name'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    CurrencyHelper.formatIDR(item.totalPrice),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          ref
                              .read(cartProvider.notifier)
                              .decreaseQuantity(item);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.remove, size: 16),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        item.quantity.toString(),
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 12),
                      InkWell(
                        onTap: () {
                          ref
                              .read(cartProvider.notifier)
                              .increaseQuantity(item);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.add, size: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () => _showNotesDialog(item),
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.pencilLine,
                              size: 13, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Text(
                            item.notes != null && item.notes!.isNotEmpty
                                ? 'Edit'
                                : 'Notes',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Listen to cart changes for animation
    ref.listen<List<CartState>>(cartProvider, _onCartChanged);

    final cartItems = ref.watch(cartProvider);

    return Expanded(
      flex: 2,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
        color: Colors.white,
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  LucideIcons.notepadText,
                  size: 24,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Order Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    side: BorderSide(
                      color: Colors.grey.shade400,
                      width: 1.5,
                    ),
                  ),
                  onPressed: () {
                    ref.read(cartProvider.notifier).clearCart();
                  },
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(Iconsax.refresh,
                            size: 16, color: Colors.grey[800]),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          'Reset Order',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 50),
            Expanded(
              child: Stack(
                children: [
                  AnimatedList(
                    key: _listKey,
                    initialItemCount: _trackedIds.length,
                    itemBuilder: (context, index, animation) {
                      if (index >= cartItems.length) {
                        return const SizedBox.shrink();
                      }
                      return _buildCartItem(cartItems[index], animation);
                    },
                  ),
                  AnimatedOpacity(
                    opacity: cartItems.isEmpty ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 100),
                    child: IgnorePointer(
                      ignoring: cartItems.isNotEmpty,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Icon(
                                LucideIcons.shoppingBag,
                                size: 42,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "Cart is Empty",
                              style: TextStyle(
                                  fontSize: 17,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Tap products to add them",
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Subtotal"),
                    Text(CurrencyHelper.formatIDR(ref
                        .read(cartProvider.notifier)
                        .getTotalCartPrice()
                        .toString())),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Tax (10%)"),
                    Text(CurrencyHelper.formatIDR(
                        (ref.read(cartProvider.notifier).getTotalCartPrice() *
                                0.1)
                            .toString())),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Service Charge"),
                    cartItems.isEmpty
                        ? Text(CurrencyHelper.formatIDR("0"))
                        : Text(CurrencyHelper.formatIDR("2000")),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      CurrencyHelper.formatIDR(
                          (ref.read(cartProvider.notifier).getTotalCartPrice() +
                                  ref
                                          .read(cartProvider.notifier)
                                          .getTotalCartPrice() *
                                      0.1 +
                                  (cartItems.isEmpty ? 0 : 2000))
                              .toString()),
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  disabledBackgroundColor: Colors.grey.shade300,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  if (cartItems.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CheckoutScreen(),
                      ),
                    );
                  }
                },
                child: const Text(
                  "Place Order",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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
