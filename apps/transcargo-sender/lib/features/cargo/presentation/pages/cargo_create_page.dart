import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/ui/app_toast.dart';
import '../../domain/cargo_repository.dart';
import '../bloc/cargo_bloc.dart';

const _brand = Color(0xFF1670F5);
const _ink = Color(0xFF0F172A);
const _muted = Color(0xFF64748B);
const _line = Color(0xFFE2E8F0);
const _surface = Color(0xFFF8FAFC);

enum _Route { intracity, intercity, international }

enum _Unit { kg, m3, piece }

extension _UnitExt on _Unit {
  String get label {
    switch (this) {
      case _Unit.kg:
        return 'kg';
      case _Unit.m3:
        return 'm³';
      case _Unit.piece:
        return 'dona';
    }
  }

  String get full {
    switch (this) {
      case _Unit.kg:
        return 'Kilogramm';
      case _Unit.m3:
        return 'Metr kub';
      case _Unit.piece:
        return 'Dona';
    }
  }

  IconData get icon {
    switch (this) {
      case _Unit.kg:
        return Iconsax.weight_copy;
      case _Unit.m3:
        return Iconsax.box_1_copy;
      case _Unit.piece:
        return Iconsax.box_copy;
    }
  }

  String get hint {
    switch (this) {
      case _Unit.kg:
        return 'Masalan: 1500';
      case _Unit.m3:
        return 'Masalan: 12';
      case _Unit.piece:
        return 'Masalan: 25';
    }
  }
}

class _VehicleType {
  const _VehicleType({
    required this.code,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.maxKg,
  });
  final String code;
  final String title;
  final String subtitle;
  final IconData icon;
  final int maxKg;
}

const _vehicles = [
  _VehicleType(
      code: 'mini',
      title: 'Mini-fургon',
      subtitle: 'Damas, Labo',
      icon: Iconsax.car_copy,
      maxKg: 700),
  _VehicleType(
      code: 'pickup',
      title: 'Pikap',
      subtitle: 'Isuzu Elf',
      icon: Iconsax.truck,
      maxKg: 3000),
  _VehicleType(
      code: 'truck',
      title: 'Yuk mashinasi',
      subtitle: '5–10 tonnali',
      icon: Iconsax.truck_fast_copy,
      maxKg: 10000),
  _VehicleType(
      code: 'fura',
      title: 'Fura',
      subtitle: '20+ tonnali',
      icon: Iconsax.truck_remove_copy,
      maxKg: 25000),
];

class _CargoCategory {
  const _CargoCategory(this.code, this.title, this.icon);
  final String code;
  final String title;
  final IconData icon;
}

const _categories = [
  _CargoCategory('general', 'Umumiy', Iconsax.box_copy),
  _CargoCategory('fragile', 'Mo\'rt', Iconsax.shield_tick_copy),
  _CargoCategory('food', 'Oziq-ovqat', Iconsax.coffee_copy),
  _CargoCategory('cold', 'Sovuq', Iconsax.cloud_snow_copy),
  _CargoCategory('furniture', 'Mebel', Iconsax.home_2_copy),
  _CargoCategory('build', 'Qurilish', Iconsax.brifecase_tick_copy),
  _CargoCategory('auto', 'Avtomobil', Iconsax.car_copy),
  _CargoCategory('other', 'Boshqa', Iconsax.more_copy),
];

class CargoCreatePage extends StatefulWidget {
  const CargoCreatePage({super.key});
  @override
  State<CargoCreatePage> createState() => _CargoCreatePageState();
}

class _CargoCreatePageState extends State<CargoCreatePage> {
  int _step = 0; // 0 yo'nalish/manzil, 1 transport, 2 yuk, 3 yakuniy
  static const _totalSteps = 4;

  _Route _route = _Route.intercity;
  _Unit _unit = _Unit.kg;
  final _pickupCtrl = TextEditingController();
  final _dropoffCtrl = TextEditingController();
  DateTime? _pickupAt;

  String _vehicleCode = 'pickup';
  int _vehicleCount = 1;

  String _category = 'general';
  final _weightCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _deliveryPriceCtrl = TextEditingController();
  XFile? _photo;

  bool _submitting = false;
  final _picker = ImagePicker();

  @override
  void dispose() {
    _pickupCtrl.dispose();
    _dropoffCtrl.dispose();
    _weightCtrl.dispose();
    _noteCtrl.dispose();
    _priceCtrl.dispose();
    _deliveryPriceCtrl.dispose();
    super.dispose();
  }

