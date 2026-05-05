import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';

import '../../auth/presentation/bloc/auth_bloc.dart';

final _money = NumberFormat.currency(locale: 'uz', symbol: 'so‘m', decimalDigits: 0);

class SenderProfilePage extends StatelessWidget {
  const SenderProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final state = context.watch<AuthBloc>().state;
    final user = state is AuthAuthenticated ? state.user : null;
    const balance = 850000;
    const totalSpent = 12500000;
    const totalShipments = 18;

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
            const CircleAvatar(radius: 30, backgroundColor: Colors.white24,
              child: Icon(Iconsax.user, color: Colors.white, size: 32)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(user?.phone ?? 'Yuk yuboruvchi',
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Rol: ${user?.role ?? 'SENDER'}', style: const TextStyle(color: Colors.white70)),
            ])),
            IconButton(icon: const Icon(Iconsax.edit, color: Colors.white), onPressed: () {}),
          ]),
        ),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: _Stat(icon: Iconsax.wallet_3_copy, color: Colors.indigo,
            label: 'Balans', value: _money.format(balance))),
          const SizedBox(width: 8),
          Expanded(child: _Stat(icon: Iconsax.box_copy, color: Colors.deepOrange,
            label: 'Yuborilgan', value: '$totalShipments ta')),
        ]),
        const SizedBox(height: 8),
        _Stat(icon: Iconsax.chart_2_copy, color: Colors.purple,
          label: 'Jami sarflangan', value: _money.format(totalSpent), full: true),
        const SizedBox(height: 12),
        SizedBox(width: double.infinity, child: ElevatedButton.icon(
          icon: const Icon(Iconsax.add_circle_copy),
          label: const Text('Hisobni to‘ldirish'),
          onPressed: () {},
        )),
        const SizedBox(height: 20),
        const _Section('Sozlamalar'),
        _Tile(icon: Iconsax.location_copy, title: 'Manzillarim', onTap: () {}),
        _Tile(icon: Iconsax.card_copy, title: 'To‘lov usullari', onTap: () {}),
        _Tile(icon: Iconsax.notification_copy, title: 'Bildirishnomalar', onTap: () {}),
        _Tile(icon: Iconsax.global_copy, title: 'Til', trailing: 'O‘zbek', onTap: () {}),
        const _Section('Yordam'),
        _Tile(icon: Iconsax.message_question_copy, title: 'Savol-javoblar', onTap: () {}),
        _Tile(icon: Iconsax.call_copy, title: 'Bog‘lanish', onTap: () {}),
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

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.color, required this.label,
    required this.value, this.full = false});
  final IconData icon; final Color color; final String label; final String value; final bool full;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: full ? double.infinity : null,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200)),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(color: Colors.black54, fontSize: 12)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        ]),
      ]),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 12, 4, 6),
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
