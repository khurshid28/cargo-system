import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../core/ui/app_toast.dart';
import '../bloc/auth_bloc.dart';

const _brand = Color(0xFF1670F5);
const _ink = Color(0xFF0F172A);
const _muted = Color(0xFF64748B);
const _line = Color(0xFFE2E8F0);
const _surface = Color(0xFFF8FAFC);

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _phoneCtrl = TextEditingController(text: '+998 ');
  final _otpCtrls = List.generate(6, (_) => TextEditingController());
  final _otpFocus = List.generate(6, (_) => FocusNode());
  static const _role = 'SENDER';

  String _lang = 'uz'; // 'uz' | 'ru'
  bool _otpStep = false;
  bool _otpToastShown = false;

  static const Map<String, Map<String, String>> _i18n = {
    'welcome':       {'uz': 'Xush kelibsiz',         'ru': 'Добро пожаловать'},
    'verify_title':  {'uz': 'Tasdiqlash kodi',       'ru': 'Код подтверждения'},
    'welcome_sub':   {'uz': 'Yuk yuborish uchun telefon raqamingizni kiriting',
                      'ru': 'Введите номер телефона, чтобы отправить груз'},
    'sent_to':       {'uz': 'Kod yuborildi: ',       'ru': 'Код отправлен: '},
    'phone_label':   {'uz': 'Telefon raqam',         'ru': 'Номер телефона'},
    'continue':      {'uz': 'Davom etish',           'ru': 'Продолжить'},
    'verify':        {'uz': 'Tasdiqlash',            'ru': 'Подтвердить'},
    'secure':        {'uz': "Ma'lumotlaringiz xavfsiz himoyalangan",
                      'ru': 'Ваши данные надёжно защищены'},
    'resend':        {'uz': 'Kodni qayta yuborish',  'ru': 'Отправить код снова'},
    'resend_in':     {'uz': 'Qayta yuborish ',       'ru': 'Повторно через '},
    'sent_toast':    {'uz': 'Tasdiqlash kodi yuborildi',
                      'ru': 'Код подтверждения отправлен'},
    'fill_phone':    {'uz': "Telefon raqamni to'liq kiriting (+998 XX XXX XX XX)",
                      'ru': 'Введите номер полностью (+998 XX XXX XX XX)'},
    'fill_otp':      {'uz': "6 xonali kodni to'liq kiriting",
                      'ru': 'Введите 6-значный код полностью'},
    'no_account':    {'uz': 'Birinchi marta kirishyapsizmi?',
                      'ru': 'Впервые входите?'},
    'register':      {'uz': "To'liq ro'yxatdan o'tish",
                      'ru': 'Регистрация'},
  };

  String _t(String k) => _i18n[k]![_lang] ?? k;

  // Pretty-print +998901234567 → +998 90 123 45 67
  String _formatE164(String e164) {
    var d = e164.replaceAll(RegExp(r'\D'), '');
    if (d.startsWith('998')) d = d.substring(3);
    if (d.length > 9) d = d.substring(0, 9);
    final b = StringBuffer('+998');
    if (d.isNotEmpty) b.write(' ${d.substring(0, d.length.clamp(0, 2))}');
    if (d.length > 2) b.write(' ${d.substring(2, d.length.clamp(2, 5))}');
    if (d.length > 5) b.write(' ${d.substring(5, d.length.clamp(5, 7))}');
    if (d.length > 7) b.write(' ${d.substring(7, d.length.clamp(7, 9))}');
    return b.toString();
  }

  String get _otp => _otpCtrls.map((c) => c.text).join();
  // Digits-only without country code (998). Need exactly 9 (e.g. 901234567).
  String get _localDigits {
    var d = _phoneCtrl.text.replaceAll(RegExp(r'\D'), '');
    if (d.startsWith('998')) d = d.substring(3);
    return d;
  }
  bool get _phoneValid => _localDigits.length == 9;
  bool get _otpValid => _otp.length == 6;
  String get _e164Phone => '+998$_localDigits';

  @override
  void initState() {
    super.initState();
    for (final f in _otpFocus) {
      f.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    for (final c in _otpCtrls) c.dispose();
    for (final f in _otpFocus) f.dispose();
    super.dispose();
  }

  void _onPhoneChanged(String value) {
    var d = value.replaceAll(RegExp(r'\D'), '');
    if (d.startsWith('998')) d = d.substring(3);
    if (d.length > 9) d = d.substring(0, 9);
    final b = StringBuffer('+998');
    if (d.isNotEmpty) b.write(' ${d.substring(0, d.length.clamp(0, 2))}');
    if (d.length > 2) b.write(' ${d.substring(2, d.length.clamp(2, 5))}');
    if (d.length > 5) b.write(' ${d.substring(5, d.length.clamp(5, 7))}');
    if (d.length > 7) b.write(' ${d.substring(7, d.length.clamp(7, 9))}');
    final formatted = b.toString();
    _phoneCtrl.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
    setState(() {});
  }

  void _clearOtp() {
    for (final c in _otpCtrls) c.clear();
    if (_otpFocus.isNotEmpty) _otpFocus[0].requestFocus();
    setState(() {});
  }

  void _submit(BuildContext context, AuthState state) {
    final isOtpStep = _otpStep || state is AuthOtpSent;
    if (isOtpStep) {
      if (!_otpValid) {
        AppToast.show(context, message: _t('fill_otp'), kind: ToastKind.warning);
        return;
      }
      context.read<AuthBloc>().add(AuthOtpVerified(
            phone: _e164Phone,
            otp: _otp,
            role: _role,
          ));
    } else {
      if (!_phoneValid) {
        AppToast.show(context, message: _t('fill_phone'), kind: ToastKind.warning);
        return;
      }
      context.read<AuthBloc>().add(
            AuthOtpRequested(phone: _e164Phone, role: _role),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthOtpSent) {
            if (!_otpStep) setState(() => _otpStep = true);
            final showToast = !_otpToastShown;
            _otpToastShown = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              if (showToast) {
                AppToast.show(context,
                    message: _t('sent_toast'), kind: ToastKind.success);
              }
              if (_otpFocus.isNotEmpty) _otpFocus[0].requestFocus();
            });
          } else if (state is AuthError) {
            _clearOtp();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              AppToast.show(context,
                  message: state.message, kind: ToastKind.error);
            });
          } else if (state is AuthUnauthenticated) {
            if (_otpStep) setState(() => _otpStep = false);
            _otpToastShown = false;
          }
        },
        builder: (context, state) {
          final loading = state is AuthLoading;
          // Derive from state too so UI reflects bloc immediately.
          final otpStep = _otpStep || state is AuthOtpSent;
          return SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Top bar — back arrow on OTP step
                      SizedBox(
                        height: 44,
                        child: Row(
                          children: [
                            if (otpStep)
                              _IconBtn(
                                icon: Iconsax.arrow_left_2,
                                onTap: loading
                                    ? null
                                    : () {
                                        _clearOtp();
                                        _otpToastShown = false;
                                        setState(() => _otpStep = false);
                                        // Reset bloc state so derived otpStep also turns false.
                                        context
                                            .read<AuthBloc>()
                                            .add(const AuthSignOutRequested());
                                      },
                              )
                            else
                              const SizedBox(width: 44),
                            const Spacer(),
                            _LangSwitcher(
                              lang: _lang,
                              onChanged: (v) => setState(() => _lang = v),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Logo (centered, fixed size; parent uses stretch)
                      Center(
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: _brand,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: _brand.withOpacity(0.28),
                                blurRadius: 22,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(Iconsax.truck_fast_copy,
                              color: Colors.white, size: 34),
                        )
                            .animate(key: ValueKey(otpStep))
                            .scale(duration: 350.ms, curve: Curves.easeOutBack)
                            .fadeIn(),
                      ),
                      const SizedBox(height: 24),

                      // Title + subtitle
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: Column(
                          key: ValueKey('$otpStep-$_lang'),
                          children: [
                            Text(
                              otpStep ? _t('verify_title') : _t('welcome'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: _ink,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: _muted,
                                    fontWeight: FontWeight.w500,
                                    height: 1.5,
                                  ),
                                  children: otpStep
                                      ? [
                                          TextSpan(text: _t('sent_to')),
                                          TextSpan(
                                            text: state is AuthOtpSent
                                                ? _formatE164(state.phone)
                                                : _phoneCtrl.text,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w800, color: _ink),
                                          ),
                                        ]
                                      : [
                                          TextSpan(text: _t('welcome_sub')),
                                        ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 36),

                      // Input
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 280),
                        transitionBuilder: (c, a) => FadeTransition(
                            opacity: a,
                            child: SlideTransition(
                              position: Tween(
                                      begin: const Offset(0.05, 0),
                                      end: Offset.zero)
                                  .animate(a),
                              child: c,
                            )),
                        child: otpStep
                            ? _OtpRow(
                                key: const ValueKey('otp'),
                                controllers: _otpCtrls,
                                focusNodes: _otpFocus,
                                onChanged: () => setState(() {}),
                                onCompleted: () => _submit(context, state),
                              )
                            : _PhoneField(
                                key: const ValueKey('phone'),
                                controller: _phoneCtrl,
                                onChanged: _onPhoneChanged,
                              ),
                      ),
                      const SizedBox(height: 28),

                      // Primary button — always tappable so we can warn via toast
                      _PrimaryButton(
                        loading: loading,
                        enabled: true,
                        label: otpStep ? _t('verify') : _t('continue'),
                        onTap: () => _submit(context, state),
                      ),

                      // Resend timer (OTP step)
                      if (otpStep) ...[
                        const SizedBox(height: 20),
                        _ResendTimer(
                          key: const ValueKey('resend'),
                          resendLabel: _t('resend'),
                          countdownLabel: _t('resend_in'),
                          onResend: () {
                            _clearOtp();
                            context.read<AuthBloc>().add(AuthOtpRequested(
                                phone: _phoneCtrl.text.replaceAll(' ', ''),
                                role: _role));
                          },
                        ),
                      ],

                      const SizedBox(height: 32),

                      // Footer
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Iconsax.shield_tick_copy,
                              size: 14, color: _muted),
                          const SizedBox(width: 6),
                          Text(
                            _t('secure'),
                            style: TextStyle(
                              fontSize: 12,
                              color: _muted.withOpacity(0.9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
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

// ─────────────────────────────────────────────────────────────────
class _PhoneField extends StatefulWidget {
  const _PhoneField({super.key, required this.controller, required this.onChanged});
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  @override
  State<_PhoneField> createState() => _PhoneFieldState();
}

class _PhoneFieldState extends State<_PhoneField> {
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
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Telefon raqam',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _ink),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: focused ? Colors.white : _surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: focused ? _brand : _line, width: focused ? 1.5 : 1),
            boxShadow: focused
                ? [BoxShadow(color: _brand.withOpacity(0.10), blurRadius: 14, offset: const Offset(0, 4))]
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(Iconsax.call_calling_copy, size: 16, color: _brand),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focus,
                  keyboardType: TextInputType.phone,
                  autofocus: true,
                  onChanged: widget.onChanged,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d+ ]')),
                    LengthLimitingTextInputFormatter(17),
                  ],
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: _ink,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 18),
                    hintText: '+998 90 123 45 67',
                    hintStyle: TextStyle(
                        color: Color(0xFFCBD5E1),
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5),
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

// ─────────────────────────────────────────────────────────────────
class _OtpRow extends StatelessWidget {
  const _OtpRow({
    super.key,
    required this.controllers,
    required this.focusNodes,
    required this.onChanged,
    required this.onCompleted,
  });
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final VoidCallback onChanged;
  final VoidCallback onCompleted;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      const gap = 10.0;
      final cellW = ((c.maxWidth - gap * 5) / 6).clamp(38.0, 56.0);
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(6, (i) {
          final filled = controllers[i].text.isNotEmpty;
          final focused = focusNodes[i].hasFocus;
          return Padding(
            padding: EdgeInsets.only(left: i == 0 ? 0 : gap),
            child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            width: cellW,
            height: cellW * 1.25,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: focused
                    ? _brand
                    : filled
                        ? _ink.withOpacity(0.20)
                        : _line,
                width: focused ? 1.6 : 1,
              ),
              boxShadow: focused
                  ? [BoxShadow(color: _brand.withOpacity(0.12), blurRadius: 12, offset: const Offset(0, 4))]
                  : null,
            ),
            alignment: Alignment.center,
            child: TextField(
              controller: controllers[i],
              focusNode: focusNodes[i],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 1,
              showCursor: true,
              cursorColor: _brand,
              cursorWidth: 2,
              cursorHeight: 22,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: _ink,
                height: 1.1,
              ),
              decoration: const InputDecoration(
                counterText: '',
                border: InputBorder.none,
                isCollapsed: true,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (v) {
                if (v.isNotEmpty && i < 5) {
                  focusNodes[i + 1].requestFocus();
                } else if (v.isEmpty && i > 0) {
                  focusNodes[i - 1].requestFocus();
                }
                onChanged();
                if (controllers.every((c) => c.text.isNotEmpty)) onCompleted();
              },
            ),
          ),
          ).animate(delay: (i * 50).ms).fadeIn(duration: 220.ms).scale(begin: const Offset(0.8, 0.8));
        }),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────
class _ResendTimer extends StatefulWidget {
  const _ResendTimer({
    super.key,
    required this.onResend,
    required this.resendLabel,
    required this.countdownLabel,
  });
  final VoidCallback onResend;
  final String resendLabel;
  final String countdownLabel;
  @override
  State<_ResendTimer> createState() => _ResendTimerState();
}

class _ResendTimerState extends State<_ResendTimer> {
  static const _total = 120;
  int _seconds = _total;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _start();
  }

  void _start() {
    _timer?.cancel();
    setState(() => _seconds = _total);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_seconds <= 0) {
        t.cancel();
        return;
      }
      setState(() => _seconds--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _mmss {
    final m = (_seconds ~/ 60).toString().padLeft(2, '0');
    final s = (_seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final ready = _seconds == 0;
    final progress = ready ? 1.0 : (_total - _seconds) / _total;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: ready
          ? _ResendReady(
              key: const ValueKey('ready'),
              label: widget.resendLabel,
              onTap: () {
                _start();
                widget.onResend();
              },
            )
          : _ResendCounting(
              key: const ValueKey('counting'),
              label: widget.countdownLabel,
              mmss: _mmss,
              progress: progress,
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
class _ResendReady extends StatelessWidget {
  const _ResendReady({super.key, required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_brand.withOpacity(0.10), _brand.withOpacity(0.04)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _brand.withOpacity(0.25)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: _brand,
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: [
                    BoxShadow(
                      color: _brand.withOpacity(0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Iconsax.refresh_copy,
                    size: 15, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  color: _brand,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResendCounting extends StatelessWidget {
  const _ResendCounting({
    super.key,
    required this.label,
    required this.mmss,
    required this.progress,
  });
  final String label;
  final String mmss;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _line),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Animated ring with seconds inside
          SizedBox(
            width: 36,
            height: 36,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 36,
                  height: 36,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: progress, end: progress),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    builder: (_, v, __) => CircularProgressIndicator(
                      strokeWidth: 3,
                      value: v,
                      backgroundColor: _line,
                      valueColor: const AlwaysStoppedAnimation(_brand),
                    ),
                  ),
                ),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: _brand,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: _muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  mmss,
                  style: const TextStyle(
                    fontSize: 18,
                    color: _ink,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _line),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Iconsax.message_copy, size: 12, color: _muted),
                SizedBox(width: 5),
                Text(
                  'SMS',
                  style: TextStyle(
                    fontSize: 10.5,
                    color: _muted,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
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

// ─────────────────────────────────────────────────────────────────
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
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
                  ? const _DotsLoader()
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

// 3-dot bouncing loader for the primary button
class _DotsLoader extends StatelessWidget {
  const _DotsLoader();
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .moveY(
                begin: 0,
                end: -6,
                duration: 420.ms,
                curve: Curves.easeInOut,
                delay: (i * 120).ms,
              ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Language switcher: UZ / RU pill toggle
class _LangSwitcher extends StatelessWidget {
  const _LangSwitcher({required this.lang, required this.onChanged});
  final String lang;
  final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _seg('UZ', lang == 'uz'),
          _seg('RU', lang == 'ru'),
        ],
      ),
    );
  }

  Widget _seg(String code, bool active) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(code.toLowerCase()),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? _brand : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: _brand.withOpacity(0.30),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          code,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
            color: active ? Colors.white : _muted,
          ),
        ),
      ),
    );
  }
}