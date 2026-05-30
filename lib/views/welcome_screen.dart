import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/auth_model.dart';

class WelcomeView extends StatefulWidget {
  const WelcomeView({super.key});

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView>
    with TickerProviderStateMixin {
  late AnimationController _contentCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    _contentCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnim =
        CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOut);

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOutCubic));

    Future.delayed(const Duration(milliseconds: 300), () {
      _contentCtrl.forward();
    });

    _checkAutoLogin();
  }

  Future<void> _checkAutoLogin() async {
    bool loggedIn = await AuthModel.isLoggedIn();
    if (loggedIn && mounted) {
      AuthModel user = await AuthModel.getFromPrefs();
      if (user.role == 'ADMIN') {
        Navigator.pushReplacementNamed(context, '/dashboard-admin');
      } else if (user.role == 'CUSTOMER') {
        Navigator.pushReplacementNamed(context, '/dashboard-customer');
      }
    }
  }

  @override
  void dispose() {
    _contentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ── Wave background bottom ──────────────────────────
          

          // ── Main content ────────────────────────────────────
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: size.height * 0.15),

                      // ── Logo / maskot ───────────────────────
                      Image.asset(
                        'assets/maskot.png',
                        height: size.height * 0.33,
                        errorBuilder: (_, __, ___) =>
                            const _PlaceholderMaskot(),
                      ),

                      const SizedBox(height: 30),

                      // ── App name ────────────────────────────
                      RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'Selamat datang\ndi ',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF2D3748),
                                height: 1.4,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            TextSpan(
                              text: 'Amerta',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: Color.fromARGB(255, 33, 172, 145),
                                fontFamily: 'Poppins',
                              ),
                            ),
                            TextSpan(
                              text: 'Pay',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: Color.fromARGB(255, 0, 208, 255),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        'Hadir untuk Mempermudah Pembayaran\nAir Anda dengan Lebih Praktis dan Efisien.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                          height: 1.6,
                        ),
                      ),

                      const Spacer(),

                      // ── Mulai button ─────────────────────────
                      _GradientButton(
                        label: 'Mulai',
                        onTap: () =>
                            Navigator.pushNamed(context, '/role-picker'),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
    }

// ─── Gradient button ────────────────────────────────────────────
class _GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _GradientButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color.fromARGB(255, 11, 162, 132), Color.fromARGB(255, 11, 162, 132)],
          ),
          borderRadius: BorderRadius.circular(16),
          // boxShadow: [
          //   BoxShadow(
          //     color: Color.fromARGB(255, 33, 172, 145).withOpacity(0.4),
          //     blurRadius: 16,
          //     offset: const Offset(0, 6),
          //   ),
          // ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_rounded,
                color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }
}

// ─── Placeholder maskot ──────────────────────────────────────────
class _PlaceholderMaskot extends StatelessWidget {
  const _PlaceholderMaskot();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color.fromARGB(255, 33, 172, 145), Color.fromARGB(255, 0, 208, 255)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(255, 33, 172, 145).withOpacity(0.35),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Icon(Icons.water_drop_rounded, size: 70, color: Colors.white),
    );
  }
}