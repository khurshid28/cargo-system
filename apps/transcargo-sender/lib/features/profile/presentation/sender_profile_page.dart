import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/store/profile_store.dart';
import '../../../core/ui/app_toast.dart';
import '../../auth/presentation/bloc/auth_bloc.dart';

const _brand = Color(0xFF1670F5);
const _ink = Color(0xFF0F172A);
const _muted = Color(0xFF64748B);
const _line = Color(0xFFE2E8F0);
const _surface = Color(0xFFF8FAFC);

class SenderProfilePage extends StatefulWidget {
  const SenderProfilePage({super.key});
  @override
  State<SenderProfilePage> createState() => _SenderProfilePageState();
}

class _SenderProfilePageState extends State<SenderProfilePage> {
  Future<void> _refresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AuthBloc>().state;
    final user = state is AuthAuthenticated ? state.user : null;
    const balance = 850000;
    const totalShipments = 18;
    const totalSpent = 12500000;
    const rating = 4.8;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      body: RefreshIndicator(
        color: _brand,
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          children: [
            _HeaderCard(
              name: ProfileStore.instance.fullName.value.isEmpty
                  ? 'Yuk yuboruvchi'
                  : ProfileStore.instance.fullName.value,
              phone: user?.phone ?? ProfileStore.instance.phone.value,
              avatar: ProfileStore.instance.avatar.value,
              onEdit: () async {
                final updated = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(builder: (_) => const ProfileEditPage()),
                );
                if (updated == true && mounted) setState(() {});
              },
            ).animate().fadeIn(duration: 250.ms).slideY(begin: -0.05),
            const SizedBox(height: 14),
            const _BalanceCard(balance: balance)
                .animate(delay: 60.ms)
                .fadeIn(duration: 250.ms)
                .slideY(begin: 0.05),
            const SizedBox(height: 14),
            Row(
              children: [
                const Expanded(
                  child: _StatTile(
                    icon: Iconsax.box_copy,
                    label: 'Buyurtmalar',
                    value: '$totalShipments',
                    color: _brand,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatTile(
                    icon: Iconsax.dollar_circle_copy,
                    label: 'Sarflangan',
                    value: '${(totalSpent / 1000000).toStringAsFixed(1)}M',
                    color: const Color(0xFF10B981),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatTile(
                    icon: Iconsax.star_1_copy,
                    label: 'Reyting',
                    value: rating.toStringAsFixed(1),
                    color: const Color(0xFFF59E0B),
                  ),
                ),
              ],
            ).animate(delay: 120.ms).fadeIn(duration: 250.ms),
            const SizedBox(height: 22),
            const _SectionHeader(text: 'Hisob'),
            const SizedBox(height: 8),
            _MenuGroup(items: [
              _MenuItem(
                icon: Iconsax.location_copy,
                title: 'Manzillarim',
                subtitle: '3 ta saqlangan manzil',
                onTap: () {},
              ),
              _MenuItem(
                icon: Iconsax.card_copy,
                title: "To'lov usullari",
                subtitle: '2 ta karta',
                onTap: () {},
              ),
              _MenuItem(
                icon: Iconsax.notification_copy,
                title: 'Bildirishnomalar',
                trailing: const _Badge(
                    text: 'Yoqilgan', color: Color(0xFF10B981)),
                onTap: () {},
              ),
            ]),
            const SizedBox(height: 18),
            const _SectionHeader(text: 'Sozlamalar'),
            const SizedBox(height: 8),
            _MenuGroup(items: [
              _MenuItem(
                icon: Iconsax.global_copy,
                title: 'Til',
                trailing: const _Badge(text: "O'zbek", color: _brand),
                onTap: () {},
              ),
              _MenuItem(
                icon: Iconsax.security_user_copy,
                title: 'Maxfiylik',
                onTap: () {},
              ),
              _MenuItem(
                icon: Iconsax.message_question_copy,
                title: 'Yordam markazi',
                onTap: () {},
              ),
              const _MenuItem(
                icon: Iconsax.info_circle_copy,
                title: 'Ilova haqida',
                trailing: Text('v1.0.0',
                    style: TextStyle(
                        fontSize: 11.5,
                        color: _muted,
                        fontWeight: FontWeight.w700)),
              ),
            ]),
            const SizedBox(height: 22),
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: () =>
                    context.read<AuthBloc>().add(const AuthSignOutRequested()),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: const Color(0xFFEF4444).withOpacity(0.30)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Iconsax.logout_copy,
                          color: Color(0xFFEF4444), size: 18),
                      SizedBox(width: 8),
                      Text('Hisobdan chiqish',
                          style: TextStyle(
                              color: Color(0xFFEF4444),
                              fontWeight: FontWeight.w800,
                              fontSize: 14)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.name,
    required this.phone,
    required this.avatar,
    required this.onEdit,
  });
  final String name;
  final String phone;
  final XFile? avatar;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_brand, Color(0xFF0E58C9)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: _brand.withOpacity(0.30),
              blurRadius: 20,
              offset: const Offset(0, 10)),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 70, height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.18),
                  border: Border.all(color: Colors.white, width: 2.5),
                ),
                child: ClipOval(
                  child: avatar != null
                      ? (kIsWeb
                          ? Image.network(avatar!.path, fit: BoxFit.cover)
                          : Image.file(File(avatar!.path), fit: BoxFit.cover))
                      : const Icon(Iconsax.user, color: Colors.white, size: 32),
                ),
              ),
              Positioned(
                right: 0, bottom: 0,
                child: Container(
                  width: 18, height: 18,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    shape: BoxShape.circle,
                    border: Border.all(color: _brand, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(phone,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.80),
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Iconsax.shield_tick_copy,
                          size: 11, color: Colors.white),
                      SizedBox(width: 4),
                      Text('Tasdiqlangan',
                          style: TextStyle(
                              fontSize: 10.5,
                              color: Colors.white,
                              fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: Colors.white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: onEdit,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 40, height: 40,
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(12)),
                child: const Icon(Iconsax.edit_2_copy,
                    color: Colors.white, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.balance});
  final int balance;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _line),
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Iconsax.wallet_3_copy,
                color: Color(0xFF10B981), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Balans',
                    style: TextStyle(
                        fontSize: 11.5,
                        color: _muted,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text("${_money(balance)} so'm",
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: _ink)),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: _brand,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            icon: const Icon(Iconsax.add, size: 16),
            label: const Text("To'ldirish",
                style:
                    TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5)),
          ),
        ],
      ),
    );
  }

  static String _money(int v) {
    final s = v.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _line),
      ),
      child: Column(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w900, color: _ink)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  fontSize: 10.5, color: _muted, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(text,
          style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w900, color: _ink)),
    );
  }
}

