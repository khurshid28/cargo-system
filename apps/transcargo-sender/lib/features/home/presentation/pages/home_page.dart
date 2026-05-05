import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../core/store/profile_store.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../notifications/presentation/notifications_page.dart';

const _brand = Color(0xFF1670F5);
const _purple = Color(0xFF7C3AED);

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 140),
          children: [
            const _GreetingHeader(),
            const SizedBox(height: 16),
            const _PromoCarousel(),
            const SizedBox(height: 20),
            const _SectionTitle(title: 'Tezkor amallar', icon: Iconsax.flash_1_copy),
            const SizedBox(height: 12),
            const _QuickActions(),
            const SizedBox(height: 24),
            const _SectionTitle(title: 'Bildirishnomalar', icon: Iconsax.notification_copy),
            const SizedBox(height: 12),
            const _NotificationsList(),
            const SizedBox(height: 24),
            const _SectionTitle(title: 'Statistika', icon: Iconsax.chart_2_copy),
            const SizedBox(height: 12),
            const _StatsRow(),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: Container(
          decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: _brand.withOpacity(0.40),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: _brand,
          borderRadius: BorderRadius.circular(20),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => context.go('/create'),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 30, height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Iconsax.box_add_copy,
                        color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 10),
                  const Text('Yuk yuborish',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 14.5,
                          letterSpacing: 0.2)),
                ],
              ),
            ),
          ),
        ),
      ).animate().scale(delay: 400.ms, curve: Curves.easeOutBack),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────
// Greeting header with avatar + bell
// ──────────────────────────────────────────────────────────────────
class _GreetingHeader extends StatelessWidget {
  const _GreetingHeader();

  String _formatPhone(String raw) {
    var d = raw.replaceAll(RegExp(r'\D'), '');
    if (d.startsWith('998')) d = d.substring(3);
    if (d.length > 9) d = d.substring(0, 9);
    if (d.isEmpty) return '';
    final b = StringBuffer('+998');
    if (d.isNotEmpty) b.write(' ${d.substring(0, d.length.clamp(0, 2))}');
    if (d.length > 2) b.write(' ${d.substring(2, d.length.clamp(2, 5))}');
    if (d.length > 5) b.write(' ${d.substring(5, d.length.clamp(5, 7))}');
    if (d.length > 7) b.write(' ${d.substring(7, d.length.clamp(7, 9))}');
    return b.toString();
  }

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Xayrli tong'
        : hour < 18
            ? 'Xayrli kun'
            : 'Xayrli kech';
    final user = (context.watch<AuthBloc>().state is AuthAuthenticated)
        ? (context.watch<AuthBloc>().state as AuthAuthenticated).user
        : null;
    return ValueListenableBuilder<String>(
      valueListenable: ProfileStore.instance.fullName,
      builder: (_, fullName, __) {
        return ValueListenableBuilder<String>(
          valueListenable: ProfileStore.instance.phone,
          builder: (_, storedPhone, __) {
            final name = fullName.isEmpty ? 'Yuk yuboruvchi' : fullName;
            final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
            final phoneRaw = (user?.phone.isNotEmpty == true) ? user!.phone : storedPhone;
            final phone = _formatPhone(phoneRaw);
            return Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(colors: [_brand, _purple]),
                boxShadow: [
                  BoxShadow(color: _brand.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4)),
                ],
              ),
              alignment: Alignment.center,
              child: Text(initial,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(greeting,
                          style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(width: 6),
                      const Text('👋', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 16,
                          fontWeight: FontWeight.w800)),
                  if (phone.isNotEmpty)
                    Text(phone,
                        style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                onTap: () => Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(builder: (_) => const NotificationsPage()),
                ),
                borderRadius: BorderRadius.circular(14),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 2)),
                        ],
                      ),
                      child: const Icon(Iconsax.notification_copy,
                          color: Color(0xFF334155), size: 22),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color: Colors.red.shade500,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 200.ms),
          ],
        );
          },
        );
      },
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1);
  }
}

// ──────────────────────────────────────────────────────────────────
// Promo carousel (banner cards)
// ──────────────────────────────────────────────────────────────────
class _PromoCarousel extends StatefulWidget {
  const _PromoCarousel();
  @override
  State<_PromoCarousel> createState() => _PromoCarouselState();
}

class _PromoCarouselState extends State<_PromoCarousel> {
  final _ctrl = PageController(viewportFraction: 0.92);
  int _page = 0;

