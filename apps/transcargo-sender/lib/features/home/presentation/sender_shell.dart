import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../cargo/presentation/pages/cargo_history_page.dart';
import '../../profile/presentation/sender_profile_page.dart';
import 'pages/home_page.dart';

const _brand = Color(0xFF1670F5);

class SenderShell extends StatefulWidget {
  const SenderShell({super.key});
  @override
  State<SenderShell> createState() => _SenderShellState();
}

class _SenderShellState extends State<SenderShell> {
  int _idx = 0;
  @override
  Widget build(BuildContext context) {
    const pages = [HomePage(), CargoHistoryPage(), SenderProfilePage()];
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      body: IndexedStack(index: _idx, children: pages),
      extendBody: true,
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: _brand.withOpacity(0.06),
                blurRadius: 30,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Iconsax.home_2_copy,
                iconActive: Iconsax.home_2,
                label: 'Bosh',
                active: _idx == 0,
                onTap: () => setState(() => _idx = 0),
              ),
              _NavItem(
                icon: Iconsax.clock_copy,
                iconActive: Iconsax.clock,
                label: 'Tarix',
                active: _idx == 1,
                onTap: () => setState(() => _idx = 1),
              ),
              _NavItem(
                icon: Iconsax.user_octagon_copy,
                iconActive: Iconsax.user_octagon,
                label: 'Profil',
                active: _idx == 2,
                onTap: () => setState(() => _idx = 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.iconActive,
    required this.label,
    required this.active,
    required this.onTap,
  });
  final IconData icon;
  final IconData iconActive;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(horizontal: active ? 14 : 12, vertical: 10),
        decoration: BoxDecoration(
          color: active ? _brand.withOpacity(0.10) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(active ? iconActive : icon, color: active ? _brand : const Color(0xFF94A3B8), size: 22),
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              child: active
                  ? Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(label,
                          style: const TextStyle(color: _brand, fontWeight: FontWeight.w700, fontSize: 13)),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
