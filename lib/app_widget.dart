import 'package:flutter/material.dart';

// =============================================
// Warna tema PDAM AmertaPay
// =============================================
class AppColors {
  static const Color primary = Color(0xFF21AC91);      // Teal utama
  static const Color primaryDark = Color(0xFF1E7A6D);  // Teal gelap
  static const Color primaryLight = Color(0xFFE8F5F3); // Teal muda
  static const Color accent = Color(0xFF4CAF8E);
  static const Color background = Color(0xFFF0F4F8);
  static const Color cardBg = Colors.white;
  static const Color textDark = Color(0xFF1A2D3D);
  static const Color textGrey = Color(0xFF8A9BB0);
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFFF9800);
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color danger = Color(0xFFE53935);
  static const Color dangerLight = Color(0xFFFFEBEE);
}

// =============================================
// Bottom Navigation Bar Customer
// =============================================
class CustomerBottomNav extends StatelessWidget {
  final int activeIndex;

  const CustomerBottomNav({super.key, required this.activeIndex});

  void _navigate(BuildContext context, int index) {
    final routes = ['/customer-dashboard', '/customer-bill', '/customer-riwayat', '/customer-profile'];
    if (index == activeIndex) return;
    Navigator.pushReplacementNamed(context, routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, -4))],
      ),
      child: BottomNavigationBar(
        currentIndex: activeIndex,
        onTap: (index) => _navigate(context, index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textGrey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        elevation: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_rounded), label: 'Bill'),
          BottomNavigationBarItem(icon: Icon(Icons.history_rounded), label: 'Riwayat'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}

// =============================================
// Status Badge Widget
// =============================================
class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color text;
    String label;
    IconData icon;

    switch (status.toUpperCase()) {
      case 'PENDING':
        bg = AppColors.warningLight;
        text = AppColors.warning;
        label = 'Menunggu Verifikasi';
        icon = Icons.hourglass_top_rounded;
        break;
      case 'VERIFIED':
        bg = AppColors.successLight;
        text = AppColors.success;
        label = 'Diverifikasi';
        icon = Icons.check_circle_rounded;
        break;
      case 'REJECTED':
        bg = AppColors.dangerLight;
        text = AppColors.danger;
        label = 'Ditolak';
        icon = Icons.cancel_rounded;
        break;
      case 'UNPAID':
        bg = AppColors.dangerLight;
        text = AppColors.danger;
        label = 'Belum Dibayar';
        icon = Icons.error_rounded;
        break;
      default:
        bg = AppColors.primaryLight;
        text = AppColors.primary;
        label = status;
        icon = Icons.info_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: text, size: 13),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: text, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// =============================================
// Maskot / Water Drop Widget (sebagai placeholder logo)
// =============================================
class WaterMascot extends StatelessWidget {
  final double size;
  final bool sad;

  const WaterMascot({super.key, this.size = 80, this.sad = false});

  @override
  Widget build(BuildContext context) {
    // Placeholder mascot - nanti bisa diganti dengan Image.asset('assets/maskot.png')
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4DD0C4), Color(0xFF2E9E8F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      child: Padding(
  padding: EdgeInsets.all(size * 0.18),
  child: Image.asset(
    'assets/bayar.png',
    width: size * 0.6,
    height: size * 0.6,
    fit: BoxFit.contain,
  ),
),
    );
  }
}

// =============================================
// Format Currency
// =============================================
String formatRupiah(double amount) {
  String str = amount.toStringAsFixed(0);
  String result = '';
  int counter = 0;
  for (int i = str.length - 1; i >= 0; i--) {
    result = str[i] + result;
    counter++;
    if (counter % 3 == 0 && i != 0) {
      result = '.$result';
    }
  }
  return 'Rp $result';
}

// =============================================
// Snackbar Helper
// =============================================
void showSnackbar(BuildContext context, String message, {bool isError = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message, style: const TextStyle(color: Colors.white)),
      backgroundColor: isError ? AppColors.danger : AppColors.primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
    ),
  );
}