import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/di/injection.dart';
import '../../domain/cargo_repository.dart';
import '../bloc/cargo_bloc.dart';
import 'cargo_detail_page.dart';

const _brand = Color(0xFF1670F5);
const _ink = Color(0xFF0F172A);
const _muted = Color(0xFF64748B);
const _line = Color(0xFFE2E8F0);

enum _Filter { all, pending, active, done, cancelled }

class CargoHistoryPage extends StatelessWidget {
  const CargoHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CargoBloc>()..add(const CargoLoadMine()),
      child: const _HistoryView(),
    );
  }
}

class _HistoryView extends StatefulWidget {
  const _HistoryView();
  @override
  State<_HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<_HistoryView> {
  _Filter _filter = _Filter.all;

  bool _matches(CargoRequestItem r) {
    final s = r.status.toLowerCase();
    switch (_filter) {
      case _Filter.all:
        return true;
      case _Filter.pending:
        return s.contains('pending') || s.contains('kutil');
      case _Filter.active:
        return s.contains('active') ||
            s.contains('progress') ||
            s.contains('jarayon') ||
            s.contains('accepted');
      case _Filter.done:
        return s.contains('done') ||
            s.contains('complete') ||
            s.contains('yakun') ||
            s.contains('tugadi');
      case _Filter.cancelled:
        return s.contains('cancel') || s.contains('bekor');
    }
  }

  Future<void> _refresh(BuildContext context) async {
    context.read<CargoBloc>().add(const CargoLoadMine());
    await Future<void>.delayed(const Duration(milliseconds: 600));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(onRefresh: () => _refresh(context)),
            _Filters(
              value: _filter,
              onChanged: (v) => setState(() => _filter = v),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: BlocBuilder<CargoBloc, CargoState>(
                builder: (context, state) {
                  if (state is CargoLoading || state is CargoInitial) {
                    return const _SkeletonList();
                  }
                  if (state is CargoFailure) {
                    return _ErrorView(
                      message: state.message,
                      onRetry: () =>
                          context.read<CargoBloc>().add(const CargoLoadMine()),
                    );
                  }
                  final all = (state as CargoLoaded).items;
                  final items = all.where(_matches).toList()
                    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
                  if (items.isEmpty) return const _EmptyView();
                  final groups = _groupByDate(items);
                  return RefreshIndicator(
                    color: _brand,
                    onRefresh: () => _refresh(context),
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                      itemCount: groups.length,
                      itemBuilder: (_, i) {
                        final g = groups[i];
                        return Padding(
                          padding: EdgeInsets.only(top: i == 0 ? 0 : 18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _GroupHeader(label: g.label, count: g.items.length),
                              const SizedBox(height: 10),
                              ...g.items.asMap().entries.map(
                                    (e) => Padding(
                                      padding: const EdgeInsets.only(bottom: 10),
                                      child: _RequestCard(item: e.value)
                                          .animate(delay: (e.key * 40).ms)
                                          .fadeIn(duration: 250.ms)
                                          .slideY(begin: 0.05),
                                    ),
                                  ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Date grouping ───────────────────────────────────────────────
class _Group {
  _Group(this.label, this.items);
  final String label;
  final List<CargoRequestItem> items;
}

List<_Group> _groupByDate(List<CargoRequestItem> items) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));

  String labelFor(DateTime d) {
    final day = DateTime(d.year, d.month, d.day);
    if (day == today) return 'Bugun';
    if (day == yesterday) return 'Kecha';
    final diff = today.difference(day).inDays;
    if (diff > 1 && diff < 7) {
      const wd = ['Du', 'Se', 'Cho', 'Pa', 'Ju', 'Sh', 'Ya'];
      return '${wd[d.weekday - 1]}, ${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}';
    }
    return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
  }

  final map = <String, List<CargoRequestItem>>{};
  for (final i in items) {
    map.putIfAbsent(labelFor(i.createdAt), () => []).add(i);
  }
  return map.entries.map((e) => _Group(e.key, e.value)).toList();
}

// ─── Header ──────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  const _Header({required this.onRefresh});
  final Future<void> Function() onRefresh;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          if (context.canPop()) ...[
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                onTap: () => context.pop(),
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
          ],
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tarix',
                    style: TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w900, color: _ink)),
                SizedBox(height: 2),
                Text("Sizning yuborgan so'rovlaringiz",
                    style: TextStyle(
                        fontSize: 12,
                        color: _muted,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              onTap: onRefresh,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _line),
                ),
                child: const Icon(Iconsax.refresh_copy, size: 20, color: _ink),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Filters ─────────────────────────────────────────────────────
class _Filters extends StatelessWidget {
  const _Filters({required this.value, required this.onChanged});
  final _Filter value;
  final ValueChanged<_Filter> onChanged;

  @override
  Widget build(BuildContext context) {
    const items = [
      (_Filter.all, 'Hammasi', Iconsax.element_3_copy),
      (_Filter.pending, 'Kutilmoqda', Iconsax.clock_copy),
      (_Filter.active, 'Jarayonda', Iconsax.truck_fast_copy),
      (_Filter.done, 'Yakunlangan', Iconsax.tick_circle_copy),
      (_Filter.cancelled, 'Bekor', Iconsax.close_circle_copy),
    ];
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final (f, label, icon) = items[i];
          final active = f == value;
          return GestureDetector(
            onTap: () => onChanged(f),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: active ? _brand : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: active ? _brand : _line),
                boxShadow: active
                    ? [
                        BoxShadow(
                          color: _brand.withOpacity(0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Icon(icon, size: 14, color: active ? Colors.white : _muted),
                  const SizedBox(width: 6),
                  Text(label,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: active ? Colors.white : _ink,
                      )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Group header ────────────────────────────────────────────────
class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.label, required this.count});
  final String label;
  final int count;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 18,
          decoration: BoxDecoration(
            color: _brand,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Text(label,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w900, color: _ink)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: _brand.withOpacity(0.10),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text('$count',
              style: const TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w800, color: _brand)),
        ),
      ],
    );
  }
}

// ─── Request card ────────────────────────────────────────────────
class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.item});
  final CargoRequestItem item;
  @override
  Widget build(BuildContext context) {
    final st = _StatusMeta.from(item.status);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => CargoDetailPage(item: item)),
        ),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _brand.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Iconsax.box_copy, color: _brand, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.cargoType.split('|').first,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w800, color: _ink),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${item.weightKg.toStringAsFixed(0)} kg · ${_fmtTime(item.createdAt)}',
                          style: const TextStyle(fontSize: 11.5, color: _muted),
                        ),
                      ],
                    ),
                  ),
                  _StatusChip(meta: st),
                ],
              ),
              const SizedBox(height: 12),
              Container(height: 1, color: _line),
              const SizedBox(height: 10),
              _Route(
                  iconColor: const Color(0xFF10B981),
                  label: item.pickupAddress,
                  icon: Iconsax.location_copy),
              const SizedBox(height: 4),
              _Route(
                  iconColor: const Color(0xFFEF4444),
                  label: item.dropoffAddress,
                  icon: Iconsax.location_tick_copy),
            ],
          ),
        ),
      ),
    );
  }
}