  bool get _stepValid {
    switch (_step) {
      case 0:
        if (_pickupCtrl.text.trim().length < 3) return false;
        if (_dropoffCtrl.text.trim().length < 3) return false;
        return true;
      case 1:
        return _vehicleCount > 0;
      case 2:
        final w = double.tryParse(_weightCtrl.text.trim()) ?? 0;
        return w > 0;
      default:
        return true;
    }
  }

  void _next() {
    if (!_stepValid) {
      AppToast.show(context,
          message: 'Iltimos, maydonlarni to\'ldiring', kind: ToastKind.warning);
      return;
    }
    if (_step < _totalSteps - 1) {
      setState(() => _step++);
    } else {
      _submit();
    }
  }

  void _back() {
    if (_step == 0) {
      context.canPop() ? context.pop() : context.go('/');
    } else {
      setState(() => _step--);
    }
  }

  Future<void> _pickPhoto() async {
    try {
      final f = await _picker.pickImage(
          source: ImageSource.gallery, maxWidth: 1600, imageQuality: 85);
      if (f != null) setState(() => _photo = f);
    } catch (_) {
      AppToast.show(context, message: 'Faylni tanlab bo\'lmadi', kind: ToastKind.error);
    }
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final initial = _pickupAt ?? now.add(const Duration(hours: 2));
    final picked = await showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black.withOpacity(0.45),
      builder: (_) => _PremiumDateTimeSheet(
        initial: initial,
        firstDate: now,
        lastDate: now.add(const Duration(days: 60)),
      ),
    );
    if (picked == null) return;
    setState(() => _pickupAt = picked);
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      final routeStr = switch (_route) {
        _Route.intracity => 'intracity',
        _Route.intercity => 'intercity',
        _Route.international => 'international',
      };
      final composed = '$_category|${_vehicleCode}x$_vehicleCount|'
          '$routeStr|${_unit.label}';
      await sl<CargoRepository>().create(
        pickupAddress: _pickupCtrl.text.trim(),
        pickupLat: 41.3111,
        pickupLng: 69.2797,
        dropoffAddress: _dropoffCtrl.text.trim(),
        dropoffLat: 39.6542,
        dropoffLng: 66.9597,
        cargoType: composed,
        weightKg: double.parse(_weightCtrl.text.trim()),
      );
      if (!mounted) return;
      try {
        context.read<CargoBloc>().add(const CargoLoadMine());
      } catch (_) {}
      AppToast.show(context,
          message: 'So\'rov yuborildi! Haydovchilar javobini kuting.',
          kind: ToastKind.success);
      Future<void>.delayed(const Duration(milliseconds: 700), () {
        if (mounted) context.go('/');
      });
    } catch (e) {
      AppToast.show(context, message: e.toString(), kind: ToastKind.error);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              children: [
                _Header(
                  step: _step,
                  total: _totalSteps,
                  onBack: _back,
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    transitionBuilder: (c, a) => FadeTransition(
                      opacity: a,
                      child: SlideTransition(
                        position: Tween(
                                begin: const Offset(0.04, 0), end: Offset.zero)
                            .animate(a),
                        child: c,
                      ),
                    ),
                    child: KeyedSubtree(
                      key: ValueKey(_step),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                        child: _buildStep(),
                      ),
                    ),
                  ),
                ),
                _Footer(
                  step: _step,
                  total: _totalSteps,
                  loading: _submitting,
                  onPrimary: _next,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return _routeStep();
      case 1:
        return _vehicleStep();
      case 2:
        return _cargoStep();
      default:
        return _summaryStep();
    }
  }

  // ─── Step 1: route + addresses ─────────────────────────────────
  Widget _routeStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _StepTitle('Yo\'nalishni tanlang',
            'Shahar ichi, shaharlararo yoki xalqaro yo\'nalish'),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _RouteCard(
              icon: Iconsax.location_copy,
              title: 'Shahar ichi',
              subtitle: 'Bitta shahar',
              active: _route == _Route.intracity,
              onTap: () => setState(() => _route = _Route.intracity),
            ),
            _RouteCard(
              icon: Iconsax.routing_2_copy,
              title: 'Shaharlararo',
              subtitle: 'O\'zbekiston ichida',
              active: _route == _Route.intercity,
              onTap: () => setState(() => _route = _Route.intercity),
            ),
            _RouteCard(
              icon: Iconsax.global_copy,
              title: 'Xalqaro',
              subtitle: 'Mamlakatlararo',
              active: _route == _Route.international,
              onTap: () => setState(() => _route = _Route.international),
            ),
          ],
        ),
        const SizedBox(height: 22),
        _AddressTile(
          icon: Iconsax.routing_copy,
          dotColor: const Color(0xFF10B981),
          label: 'Olib ketish',
          hint: switch (_route) {
            _Route.intracity => 'Ko\'cha, uy raqami',
            _Route.intercity => 'Toshkent sh., Chilonzor tumani',
            _Route.international => 'Davlat, shahar, manzil',
          },
          controller: _pickupCtrl,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 10),
        _AddressTile(
          icon: Iconsax.location_tick_copy,
          dotColor: const Color(0xFFEF4444),
          label: 'Yetkazib berish',
          hint: switch (_route) {
            _Route.intracity => 'Manzil',
            _Route.intercity => 'Samarqand sh., Registon ko\'chasi',
            _Route.international => 'Davlat, shahar, manzil',
          },
          controller: _dropoffCtrl,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 18),
        // Date/time
        GestureDetector(
          onTap: _pickDateTime,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _line),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _brand.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Iconsax.calendar_copy, color: _brand, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Olib ketish vaqti',
                          style: TextStyle(fontSize: 11, color: _muted, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(
                        _pickupAt == null
                            ? 'Imkon qadar tezroq'
                            : _fmtDate(_pickupAt!),
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w800, color: _ink),
                      ),
                    ],
                  ),
                ),
                const Icon(Iconsax.arrow_right_3_copy, size: 18, color: _muted),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─── Step 2: vehicle + count ───────────────────────────────────
  Widget _vehicleStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _StepTitle('Transport turi', 'Yukingizga mos transport va sonini tanlang'),
        const SizedBox(height: 16),
        ..._vehicles.asMap().entries.map((e) {
          final v = e.value;
          final active = _vehicleCode == v.code;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GestureDetector(
              onTap: () => setState(() => _vehicleCode = v.code),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: active ? _brand.withOpacity(0.06) : _surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: active ? _brand : _line,
                    width: active ? 1.5 : 1,
                  ),
                  boxShadow: active
                      ? [
                          BoxShadow(
                            color: _brand.withOpacity(0.10),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: (active ? _brand : _muted).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(v.icon, color: active ? _brand : _ink, size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(v.title,
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w800, color: _ink)),
                          const SizedBox(height: 2),
                          Text('${v.subtitle} · max ${v.maxKg} kg',
                              style: const TextStyle(fontSize: 12, color: _muted)),
                        ],
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: active ? _brand : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(color: active ? _brand : _line, width: 1.5),
                      ),
                      child: active
                          ? const Icon(Iconsax.tick_circle, color: Colors.white, size: 14)
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          ).animate(delay: (e.key * 50).ms).fadeIn(duration: 250.ms).slideY(begin: 0.05);
        }),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _line),
          ),
          child: Row(
            children: [
              const Icon(Iconsax.truck_copy, size: 18, color: _muted),
              const SizedBox(width: 10),
              const Expanded(
                child: Text('Mashinalar soni',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _ink)),
              ),
              _CountStepper(
                value: _vehicleCount,
                onChanged: (v) => setState(() => _vehicleCount = v),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Step 3: cargo info + photo ────────────────────────────────
  Widget _cargoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _StepTitle('Yuk haqida', 'Toifa, miqdor va ixtiyoriy rasm'),
        const SizedBox(height: 16),
        // Categories grid
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _categories.map((c) {
            final active = _category == c.code;
            return GestureDetector(
              onTap: () => setState(() => _category = c.code),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: active ? _brand : _surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: active ? _brand : _line,
                    width: 1,
                  ),
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(c.icon, size: 16, color: active ? Colors.white : _muted),
                    const SizedBox(width: 8),
                    Text(
                      c.title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: active ? Colors.white : _ink,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 18),
        _QuantityField(
          unit: _unit,
          controller: _weightCtrl,
          onUnitChanged: (u) => setState(() => _unit = u),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 14),
        _SimpleField(
          label: 'Qo\'shimcha izoh',
          hint: 'O\'lcham, joylash xususiyati...',
          icon: Iconsax.note_text_copy,
          controller: _noteCtrl,
          maxLines: 3,
        ),
        const SizedBox(height: 14),
        // Price fields
        Row(
          children: [
            Expanded(
              child: _MoneyField(
                label: 'Yuk narxi',
                hint: '0',
                icon: Iconsax.money_3_copy,
                controller: _priceCtrl,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MoneyField(
                label: 'Yetkazish narxi',
                hint: '0',
                icon: Iconsax.truck_fast_copy,
                controller: _deliveryPriceCtrl,
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        // Photo upload
        _PhotoTile(file: _photo, onTap: _pickPhoto, onRemove: () => setState(() => _photo = null)),
      ],
    );
  }

  // ─── Step 4: summary ───────────────────────────────────────────
  Widget _summaryStep() {
    final v = _vehicles.firstWhere((x) => x.code == _vehicleCode);
    final c = _categories.firstWhere((x) => x.code == _category);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _StepTitle('Yakuniy tekshiruv', 'Ma\'lumotlarni tasdiqlang va yuboring'),
        const SizedBox(height: 18),
        _SummaryCard(
          title: 'Yo\'nalish',
          icon: Iconsax.routing_2_copy,
          children: [
            _SummaryRow(
              icon: Iconsax.location_copy,
              label: 'Olib ketish',
              value: _pickupCtrl.text,
              dotColor: const Color(0xFF10B981),
            ),
            _SummaryRow(
              icon: Iconsax.location_tick_copy,
              label: 'Yetkazib berish',
              value: _dropoffCtrl.text,
              dotColor: const Color(0xFFEF4444),
            ),
            _SummaryRow(
              icon: Iconsax.calendar_copy,
              label: 'Vaqt',
              value: _pickupAt == null ? 'Imkon qadar tezroq' : _fmtDate(_pickupAt!),
            ),
            _SummaryRow(
              icon: Iconsax.global_copy,
              label: 'Tur',
              value: switch (_route) {
                _Route.intracity => 'Shahar ichi',
                _Route.intercity => 'Shaharlararo',
                _Route.international => 'Xalqaro',
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        _SummaryCard(
          title: 'Transport',
          icon: Iconsax.truck_fast_copy,
          children: [
            _SummaryRow(icon: v.icon, label: v.title, value: v.subtitle),
            _SummaryRow(icon: Iconsax.hashtag_copy, label: 'Soni', value: '$_vehicleCount dona'),
          ],
        ),
        const SizedBox(height: 12),
        _SummaryCard(
          title: 'Yuk',
          icon: Iconsax.box_copy,
          children: [
            _SummaryRow(icon: c.icon, label: 'Toifa', value: c.title),
            _SummaryRow(
                icon: _unit.icon,
                label: 'Miqdori',
                value: '${_weightCtrl.text} ${_unit.label}'),
            if (_noteCtrl.text.trim().isNotEmpty)
              _SummaryRow(
                  icon: Iconsax.note_text_copy, label: 'Izoh', value: _noteCtrl.text),
            if (_priceCtrl.text.trim().isNotEmpty)
              _SummaryRow(
                  icon: Iconsax.money_3_copy,
                  label: 'Yuk narxi',
                  value: "${_fmtMoney(_priceCtrl.text)} so'm"),
            if (_deliveryPriceCtrl.text.trim().isNotEmpty)
              _SummaryRow(
                  icon: Iconsax.truck_fast_copy,
                  label: 'Yetkazish narxi',
                  value: "${_fmtMoney(_deliveryPriceCtrl.text)} so'm"),
            if (_photo != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    height: 140,
                    width: double.infinity,
                    child: kIsWeb
                        ? Image.network(_photo!.path, fit: BoxFit.cover)
                        : Image.file(File(_photo!.path), fit: BoxFit.cover),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  String _fmtDate(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}.${two(d.month)}.${d.year}  ${two(d.hour)}:${two(d.minute)}';
  }

  String _fmtMoney(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return '0';
    final b = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) b.write(' ');
      b.write(digits[i]);
    }
    return b.toString();
  }
}

// ─────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  const _Header({required this.step, required this.total, required this.onBack});
  final int step;
  final int total;
  final VoidCallback onBack;

  static const _stepLabels = ['Yo\u2018nalish', 'Transport', 'Yuk', 'Yakuniy'];
  static const _stepIcons = [
    Iconsax.routing_2_copy,
    Iconsax.truck_fast_copy,
    Iconsax.box_copy,
    Iconsax.tick_circle_copy,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
        boxShadow: [
          BoxShadow(color: Color(0x0A000000), blurRadius: 14, offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Material(
                color: _surface,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  onTap: onBack,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _line),
                    ),
                    child: const Icon(Iconsax.arrow_left_2, size: 20, color: _ink),
                  ),
                ),
              ),
              const Spacer(),
              Column(
                children: [
                  const Text('Yangi yuk',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: _ink)),
                  const SizedBox(height: 2),
                  Text(
                    '${step + 1}-qadam · ${_stepLabels[step]}',
                    style: const TextStyle(fontSize: 11.5, color: _muted, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                width: 44, height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_brand, Color(0xFF7C3AED)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(color: _brand.withOpacity(0.25), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Text(
                  '${step + 1}/$total',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Premium step indicator
          Row(
            children: List.generate(total, (i) {
              final done = i < step;
              final active = i == step;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i == total - 1 ? 0 : 6),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 280),
                            curve: Curves.easeOutCubic,
                            width: active ? 32 : 26,
                            height: active ? 32 : 26,
                            decoration: BoxDecoration(
                              color: done || active ? _brand : Colors.white,
                              borderRadius: BorderRadius.circular(active ? 11 : 9),
                              border: Border.all(
                                color: done || active ? _brand : _line,
                                width: active ? 0 : 1.5,
                              ),
                              boxShadow: active
                                  ? [BoxShadow(color: _brand.withOpacity(0.30), blurRadius: 10, offset: const Offset(0, 4))]
                                  : null,
                            ),
                            child: Icon(
                              done ? Iconsax.tick_square_copy : _stepIcons[i],
                              size: active ? 16 : 13,
                              color: done || active ? Colors.white : _muted,
                            ),
                          ),
                          if (i < total - 1)
                            Expanded(
                              child: Container(
                                height: 2,
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  color: i < step ? _brand : _line,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _stepLabels[i],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: active ? FontWeight.w900 : FontWeight.w600,
                            color: done
                                ? _brand
                                : active
                                    ? _ink
                                    : _muted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({
    required this.step,
    required this.total,
    required this.loading,
    required this.onPrimary,
  });
  final int step;
  final int total;
  final bool loading;
  final VoidCallback onPrimary;

  @override
  Widget build(BuildContext context) {
    final isLast = step == total - 1;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: _line)),
      ),
      child: SizedBox(
        height: 56,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: loading ? null : onPrimary,
            borderRadius: BorderRadius.circular(16),
            child: Ink(
              decoration: BoxDecoration(
                color: _brand,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _brand.withOpacity(0.32),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.4, color: Colors.white),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isLast ? 'So\'rovni yuborish' : 'Davom etish',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            isLast
                                ? Iconsax.send_2_copy
                                : Iconsax.arrow_right_3_copy,
                            color: Colors.white,
                            size: 18,
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StepTitle extends StatelessWidget {
  const _StepTitle(this.title, this.subtitle);
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: _ink)),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(fontSize: 13, color: _muted)),
      ],
    );
  }
}

class _AddressTile extends StatefulWidget {
  const _AddressTile({
    required this.icon,
    required this.dotColor,
    required this.label,
    required this.hint,
    required this.controller,
    required this.onChanged,
  });
  final IconData icon;
  final Color dotColor;
  final String label;
  final String hint;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  @override
  State<_AddressTile> createState() => _AddressTileState();
}

class _AddressTileState extends State<_AddressTile> {
  final _focus = FocusNode();
  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final f = _focus.hasFocus;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          margin: const EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            color: widget.dotColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(widget.icon, color: widget.dotColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 4, top: 2),
                child: Text(widget.label,
                    style: const TextStyle(
                        fontSize: 12, color: _muted, fontWeight: FontWeight.w700)),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: f ? Colors.white : _surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: f ? _brand : _line, width: f ? 1.5 : 1),
                ),
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focus,
                  onChanged: widget.onChanged,
                  style: const TextStyle(
                      fontSize: 14.5, fontWeight: FontWeight.w700, color: _ink),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    hintText: widget.hint,
                    hintStyle: const TextStyle(
                        color: Color(0xFFCBD5E1), fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SimpleField extends StatefulWidget {
  const _SimpleField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    this.maxLines = 1,
  });
  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final int maxLines;
  @override
  State<_SimpleField> createState() => _SimpleFieldState();
}

class _SimpleFieldState extends State<_SimpleField> {
  final _focus = FocusNode();
  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final f = _focus.hasFocus;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(widget.label,
              style: const TextStyle(fontSize: 12.5, color: _ink, fontWeight: FontWeight.w700)),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: f ? Colors.white : _surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: f ? _brand : _line, width: f ? 1.5 : 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Icon(widget.icon, size: 18, color: f ? _brand : _muted),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focus,
                  maxLines: widget.maxLines,
                  style: const TextStyle(
                      fontSize: 14.5, fontWeight: FontWeight.w700, color: _ink),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    hintText: widget.hint,
                    hintStyle: const TextStyle(
                        color: Color(0xFFCBD5E1), fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MoneyField extends StatefulWidget {
  const _MoneyField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    required this.onChanged,
  });
  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  @override
  State<_MoneyField> createState() => _MoneyFieldState();
}

class _MoneyFieldState extends State<_MoneyField> {
  final _focus = FocusNode();
  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  String _format(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return '';
    final b = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) b.write(' ');
      b.write(digits[i]);
    }
    return b.toString();
  }

  @override
  Widget build(BuildContext context) {
    final f = _focus.hasFocus;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(widget.label,
              style: const TextStyle(fontSize: 12.5, color: _ink, fontWeight: FontWeight.w700)),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: f ? Colors.white : _surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: f ? _brand : _line, width: f ? 1.5 : 1),
          ),
          child: Row(
            children: [
              Container(
                width: 30, height: 30,
                decoration: BoxDecoration(
                  color: _brand.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(widget.icon, size: 16, color: _brand),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focus,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    TextInputFormatter.withFunction((old, n) {
                      final formatted = _format(n.text);
                      return TextEditingValue(
                        text: formatted,
                        selection: TextSelection.collapsed(offset: formatted.length),
                      );
                    }),
                  ],
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w800, color: _ink),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    hintText: widget.hint,
                    hintStyle: const TextStyle(
                        color: Color(0xFFCBD5E1), fontWeight: FontWeight.w500),
                  ),
                  onChanged: widget.onChanged,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 6),
                child: Text("so'm",
                    style: TextStyle(
                        fontSize: 12, color: _muted, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CountStepper extends StatelessWidget {
  const _CountStepper({required this.value, required this.onChanged});
  final int value;
  final ValueChanged<int> onChanged;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _btn(Iconsax.minus, value > 1, () => onChanged(value - 1)),
          SizedBox(
            width: 36,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w800, color: _ink),
            ),
          ),
          _btn(Iconsax.add, value < 99, () => onChanged(value + 1)),
        ],
      ),
    );
  }

  Widget _btn(IconData ic, bool enabled, VoidCallback onTap) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: enabled ? _brand.withOpacity(0.10) : _surface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(ic, size: 16, color: enabled ? _brand : _muted),
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({required this.file, required this.onTap, required this.onRemove});
  final XFile? file;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  @override
  Widget build(BuildContext context) {
    final picked = file != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: picked ? 160 : 110,
        decoration: BoxDecoration(
          color: picked ? Colors.transparent : _surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: picked ? Colors.transparent : _line,
            width: picked ? 0 : 1.4,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: picked
            ? Stack(
                fit: StackFit.expand,
                children: [
                  if (kIsWeb)
                    Image.network(file!.path, fit: BoxFit.cover)
                  else
                    Image.file(File(file!.path), fit: BoxFit.cover),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Material(
                      color: Colors.black.withOpacity(0.55),
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: onRemove,
                        child: const Padding(
                          padding: EdgeInsets.all(6),
                          child: Icon(Iconsax.trash, color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _brand.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Iconsax.gallery_add_copy, color: _brand, size: 22),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Yuk rasmini yuklash',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: _ink)),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _muted.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('Ixtiyoriy',
                            style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: _muted)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  const Text('Tavsiya etiladi, lekin majburiy emas',
                      style: TextStyle(fontSize: 11, color: _muted)),
                ],
              ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.title, required this.icon, required this.children});
  final String title;
  final IconData icon;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: _brand.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: _brand),
              ),
              const SizedBox(width: 10),
              Text(title,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w800, color: _ink)),
            ],
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
    this.dotColor,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color? dotColor;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: dotColor ?? _muted),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(fontSize: 11, color: _muted, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        fontSize: 13.5, color: _ink, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteCard extends StatelessWidget {
  const _RouteCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.active,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final bool active;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final w = (MediaQuery.of(context).size.width - 32 - 20) / 3;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: w.clamp(96, 200),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: active ? _brand : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: active ? _brand : _line),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: _brand.withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: active
                    ? Colors.white.withOpacity(0.18)
                    : _brand.withOpacity(0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon,
                  size: 18, color: active ? Colors.white : _brand),
            ),
            const SizedBox(height: 8),
            Text(title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: active ? Colors.white : _ink,
                )),
            const SizedBox(height: 2),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: active ? Colors.white.withOpacity(0.85) : _muted,
                )),
          ],
        ),
      ),
    );
  }
}