  static const _banners = [
    _Banner(
      title: 'Birinchi yukingizga\n−20% chegirma',
      subtitle: 'Promokod: TRANS20',
      icon: Iconsax.discount_shape_copy,
      colors: [_brand, _purple],
    ),
    _Banner(
      title: 'Tezkor topish',
      subtitle: '5 daqiqada haydovchi tanlanadi',
      icon: Iconsax.flash_circle_copy,
      colors: [Color(0xFFF97316), Color(0xFFEA580C)],
    ),
    _Banner(
      title: 'Xavfsiz to\u2018lov',
      subtitle: 'Click · Payme · Uzum orqali',
      icon: Iconsax.shield_tick_copy,
      colors: [Color(0xFF10B981), Color(0xFF047857)],
    ),
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 140,
          child: PageView.builder(
            controller: _ctrl,
            itemCount: _banners.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (_, i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: _banners[i],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_banners.length, (i) {
            final active = i == _page;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 22 : 7,
              height: 7,
              decoration: BoxDecoration(
                color: active ? _brand : const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    ).animate().fadeIn(delay: 100.ms, duration: 500.ms);
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.title, required this.subtitle, required this.icon, required this.colors});
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> colors;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
        boxShadow: [
          BoxShadow(color: colors.first.withOpacity(0.35), blurRadius: 18, offset: const Offset(0, 8)),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.12), shape: BoxShape.circle),
            ),
          ),
          Positioned(
            right: 20,
            bottom: -30,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.10), shape: BoxShape.circle),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800, height: 1.2)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.22),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(subtitle,
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.22),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(icon, color: Colors.white, size: 30),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────
// Quick action grid
// ──────────────────────────────────────────────────────────────────
class _QuickActions extends StatelessWidget {
  const _QuickActions();
  @override
  Widget build(BuildContext context) {
    final actions = [
      _Action(Iconsax.add_square_copy, 'Yangi yuk', _brand, () => context.go('/create')),
      _Action(Iconsax.clock_copy, 'Tarix', const Color(0xFF7C3AED), () => context.go('/history')),
      _Action(Iconsax.location_copy, 'Kuzatish', const Color(0xFF10B981), () {}),
      _Action(Iconsax.message_question_copy, 'Yordam', const Color(0xFFF59E0B), () {}),
    ];
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      children: [
        for (var i = 0; i < actions.length; i++)
          actions[i].build(context).animate(delay: (i * 80).ms).fadeIn(duration: 350.ms).slideY(begin: 0.2),
      ],
    );
  }
}

class _Action {
  _Action(this.icon, this.label, this.color, this.onTap);
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(label,
                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────
// Notification list
// ──────────────────────────────────────────────────────────────────
class _NotificationsList extends StatelessWidget {
  const _NotificationsList();
  @override
  Widget build(BuildContext context) {
    final items = [
      _Notif(
        icon: Iconsax.truck_copy,
        title: 'Haydovchi topildi',
        msg: 'Akmal A. · Damas · 2 km masofada',
        time: '2 daq oldin',
        color: const Color(0xFF10B981),
      ),
      _Notif(
        icon: Iconsax.dollar_circle_copy,
        title: 'To\u2018lov qabul qilindi',
        msg: 'Buyurtma #A-1287 — 75 000 so\u2018m',
        time: '1 soat oldin',
        color: const Color(0xFF7C3AED),
      ),
      _Notif(
        icon: Iconsax.gift_copy,
        title: 'Yangi promokod',
        msg: 'Keyingi yukingizga −15% — MAY15',
        time: 'Bugun',
        color: const Color(0xFFF59E0B),
      ),
    ];
    return Column(
      children: [
        for (var i = 0; i < items.length; i++)
          items[i].build().animate(delay: (i * 100).ms).fadeIn(duration: 350.ms).slideX(begin: 0.08),
      ],
    );
  }
}

class _Notif {
  _Notif({required this.icon, required this.title, required this.msg, required this.time, required this.color});
  final IconData icon;
  final String title;
  final String msg;
  final String time;
  final Color color;
  Widget build() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(title,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                    ),
                    Text(time, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                  ],
                ),
                const SizedBox(height: 2),
                Text(msg,
                    style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B), height: 1.35)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────
// Stats row
// ──────────────────────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  const _StatsRow();
  @override
  Widget build(BuildContext context) {
    const stats = [
      _Stat('Faol', '2', Iconsax.truck_fast_copy, _brand),
      _Stat('Tugagan', '17', Iconsax.tick_circle_copy, Color(0xFF10B981)),
      _Stat('Ball', '4.9', Iconsax.star_1_copy, Color(0xFFF59E0B)),
    ];
    return Row(
      children: [
        for (var i = 0; i < stats.length; i++) ...[
          Expanded(child: stats[i].build().animate(delay: (i * 80).ms).fadeIn().scale(begin: const Offset(0.9, 0.9))),
          if (i < stats.length - 1) const SizedBox(width: 10),
        ],
      ],
    );
  }
}

class _Stat {
  const _Stat(this.label, this.value, this.icon, this.color);
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  Widget build() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(11)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 10),
          Text(value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────
// Section title helper
// ──────────────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.icon});
  final String title;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF334155)),
        const SizedBox(width: 8),
        Text(title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
        const Spacer(),
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
              minimumSize: const Size(0, 28),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap),
          child: const Text('Barchasi', style: TextStyle(fontSize: 12.5, color: _brand, fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}

