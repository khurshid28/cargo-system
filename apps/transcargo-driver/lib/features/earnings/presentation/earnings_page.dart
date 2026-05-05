import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/di/injection.dart';
import '../data/earnings_remote_data_source.dart';

final _money = NumberFormat.currency(locale: 'uz', symbol: 'so‘m', decimalDigits: 0);
final _date = DateFormat('dd MMM, HH:mm');

class EarningsPage extends StatefulWidget {
  const EarningsPage({super.key});
  @override
  State<EarningsPage> createState() => _EarningsPageState();
}

class _EarningsPageState extends State<EarningsPage> {
  late Future<EarningsSummary> _f;
  @override
  void initState() {
    super.initState();
    _f = sl<EarningsRemoteDataSource>().summary();
  }

  Future<void> _refresh() async {
    setState(() => _f = sl<EarningsRemoteDataSource>().summary());
    await _f;
  }

  void _payout(int balance) async {
    final ok = await showModalBottomSheet<bool>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
          const Text('Pulni yechib olish', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text('Yechiladigan summa: ${_money.format(balance)}'),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, child: ElevatedButton.icon(
            icon: const Icon(Iconsax.tick_circle),
            label: const Text('Tasdiqlash'),
            onPressed: () => Navigator.pop(ctx, true),
          )),
        ]),
      ),
    );
    if (ok == true && mounted) {
      await sl<EarningsRemoteDataSource>().requestPayout(balance);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Yechib olish so‘rovi yuborildi')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: FutureBuilder<EarningsSummary>(
        future: _f,
        builder: (_, snap) {
          if (!snap.hasData) return _shimmer();
          final s = snap.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _balanceCard(context, s),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _statCard(Iconsax.calendar_copy, Colors.indigo, 'Bugun', s.todayAmount)),
                const SizedBox(width: 8),
                Expanded(child: _statCard(Iconsax.calendar_1_copy, Colors.deepOrange, 'Hafta', s.weekAmount)),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: _statCard(Iconsax.chart_2_copy, Colors.purple, 'Oy', s.monthAmount)),
                const SizedBox(width: 8),
                Expanded(child: _statCard(Iconsax.truck_copy, Colors.green, 'Reyslar', s.completedTrips,
                  isCount: true)),
              ]),
              const SizedBox(height: 20),
              const Text('Tarix', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              for (final e in s.entries) _entryTile(e),
            ],
          );
        },
      ),
    );
  }

  Widget _balanceCard(BuildContext context, EarningsSummary s) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [scheme.primary, scheme.primary.withOpacity(0.7)]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Mavjud balans', style: TextStyle(color: Colors.white70)),
        const SizedBox(height: 4),
        Text(_money.format(s.balance),
          style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: scheme.primary),
            icon: const Icon(Iconsax.money_recive_copy),
            label: const Text('Yechib olish'),
            onPressed: () => _payout(s.balance),
          )),
          const SizedBox(width: 8),
          IconButton(
            style: IconButton.styleFrom(backgroundColor: Colors.white24),
            icon: const Icon(Iconsax.document_text_copy, color: Colors.white),
            onPressed: () {},
          ),
        ]),
      ]),
    );
  }

  Widget _statCard(IconData icon, Color color, String label, int value, {bool isCount = false}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.black54, fontSize: 12)),
        const SizedBox(height: 2),
        Text(isCount ? '$value' : _money.format(value),
          style: const TextStyle(fontWeight: FontWeight.bold)),
      ]),
    );
  }

  Widget _entryTile(EarningEntry e) {
    final paid = e.status == 'PAID';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200)),
      child: Row(children: [
        CircleAvatar(
          backgroundColor: (paid ? Colors.green : Colors.amber).withOpacity(0.15),
          child: Icon(paid ? Iconsax.tick_circle_copy : Iconsax.clock_copy,
            color: paid ? Colors.green : Colors.amber.shade800),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(e.route, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(_date.format(e.date), style: const TextStyle(color: Colors.black54, fontSize: 12)),
        ])),
        Text(_money.format(e.amount), style: const TextStyle(fontWeight: FontWeight.bold)),
      ]),
    );
  }

  Widget _shimmer() => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(height: 130, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20))),
      ),
      const SizedBox(height: 12),
      for (int i = 0; i < 3; i++) Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(height: 70, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
        ),
      ),
    ],
  );
}