// Premium quantity field with unit dropdown suffix
class _QuantityField extends StatefulWidget {
  const _QuantityField({
    required this.unit,
    required this.controller,
    required this.onUnitChanged,
    required this.onChanged,
  });
  final _Unit unit;
  final TextEditingController controller;
  final ValueChanged<_Unit> onUnitChanged;
  final ValueChanged<String> onChanged;
  @override
  State<_QuantityField> createState() => _QuantityFieldState();
}

class _QuantityFieldState extends State<_QuantityField> {
  final _focus = FocusNode();
  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final f = _focus.hasFocus;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 6),
          child: Text('Miqdori',
              style: TextStyle(
                  fontSize: 12, color: _muted, fontWeight: FontWeight.w700)),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: f ? Colors.white : _surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: f ? _brand : _line, width: f ? 1.5 : 1),
          ),
          child: Row(
            children: [
              Icon(widget.unit.icon, size: 18, color: _muted),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focus,
                  onChanged: widget.onChanged,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: const TextStyle(
                      fontSize: 14.5, fontWeight: FontWeight.w700, color: _ink),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    hintText: widget.unit.hint,
                    hintStyle: const TextStyle(
                        color: Color(0xFFCBD5E1), fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              _UnitSuffixMenu(
                unit: widget.unit,
                onChanged: widget.onUnitChanged,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _UnitSuffixMenu extends StatelessWidget {
  const _UnitSuffixMenu({required this.unit, required this.onChanged});
  final _Unit unit;
  final ValueChanged<_Unit> onChanged;
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_Unit>(
      tooltip: 'O\'lchov birligi',
      onSelected: onChanged,
      position: PopupMenuPosition.under,
      offset: const Offset(0, 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: Colors.white,
      itemBuilder: (_) => _Unit.values.map((u) {
        final active = u == unit;
        return PopupMenuItem<_Unit>(
          value: u,
          height: 42,
          child: Row(
            children: [
              Icon(u.icon, size: 16, color: active ? _brand : _muted),
              const SizedBox(width: 10),
              Text(u.full,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: active ? _brand : _ink,
                  )),
              const Spacer(),
              Text(u.label,
                  style: const TextStyle(
                      fontSize: 11,
                      color: _muted,
                      fontWeight: FontWeight.w600)),
              if (active) ...[
                const SizedBox(width: 6),
                const Icon(Iconsax.tick_circle, size: 14, color: _brand),
              ],
            ],
          ),
        );
      }).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: _brand.withOpacity(0.10),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(unit.label,
                style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: _brand)),
            const SizedBox(width: 4),
            const Icon(Iconsax.arrow_down_1, size: 14, color: _brand),
          ],
        ),
      ),
    );
  }
}



