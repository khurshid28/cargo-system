import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/ui/app_toast.dart';
import '../../../../core/store/profile_store.dart';

const _brand = Color(0xFF1670F5);
const _ink = Color(0xFF0F172A);
const _muted = Color(0xFF64748B);
const _line = Color(0xFFE2E8F0);
const _surface = Color(0xFFF8FAFC);

enum _AccountType { individual, legal }

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  _AccountType _type = _AccountType.individual;
  final _picker = ImagePicker();

  // Common
  final _nameCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  // Legal-only
  final _innCtrl = TextEditingController();
  final _mfoCtrl = TextEditingController();
  final _bankCtrl = TextEditingController();
  final _directorCtrl = TextEditingController();

  XFile? _avatar;
  XFile? _document;
  bool _agree = false;
  bool _submitting = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    _innCtrl.dispose();
    _mfoCtrl.dispose();
    _bankCtrl.dispose();
    _directorCtrl.dispose();
    super.dispose();
  }

  Future<void> _pick(bool avatar) async {
    try {
      final f = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        imageQuality: 85,
      );
      if (f == null) return;
      setState(() {
        if (avatar) {
          _avatar = f;
        } else {
          _document = f;
        }
      });
    } catch (e) {
      AppToast.show(context, message: 'Faylni tanlab bo\'lmadi', kind: ToastKind.error);
    }
  }

  bool get _formValid {
    if (_nameCtrl.text.trim().length < 2) return false;
    if (!_agree) return false;
    if (_type == _AccountType.legal) {
      if (_innCtrl.text.trim().length < 9) return false;
      if (_directorCtrl.text.trim().length < 2) return false;
    }
    return true;
  }

  Future<void> _submit() async {
    if (!_formValid) {
      AppToast.show(context,
          message: 'Iltimos, barcha majburiy maydonlarni to\'ldiring',
          kind: ToastKind.warning);
      return;
    }
    setState(() => _submitting = true);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    // Persist profile so router redirect lets us into home
    await ProfileStore.instance.save(
      fullName: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      bio: _bioCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      avatar: _avatar,
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    AppToast.show(context,
        message: 'Ro\'yxatdan o\'tildi! Bosh sahifaga o\'tilmoqda.',
        kind: ToastKind.success);
    Future<void>.delayed(const Duration(milliseconds: 600), () {
      if (mounted) context.go('/');
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLegal = _type == _AccountType.legal;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    children: [
                      _IconBtn(
                        icon: Iconsax.arrow_left_2,
                        onTap: () => context.canPop() ? context.pop() : context.go('/login'),
                      ),
                      const Spacer(),
                      const Text(
                        'Ro\'yxatdan o\'tish',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: _ink,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 44),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Type segmented
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: _surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: _line),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _SegBtn(
                                  icon: Iconsax.user_copy,
                                  label: 'Jismoniy shaxs',
                                  active: !isLegal,
                                  onTap: () => setState(() => _type = _AccountType.individual),
                                ),
                              ),
                              Expanded(
                                child: _SegBtn(
                                  icon: Iconsax.building_4_copy,
                                  label: 'Yuridik shaxs',
                                  active: isLegal,
                                  onTap: () => setState(() => _type = _AccountType.legal),
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(duration: 250.ms),
                        const SizedBox(height: 24),

                        // Avatar / Logo upload
                        Center(
                          child: _AvatarPicker(
                            file: _avatar,
                            isLegal: isLegal,
                            onTap: () => _pick(true),
                            onRemove: () => setState(() => _avatar = null),
                          ),
                        ).animate().fadeIn(delay: 60.ms),
                        const SizedBox(height: 8),
                        Text(
                          isLegal ? 'Kompaniya logotipi' : 'Profil rasmingiz',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 12, color: _muted, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 28),

                        // Common fields
                        _Field(
                          label: isLegal ? 'Kompaniya nomi' : 'F.I.O',
                          hint: isLegal ? 'TransCargo MChJ' : 'Otabek Karimov',
                          icon: isLegal ? Iconsax.building_copy : Iconsax.user_copy,
                          controller: _nameCtrl,
                          required: true,
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 14),
                        _Field(
                          label: 'Bio / Ma\'lumot',
                          hint: isLegal
                              ? 'Kompaniya faoliyati haqida qisqacha'
                              : 'O\'zingiz haqingizda bir-ikki gap',
                          icon: Iconsax.note_text_copy,
                          controller: _bioCtrl,
                          maxLines: 4,
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 14),
                        _Field(
                          label: 'Email',
                          hint: 'name@example.com',
                          icon: Iconsax.sms_copy,
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 14),
                        _Field(
                          label: 'Manzil',
                          hint: 'Toshkent sh., Yunusobod tumani, ...',
                          icon: Iconsax.location_copy,
                          controller: _addressCtrl,
                          onChanged: (_) => setState(() {}),
                        ),

                        // Legal-only block
                        AnimatedSize(
                          duration: const Duration(milliseconds: 280),
                          curve: Curves.easeOut,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            transitionBuilder: (c, a) =>
                                FadeTransition(opacity: a, child: c),
                            child: isLegal
                                ? Column(
                                    key: const ValueKey('legal'),
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      const SizedBox(height: 22),
                                      const _SectionTitle(
                                          icon: Iconsax.briefcase_copy,
                                          label: 'Yuridik ma\'lumotlar'),
                                      const SizedBox(height: 12),
                                      _Field(
                                        label: 'STIR (INN)',
                                        hint: '309876543',
                                        icon: Iconsax.hashtag_copy,
                                        controller: _innCtrl,
                                        keyboardType: TextInputType.number,
                                        required: true,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly,
                                          LengthLimitingTextInputFormatter(12),
                                        ],
                                        onChanged: (_) => setState(() {}),
                                      ),
                                      const SizedBox(height: 14),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _Field(
                                              label: 'MFO',
                                              hint: '00440',
                                              icon: Iconsax.bank_copy,
                                              controller: _mfoCtrl,
                                              keyboardType: TextInputType.number,
                                              inputFormatters: [
                                                FilteringTextInputFormatter.digitsOnly,
                                                LengthLimitingTextInputFormatter(5),
                                              ],
                                              onChanged: (_) => setState(() {}),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            flex: 2,
                                            child: _Field(
                                              label: 'Bank nomi',
                                              hint: 'Asaka Bank',
                                              icon: Iconsax.card_copy,
                                              controller: _bankCtrl,
                                              onChanged: (_) => setState(() {}),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 14),
                                      _Field(
                                        label: 'Direktor F.I.O',
                                        hint: 'Karimov Otabek',
                                        icon: Iconsax.user_tick_copy,
                                        controller: _directorCtrl,
                                        required: true,
                                        onChanged: (_) => setState(() {}),
                                      ),
                                    ],
                                  )
                                : const SizedBox.shrink(key: ValueKey('none')),
                          ),
                        ),

                        const SizedBox(height: 22),

                        // Document upload
                        _SectionTitle(
                          icon: Iconsax.document_copy,
                          label: isLegal ? 'Tashkilot guvohnomasi' : 'Pasport / ID',
                        ),
                        const SizedBox(height: 10),
                        _DocumentTile(
                          file: _document,
                          onTap: () => _pick(false),
                          onRemove: () => setState(() => _document = null),
                        ),

                        const SizedBox(height: 22),

                        // Agreement
                        _AgreeRow(value: _agree, onChanged: (v) => setState(() => _agree = v)),

                        const SizedBox(height: 24),

                        // Submit
                        _PrimaryButton(
                          loading: _submitting,
                          enabled: true,
                          label: 'Ro\'yxatdan o\'tish',
                          onTap: _submit,
                        ),
                        const SizedBox(height: 14),
                        Center(
                          child: Text(
                            isLegal
                                ? 'Yuridik shaxslar uchun moderatsiya 24 soatgacha davom etishi mumkin'
                                : 'Hisobingiz darhol faollashadi',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: _muted.withOpacity(0.9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
class _IconBtn extends StatelessWidget {
  const _IconBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: _surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _line),
          ),
          child: Icon(icon, size: 20, color: _ink),
        ),
      ),
    );
  }
}

