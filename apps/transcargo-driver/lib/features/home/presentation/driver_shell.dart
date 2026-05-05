import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../core/env/app_env.dart';
import '../../earnings/presentation/earnings_page.dart';
import '../../jobs/presentation/pages/driver_home_page.dart';
import '../../profile/presentation/driver_profile_page.dart';

class DriverShell extends StatefulWidget {
  const DriverShell({super.key});
  @override
  State<DriverShell> createState() => _DriverShellState();
}

class _DriverShellState extends State<DriverShell> {
  int _idx = 0;
  static const _titles = ['Yuklar', 'Daromadlar', 'Profil'];
  @override
  Widget build(BuildContext context) {
    final pages = const [
      DriverHomePage(),
      EarningsPage(),
      DriverProfilePage(),
    ];
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
          NavigationDestination(icon: Icon(Iconsax.truck_copy), label: 'Yuklar'),
          NavigationDestination(icon: Icon(Iconsax.wallet_3_copy), label: 'Daromad'),
          NavigationDestination(icon: Icon(Iconsax.user), label: 'Profil'),
        ],
      ),
    );
  }
}
