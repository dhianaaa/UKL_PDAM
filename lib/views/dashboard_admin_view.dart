import 'package:amerta_pay/views/admin_service.dart';
import 'package:flutter/material.dart';
import '../models/auth_model.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/alert.dart';

class DashboardAdminView extends StatefulWidget {
  const DashboardAdminView({super.key});

  @override
  State<DashboardAdminView> createState() => _DashboardAdminViewState();
}

class _DashboardAdminViewState extends State<DashboardAdminView> {
  final AdminService _adminService = AdminService();

  String _namaAdmin = 'Admin';
  int _totalCustomer = 0;
  int _pembayaranBelum = 0;
  int _totalLayanan = 0;
  List _recentBills = [];
  List _recentCustomers = [];
  bool _loading = true;

  static const _teal = Color(0xFF26C6A6);
  static const _bg   = Color(0xFFF0F4F8);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      // Get admin name from prefs
      final auth = await AuthModel.getFromPrefs();
      _namaAdmin = auth.name?? 'Admin';

      // Get dashboard stats
      final statsResult = await _adminService.getDashboardStats();
      if (statsResult.status && statsResult.data != null) {
        final data = statsResult.data!;
        _totalCustomer   = data['total_customer'] ?? 0;
        _pembayaranBelum = data['pembayaran_belum'] ?? 0;
        _totalLayanan    = data['total_layanan'] ?? 0;
        _recentBills     = data['recent_bills'] ?? [];
      }

      // Recent customers
      _recentCustomers = await _adminService.getRecentCustomers();
    } catch (e) {
      if (mounted) AlertMessage.show(context, 'Gagal memuat data', false);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: RefreshIndicator(
          color: _teal,
          onRefresh: _loadData,
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF26C6A6)))
              : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 24),
                      _buildStatCards(),
                      const SizedBox(height: 28),
                      _buildRecentActivity(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
        ),
      ),
      bottomNavigationBar: const BottomNavAdmin(0),
    );
  }

  // ── Header ──────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Halo, $_namaAdmin ',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A202C),
                    ),
                  ),
                  // Maskot image (replace with actual asset)
                  Image.asset(
                    'assets/images/maskot.png',
                    width: 36,
                    height: 36,
                    errorBuilder: (_, __, ___) => const Text('💧',
                        style: TextStyle(fontSize: 28)),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Selamat datang kembali!',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        // Notification bell
        Stack(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2))
                ],
              ),
              child: const Icon(Icons.notifications_none_rounded,
                  color: Color(0xFF1A202C), size: 22),
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Stats Cards ─────────────────────────────────────────────────
  Widget _buildStatCards() {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            iconBg: const Color(0xFFE3F0FF),
            icon: Icons.people_rounded,
            iconColor: const Color(0xFF2979FF),
            value: _totalCustomer.toString(),
            label: 'Total Customer',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            iconBg: const Color(0xFFFFF3E0),
            icon: Icons.payments_rounded,
            iconColor: const Color(0xFFFF6D00),
            value: _pembayaranBelum.toString(),
            label: 'Pembayaran belum Diverifikasi',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            iconBg: const Color(0xFFE8F5E9),
            icon: Icons.water_drop_rounded,
            iconColor: const Color(0xFF26C6A6),
            value: _totalLayanan.toString(),
            label: 'Total Layanan',
          ),
        ),
      ],
    );
  }

  // ── Recent Activity ─────────────────────────────────────────────
  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Aktivitas terbaru',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A202C),
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/bill-admin'),
              child: const Text(
                'Lihat semua',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF26C6A6),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4))
            ],
          ),
          child: Column(
            children: [
              // Recent Bills
              ..._recentBills.asMap().entries.map((e) {
                final bill = e.value;
                final isVerified =
                    bill['status'] == true || bill['status'] == 'SUDAH';
                final inv = bill['invoice_number'] ??
                    'INV/${bill['year'] ?? '2024'}/${bill['month']?.toString().padLeft(2, '0') ?? '01'}/${bill['id']?.toString().padLeft(3, '0') ?? '000'}';
                return _ActivityTile(
                  icon: Icons.receipt_long_rounded,
                  title: 'Pembayaran baru',
                  subtitle: inv,
                  trailing: isVerified ? 'Diverifikasi' : 'Belum Diverifikasi',
                  trailingColor: isVerified
                      ? const Color(0xFF26C6A6)
                      : const Color(0xFFFF8A80),
                  trailingBg: isVerified
                      ? const Color(0xFFE8F5E9)
                      : const Color(0xFFFFEBEE),
                  timeAgo: '${(e.key + 1) * 5} menit yang lalu',
                  showDivider: true,
                );
              }).toList(),

              // Recent Customers
              ..._recentCustomers.asMap().entries.map((e) {
                final cust = e.value;
                final custNum = cust['customer_number'] ?? '-';
                final custName = cust['name'] ?? '-';
                final idx = _recentBills.length + e.key;
                return _ActivityTile(
                  icon: Icons.people_rounded,
                  title: 'Customer baru',
                  subtitle: 'C-${custNum.toString().padLeft(6, '0')} - $custName',
                  trailing: null,
                  trailingColor: Colors.transparent,
                  trailingBg: Colors.transparent,
                  timeAgo: '${(idx + 1) * 10} menit yang lalu',
                  showDivider: e.key < _recentCustomers.length - 1,
                );
              }).toList(),

              if (_recentBills.isEmpty && _recentCustomers.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: Text('Belum ada aktivitas terbaru',
                        style: TextStyle(color: Colors.grey)),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Stat Card ───────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final Color iconBg;
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _StatCard({
    required this.iconBg,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: iconColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Activity Tile ────────────────────────────────────────────────
class _ActivityTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? trailing;
  final Color trailingColor;
  final Color trailingBg;
  final String timeAgo;
  final bool showDivider;

  const _ActivityTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.trailingColor,
    required this.trailingBg,
    required this.timeAgo,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.grey.shade600, size: 20),
              ),
              const SizedBox(width: 12),

              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A202C),
                        )),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        )),
                  ],
                ),
              ),

              // Trailing
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(timeAgo,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade400,
                      )),
                  if (trailing != null) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: trailingBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        trailing!,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: trailingColor,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
              height: 1,
              color: Colors.grey.shade100,
              indent: 16,
              endIndent: 16),
      ],
    );
  }
}