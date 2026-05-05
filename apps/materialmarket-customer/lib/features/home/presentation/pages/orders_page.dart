import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/di/injection.dart';
import '../../../orders/data/orders_remote_data_source.dart';

final _money = NumberFormat.currency(locale: 'uz', symbol: 'so‘m', decimalDigits: 0);
final _date = DateFormat('dd.MM.yyyy HH:mm');

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});
  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  late Future<List<OrderSummary>> _f;
  @override
  void initState() {
    super.initState();
    _f = sl<OrdersRemoteDataSource>().mine();
  }

  Future<void> _refresh() async {
    setState(() => _f = sl<OrdersRemoteDataSource>().mine());
    await _f;
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'CREATED': return Colors.blueGrey;
      case 'CONFIRMED': return Colors.indigo;
      case 'PREPARING': return Colors.amber.shade800;
      case 'SHIPPING': return Colors.deepOrange;
      case 'DELIVERED': return Colors.green;
      case 'CANCELLED': return Colors.redAccent;
      default: return Colors.grey;
    }
  }

  String _statusLabel(String s) => switch (s) {
        'CREATED' => 'Yaratildi',
        'CONFIRMED' => 'Tasdiqlandi',
        'PREPARING' => 'Tayyorlanmoqda',
        'SHIPPING' => 'Yo‘lda',
        'DELIVERED' => 'Yetkazildi',
        'CANCELLED' => 'Bekor qilindi',
        _ => s,
      };

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: FutureBuilder<List<OrderSummary>>(
        future: _f,
        builder: (_, snap) {
          if (!snap.hasData) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 4,
              itemBuilder: (_, __) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(height: 120,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
                ),
              ),
            );
          }
          final orders = snap.data!;
          if (orders.isEmpty) {
            return ListView(children: const [
              SizedBox(height: 120),
              Center(child: Icon(Iconsax.box_copy, size: 56, color: Colors.black26)),
              SizedBox(height: 12),
              Center(child: Text('Hali buyurtmangiz yo‘q', style: TextStyle(color: Colors.black54))),
            ]);
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final o = orders[i];
              return Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Expanded(child: Text('#${o.id.substring(0, 6).toUpperCase()}',
                          style: const TextStyle(fontWeight: FontWeight.bold))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: _statusColor(o.status).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8)),
                        child: Text(_statusLabel(o.status),
                            style: TextStyle(color: _statusColor(o.status), fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                    ]),
                    const SizedBox(height: 6),
                    Row(children: [
                      const Icon(Iconsax.location_copy, size: 14, color: Colors.black54),
                      const SizedBox(width: 4),
                      Expanded(child: Text(o.address, style: const TextStyle(fontSize: 12))),
                    ]),
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Iconsax.calendar_1_copy, size: 14, color: Colors.black54),
                      const SizedBox(width: 4),
                      Text(_date.format(o.createdAt), style: const TextStyle(fontSize: 12, color: Colors.black54)),
                      const Spacer(),
                      Text(_money.format(o.total),
                          style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                    ]),
                    if (o.driverName != null) ...[
                      const Divider(height: 20),
                      Row(children: [
                        CircleAvatar(radius: 14, child: Text(o.driverName!.substring(0, 1))),
                        const SizedBox(width: 8),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(o.driverName!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            Text(o.driverPhone ?? '', style: const TextStyle(fontSize: 11, color: Colors.black54)),
                          ],
                        )),
                        IconButton(icon: const Icon(Iconsax.call_copy, color: Colors.green),
                          onPressed: () {}),
                      ]),
                    ],
                  ]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
