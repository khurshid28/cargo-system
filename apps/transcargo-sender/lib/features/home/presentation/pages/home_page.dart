import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = (context.read<AuthBloc>().state as AuthAuthenticated?)?.user;
    return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Iconsax.user_copy, size: 36),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user?.phone ?? '—', style: const TextStyle(fontWeight: FontWeight.w600)),
                            Text('Rol: ${user?.role ?? '—'}', style: const TextStyle(color: Colors.black54, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 300.ms),
              const SizedBox(height: 16),
              _Tile(
                icon: Iconsax.add_square_copy,
                title: 'Yangi yuk so‘rovi',
                subtitle: 'A → B yuk yuborish',
                onTap: () => context.go('/create'),
              ),
              const SizedBox(height: 12),
              _Tile(
                icon: Iconsax.clock_copy,
                title: 'Tarix',
                subtitle: 'Oldingi yuborilgan yuklar',
                onTap: () => context.go('/history'),
              ),
            ],
          ),
        ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.icon, required this.title, required this.subtitle, required this.onTap});
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Iconsax.arrow_right_3),
        onTap: onTap,
      ),
    ).animate().slideX(begin: 0.05, duration: 250.ms).fadeIn();
  }
}