class _SegBtn extends StatelessWidget {
  const _SegBtn({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: active ? _brand : _muted),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: active ? _ink : _muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.label});
  final IconData icon;
  final String label;
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
          child: Icon(icon, size: 16, color: _brand),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: _ink,
          ),
        ),
      ],
    );
  }
}

class _Field extends StatefulWidget {
  const _Field({
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    this.maxLines = 1,
    this.keyboardType,
    this.required = false,
    this.inputFormatters,
    this.onChanged,
  });
  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final int maxLines;
  final TextInputType? keyboardType;
  final bool required;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
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
    final focused = _focus.hasFocus;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: RichText(
            text: TextSpan(
              text: widget.label,
              style: const TextStyle(
                  fontSize: 12.5, fontWeight: FontWeight.w700, color: _ink),
              children: widget.required
                  ? const [
                      TextSpan(
                          text: '  *',
                          style: TextStyle(color: Color(0xFFEF4444))),
                    ]
                  : const [],
            ),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: focused ? Colors.white : _surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: focused ? _brand : _line, width: focused ? 1.5 : 1),
            boxShadow: focused
                ? [
                    BoxShadow(
                      color: _brand.withOpacity(0.10),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Icon(widget.icon, size: 18, color: focused ? _brand : _muted),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focus,
                  maxLines: widget.maxLines,
                  keyboardType: widget.keyboardType,
                  inputFormatters: widget.inputFormatters,
                  onChanged: widget.onChanged,
                  style: const TextStyle(
                      fontSize: 14.5, fontWeight: FontWeight.w600, color: _ink),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    hintText: widget.hint,
                    hintStyle: const TextStyle(
                      color: Color(0xFFCBD5E1),
                      fontWeight: FontWeight.w500,
                    ),
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

class _AvatarPicker extends StatelessWidget {
  const _AvatarPicker({
    required this.file,
    required this.isLegal,
    required this.onTap,
    required this.onRemove,
  });
  final XFile? file;
  final bool isLegal;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  @override
  Widget build(BuildContext context) {
    final radius = isLegal ? 22.0 : 60.0;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(color: _line, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: _brand.withOpacity(0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: file == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isLegal ? Iconsax.gallery_add_copy : Iconsax.camera_copy,
                        size: 28,
                        color: _muted,
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Yuklash',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: _muted),
                      ),
                    ],
                  )
                : _ImagePreview(file: file!),
          ),
        ),
        Positioned(
          right: -4,
          bottom: -4,
          child: GestureDetector(
            onTap: file == null ? onTap : onRemove,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: file == null ? _brand : const Color(0xFFEF4444),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                file == null ? Iconsax.add : Iconsax.trash,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({required this.file});
  final XFile file;
  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Image.network(file.path, fit: BoxFit.cover);
    }
    return Image.file(File(file.path), fit: BoxFit.cover);
  }
}

class _DocumentTile extends StatelessWidget {
  const _DocumentTile({
    required this.file,
    required this.onTap,
    required this.onRemove,
  });
  final XFile? file;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  @override
  Widget build(BuildContext context) {
    final picked = file != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: picked ? _brand.withOpacity(0.04) : _surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: picked ? _brand.withOpacity(0.4) : _line,
            width: picked ? 1.5 : 1,
            style: picked ? BorderStyle.solid : BorderStyle.solid,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: (picked ? _brand : _muted).withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                picked ? Iconsax.document_text_copy : Iconsax.document_upload_copy,
                size: 22,
                color: picked ? _brand : _muted,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    picked ? 'Fayl tanlandi' : 'Hujjat yuklash',
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w800, color: _ink),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    picked
                        ? (file!.name.length > 30
                            ? '${file!.name.substring(0, 30)}…'
                            : file!.name)
                        : 'JPG, PNG yoki PDF formatida (maks. 10MB)',
                    style: const TextStyle(fontSize: 12, color: _muted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (picked)
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Iconsax.close_circle_copy,
                    color: Color(0xFFEF4444), size: 22),
              )
            else
              const Icon(Iconsax.arrow_right_3_copy, size: 18, color: _muted),
          ],
        ),
      ),
    );
  }
}

