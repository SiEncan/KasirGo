import 'package:flutter_riverpod/flutter_riverpod.dart';

class CartState {
  final Map<String, dynamic> product;
  final int quantity;
  final double totalPrice;

  CartState({
    required this.product,
    required this.quantity,
    required this.totalPrice,
  });
}

class CartNotifier extends StateNotifier<List<CartState>> {
  CartNotifier() : super([]);
  
  List<CartState> getallCartItems() {
    return state;
  }

  void addCartItem(CartState item) {
    if (state.any((cartItem) => cartItem.product['id'] == item.product['id'])) {
      state = state.map((cartItem) {
        if (cartItem.product['id'] == item.product['id']) {
          double totalPrice = (cartItem.totalPrice + (item.quantity * double.parse(item.product['price'])));
          return CartState(
            product: cartItem.product,
            quantity: cartItem.quantity + item.quantity,
            totalPrice: totalPrice,
          );
        }
        return cartItem;
      }).toList();
    } else {
      state = [...state, item];
    }
  }

  void increaseQuantity(CartState item) {
    state = state.map((cartItem) {
      if (cartItem.product['id'] == item.product['id']) {
        double totalPrice = cartItem.totalPrice + double.parse(item.product['price']);
        return CartState(
          product: cartItem.product,
          quantity: cartItem.quantity + 1,
          totalPrice: totalPrice,
        );
      }
      return cartItem;
    }).toList();
  }

  void decreaseQuantity(CartState item) {
    state = state.where((cartItem) {
      if (cartItem.product['id'] == item.product['id']) {
        return cartItem.quantity > 1;
      }
      return true;
    }).map((cartItem) {
      if (cartItem.product['id'] == item.product['id']) {
        double totalPrice = cartItem.totalPrice - double.parse(item.product['price']);
        return CartState(
          product: cartItem.product,
          quantity: cartItem.quantity - 1,
          totalPrice: totalPrice,
        );
      }
      return cartItem;
    }).toList();
  }

  double getTotalCartPrice() {
    return state.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  void clearCart() {
    state = [];
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartState>>((ref) {
  return CartNotifier();
});