import 'dart:math' as math;
import 'package:amerta_pay/views/welcome_screen.dart';
import 'package:flutter/material.dart';

/// ============================================================
///  CARA PENGGUNAAN:
///  1. Letakkan file logo kamu di: assets/images/logo.png
///  2. Tambahkan di pubspec.yaml:
///       flutter:
///         assets:
///           - assets/images/logo.png
///  3. Panggil SplashScreen() sebagai route pertama di MaterialApp
/// ============================================================

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AmertaPay',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF26C6A6)),
      ),
      home: const SplashScreen(),
    );
  }
}

// ─────────────────────────────────────────────
//  SPLASH SCREEN
// ─────────────────────────────────────────────
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Wave animation controllers
  late AnimationController _wave1Controller;
  late AnimationController _wave2Controller;
  late AnimationController _wave3Controller;

  // Background fill controller (teal → white)
  late AnimationController _fillController;
  late Animation<double> _fillAnimation;

  // Logo & tagline fade-in
  late AnimationController _logoController;
  late Animation<double> _logoFade;
  late Animation<Offset> _logoSlide;

  // Wave rise animation
  late AnimationController _riseController;
  late Animation<double> _riseAnimation;

  @override
  void initState() {
    super.initState();

    // ── Wave oscillation ──────────────────────────────────────
    _wave1Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();

    _wave2Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3400),
    )..repeat();

    _wave3Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    // ── Background fill: solid teal → reveal white ────────────
    _fillController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fillAnimation = CurvedAnimation(
      parent: _fillController,
      curve: Curves.easeInOut,
    );

    // ── Wave rise from bottom ──────────────────────────────────
    _riseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _riseAnimation = CurvedAnimation(
      parent: _riseController,
      curve: Curves.easeOutCubic,
    );

    // ── Logo fade + slide ──────────────────────────────────────
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _logoFade = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeIn,
    );
    _logoSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOutCubic,
    ));

    // ── Sequence ──────────────────────────────────────────────
    _runSequence();
  }

  Future<void> _runSequence() async {
    // Phase 1: solid teal background (already there by default)
    await Future.delayed(const Duration(milliseconds: 400));

    // Phase 2: background transitions to white
    _fillController.forward();
    await Future.delayed(const Duration(milliseconds: 600));

    // Phase 3: waves rise from bottom
    _riseController.forward();
    await Future.delayed(const Duration(milliseconds: 800));

    // Phase 4: logo appears
    _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 1200));

    //Phase 5: Navigate to main screen (uncomment & replace route)
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WelcomeView()),
      );
    }
  }

  @override
  void dispose() {
    _wave1Controller.dispose();
    _wave2Controller.dispose();
    _wave3Controller.dispose();
    _fillController.dispose();
    _riseController.dispose();
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _fillAnimation,
          _wave1Controller,
          _wave2Controller,
          _wave3Controller,
          _riseAnimation,
        ]),
        builder: (context, child) {
          return Stack(
            children: [
              // ── Background: teal → white ──────────────────────
              Container(
                color: Color.lerp(
                  const Color(0xFF26C6A6),
                  Colors.white,
                  _fillAnimation.value,
                ),
              ),

              // ── Wave layer 3 (back / darkest teal) ────────────
              _WavePainter(
                controller: _wave3Controller,
                phase: 0.0,
                amplitude: 18,
                color: const Color.fromARGB(255, 38, 131, 198).withOpacity(0.55),
                verticalOffset: _riseAnimation.value,
                yBase: 0.82,
                speed: 0.8,
              ),

              // ── Wave layer 2 (mid / sky blue) ─────────────────
              _WavePainter(
                controller: _wave2Controller,
                phase: math.pi * 0.7,
                amplitude: 22,
                color: const Color(0xFF72D8EF).withOpacity(0.70),
                verticalOffset: _riseAnimation.value,
                yBase: 0.855,
                speed: 1.0,
              ),

              // ── Wave layer 1 (front / bright teal) ────────────
              _WavePainter(
                controller: _wave1Controller,
                phase: math.pi * 1.3,
                amplitude: 16,
                color: const Color.fromARGB(255, 38, 198, 179),
                verticalOffset: _riseAnimation.value,
                yBase: 0.89,
                speed: 1.2,
              ),

              // ── Logo + Tagline ─────────────────────────────────
              child!,
            ],
          );
        },
        child: _buildLogo(),
      ),
    );
  }

  Widget _buildLogo() {
    return Align(
      alignment: const Alignment(0, -0.15),
      child: FadeTransition(
        opacity: _logoFade,
        child: SlideTransition(
          position: _logoSlide,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Logo image ─────────────────────────────────────
              // Ganti dengan path logo kamu. Pastikan sudah terdaftar
              // di pubspec.yaml pada bagian assets.
              Image.asset(
                'assets/logo.png',
                width: 170,
                height: 170,
                // Jika logo belum ada, gunakan placeholder di bawah:
                errorBuilder: (context, error, stackTrace) =>
                    _PlaceholderLogo(),
              ),

              const SizedBox(height: 15),

              // ── App name ───────────────────────────────────────
              

              const SizedBox(height: 6),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  WAVE PAINTER WIDGET
// ─────────────────────────────────────────────
class _WavePainter extends StatelessWidget {
  final AnimationController controller;
  final double phase;
  final double amplitude;
  final Color color;
  final double verticalOffset; // 0..1
  final double yBase;          // 0..1 dari atas layar
  final double speed;

  const _WavePainter({
    required this.controller,
    required this.phase,
    required this.amplitude,
    required this.color,
    required this.verticalOffset,
    required this.yBase,
    required this.speed,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _WaveCustomPainter(
            progress: controller.value,
            phase: phase,
            amplitude: amplitude,
            color: color,
            // Mulai dari bawah layar, naik ke yBase saat riseOffset → 1
            yFraction: 1.0 - verticalOffset * (1.0 - yBase),
            speed: speed,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _WaveCustomPainter extends CustomPainter {
  final double progress;
  final double phase;
  final double amplitude;
  final Color color;
  final double yFraction;
  final double speed;

  _WaveCustomPainter({
    required this.progress,
    required this.phase,
    required this.amplitude,
    required this.color,
    required this.yFraction,
    required this.speed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();

    final double baseY = size.height * yFraction;
    final double shiftX = progress * size.width * 2 * speed;

    path.moveTo(0, size.height);

    for (double x = 0; x <= size.width; x++) {
      final double y = baseY +
          math.sin((x + shiftX) / size.width * 2 * math.pi + phase) *
              amplitude +
          math.sin((x + shiftX * 0.6) / size.width * 3 * math.pi + phase * 1.5) *
              (amplitude * 0.4);
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_WaveCustomPainter old) =>
      old.progress != progress ||
      old.yFraction != yFraction ||
      old.amplitude != amplitude;
}

// ─────────────────────────────────────────────
//  PLACEHOLDER LOGO (saat assets belum ada)
// ─────────────────────────────────────────────
class _PlaceholderLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF26C6A6), Color(0xFF72D8EF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF26C6A6).withOpacity(0.35),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Icon(
        Icons.water_drop_rounded,
        size: 52,
        color: Colors.white,
      ),
    );
  }
}