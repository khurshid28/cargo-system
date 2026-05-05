import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

const _brand = Color(0xFF1670F5);
const _ink = Color(0xFF0F172A);
const _muted = Color(0xFF64748B);
const _line = Color(0xFFE2E8F0);

enum _NotifKind { order, payment, promo, system }

class _NotifItem {
  final String id;
  final _NotifKind kind;
  final String title;
  final String body;
  final DateTime at;
  bool read;
  _NotifItem({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    required this.at,
    this.read = false,
  });
}

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});
  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late final List<_NotifItem> _items;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _items = [
      _NotifItem(
        id: '1',
        kind: _NotifKind.order,
        title: 'Buyurtma qabul qilindi',
        body: "Toshkent → Samarqand yo'nalishi bo'yicha haydovchi tayinlandi.",
        at: now.subtract(const Duration(minutes: 8)),
      ),
      _NotifItem(
        id: '2',
        kind: _NotifKind.payment,
        title: "To'lov muvaffaqiyatli",
        body: "850 000 so'm balansingizga qo'shildi.",
        at: now.subtract(const Duration(hours: 2)),
      ),
      _NotifItem(
        id: '3',
        kind: _NotifKind.promo,
        title: '−20% chegirma',
        body: 'Birinchi yukingizga TRANS20 promokod.',
        at: now.subtract(const Duration(hours: 5)),
        read: true,
      ),
      _NotifItem(
        id: '4',
        kind: _NotifKind.system,
        title: 'Yangi versiya mavjud',
        body: 'Ilovani 1.2.0 versiyasiga yangilang.',
        at: now.subtract(const Duration(days: 1)),
        read: true,
      ),
      _NotifItem(
        id: '5',
        kind: _NotifKind.order,
        title: 'Yuk yetkazildi',
        body: 'Buyurtma #1247 muvaffaqiyatli yopildi.',
        at: now.subtract(const Duration(days: 2)),
        read: true,
      ),
    ];
  }

  void _markAllRead() {
    setState(() {
      for (final n in _items) n.read = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final unread = _items.where((n) => !n.read).length;
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: _line),
                        ),
                        child: const Icon(Iconsax.arrow_left_2,
                            size: 20, color: _ink),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Bildirishnomalar',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: _ink)),
                      ],
                    ),
                  ),
                  if (unread > 0)
                    Material(
                      color: _brand.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: _markAllRead,
                        borderRadius: BorderRadius.circular(12),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          child: Row(
                            children: [
                              Icon(Iconsax.tick_circle_copy,
                                  size: 14, color: _brand),
                              SizedBox(width: 6),
                              Text("Hammasini o'qildi",
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: _brand)),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: unread > 0 ? _brand : const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      unread > 0 ? '$unread ta yangi' : 'Yangi yo\u2018q',
                      style: TextStyle(
                          color: unread > 0 ? Colors.white : _muted,
                          fontSize: 11,
                          fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('Jami: ${_items.length}',
                      style: const TextStyle(
                          color: _muted,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: _items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final n = _items[i];
                  return _NotifTile(
                    item: n,
                    onTap: () => setState(() => n.read = true),
                  ).animate(delay: (i * 60).ms).fadeIn(duration: 250.ms).slideY(begin: 0.05);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  const _NotifTile({required this.item, required this.onTap});
  final _NotifItem item;
  final VoidCallback onTap;

  static const _kindMeta = {
    _NotifKind.order: (Iconsax.box_copy, _brand),
    _NotifKind.payment: (Iconsax.wallet_3_copy, Color(0xFF10B981)),
    _NotifKind.promo: (Iconsax.discount_shape_copy, Color(0xFFF97316)),
    _NotifKind.system: (Iconsax.info_circle_copy, Color(0xFF7C3AED)),
  };

  String _ago(DateTime at) {
    final d = DateTime.now().difference(at);
    if (d.inMinutes < 1) return 'hozirgina';
    if (d.inMinutes < 60) return '${d.inMinutes} daq oldin';
    if (d.inHours < 24) return '${d.inHours} soat oldin';
    if (d.inDays < 7) return '${d.inDays} kun oldin';
    return '${at.day}.${at.month.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final meta = _kindMeta[item.kind]!;
    final color = meta.$2;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _line),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2)),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(meta.$1, size: 20, color: color),
                  ),
                  if (!item.read)
                    Positioned(
                      top: -2, right: -2,
                      child: Container(
                        width: 11, height: 11,
                        decoration: BoxDecoration(
                          color: Colors.red.shade500,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: item.read
                                      ? FontWeight.w700
                                      : FontWeight.w900,
                                  color: _ink)),
                        ),
                        Text(_ago(item.at),
                            style: const TextStyle(
                                fontSize: 11,
                                color: _muted,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(item.body,
                        style: const TextStyle(
                            fontSize: 13,
                            color: _muted,
                            fontWeight: FontWeight.w500,
                            height: 1.4)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
