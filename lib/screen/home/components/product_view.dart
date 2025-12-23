import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kasir_go/providers/cart_provider.dart';
import 'package:kasir_go/utils/currency_helper.dart';

class ProductView extends ConsumerWidget {
  final List<Map<String, dynamic>> products;

  const ProductView({
    super.key,
    required this.products,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverPadding(
      padding: const EdgeInsets.only(top: 4, left: 16, right: 12, bottom: 24),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.9,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final product = products[index];
            return _ProductCard(product: product, ref: ref);
          },
          childCount: products.length,
        ),
      ),
    );
  }
}

class _ProductCard extends StatefulWidget {
  final Map<String, dynamic> product;
  final WidgetRef ref;

  const _ProductCard({
    required this.product,
    required this.ref,
  });

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  final List<_BadgeAnimation> _badges = [];
  int _badgeIdCounter = 0;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    for (final badge in _badges) {
      badge.controller.dispose();
    }
    super.dispose();
  }

  void _spawnBadge() {
    final controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    final id = _badgeIdCounter++;
    final badge = _BadgeAnimation(id: id, controller: controller);

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          setState(() {
            _badges.removeWhere((b) => b.id == id);
          });
          controller.dispose();
        }
      }
    });

    setState(() => _badges.add(badge));
    controller.forward();
  }

  void _onTap() {
    final price = widget.product['price'];

    _scaleController.forward().then((_) => _scaleController.reverse());

    widget.ref.read(cartProvider.notifier).addCartItem(
          CartState(
            product: widget.product,
            quantity: 1,
            totalPrice: double.tryParse(price) ?? 0.0,
          ),
        );

    _spawnBadge();
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.product['image'] as String?;
    final price = widget.product['price'];

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.zero,
              side: BorderSide(
                color: Colors.grey.shade200,
                width: 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: _onTap,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: imageUrl != null
                            ? Colors.transparent
                            : Colors.grey.shade200,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: imageUrl != null && imageUrl.isNotEmpty
                            ? Image.network(
                                'http://10.0.2.2:8000$imageUrl',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.image_not_supported,
                                    size: 40,
                                    color: Colors.grey.shade400,
                                  );
                                },
                              )
                            : Icon(
                                Icons.restaurant,
                                size: 40,
                                color: Colors.grey.shade400,
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.product['name'] ?? 'Unknown',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  widget.product['description'] != null &&
                          widget.product['description'].isNotEmpty
                      ? Text(
                          widget.product['description'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        )
                      : const SizedBox.shrink(),
                  const SizedBox(height: 8),
                  Text(
                    CurrencyHelper.formatIDR(price),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ..._badges.map((badge) => Positioned(
                top: 0,
                bottom: 100,
                left: 0,
                right: 0,
                child: AnimatedBuilder(
                  animation: badge.controller,
                  builder: (context, child) {
                    final progress = badge.controller.value;
                    final opacity =
                        progress < 0.6 ? 1.0 : 1.0 - ((progress - 0.6) / 0.4);
                    final yOffset = -70 * progress;

                    return Transform.translate(
                      offset: Offset(0, yOffset),
                      child: Opacity(
                        opacity: opacity,
                        child: child,
                      ),
                    );
                  },
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.shade500,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Text(
                        '+1',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

class _BadgeAnimation {
  final int id;
  final AnimationController controller;

  _BadgeAnimation({required this.id, required this.controller});
}
