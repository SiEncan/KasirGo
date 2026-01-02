import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kasir_go/utils/session_helper.dart';
import 'package:kasir_go/utils/snackbar_helper.dart';
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
  bool _isStreamError = false;
  bool _isConnected = false;

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
          FirebaseDatabase.instance.ref('stores/$cafeId/kitchen_trigger');
      _kitchenSubscription = dbRef.onValue.listen((event) {
        // Safe to call ref.read here as long as widget is mounted
        if (mounted) {
          ref.read(transactionProvider.notifier).fetchKitchenTransactions();
        }
      }, onError: (error) {
        debugPrint('[KDS] Stream Error: $error');
        if (mounted) {
          setState(() {
            _isStreamError = true;
            _isConnected = false;
          });
          // Retry logic: Try to reconnect after 5 seconds
          Future.delayed(const Duration(seconds: 5), () {
            if (mounted) {
              debugPrint('[KDS] Retrying connection...');
              _startListening();
            }
          });
        }
      });
      debugPrint('[KDS] Listening to stores/$cafeId/kitchen_trigger');
      if (mounted) {
        setState(() {
          _isConnected = true;
          _isStreamError = false;
        });
      }
    } catch (e) {
      debugPrint('[KDS] Firebase Listener Error: $e');
      if (mounted) {
        setState(() {
          _isStreamError = true;
          _isConnected = false;
        });
        // Retry logic: Try to reconnect after 5 seconds
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) {
            debugPrint('[KDS] Retrying connection...');
            _startListening();
          }
        });
      }
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

    ref.listen(transactionProvider, (previous, next) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        if (isSessionExpiredError(next.errorMessage)) {
          handleSessionExpired(context, ref);
          return;
        }
        showErrorSnackBar(context, next.errorMessage!);
      }
    });

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                LucideIcons.chefHat,
                color: Colors.orange.shade600,
                size: 28,
              ),
            ),
            const SizedBox(width: 8),
            const Text(' Kitchen Display System',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          // Connection Status Indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _isStreamError
                  ? Colors.red.shade50
                  : (_isConnected ? Colors.green.shade50 : Colors.grey.shade50),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _isStreamError
                    ? Colors.red.shade200
                    : (_isConnected
                        ? Colors.green.shade200
                        : Colors.grey.shade300),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _isStreamError
                      ? LucideIcons.wifiOff
                      : (_isConnected ? LucideIcons.wifi : LucideIcons.loader),
                  size: 16,
                  color: _isStreamError
                      ? Colors.red
                      : (_isConnected ? Colors.green : Colors.grey),
                ),
                const SizedBox(width: 6),
                Text(
                  _isStreamError
                      ? 'OFFLINE'
                      : (_isConnected ? 'LIVE' : 'CONNECTING'),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _isStreamError
                        ? Colors.red
                        : (_isConnected ? Colors.green : Colors.grey),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
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
                  color: Colors.orange.shade600,
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
