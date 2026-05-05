import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/di/injection.dart';
import '../bloc/cargo_bloc.dart';

class CargoHistoryPage extends StatelessWidget {
  const CargoHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CargoBloc>()..add(const CargoLoadMine()),
      child: BlocBuilder<CargoBloc, CargoState>(
          builder: (context, state) {
            if (state is CargoLoading || state is CargoInitial) {
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: 5,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, __) => Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(height: 80, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
                ),
              );
            }
            if (state is CargoFailure) return Center(child: Text(state.message));
            final items = (state as CargoLoaded).items;
            if (items.isEmpty) return const Center(child: Text('So‘rov yo‘q'));
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final r = items[i];
                return Card(
                  child: ListTile(
                    title: Text('${r.pickupAddress} → ${r.dropoffAddress}'),
                    subtitle: Text('${r.cargoType} · ${r.weightKg.toStringAsFixed(0)} kg'),
                    trailing: Chip(label: Text(r.status)),
                  ),
                );
              },
            );
          },
        ),
    );
  }
}
