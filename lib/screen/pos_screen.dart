import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: NavigationRail(
              backgroundColor: Colors.white,
              elevation: 2,
              selectedIconTheme: IconThemeData(
                color: Colors.deepOrange.shade400,
                opacity: 1,
              ),
              unselectedIconTheme: IconThemeData(
                color: Colors.grey[400],
                opacity: 1,
              ),
              unselectedLabelTextStyle: const TextStyle(
                color: Colors.white,
              ),
              useIndicator: false,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/logo/logo.svg',
                      width: 42,
                      height: 42,
                    ),
                    const SizedBox(height: 24),
                    Container(
                      height: 1,
                      width: 90,
                      color: Colors.grey[400],
                    ),
                  ],),
              ),
              destinations: [
                NavigationRailDestination(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  icon: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      // splashColor: Colors.deepOrange.withOpacity(0.3),
                      onTap: () {
                        setState(() {
                          selectedMenu = 'home';
                        });
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Iconsax.home5, size: 36),
                      ),
                    ),
                  ),
                  label: const Text("Home"),
                ),
                NavigationRailDestination(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  icon: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        setState(() {
                          selectedMenu = 'category';
                        });
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Iconsax.category5, size: 36),
                      ),
                    ),
                  ),
                  label: const Text("Category"),
                ),
                NavigationRailDestination(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  icon: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        setState(() {
                          selectedMenu = 'products';
                        });
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.fastfood, size: 36),
                      ),
                    ),
                  ),
                  label: const Text("Products"),
                ),
                NavigationRailDestination(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  icon: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        setState(() {
                          selectedMenu = 'profile';
                        });
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Iconsax.profile_circle4, size: 36),
                      ),
                    ),
                  ),
                  label: const Text("Profile"),
                ),
                NavigationRailDestination(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  icon: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        setState(() {
                          selectedMenu = 'settings';
                        });
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.settings, size: 36),
                      ),
                    ),
                  ),
                  label: const Text("Settings"),
                ),
              ],
              selectedIndex: _getSelectedIndex(),
              onDestinationSelected: (index) {
                setState(() {
                  selectedMenu = _getMenuFromIndex(index);
                });
              },
            ),
          ),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  int _getSelectedIndex() {
    switch (selectedMenu) {
      case 'home':
        return 0;
      case 'category':
        return 1;
      case 'products':
        return 2;
      case 'profile':
        return 3;
      case 'settings':
        return 4;
      default:
        return 0;
    }
  }

  String _getMenuFromIndex(int index) {
    switch (index) {
      case 0:
        return 'home';
      case 1:
        return 'category';
      case 2:
        return 'products';
      case 3:
        return 'profile';
      case 4:
        return 'settings';
      default:
        return 'home';
    }
  }

  Widget _buildContent() {
    switch (selectedMenu) {
      case 'home':
        return const HomeScreen();
      case 'category':
        return _buildCategoryScreen();
      case 'products':
        return _buildProductsScreen();
      case 'profile':
        return _buildProfileScreen();
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

  Widget _buildProductsScreen() {
    final authService = context.read<AuthService>();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.deepOrange.shade600,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Products & Cart',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                authService.currentUser?.name ?? 'User',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),

    ]);
  }

  Widget _buildProfileScreen() {
    final authService = context.read<AuthService>();

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 80,
            backgroundColor: Colors.deepOrange.shade600,
            child: const Icon(
              Icons.person,
              size: 80,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            authService.currentUser?.name ?? 'User',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            authService.currentUser?.email ?? 'user@cafe.com',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.deepOrange.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              authService.currentUser?.role ?? 'cashier',
              style: TextStyle(
                fontSize: 14,
                color: Colors.deepOrange.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              authService.logout();
              Navigator.of(context).pushReplacementNamed('/login');
            },
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
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