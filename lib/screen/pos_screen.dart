import 'package:flutter/material.dart';
import 'package:kasir_go/component/main_navigation_rail.dart';
import 'package:kasir_go/screen/products/products_screen.dart';
import 'package:kasir_go/screen/profile/profile_screen.dart';
import 'package:kasir_go/screen/home/home_screen.dart';
import 'package:kasir_go/screen/transaction_history/transaction_history_screen.dart';
import 'package:kasir_go/screen/settings/settings_screen.dart';

class POSScreen extends StatefulWidget {
  const POSScreen({super.key});

  @override
  State<POSScreen> createState() => _POSScreenState();
}

class _POSScreenState extends State<POSScreen> {
  String selectedMenu = "home";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          MainNavigationRail(
            selectedMenu: selectedMenu,
            onMenuSelected: (menu) {
              setState(() {
                selectedMenu = menu;
              });
            },
          ),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (selectedMenu) {
      case 'home':
        return const HomeScreen();
      case 'transactionhistory':
        return const TransactionHistoryScreen();
      case 'products':
        return const ManageProductsScreen();
      case 'profile':
        return const ProfileScreen();
      case 'settings':
        return const SettingsScreen();
      default:
        return const HomeScreen();
    }
  }
}
