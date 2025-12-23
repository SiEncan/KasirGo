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

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80, // Set fixed width for custom rail
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 13),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/logo/logo.svg',
                  width: 42,
                  height: 42,
                ),
              ],
            ),
          ),
          Divider(
            color: Colors.grey[300],
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCustomDestination(
                    Iconsax.home5, 'Home', 'home', selectedMenu == 'home'),
                _buildCustomDestination(Icons.fastfood, 'Products', 'products',
                    selectedMenu == 'products'),
                _buildCustomDestination(
                    Iconsax.category5,
                    'Transaction History',
                    'transactionhistory',
                    selectedMenu == 'transactionhistory'),
                _buildCustomDestination(Iconsax.profile_circle5, 'Profile',
                    'profile', selectedMenu == 'profile'),
                _buildCustomDestination(Icons.settings, 'Settings', 'settings',
                    selectedMenu == 'settings'),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCustomDestination(
      IconData icon, String label, String menu, bool isSelected) {
    return InkWell(
        onTap: () => onMenuSelected(menu),
        borderRadius: BorderRadius.circular(12),
        child: TweenAnimationBuilder<Color?>(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
          tween: ColorTween(
            end: isSelected ? Colors.deepOrange.shade400 : Colors.grey[400],
          ),
          builder: (context, color, _) {
            return Icon(
              icon,
              size: 42,
              color: color,
            );
          },
        ));
  }
}