class _MenuGroup extends StatelessWidget {
  const _MenuGroup({required this.items});
  final List<_MenuItem> items;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _line),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            items[i],
            if (i < items.length - 1)
              const Padding(
                padding: EdgeInsets.only(left: 56),
                child: Divider(height: 1, color: _line),
              ),
          ],
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: _brand.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: _brand),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: _ink)),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(subtitle!,
                          style: const TextStyle(
                              fontSize: 11.5,
                              color: _muted,
                              fontWeight: FontWeight.w600)),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                trailing!,
                const SizedBox(width: 6),
              ],
              const Icon(Iconsax.arrow_right_3, size: 16, color: _muted),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text, required this.color});
  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text,
          style: TextStyle(
              fontSize: 10.5, fontWeight: FontWeight.w800, color: color)),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// EDIT PAGE
// ═══════════════════════════════════════════════════════════════
class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});
  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  late final _name = TextEditingController(text: ProfileStore.instance.fullName.value);
  late final _email = TextEditingController(text: ProfileStore.instance.email.value);
  late final _bio = TextEditingController(text: ProfileStore.instance.bio.value);
  late final _address = TextEditingController(text: ProfileStore.instance.address.value);
  XFile? _avatar = ProfileStore.instance.avatar.value;
  final _picker = ImagePicker();
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _bio.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    final f = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 80,
    );
    if (f != null) setState(() => _avatar = f);
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      AppToast.show(context,
          message: 'F.I.O kiritilishi shart', kind: ToastKind.warning);
      return;
    }
    setState(() => _saving = true);
    await ProfileStore.instance.save(
      fullName: _name.text.trim(),
      email: _email.text.trim(),
      bio: _bio.text.trim(),
      address: _address.text.trim(),
      avatar: _avatar,
    );
    if (!mounted) return;
    AppToast.show(context,
        message: "Ma'lumotlar yangilandi", kind: ToastKind.success);
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
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
                    child: Text('Profilni tahrirlash',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: _ink)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  Center(
                    child: Stack(
                      children: [
                        GestureDetector(
                          onTap: _pick,
                          child: Container(
                            width: 110, height: 110,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _brand.withOpacity(0.08),
                              border: Border.all(color: _line, width: 2),
                            ),
                            child: ClipOval(
                              child: _avatar != null
                                  ? (kIsWeb
                                      ? Image.network(_avatar!.path,
                                          fit: BoxFit.cover)
                                      : Image.file(File(_avatar!.path),
                                          fit: BoxFit.cover))
                                  : const Icon(Iconsax.user,
                                      color: _brand, size: 44),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 2, bottom: 2,
                          child: GestureDetector(
                            onTap: _pick,
                            child: Container(
                              width: 36, height: 36,
                              decoration: BoxDecoration(
                                color: _brand,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 3),
                              ),
                              child: const Icon(Iconsax.camera,
                                  color: Colors.white, size: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Center(
                    child: Text('Suratni tanlash uchun bosing',
                        style: TextStyle(
                            fontSize: 12,
                            color: _muted,
                            fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 22),
                  _Field(
                    label: 'F.I.O',
                    icon: Iconsax.user_copy,
                    controller: _name,
                    hint: 'Ism Familiya',
                  ),
                  const SizedBox(height: 12),
                  _Field(
                    label: 'Email',
                    icon: Iconsax.sms_copy,
                    controller: _email,
                    hint: 'name@email.com',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  _Field(
                    label: 'Manzil',
                    icon: Iconsax.location_copy,
                    controller: _address,
                    hint: 'Shahar, ko\'cha, uy',
                  ),
                  const SizedBox(height: 12),
                  _Field(
                    label: 'Bio',
                    icon: Iconsax.note_text_copy,
                    controller: _bio,
                    hint: "O'zingiz haqingizda qisqa ma'lumot",
                    maxLines: 4,
                  ),
                ],
              ),
            ),
            SafeArea(
              minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _brand,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.4, color: Colors.white),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Iconsax.tick_circle, size: 18),
                            SizedBox(width: 8),
                            Text('Saqlash',
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w800)),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatefulWidget {
  const _Field({
    required this.label,
    required this.icon,
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType,
  });
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final TextInputType? keyboardType;
  @override
  State<_Field> createState() => _FieldState();
}

class _FieldState extends State<_Field> {
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
              style: const TextStyle(
                  fontSize: 12, color: _muted, fontWeight: FontWeight.w700)),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: f ? Colors.white : _surface,
            borderRadius: BorderRadius.circular(14),
            border:
                Border.all(color: f ? _brand : _line, width: f ? 1.5 : 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Icon(widget.icon,
                    size: 18, color: f ? _brand : _muted),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focus,
                  maxLines: widget.maxLines,
                  keyboardType: widget.keyboardType,
                  style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: _ink),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 14),
                    hintText: widget.hint,
                    hintStyle: const TextStyle(
                        color: Color(0xFFCBD5E1),
                        fontWeight: FontWeight.w500),
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
