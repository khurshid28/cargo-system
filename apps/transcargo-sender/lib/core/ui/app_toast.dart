import 'dart:async';

import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

enum ToastKind { success, error, info, warning }

class AppToast {
  AppToast._();
  static OverlayEntry? _entry;
  static Timer? _timer;

  static void show(
    BuildContext context, {
    required String message,
    ToastKind kind = ToastKind.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;
    _entry?.remove();
    _timer?.cancel();

    final entry = OverlayEntry(
      builder: (_) => _ToastWidget(
        message: message,
        kind: kind,
        onDismiss: dismiss,
      ),
    );
    _entry = entry;
    overlay.insert(entry);

    _timer = Timer(duration, dismiss);
  }

  static void dismiss() {
    _timer?.cancel();
    _timer = null;
    _entry?.remove();
    _entry = null;
  }
}

class _ToastWidget extends StatefulWidget {
  const _ToastWidget({required this.message, required this.kind, required this.onDismiss});
  final String message;
  final ToastKind kind;
  final VoidCallback onDismiss;
  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 280));
    _slide = Tween(begin: const Offset(0, -1.2), end: Offset.zero)
        .chain(CurveTween(curve: Curves.easeOutCubic))
        .animate(_ctrl);
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color get _bg {
    switch (widget.kind) {
      case ToastKind.success:
        return const Color(0xFF10B981);
      case ToastKind.error:
        return const Color(0xFFEF4444);
      case ToastKind.warning:
        return const Color(0xFFF59E0B);
      case ToastKind.info:
        return const Color(0xFF1670F5);
    }
  }

  IconData get _icon {
    switch (widget.kind) {
      case ToastKind.success:
        return Iconsax.tick_circle_copy;
      case ToastKind.error:
        return Iconsax.close_circle_copy;
      case ToastKind.warning:
        return Iconsax.warning_2_copy;
      case ToastKind.info:
        return Iconsax.info_circle_copy;
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return Positioned(
      top: media.padding.top + 12,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _fade,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Material(
                color: Colors.transparent,
                child: GestureDetector(
                  onTap: () async {
                    await _ctrl.reverse();
                    widget.onDismiss();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.10),
                          blurRadius: 22,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: _bg.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(_icon, color: _bg, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.message,
                            style: const TextStyle(
                              color: Color(0xFF0F172A),
                              fontWeight: FontWeight.w700,
                              fontSize: 13.5,
                              height: 1.35,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(width: 4, height: 36, decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(2))),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
