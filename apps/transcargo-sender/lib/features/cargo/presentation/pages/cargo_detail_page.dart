import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../domain/cargo_repository.dart';

const _brand = Color(0xFF1670F5);
const _ink = Color(0xFF0F172A);
const _muted = Color(0xFF64748B);
const _line = Color(0xFFE2E8F0);
const _surface = Color(0xFFF8FAFC);

class CargoDetailPage extends StatelessWidget {
  const CargoDetailPage({super.key, required this.item});
  final CargoRequestItem item;

  bool get _hasDriver {
    final s = item.status.toLowerCase();
    return s.contains('active') ||
        s.contains('progress') ||
        s.contains('jarayon') ||
        s.contains('accepted') ||
        s.contains('done') ||
        s.contains('complete') ||
        s.contains('yakun');
  }

  @override
  Widget build(BuildContext context) {
    final st = _StatusMeta.from(item.status);
    final parts = item.cargoType.split('|');
    final category = parts.isNotEmpty ? parts[0] : '';
    final vehicle = parts.length > 1 ? parts[1] : '';
    final routeStr = parts.length > 2 ? parts[2] : '';
    final unit = parts.length > 3 ? parts[3] : 'kg';

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(title: 'Buyurtma #${item.id.substring(0, 6).toUpperCase()}'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                children: [
                  _StatusBanner(meta: st, createdAt: item.createdAt)
                      .animate().fadeIn(duration: 250.ms).slideY(begin: 0.05),
                  const SizedBox(height: 14),
                  _TimelineCard(item: item, status: st.label)
                      .animate(delay: 60.ms)
                      .fadeIn(duration: 250.ms)
                      .slideY(begin: 0.06),
                  const SizedBox(height: 14),
                  if (_hasDriver) ...[
                    _DriverCard()
                        .animate(delay: 80.ms)
                        .fadeIn(duration: 250.ms)
                        .slideY(begin: 0.06),
                    const SizedBox(height: 14),
                  ],
                  _RouteCard(item: item, routeKind: routeStr)
                      .animate(delay: 140.ms)
                      .fadeIn(duration: 250.ms)
                      .slideY(begin: 0.06),
                  const SizedBox(height: 14),
                  _CargoCard(
                    category: category,
                    vehicle: vehicle,
                    weight: item.weightKg,
                    unit: unit,
                  )
                      .animate(delay: 200.ms)
                      .fadeIn(duration: 250.ms)
                      .slideY(begin: 0.06),
                  const SizedBox(height: 14),
                  _PriceCard(price: _estimatePrice(item))
                      .animate(delay: 260.ms)
                      .fadeIn(duration: 250.ms)
                      .slideY(begin: 0.06),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _hasDriver
          ? SafeArea(
              minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: _ActionBtn(
                      icon: Iconsax.call_copy,
                      label: 'Qo\'ng\'iroq',
                      filled: true,
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ActionBtn(
                      icon: Iconsax.message_copy,
                      label: 'Xabar',
                      filled: false,
                      onTap: () {},
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}

double _estimatePrice(CargoRequestItem i) =>
    150000 + (i.weightKg * 80) + (i.dropoffAddress.length * 1500);

// ─── Header ──────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  const _Header({required this.title});
  final String title;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              onTap: () =>
                  context.canPop() ? context.pop() : context.go('/history'),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _line),
                ),
                child: const Icon(Iconsax.arrow_left_2, size: 20, color: _ink),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w900, color: _ink)),
          ),
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _line),
                ),
                child: const Icon(Iconsax.more, size: 20, color: _ink),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Status banner ───────────────────────────────────────────────
class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.meta, required this.createdAt});
  final _StatusMeta meta;
  final DateTime createdAt;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: meta.color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: meta.color.withOpacity(0.30),
              blurRadius: 14,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(meta.icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(meta.label,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900)),
                const SizedBox(height: 2),
                Text(_fmt(createdAt),
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _fmt(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}.${two(d.month)}.${d.year} · ${two(d.hour)}:${two(d.minute)}';
  }
}

