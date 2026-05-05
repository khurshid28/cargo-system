import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../domain/cargo_repository.dart';
import '../bloc/cargo_bloc.dart';

class CargoCreatePage extends StatefulWidget {
  const CargoCreatePage({super.key});
  @override
  State<CargoCreatePage> createState() => _CargoCreatePageState();
}

class _CargoCreatePageState extends State<CargoCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _pickupCtrl = TextEditingController(text: 'Toshkent, Chilonzor');
  final _dropoffCtrl = TextEditingController(text: 'Samarqand, Registon');
  final _typeCtrl = TextEditingController(text: 'general');
  final _weightCtrl = TextEditingController(text: '1000');
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yangi so‘rov')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _pickupCtrl,
                decoration: const InputDecoration(labelText: 'Olib ketish manzili'),
                validator: (v) => (v == null || v.isEmpty) ? 'Majburiy' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _dropoffCtrl,
                decoration: const InputDecoration(labelText: 'Yetkazib berish manzili'),
                validator: (v) => (v == null || v.isEmpty) ? 'Majburiy' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _typeCtrl,
                decoration: const InputDecoration(labelText: 'Yuk turi'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _weightCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Og‘irlik (kg)'),
                validator: (v) =>
                    (double.tryParse(v ?? '') ?? 0) <= 0 ? 'Noto‘g‘ri og‘irlik' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Yuborish'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    try {
      // Tashkent default coords for now (geocoding/map picker — keyingi qadamda).
      await sl<CargoRepository>().create(
        pickupAddress: _pickupCtrl.text.trim(),
        pickupLat: 41.3111,
        pickupLng: 69.2797,
        dropoffAddress: _dropoffCtrl.text.trim(),
        dropoffLat: 39.6542,
        dropoffLng: 66.9597,
        cargoType: _typeCtrl.text.trim(),
        weightKg: double.parse(_weightCtrl.text.trim()),
      );
      if (!mounted) return;
      // Refresh history bloc if present.
      try {
        context.read<CargoBloc>().add(const CargoLoadMine());
      } catch (_) {}
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('So‘rov yuborildi')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