class _Route extends StatelessWidget {
  const _Route({required this.iconColor, required this.label, required this.icon});
  final Color iconColor;
  final String label;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
                fontSize: 12.5, color: _ink, fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.meta});
  final _StatusMeta meta;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: meta.color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6, height: 6,
            decoration: BoxDecoration(color: meta.color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(meta.label,
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w800, color: meta.color)),
        ],
      ),
    );
  }
}

class _StatusMeta {
  const _StatusMeta(this.label, this.color);
  final String label;
  final Color color;
  factory _StatusMeta.from(String s) {
    final l = s.toLowerCase();
    if (l.contains('pending') || l.contains('kutil')) {
      return const _StatusMeta('Kutilmoqda', Color(0xFFF59E0B));
    }
    if (l.contains('active') ||
        l.contains('progress') ||
        l.contains('jarayon') ||
        l.contains('accepted')) {
      return const _StatusMeta('Jarayonda', _brand);
    }
    if (l.contains('done') ||
        l.contains('complete') ||
        l.contains('yakun') ||
        l.contains('tugadi')) {
      return const _StatusMeta('Yakunlangan', Color(0xFF10B981));
    }
    if (l.contains('cancel') || l.contains('bekor')) {
      return const _StatusMeta('Bekor', Color(0xFFEF4444));
    }
    return _StatusMeta(s, _muted);
  }
}

String _fmtTime(DateTime d) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(d.hour)}:${two(d.minute)}';
}

// ─── Skeletons / empty / error ───────────────────────────────────
class _SkeletonList extends StatelessWidget {
  const _SkeletonList();
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: const Color(0xFFE2E8F0),
        highlightColor: const Color(0xFFF1F5F9),
        child: Container(
          height: 120,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(18)),
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: _brand.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Iconsax.box_search_copy, size: 44, color: _brand),
            ),
            const SizedBox(height: 18),
            const Text('So\'rov topilmadi',
                style: TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w900, color: _ink)),
            const SizedBox(height: 6),
            const Text(
              "Tanlangan filter bo'yicha buyurtma yo'q.\nYangi yuk yuborib ko'ring.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: _muted, height: 1.5),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: () => context.go('/create'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _brand,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Iconsax.add, size: 18),
              label: const Text('Yangi yuk',
                  style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(Iconsax.warning_2_copy,
                  color: Color(0xFFEF4444), size: 40),
            ),
            const SizedBox(height: 16),
            const Text('Xatolik yuz berdi',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w900, color: _ink)),
            const SizedBox(height: 6),
            Text(message,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: _muted)),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Iconsax.refresh_copy, size: 16, color: _brand),
              label: const Text('Qayta urinish',
                  style: TextStyle(color: _brand, fontWeight: FontWeight.w800)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: _brand),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
