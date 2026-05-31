import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:amerta_pay/views/kelola_bill_view.dart';
import 'package:amerta_pay/views/kelola_customer_view.dart';

// ── Auth Screens ───────────────────────────────────────────────
import 'views/splash_screen.dart';
import 'views/welcome_screen.dart';
import 'views/role_picker_view.dart';
import 'views/login_view.dart';
import 'views/register_admin_view.dart';
import 'views/contact_admin_view.dart';

// ── Admin Screens ──────────────────────────────────────────────
import 'views/dashboard_admin_view.dart';
import 'views/service_view.dart';
import 'views/profile_admin_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('id_ID', null);

  runApp(const AmertaPayApp());
}

class AmertaPayApp extends StatelessWidget {
  const AmertaPayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AmertaPay',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF26C6A6),
        ),
        fontFamily: 'Poppins',
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF0F4F8),
      ),
      initialRoute: '/',
      routes: {
        // ── AUTH FLOW ──────────────────────────────────────────
        '/': (ctx) => const SplashScreen(),
        '/welcome': (ctx) => const WelcomeView(),
        '/role-picker': (ctx) => const RolePickerView(),
        '/login-admin': (ctx) => const LoginView(isAdmin: true),
        '/login-customer': (ctx) => const LoginView(isAdmin: false),
        '/register-admin': (ctx) => const RegisterAdminView(),
        '/contact-admin': (ctx) => const ContactAdminView(),

        // ── ADMIN ─────────────────────────────────────────────
        '/dashboard-admin': (ctx) => const DashboardAdminView(),
        '/service-admin': (ctx) => const ServiceAdminView(),
        '/profile-admin': (ctx) => const ProfileAdminView(),
        '/customer-admin': (ctx) => const KelolaCustomerView(),
        '/bill-admin': (ctx) => const KelolaBillView(),

        // ── CUSTOMER ──────────────────────────────────────────
        '/dashboard-customer': (ctx) => const _TempCustomerDashboard(),
      },
    );
  }
}

class _TempPage extends StatelessWidget {
  final String title;

  const _TempPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF26C6A6),
        elevation: 0,
      ),
      body: Center(
        child: Text(
          'Halaman $title\nakan dibuat selanjutnya.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF4A5568),
          ),
        ),
      ),
    );
  }
}

class _TempCustomerDashboard extends StatelessWidget {
  const _TempCustomerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text(
          'Dashboard Customer',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF26C6A6),
        elevation: 0,
      ),
      body: const Center(
        child: Text(
          'Dashboard Customer\nakan dibuat selanjutnya.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF4A5568),
          ),
        ),
      ),
    );
  }
}