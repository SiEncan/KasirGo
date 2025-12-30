import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:kasir_go/providers/app_mode_provider.dart';
import 'package:kasir_go/screen/pos_screen.dart';
import 'package:kasir_go/screen/kitchen/kitchen_screen.dart';

class ModeSelectionScreen extends ConsumerWidget {
  const ModeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Select Operation Mode',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Choose how you want to use this device today',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 48),
              Row(
                children: [
                  Expanded(
                    child: _ModeCard(
                      title: 'Cashier (POS)',
                      description:
                          'Take orders, process payments, and manage transactions.',
                      icon: LucideIcons.store,
                      color: Colors.blue,
                      onTap: () => _selectMode(context, ref, AppMode.pos),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _ModeCard(
                      title: 'Kitchen Display',
                      description:
                          'View incoming orders and manage preparation status.',
                      icon: LucideIcons.chefHat,
                      color: Colors.orange,
                      onTap: () => _selectMode(context, ref, AppMode.kitchen),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                'You can switch modes specifically in Settings later, or logout.',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectMode(
      BuildContext context, WidgetRef ref, AppMode mode) async {
    // Save selection
    await ref.read(appModeProvider.notifier).setMode(mode);

    if (!context.mounted) return;

    // Navigate
    if (mode == AppMode.pos) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const POSScreen()),
      );
    } else if (mode == AppMode.kitchen) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const KitchenScreen()),
      );
    }
  }
}

class _ModeCard extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final MaterialColor color;
  final VoidCallback onTap;

  const _ModeCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<_ModeCard> createState() => _ModeCardState();
}

class _ModeCardState extends State<_ModeCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 300,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _isHovered ? widget.color.shade400 : Colors.grey.shade200,
              width: _isHovered ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: _isHovered ? 0.2 : 0.05),
                blurRadius: _isHovered ? 24 : 12,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: widget.color.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.icon,
                  size: 48,
                  color: widget.color.shade600,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade900,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                widget.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