class _AgreeRow extends StatelessWidget {
  const _AgreeRow({required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      behavior: HitTestBehavior.opaque,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: value ? _brand : Colors.white,
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: value ? _brand : _line, width: 1.5),
            ),
            child: value
                ? const Icon(Iconsax.tick_circle, size: 14, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 2),
              child: Text.rich(
                TextSpan(
                  style: TextStyle(
                      fontSize: 12.5, color: _muted, fontWeight: FontWeight.w500, height: 1.4),
                  children: [
                    TextSpan(text: 'Men '),
                    TextSpan(
                        text: 'foydalanish shartlari',
                        style: TextStyle(color: _brand, fontWeight: FontWeight.w800)),
                    TextSpan(text: ' va '),
                    TextSpan(
                        text: 'maxfiylik siyosati',
                        style: TextStyle(color: _brand, fontWeight: FontWeight.w800)),
                    TextSpan(text: 'ga roziman'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatefulWidget {
  const _PrimaryButton({
    required this.loading,
    required this.enabled,
    required this.label,
    required this.onTap,
  });
  final bool loading;
  final bool enabled;
  final String label;
  final VoidCallback onTap;

  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<_PrimaryButton> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) {
    final disabled = widget.loading || !widget.enabled;
    return AnimatedScale(
      scale: _pressed && !disabled ? 0.98 : 1,
      duration: const Duration(milliseconds: 110),
      child: Container(
        height: 58,
        decoration: BoxDecoration(
          color: disabled ? _ink.withOpacity(0.12) : _brand,
          borderRadius: BorderRadius.circular(16),
          boxShadow: disabled
              ? null
              : [
                  BoxShadow(
                    color: _brand.withOpacity(0.32),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: disabled ? null : widget.onTap,
            onTapDown: (_) => setState(() => _pressed = true),
            onTapCancel: () => setState(() => _pressed = false),
            onTapUp: (_) => setState(() => _pressed = false),
            borderRadius: BorderRadius.circular(16),
            child: Center(
              child: widget.loading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.4, color: Colors.white),
                    )
                  : Text(
                      widget.label,
                      style: TextStyle(
                        color: disabled ? _muted : Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
