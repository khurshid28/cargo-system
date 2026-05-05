import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../core/env/app_env.dart';
import '../../cargo/presentation/pages/cargo_history_page.dart';
import '../../profile/presentation/sender_profile_page.dart';
import 'pages/home_page.dart';

class SenderShell extends StatefulWidget {
  const SenderShell({super.key});
  @override
  State<SenderShell> createState() => _SenderShellState();
}

class _SenderShellState extends State<SenderShell> {
  int _idx = 0;
  static const _titles = ['Bosh sahifa', 'Tarix', 'Profil'];
  @override
  Widget build(BuildContext context) {
    final pages = const [HomePage(), CargoHistoryPage(), SenderProfilePage()];
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_idx]),
        actions: [
          if (AppEnv.useMock)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.circular(8)),
              child: const Center(
                child: Text('MOCK', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.brown)),
              ),
            ),
        ],
      ),
      body: IndexedStack(index: _idx, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _idx,
        onDestinationSelected: (i) => setState(() => _idx = i),
        destinations: const [
          NavigationDestination(icon: Icon(Iconsax.home_2_copy), label: 'Bosh'),
          NavigationDestination(icon: Icon(Iconsax.clock_copy), label: 'Tarix'),
          NavigationDestination(icon: Icon(Iconsax.user), label: 'Profil'),
        ],
      ),
    );
  }
}