// =================================================================
// Premium Date + Time picker bottom sheet
// =================================================================
class _PremiumDateTimeSheet extends StatefulWidget {
  const _PremiumDateTimeSheet({
    required this.initial,
    required this.firstDate,
    required this.lastDate,
  });
  final DateTime initial;
  final DateTime firstDate;
  final DateTime lastDate;
  @override
  State<_PremiumDateTimeSheet> createState() => _PremiumDateTimeSheetState();
}

class _PremiumDateTimeSheetState extends State<_PremiumDateTimeSheet> {
  late DateTime _selected;
  late int _hour;
  late int _minute;
  late ScrollController _daysCtrl;
  static const _wDays = ['Du', 'Se', 'Cho', 'Pa', 'Ju', 'Sha', 'Yak'];
  static const _months = [
    'Yanvar','Fevral','Mart','Aprel','May','Iyun',
    'Iyul','Avgust','Sentabr','Oktabr','Noyabr','Dekabr',
  ];

  @override
  void initState() {
    super.initState();
    _selected = DateTime(widget.initial.year, widget.initial.month, widget.initial.day);
    _hour = widget.initial.hour;
    _minute = widget.initial.minute;
    final daysFromStart = _selected.difference(_dayOnly(widget.firstDate)).inDays;
    _daysCtrl = ScrollController(initialScrollOffset: (daysFromStart * 70.0).clamp(0.0, double.infinity));
  }

