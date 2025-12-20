import 'package:flutter/material.dart';
import 'package:kasir_go/component/main_navigation_rail.dart';
import 'package:kasir_go/screen/products/products_screen.dart';
import 'package:kasir_go/screen/profile_screen.dart';
import 'package:kasir_go/screen/home/home_screen.dart';

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
      case 'category':
        return _buildCategoryScreen();
      case 'products':
        return const ManageProductsScreen();
      case 'profile':
        return const ProfileScreen();
      case 'settings':
        return _buildSettingsScreen();
      default:
        return const HomeScreen();
    }
  }

  Widget _buildCategoryScreen() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Categories',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsScreen() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Settings',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Card(
            child: ListTile(
              leading: const Icon(Icons.receipt),
              title: const Text('Tax Rate'),
              subtitle: const Text('10%'),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {},
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.currency_exchange),
              title: const Text('Currency'),
              subtitle: const Text('USD (\$)'),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {},
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.print),
              title: const Text('Printer Settings'),
              subtitle: const Text('Default Printer'),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {},
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info),
              title: const Text('App Version'),
              subtitle: const Text('1.0.0'),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}
