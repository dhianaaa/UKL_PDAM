import 'package:flutter/material.dart';

/// Bottom Navigation Bar untuk ADMIN
/// Kirim [activePage] sesuai index tab aktif:
///   0 = Dashboard, 1 = Layanan, 2 = Customer, 3 = Bill, 4 = Profile
class BottomNavAdmin extends StatelessWidget {
  final int activePage;
  const BottomNavAdmin(this.activePage, {super.key});

  static const _teal = Color(0xFF26C6A6);
  static const _grey = Color(0xFF9E9E9E);
  static const _bg   = Colors.white;

  void _navigate(BuildContext context, int index) {
    if (index == activePage) return;
    const routes = [
      '/dashboard-admin',
      '/service-admin',
      '/customer-admin',
      '/bill-admin',
      '/profile-admin',
    ];
    Navigator.pushReplacementNamed(context, routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _bg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.grid_view_rounded,
                label: 'Dashboard',
                active: activePage == 0,
                onTap: () => _navigate(context, 0),
              ),
              _NavItem(
                icon: Icons.water_drop_rounded,
                label: 'Layanan',
                active: activePage == 1,
                onTap: () => _navigate(context, 1),
              ),
              _NavItem(
                icon: Icons.people_rounded,
                label: 'Customer',
                active: activePage == 2,
                onTap: () => _navigate(context, 2),
              ),
              _NavItem(
                icon: Icons.receipt_long_rounded,
                label: 'Bill',
                active: activePage == 3,
                onTap: () => _navigate(context, 3),
              ),
              _NavItem(
                icon: Icons.person_rounded,
                label: 'Profile',
                active: activePage == 4,
                onTap: () => _navigate(context, 4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  static const _teal = Color(0xFF26C6A6);
  static const _grey = Color(0xFF9E9E9E);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon,
              color: active ? _teal : _grey,
              size: active ? 26 : 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: active ? FontWeight.w700 : FontWeight.w400,
              color: active ? _teal : _grey,
            ),
          ),
        ],
      ),
    );
  }
}