// ─── Driver card (mock) ──────────────────────────────────────────
class _DriverCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(icon: Iconsax.user_octagon_copy, text: 'Haydovchi'),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _brand, width: 2),
                ),
                child: ClipOval(
                  child: Image.network(
                    'https://i.pravatar.cc/200?img=14',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: _brand.withOpacity(0.12),
                      child: const Icon(Iconsax.user, color: _brand, size: 28),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Akmal Karimov',
                        style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w900,
                            color: _ink)),
                    const SizedBox(height: 4),
                    const Row(
                      children: [
                        Icon(Iconsax.star_1_copy,
                            size: 14, color: Color(0xFFF59E0B)),
                        SizedBox(width: 4),
                        Text('4.9',
                            style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: _ink)),
                        SizedBox(width: 6),
                        Text('· 327 reys',
                            style: TextStyle(
                                fontSize: 11.5,
                                color: _muted,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Iconsax.shield_tick_copy,
                                  size: 11, color: Color(0xFF10B981)),
                              SizedBox(width: 3),
                              Text('Tasdiqlangan',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: Color(0xFF10B981),
                                      fontWeight: FontWeight.w800)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Vehicle photo + plate
          Container(
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _line),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    'https://images.unsplash.com/photo-1601584115197-04ecc0da31d8?w=600',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: _brand.withOpacity(0.06),
                      child: const Center(
                          child: Icon(Iconsax.truck,
                              size: 50, color: _brand)),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: _brand.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child:
                            const Icon(Iconsax.truck, color: _brand, size: 18),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Isuzu Elf · Oq',
                                style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w800,
                                    color: _ink)),
                            SizedBox(height: 2),
                            Text('3 tonna · Yopiq kuzov',
                                style: TextStyle(
                                    fontSize: 11.5,
                                    color: _muted,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: _ink,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('01 A 123 BC',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                letterSpacing: 0.5,
                                fontWeight: FontWeight.w900)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Route card ──────────────────────────────────────────────────
class _RouteCard extends StatelessWidget {
  const _RouteCard({required this.item, required this.routeKind});
  final CargoRequestItem item;
  final String routeKind;
  @override
  Widget build(BuildContext context) {
    String kindLabel() {
      switch (routeKind) {
        case 'intracity':
          return 'Shahar ichi';
        case 'international':
          return 'Xalqaro';
        case 'intercity':
        default:
          return 'Shaharlararo';
      }
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _SectionTitle(
                  icon: Iconsax.routing_2_copy, text: 'Yo\'nalish'),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _brand.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(kindLabel(),
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: _brand)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _RoutePoint(
            color: const Color(0xFF10B981),
            label: 'Olib ketish',
            value: item.pickupAddress,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 9),
            child: Container(width: 2, height: 24, color: _line),
          ),
          _RoutePoint(
            color: const Color(0xFFEF4444),
            label: 'Yetkazib berish',
            value: item.dropoffAddress,
          ),
        ],
      ),
    );
  }
}

class _RoutePoint extends StatelessWidget {
  const _RoutePoint(
      {required this.color, required this.label, required this.value});
  final Color color;
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 4),
          width: 20, height: 20,
          decoration: BoxDecoration(
            color: color.withOpacity(0.18),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Container(
              width: 8, height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 11,
                      color: _muted,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: _ink)),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Cargo card ──────────────────────────────────────────────────
class _CargoCard extends StatelessWidget {
  const _CargoCard(
      {required this.category,
      required this.vehicle,
      required this.weight,
      required this.unit});
  final String category;
  final String vehicle;
  final double weight;
  final String unit;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(icon: Iconsax.box_copy, text: 'Yuk ma\'lumotlari'),
          const SizedBox(height: 12),
          _InfoRow(
              icon: Iconsax.tag_copy,
              label: 'Toifa',
              value: category.isEmpty ? 'Umumiy' : _prettify(category)),
          _InfoRow(
              icon: Iconsax.weight_copy,
              label: 'Miqdori',
              value: '${weight.toStringAsFixed(0)} $unit'),
          _InfoRow(
              icon: Iconsax.truck_copy,
              label: 'Transport',
              value: vehicle.isEmpty ? '—' : vehicle),
        ],
      ),
    );
  }

  static String _prettify(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(
      {required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Icon(icon, size: 16, color: _muted),
          const SizedBox(width: 10),
          Text(label,
              style: const TextStyle(
                  fontSize: 12.5,
                  color: _muted,
                  fontWeight: FontWeight.w600)),
          const Spacer(),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.end,
                style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: _ink)),
          ),
        ],
      ),
    );
  }
}

// ─── Price card ──────────────────────────────────────────────────
class _PriceCard extends StatelessWidget {
  const _PriceCard({required this.price});
  final double price;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _ink,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Iconsax.wallet_2_copy,
                color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("To'lov summasi",
                    style: TextStyle(
                        fontSize: 11.5,
                        color: Colors.white.withOpacity(0.65),
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text('${_fmtMoney(price)} so\'m',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900)),
              ],
            ),
          ),
          const Icon(Iconsax.tick_circle_copy,
              color: Color(0xFF10B981), size: 22),
        ],
      ),
    );
  }
}

String _fmtMoney(double v) {
  final s = v.round().toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
    buf.write(s[i]);
  }
  return buf.toString();
}

