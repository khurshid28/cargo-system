import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../bloc/auth_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _phoneCtrl = TextEditingController(text: '+998901234567');
  final _otpCtrl = TextEditingController();
  static const _role = 'SENDER';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          final loading = state is AuthLoading;
          final otpStep = state is AuthOtpSent;
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 60),
                  Icon(Iconsax.truck_fast_copy, size: 64, color: Theme.of(context).colorScheme.primary)
                      .animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.8, 0.8)),
                  const SizedBox(height: 12),
                  const Text('TransCargo Sender',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('Yuk yuborish uchun tizimga kiring',
                      textAlign: TextAlign.center, style: TextStyle(color: Colors.black54)),
                  const SizedBox(height: 40),
                  TextField(
                    controller: _phoneCtrl,
                    enabled: !otpStep,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Telefon',
                      prefixIcon: Icon(Iconsax.call_copy),
                    ),
                  ),
                  if (otpStep) ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: _otpCtrl,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      decoration: const InputDecoration(
                        labelText: 'OTP (test: 666666)',
                        prefixIcon: Icon(Iconsax.password_check_copy),
                      ),
                    ).animate().slideY(begin: 0.2, duration: 250.ms),
                  ],
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: loading
                        ? null
                        : () {
                            if (otpStep) {
                              context.read<AuthBloc>().add(AuthOtpVerified(
                                    phone: _phoneCtrl.text.trim(),
                                    otp: _otpCtrl.text.trim(),
                                    role: _role,
                                  ));
                            } else {
                              context.read<AuthBloc>().add(
                                    AuthOtpRequested(phone: _phoneCtrl.text.trim(), role: _role),
                                  );
                            }
                          },
                    child: loading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(otpStep ? 'Tasdiqlash' : 'OTP yuborish'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