  @override
  void dispose() {
    _daysCtrl.dispose();
    super.dispose();
  }

  DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  void _setHour(int h) => setState(() => _hour = h.clamp(0, 23));
  void _setMin(int m) => setState(() => _minute = m.clamp(0, 59));

  void _quick(Duration offset) {
    final t = DateTime.now().add(offset);
    setState(() {
      _selected = _dayOnly(t);
      _hour = t.hour;
      _minute = t.minute;
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalDays = _dayOnly(widget.lastDate).difference(_dayOnly(widget.firstDate)).inDays + 1;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 14,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44, height: 5,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: _brand.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Iconsax.calendar_2_copy, color: _brand, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Olib ketish vaqti',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: _ink)),
                    SizedBox(height: 2),
                    Text('Sana va vaqtni tanlang',
                      style: TextStyle(fontSize: 12, color: _muted, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Iconsax.close_square_copy, color: _muted),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Quick chips
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _QuickChip(label: '1 soatdan keyin', onTap: () => _quick(const Duration(hours: 1))),
                _QuickChip(label: 'Bugun kechqurun', onTap: () { final t = DateTime.now(); setState(() { _selected = _dayOnly(t); _hour = 18; _minute = 0; });}),
                _QuickChip(label: 'Ertaga ertalab', onTap: () { final t = DateTime.now().add(const Duration(days: 1)); setState(() { _selected = _dayOnly(t); _hour = 9; _minute = 0; });}),
                _QuickChip(label: '3 kundan keyin', onTap: () => _quick(const Duration(days: 3))),
              ],
            ),
          ),
          const SizedBox(height: 18),
          // Month label
          Row(
            children: [
              Text('${_months[_selected.month - 1]} ${_selected.year}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _ink)),
              const Spacer(),
              const Icon(Iconsax.arrow_left_2, size: 16, color: _muted),
              const SizedBox(width: 6),
              const Icon(Iconsax.arrow_right_3_copy, size: 16, color: _muted),
            ],
          ),
          const SizedBox(height: 10),
          // Horizontal day strip
          SizedBox(
            height: 78,
            child: ListView.separated(
              controller: _daysCtrl,
              scrollDirection: Axis.horizontal,
              itemCount: totalDays,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final d = _dayOnly(widget.firstDate).add(Duration(days: i));
                final selected = _dayOnly(_selected) == d;
                final isToday = _dayOnly(DateTime.now()) == d;
                return GestureDetector(
                  onTap: () => setState(() => _selected = d),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 62,
                    decoration: BoxDecoration(
                      color: selected ? _brand : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selected
                          ? _brand
                          : isToday ? _brand.withOpacity(0.4) : _line,
                        width: selected ? 2 : 1,
                      ),
                      boxShadow: selected
                        ? [BoxShadow(color: _brand.withOpacity(0.30), blurRadius: 14, offset: const Offset(0, 6))]
                        : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_wDays[d.weekday - 1],
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: selected ? Colors.white.withOpacity(0.9) : _muted)),
                        const SizedBox(height: 4),
                        Text('${d.day}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: selected ? Colors.white : _ink)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 22),
          // Time pickers
          Row(
            children: [
              Expanded(child: _TimeWheel(label: 'Soat', value: _hour, max: 23, onChange: _setHour)),
              const SizedBox(width: 12),
              const Text(':', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: _ink)),
              const SizedBox(width: 12),
              Expanded(child: _TimeWheel(label: 'Daqiqa', value: _minute, max: 59, step: 5, onChange: _setMin)),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 52),
                    side: const BorderSide(color: _line),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Bekor', style: TextStyle(color: _ink, fontWeight: FontWeight.w800)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(DateTime(_selected.year, _selected.month, _selected.day, _hour, _minute));
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 52),
                    backgroundColor: _brand,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Text('Tasdiqlash', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: _surface,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _line),
            ),
            child: Text(label, style: const TextStyle(fontSize: 12.5, color: _ink, fontWeight: FontWeight.w700)),
          ),
        ),
      ),
    );
  }
}

class _TimeWheel extends StatelessWidget {
  const _TimeWheel({required this.label, required this.value, required this.max, this.step = 1, required this.onChange});
  final String label;
  final int value;
  final int max;
  final int step;
  final ValueChanged<int> onChange;
  @override
  Widget build(BuildContext context) {
    String two(int n) => n.toString().padLeft(2, '0');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _line),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: _muted, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => onChange(value - step < 0 ? max : value - step),
                icon: const Icon(Iconsax.minus, size: 18, color: _muted),
                style: IconButton.styleFrom(backgroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: _line))),
              ),
              Text(two(value),
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: _ink, fontFeatures: [FontFeature.tabularFigures()])),
              IconButton(
                onPressed: () => onChange(value + step > max ? 0 : value + step),
                icon: const Icon(Iconsax.add, size: 18, color: _brand),
                style: IconButton.styleFrom(backgroundColor: _brand.withOpacity(0.08), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: _brand.withOpacity(0.25)))),
              ),
            ],
          ),
        ],
      ),
    );
  }
}