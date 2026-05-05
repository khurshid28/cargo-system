import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/di/injection.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../data/jobs_remote_data_source.dart';

class DriverHomePage extends StatefulWidget {
  const DriverHomePage({super.key});
  @override
  State<DriverHomePage> createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {
  bool _online = true;
  late Future<List<JobItem>> _availableF;
  late Future<List<JobItem>> _activeF;

  final _money = NumberFormat.currency(locale: 'uz', symbol: 'so‘m', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _availableF = sl<JobsRemoteDataSource>().available();
      _activeF = sl<JobsRemoteDataSource>().active();
    });
  }

  Future<void> _accept(JobItem j) async {
    await sl<JobsRemoteDataSource>().accept(j.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Qabul qilindi: ${j.pickupAddress} → ${j.dropoffAddress}')),
    );
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final user = (context.read<AuthBloc>().state as AuthAuthenticated?)?.user;
    final scheme = Theme.of(context).colorScheme;
    return RefreshIndicator(
      onRefresh: () async => _refresh(),
      child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Driver card + online toggle
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: scheme.primaryContainer,
                      child: Icon(Iconsax.user_copy, color: scheme.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user?.phone ?? '—', style: const TextStyle(fontWeight: FontWeight.w600)),
                          Text(_online ? 'Onlayn — buyurtma qabul qiladi' : 'Oflayn',
                              style: TextStyle(fontSize: 12, color: _online ? Colors.green : Colors.black54)),
                        ],
                      ),
                    ),
                    Switch(
                      value: _online,
                      onChanged: (v) => setState(() => _online = v),
                      activeColor: scheme.primary,
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 300.ms),
            const SizedBox(height: 20),

            const _SectionTitle(title: 'Mening yuklarim', icon: Iconsax.truck_copy),
            FutureBuilder<List<JobItem>>(
              future: _activeF,
              builder: (_, snap) {
                if (!snap.hasData) return _shimmerCard();
                final list = snap.data!;
                if (list.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Faol yuk yo‘q', style: TextStyle(color: Colors.black54)),
                  );
                }
                return Column(
                  children: list.map((j) => _ActiveJobCard(job: j, money: _money, onUpdate: _refresh)).toList(),
                );
              },
            ),
            const SizedBox(height: 20),

            const _SectionTitle(title: 'Mavjud yuklar', icon: Iconsax.box_search_copy),
            if (!_online)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Oflaynsiz buyurtma kelmaydi', style: TextStyle(color: Colors.black54)),
              )
            else
              FutureBuilder<List<JobItem>>(
                future: _availableF,
                builder: (_, snap) {
                  if (!snap.hasData) {
                    return Column(children: [for (int i = 0; i < 2; i++) _shimmerCard()]);
                  }
                  final list = snap.data!;
                  if (list.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Hozircha mavjud buyurtma yo‘q', style: TextStyle(color: Colors.black54)),
                    );
                  }
                  return Column(
                    children: list
                        .map((j) => _AvailableJobCard(job: j, money: _money, onAccept: () => _accept(j))
                            .animate().fadeIn().slideY(begin: 0.1))
                        .toList(),
                  );
                },
              ),
          ],
        ),
    );
  }

  Widget _shimmerCard() => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            height: 110,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
          ),
        ),
      );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.icon});
  final String title;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 8),
      child: Row(children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
      ]),
    );
  }
}

class _AvailableJobCard extends StatelessWidget {
  const _AvailableJobCard({required this.job, required this.money, required this.onAccept});
  final JobItem job;
  final NumberFormat money;
  final VoidCallback onAccept;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Iconsax.location_copy, size: 16, color: Colors.green),
                const SizedBox(width: 6),
                Expanded(child: Text(job.pickupAddress, style: const TextStyle(fontWeight: FontWeight.w600))),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Iconsax.location_tick_copy, size: 16, color: Colors.red),
                const SizedBox(width: 6),
                Expanded(child: Text(job.dropoffAddress, style: const TextStyle(fontWeight: FontWeight.w600))),
              ],
            ),
            const Divider(height: 18),
            Wrap(spacing: 8, runSpacing: 4, children: [
              _Chip(icon: Iconsax.box_copy, label: '${job.weightKg.toStringAsFixed(0)} kg'),
              _Chip(icon: Iconsax.routing_copy, label: '${job.distanceKm.toStringAsFixed(0)} km'),
              _Chip(icon: Iconsax.tag_copy, label: job.cargoType),
            ]),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(money.format(job.priceUzs),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                ElevatedButton.icon(
                  onPressed: onAccept,
                  icon: const Icon(Iconsax.tick_circle, size: 18),
                  label: const Text('Qabul'),
                  style: ElevatedButton.styleFrom(minimumSize: const Size(110, 40)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveJobCard extends StatelessWidget {
  const _ActiveJobCard({required this.job, required this.money, required this.onUpdate});
  final JobItem job;
  final NumberFormat money;
  final VoidCallback onUpdate;

  Future<void> _next(BuildContext context) async {
    final next = switch (job.status) {
      'ASSIGNED' => 'PICKED_UP',
      'PICKED_UP' => 'IN_TRANSIT',
      'IN_TRANSIT' => 'DELIVERED',
      _ => null,
    };
    if (next == null) return;
    await sl<JobsRemoteDataSource>().updateStatus(job.id, next);
    onUpdate();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Chip(label: Text(job.status), backgroundColor: Colors.white),
              const Spacer(),
              Text(money.format(job.priceUzs), style: const TextStyle(fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 8),
            Text('${job.pickupAddress} → ${job.dropoffAddress}'),
            const SizedBox(height: 8),
            if (job.status != 'DELIVERED')
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _next(context),
                  icon: const Icon(Iconsax.arrow_right_3),
                  label: Text(_nextLabel(job.status)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _nextLabel(String s) => switch (s) {
        'ASSIGNED' => 'Yukni oldim',
        'PICKED_UP' => 'Yo‘ldaman',
        'IN_TRANSIT' => 'Yetkazib berdim',
        _ => 'Tayyor',
      };
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label});
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ]),
    );
  }
}
