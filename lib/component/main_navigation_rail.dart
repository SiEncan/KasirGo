import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iconsax/iconsax.dart';

class MainNavigationRail extends StatelessWidget {
  final String selectedMenu;
  final ValueChanged<String> onMenuSelected;

  const MainNavigationRail({
    super.key,
    required this.selectedMenu,
    required this.onMenuSelected,
  });

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

  String _getMenuByIndex(int index) {
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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: NavigationRail(
        selectedIndex: _getSelectedIndex(),
        onDestinationSelected: (index) {
          onMenuSelected(_getMenuByIndex(index));
        },
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
            ],
          ),
        ),
        destinations: [
          _buildDestination(Iconsax.home5, 'Home', 'home'),
          _buildDestination(Iconsax.category5, 'Category', 'category'),
          _buildDestination(Icons.fastfood, 'Products', 'products'),
          _buildDestination(Iconsax.profile_circle4, 'Profile', 'profile'),
          _buildDestination(Icons.settings, 'Settings', 'settings'),
        ],
      ),
    );
  }

  NavigationRailDestination _buildDestination(IconData icon, String label, String menu) {
    return NavigationRailDestination(
      padding: const EdgeInsets.symmetric(vertical: 8),
      icon: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            onMenuSelected(menu);
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(icon, size: 36),
          ),
        ),
      ),
      label: Text(label),
    );
  }
}