// ─── Section title ───────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: _brand.withOpacity(0.10),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 15, color: _brand),
        ),
        const SizedBox(width: 8),
        Text(text,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w900, color: _ink)),
      ],
    );
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn(
      {required this.icon,
      required this.label,
      required this.filled,
      required this.onTap});
  final IconData icon;
  final String label;
  final bool filled;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? _brand : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: filled ? _brand : _line),
            boxShadow: filled
                ? [
                    BoxShadow(
                      color: _brand.withOpacity(0.30),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 18, color: filled ? Colors.white : _ink),
              const SizedBox(width: 8),
              Text(label,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: filled ? Colors.white : _ink)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Status meta ─────────────────────────────────────────────────
class _StatusMeta {
  const _StatusMeta(this.label, this.color, this.icon);
  final String label;
  final Color color;
  final IconData icon;
  factory _StatusMeta.from(String s) {
    final l = s.toLowerCase();
    if (l.contains('pending') || l.contains('kutil')) {
      return const _StatusMeta(
          'Kutilmoqda', Color(0xFFF59E0B), Iconsax.clock_copy);
    }
    if (l.contains('active') ||
        l.contains('progress') ||
        l.contains('jarayon') ||
        l.contains('accepted')) {
      return const _StatusMeta('Jarayonda', _brand, Iconsax.truck_fast_copy);
    }
    if (l.contains('done') ||
        l.contains('complete') ||
        l.contains('yakun') ||
        l.contains('tugadi')) {
      return const _StatusMeta(
          'Yakunlangan', Color(0xFF10B981), Iconsax.tick_circle_copy);
    }
    if (l.contains('cancel') || l.contains('bekor')) {
      return const _StatusMeta(
          'Bekor qilingan', Color(0xFFEF4444), Iconsax.close_circle_copy);
    }
    return _StatusMeta(s, _muted, Iconsax.info_circle_copy);
  }
}


// --- Timeline card -----------------------------------------------
class _TimelineCard extends StatelessWidget {
  const _TimelineCard({required this.item, required this.status});
  final CargoRequestItem item;
  final String status;

  @override
  Widget build(BuildContext context) {
    final s = status.toLowerCase();
    // Derive timeline events from createdAt + status.
    final created = item.createdAt;
    final accepted = s.contains('jarayon') || s.contains('yakun') || s.contains('faol')
        ? created.add(const Duration(minutes: 12))
        : null;
    final loaded = s.contains('yakun') || s.contains('faol')
        ? created.add(const Duration(hours: 1, minutes: 30))
        : null;
    final delivered = s.contains('yakun')
        ? created.add(const Duration(hours: 6, minutes: 45))
        : null;

    final events = <_Ev>[
      _Ev('Buyurtma yaratildi', created, true, Iconsax.add_circle_copy, _brand),
      _Ev('Haydovchi qabul qildi', accepted, accepted != null, Iconsax.user_tick_copy, _brand),
      _Ev('Yuk ortildi', loaded, loaded != null, Iconsax.box_tick_copy, const Color(0xFFF59E0B)),
      _Ev('Yetkazib berildi', delivered, delivered != null, Iconsax.tick_circle_copy, const Color(0xFF10B981)),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _line),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(color: _brand.withOpacity(0.10), borderRadius: BorderRadius.circular(9)),
                child: const Icon(Iconsax.clock_copy, size: 16, color: _brand),
              ),
              const SizedBox(width: 10),
              const Text('Buyurtma jarayoni',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: _ink)),
            ],
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < events.length; i++)
            _TimelineRow(ev: events[i], isLast: i == events.length - 1),
        ],
      ),
    );
  }
}

class _Ev {
  final String label;
  final DateTime? at;
  final bool done;
  final IconData icon;
  final Color color;
  const _Ev(this.label, this.at, this.done, this.icon, this.color);
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.ev, required this.isLast});
  final _Ev ev;
  final bool isLast;

  String _fmt(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}.${two(d.month)} � ${two(d.hour)}:${two(d.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final dim = !ev.done;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  color: dim ? const Color(0xFFF1F5F9) : ev.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: dim ? _line : ev.color.withOpacity(0.4)),
                ),
                child: Icon(ev.icon, size: 14, color: dim ? _muted : ev.color),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: dim ? const Color(0xFFE2E8F0) : ev.color.withOpacity(0.35),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ev.label,
                    style: TextStyle(
                      fontSize: 13.5,
                      color: dim ? _muted : _ink,
                      fontWeight: FontWeight.w800,
                    )),
                  const SizedBox(height: 2),
                  Text(
                    ev.at == null ? 'Kutilmoqda�' : _fmt(ev.at!),
                    style: TextStyle(
                      fontSize: 12,
                      color: dim ? const Color(0xFFCBD5E1) : _muted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}