import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/env/app_env.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../cart/data/cart_store.dart';
import 'cart_page.dart';
import 'catalog_page.dart';
import 'orders_page.dart';
import 'profile_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _idx = 0;

  @override
  Widget build(BuildContext context) {
    const pages = [
      CatalogPage(),
      CartPage(),
      OrdersPage(),
      ProfilePage(),
    ];
    final cart = sl<CartStore>();
    return Scaffold(
      appBar: AppBar(
        title: Text(const ['Mahsulotlar', 'Savat', 'Buyurtmalarim', 'Profil'][_idx]),
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
          IconButton(
            icon: const Icon(Iconsax.logout),
            onPressed: () => context.read<AuthBloc>().add(const AuthSignOutRequested()),
          ),
        ],
      ),
      body: IndexedStack(index: _idx, children: pages),
      bottomNavigationBar: AnimatedBuilder(
        animation: cart,
        builder: (_, __) => NavigationBar(
          selectedIndex: _idx,
          onDestinationSelected: (i) => setState(() => _idx = i),
          destinations: [
            const NavigationDestination(icon: Icon(Iconsax.shop_copy), label: 'Katalog'),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: cart.count > 0,
                label: Text('${cart.count}'),
                child: const Icon(Iconsax.shopping_cart_copy),
              ),
              label: 'Savat',
            ),
            const NavigationDestination(icon: Icon(Iconsax.box_copy), label: 'Buyurtmalar'),
            const NavigationDestination(icon: Icon(Iconsax.user), label: 'Profil'),
          ],
        ),
      ),
    );
  }
}
