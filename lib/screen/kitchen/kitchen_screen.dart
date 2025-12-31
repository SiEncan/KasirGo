import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:kasir_go/providers/transaction_provider.dart';
import 'package:kasir_go/screen/kitchen/components/kitchen_order_card.dart';
import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:kasir_go/utils/dialog_helper.dart';
import 'package:kasir_go/providers/app_mode_provider.dart';
import 'package:kasir_go/providers/auth_provider.dart';

class KitchenScreen extends ConsumerStatefulWidget {
  const KitchenScreen({super.key});

  @override
  ConsumerState<KitchenScreen> createState() => _KitchenScreenState();
}

class _KitchenScreenState extends ConsumerState<KitchenScreen> {
  StreamSubscription<DatabaseEvent>? _kitchenSubscription;

  @override
  void initState() {
    super.initState();
    _startListening();

    // Initial fetch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(transactionProvider.notifier).fetchKitchenTransactions();
    });
  }

  void _startListening() async {
    try {
      final tokenStorage = ref.read(tokenStorageProvider);
      final cafeId = await tokenStorage.getCafeId();

      if (cafeId == null) {
        debugPrint('[KDS] Failed to start listener: No Cafe ID found');
        return;
      }

      final dbRef =
          FirebaseDatabase.instance.ref('store_$cafeId/kitchen_trigger');
      _kitchenSubscription = dbRef.onValue.listen((event) {
        // Safe to call ref.read here as long as widget is mounted
        if (mounted) {
          ref.read(transactionProvider.notifier).fetchKitchenTransactions();
        }
      });
      debugPrint('[KDS] Listening to store_$cafeId/kitchen_trigger');
    } catch (e) {
      debugPrint('[KDS] Firebase Listener Error: $e');
    }
  }

  @override
  void dispose() {
    _kitchenSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(transactionProvider);
    final orders = state.kitchenTransactions;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('👨‍🍳 Kitchen Display System',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw),
            tooltip: 'Refresh Orders',
            onPressed: () {
              ref.read(transactionProvider.notifier).fetchKitchenTransactions();
            },
          ),
          PopupMenuButton<String>(
            color: Colors.white,
            onSelected: (value) async {
              if (value == 'switch') {
                final confirm = await showConfirmDialog(context,
                    message:
                        "Switching mode will return to mode selection. Continue?",
                    title: "Switch Mode");
                if (confirm == true) {
                  await ref.read(appModeProvider.notifier).clearMode();
                  if (context.mounted) {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        '/mode_selection', (route) => false);
                  }
                }
              } else if (value == 'logout') {
                final confirm = await showConfirmDialog(context,
                    message: "Are you sure you want to logout?",
                    title: "Logout");
                if (confirm == true) {
                  await ref.read(authProvider.notifier).logout();
                  await ref.read(appModeProvider.notifier).clearMode();
                  if (context.mounted) {
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil('/login', (route) => false);
                  }
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'switch',
                child: Row(
                  children: [
                    Icon(LucideIcons.arrowLeftRight,
                        size: 20, color: Colors.black87),
                    SizedBox(width: 12),
                    Text('Switch Mode'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(LucideIcons.logOut, size: 20, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Logout', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            icon: const Icon(Icons.more_vert),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: state.isLoadingKitchen && orders.isEmpty
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.orange.shade600,
              ),
            )
          : orders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.chefHat,
                          size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text('No active orders',
                          style: TextStyle(
                              fontSize: 18, color: Colors.grey.shade500)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => ref
                      .read(transactionProvider.notifier)
                      .fetchKitchenTransactions(),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 350,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return KitchenOrderCard(order: order);
                    },
                  ),
                ),
    );
  }
}
