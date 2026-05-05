import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../auth/presentation/bloc/auth_bloc.dart';

class DriverProfilePage extends StatelessWidget {
  const DriverProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final state = context.watch<AuthBloc>().state;
    final user = state is AuthAuthenticated ? state.user : null;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [scheme.primary, scheme.primary.withOpacity(0.7)]),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(children: [
            const CircleAvatar(radius: 32, backgroundColor: Colors.white24,
              child: Icon(Iconsax.user, color: Colors.white, size: 36)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(user?.phone ?? 'Haydovchi',
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(6)),
                child: Row(mainAxisSize: MainAxisSize.min, children: const [
                  Icon(Iconsax.star1, color: Colors.amber, size: 14),
                  SizedBox(width: 4),
                  Text('4.9 · Premium haydovchi', style: TextStyle(color: Colors.white, fontSize: 12)),
                ]),
              ),
            ])),
          ]),
        ),
        const SizedBox(height: 20),
        const _Section('Hujjatlar'),
        _Tile(icon: Iconsax.car_copy, title: 'Avtomobil', trailing: 'Damas, 01A123BC', onTap: () {}),
        _Tile(icon: Iconsax.card_copy, title: 'Haydovchilik guvohnomasi', trailing: 'Tasdiqlangan', onTap: () {}),
        _Tile(icon: Iconsax.shield_tick_copy, title: 'Sug‘urta', trailing: '2026 gacha', onTap: () {}),
        const SizedBox(height: 12),
        const _Section('Sozlamalar'),
        _Tile(icon: Iconsax.notification_copy, title: 'Bildirishnomalar', onTap: () {}),
        _Tile(icon: Iconsax.global_copy, title: 'Til', trailing: 'O‘zbek', onTap: () {}),
        _Tile(icon: Iconsax.message_question_copy, title: 'Yordam', onTap: () {}),
        const SizedBox(height: 20),
        OutlinedButton.icon(
          icon: const Icon(Iconsax.logout, color: Colors.red),
          label: const Text('Chiqish', style: TextStyle(color: Colors.red)),
          style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.redAccent)),
          onPressed: () => context.read<AuthBloc>().add(const AuthSignOutRequested()),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 8, 4, 6),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
  );
}

class _Tile extends StatelessWidget {
  const _Tile({required this.icon, required this.title, this.trailing, this.onTap});
  final IconData icon; final String title; final String? trailing; final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    child: ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      trailing: trailing != null
        ? Row(mainAxisSize: MainAxisSize.min, children: [
            Text(trailing!, style: const TextStyle(color: Colors.black54)),
            const SizedBox(width: 4),
            const Icon(Iconsax.arrow_right_3_copy, size: 16),
          ])
        : const Icon(Iconsax.arrow_right_3_copy, size: 16),
      onTap: onTap,
    ),
  );
}
