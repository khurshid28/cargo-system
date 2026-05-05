import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

const _brand = Color(0xFF1670F5);
const _brandDeep = Color(0xFF0B4FB8);
const _purple = Color(0xFF7C3AED);

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_brandDeep, _brand, _purple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // decorative blobs
            Positioned(
              top: -80, left: -60,
              child: _Blob(color: Colors.white.withOpacity(0.08), size: 240),
            ),
            Positioned(
              bottom: -60, right: -40,
              child: _Blob(color: Colors.white.withOpacity(0.06), size: 200),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // pulsing halo + logo
                  SizedBox(
                    width: 140, height: 140,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 140, height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.10),
                          ),
                        ).animate(onPlay: (c) => c.repeat()).scale(
                              duration: 1800.ms,
                              begin: const Offset(0.85, 0.85),
                              end: const Offset(1.05, 1.05),
                              curve: Curves.easeInOut,
                            ).then().scale(
                              duration: 1800.ms,
                              begin: const Offset(1.05, 1.05),
                              end: const Offset(0.85, 0.85),
                              curve: Curves.easeInOut,
                            ),
                        Container(
                          width: 96, height: 96,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 24, offset: const Offset(0, 8)),
                            ],
                          ),
                          child: const Icon(Iconsax.truck_fast_copy, color: _brand, size: 44),
                        ).animate().scale(
                              duration: 500.ms,
                              begin: const Offset(0.4, 0.4),
                              curve: Curves.easeOutBack,
                            ).fadeIn(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Cargo Sender',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ).animate().fadeIn(delay: 200.ms, duration: 500.ms).slideY(begin: 0.2),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.25)),
                    ),
                    child: const Text(
                      'SENDER',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        letterSpacing: 3,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ).animate().fadeIn(delay: 350.ms),
                  const SizedBox(height: 36),
                  SizedBox(
                    width: 38, height: 38,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation(Colors.white.withOpacity(0.9)),
                    ),
                  ).animate().fadeIn(delay: 500.ms),
                ],
              ),
            ),
            Positioned(
              left: 0, right: 0, bottom: 28,
              child: Center(
                child: Text(
                  'Yuk yuborish — bir tugma narida',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ).animate().fadeIn(delay: 700.ms, duration: 500.ms),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.color, required this.size});
  final Color color;
  final double size;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
