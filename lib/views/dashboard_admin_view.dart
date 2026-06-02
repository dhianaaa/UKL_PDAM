import 'package:amerta_pay/services/admin_service.dart';
import 'package:amerta_pay/views/all_activities_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/auth_model.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/alert.dart';
import 'dart:async';
import 'dart:convert';
import 'package:amerta_pay/services/bill_service.dart';
import 'package:amerta_pay/models/bill_model.dart';

class DashboardAdminView extends StatefulWidget {
  final String? token;

  const DashboardAdminView({super.key, this.token});

  @override
  State<DashboardAdminView> createState() => _DashboardAdminViewState();
}

class _DashboardAdminViewState extends State<DashboardAdminView> {
  final AdminService _adminService = AdminService();
  final BillService _billService = BillService();
  String _normalizeStatus(dynamic value) {
    return value?.toString().trim().toUpperCase().replaceAll(' ', '_') ?? '';
  }

  String _dashboardBillStatus(BillModel b) {
    final paymentStatus = _normalizeStatus(b.paymentStatus);
    final billStatus = _normalizeStatus(b.status);

    if (paymentStatus == 'REJECTED' ||
        paymentStatus == 'DITOLAK' ||
        paymentStatus == 'FAILED' ||
        paymentStatus == 'CANCELED' ||
        paymentStatus == 'CANCELLED' ||
        paymentStatus == 'DECLINED' ||
        paymentStatus == 'DENIED' ||
        billStatus == 'DITOLAK') {
      return 'belum_dibayar';
    }

    if (b.verifiedPayment == true ||
        paymentStatus == 'VERIFIED' ||
        paymentStatus == 'SUCCESS' ||
        paymentStatus == 'LUNAS' ||
        paymentStatus == 'PAID' ||
        paymentStatus == 'APPROVED' ||
        billStatus == 'LUNAS') {
      return 'lunas';
    }

    if (paymentStatus == 'PENDING' ||
        paymentStatus == 'WAITING' ||
        paymentStatus == 'BELUM_DIVERIFIKASI' ||
        paymentStatus == 'MENUNGGU_VERIFIKASI' ||
        paymentStatus == 'UNVERIFIED' ||
        billStatus == 'BELUM_DIVERIFIKASI') {
      return 'belum_diverifikasi';
    }

    if (b.paid == true && b.verifiedPayment == false) {
      return 'belum_diverifikasi';
    }

    return 'belum_dibayar';
  }

  ActivityService? _activityService;
  Timer? _timer;

  String _namaAdmin = 'Admin';
  int _totalCustomer = 0;
  int _pembayaranBelum = 0;
  int _totalLayanan = 0;

  double _totalPendapatan = 0;
  List<double> _revenueChartData = [0, 0, 0, 0, 0, 0];
  List<String> _revenueChartMonths = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun'];

  List<ActivityItem> _recentActivities = [];

  bool _loading = true;

  static const Color _teal = Color(0xFF26C6A6);
  static const Color _bg = Color(0xFFF0F4F8);
  static const int _previewCount = 6;

  bool _isPaymentPending(ActivityItem item) {
    final type = item.type.toString().toLowerCase();
    final status = item.status?.toString().toLowerCase() ?? '';

    return type == 'payment' &&
        (status == 'pending' ||
            status == 'waiting' ||
            status == 'belum_diverifikasi');
  }

  bool _isPaymentVerified(ActivityItem item) {
    final type = item.type.toString().toLowerCase();
    final status = item.status?.toString().toLowerCase() ?? '';

    return type == 'payment' &&
        (status == 'verified' ||
            status == 'success' ||
            status == 'lunas' ||
            status == 'paid' ||
            status == 'approved');
  }

  bool _isPaymentRejected(ActivityItem item) {
    final type = item.type.toString().toLowerCase();
    final status = item.status?.toString().toLowerCase() ?? '';

    return type == 'payment' &&
        (status == 'rejected' ||
            status == 'ditolak' ||
            status == 'failed' ||
            status == 'canceled' ||
            status == 'cancelled' ||
            status == 'declined' ||
            status == 'denied');
  }

  String? _activityTrailing(ActivityItem item) {
    if (item.type != 'payment') return null;

    if (_isPaymentVerified(item)) return 'Diverifikasi';
    if (_isPaymentRejected(item)) return 'Ditolak';

    return 'Belum Diverifikasi';
  }

  Color _activityTrailingColor(ActivityItem item) {
    if (_isPaymentVerified(item)) return const Color(0xFF26C6A6);
    if (_isPaymentRejected(item)) return const Color(0xFFE53935);

    return const Color(0xFFFF8A00);
  }

  Color _activityTrailingBg(ActivityItem item) {
    if (_isPaymentVerified(item)) return const Color(0xFFE8F5E9);
    if (_isPaymentRejected(item)) return const Color(0xFFFFEBEE);

    return const Color(0xFFFFF3E0);
  }

  @override
  void initState() {
    super.initState();
    _loadData();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) {
      _loadData(silent: true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ── getTotalCustomer ────────────────────────────────────────────
  Future<int> _getTotalCustomer() async {
    final auth = await AuthModel.getFromPrefs();
    final token = auth.token;

    final res = await http.get(
      Uri.parse('$baseUrl/customers?page=1&quantity=10&search='),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        if (appKey.isNotEmpty) 'app-key': appKey,
      },
    );

    if (res.statusCode != 200) return 0;
    final body = jsonDecode(res.body);
    return body['count'] ?? 0;
  }

  // ── getPendingPaymentsCount ─────────────────────────────────────
  // Mengambil langsung dari endpoint /payments dan menghitung yang PENDING
  Future<int> _getPendingPaymentsCount() async {
    final auth = await AuthModel.getFromPrefs();
    final token = auth.token;

    try {
      final res = await http.get(
        Uri.parse('$baseUrl/payments?page=1&quantity=1000'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          if (appKey.isNotEmpty) 'app-key': appKey,
        },
      );

      print('PAYMENTS RESPONSE CODE: ${res.statusCode}');
      print('PAYMENTS RESPONSE BODY: ${res.body}');

      if (res.statusCode != 200) {
        return 0;
      }

      final body = jsonDecode(res.body);

      List<dynamic> payments = [];

      if (body is List) {
        payments = body;
      } else if (body is Map) {
        final data = body['data'];

        if (data is List) {
          payments = data;
        } else if (data is Map) {
          final nested =
              data['data'] ??
              data['items'] ??
              data['payments'] ??
              data['rows'] ??
              data['result'];

          if (nested is List) {
            payments = nested;
          }
        }

        if (payments.isEmpty) {
          final alt =
              body['payments'] ??
              body['items'] ??
              body['rows'] ??
              body['result'];

          if (alt is List) {
            payments = alt;
          }
        }
      }

      print('PARSED PAYMENTS LENGTH: ${payments.length}');

      final Map<int, Map<String, dynamic>> latestByBill = {};
      int pendingWithoutBillId = 0;

      for (final raw in payments) {
        if (raw is! Map) continue;

        final p = Map<String, dynamic>.from(raw);

        final status =
            (p['status'] ?? p['payment_status'] ?? p['paymentStatus'] ?? '')
                .toString()
                .trim()
                .toUpperCase()
                .replaceAll(' ', '_');

        final billRaw = p['bill'];

        final billId = int.tryParse(
          (p['bill_id'] ??
                      p['billId'] ??
                      p['billID'] ??
                      p['tagihan_id'] ??
                      p['tagihanId'] ??
                      (billRaw is Map ? billRaw['id'] : null))
                  ?.toString() ??
              '',
        );

        final paymentId = int.tryParse(p['id']?.toString() ?? '0') ?? 0;

        print(
          'PAYMENT CHECK => id: $paymentId, billId: $billId, status: $status',
        );

        final isPending =
            status == 'PENDING' ||
            status == 'WAITING' ||
            status == 'BELUM_DIVERIFIKASI' ||
            status == 'MENUNGGU_VERIFIKASI' ||
            status == 'UNVERIFIED';

        // Kalau billId tidak ada, tetap hitung pending sebagai fallback
        if (billId == null) {
          if (isPending) pendingWithoutBillId++;
          continue;
        }

        final oldPayment = latestByBill[billId];
        final oldPaymentId =
            int.tryParse(oldPayment?['id']?.toString() ?? '0') ?? 0;

        if (oldPayment == null || paymentId > oldPaymentId) {
          latestByBill[billId] = p;
        }
      }

      int pendingLatestByBill = 0;

      latestByBill.forEach((billId, p) {
        final status =
            (p['status'] ?? p['payment_status'] ?? p['paymentStatus'] ?? '')
                .toString()
                .trim()
                .toUpperCase()
                .replaceAll(' ', '_');

        if (status == 'PENDING' ||
            status == 'WAITING' ||
            status == 'BELUM_DIVERIFIKASI' ||
            status == 'MENUNGGU_VERIFIKASI' ||
            status == 'UNVERIFIED') {
          pendingLatestByBill++;
        }
      });

      final totalPending = latestByBill.isNotEmpty
          ? pendingLatestByBill
          : pendingWithoutBillId;

      print('LATEST BY BILL: $latestByBill');
      print('PENDING LATEST BY BILL: $pendingLatestByBill');
      print('PENDING WITHOUT BILL ID: $pendingWithoutBillId');
      print('FINAL PENDING COUNT ADMIN: $totalPending');

      return totalPending;
    } catch (e) {
      print('GET PENDING PAYMENTS COUNT ERROR: $e');
      return 0;
    }
  }

  // ── _loadData ───────────────────────────────────────────────────
  Future<void> _loadData({bool silent = false}) async {
    if (!silent && mounted) {
      setState(() => _loading = true);
    }

    try {
      final auth = await AuthModel.getFromPrefs();
      _namaAdmin = auth.name ?? 'Admin';

      final token = await ActivityService.login();
      _activityService = ActivityService(token: token);

      final results = await Future.wait([
  _adminService.getDashboardStats(),
  _getTotalCustomer(),
  _getBillDashboardSummary(),
  _activityService!.fetchAll(),
]);

      final statsResult = results[0] as dynamic;
      final newTotalCustomer = results[1] as int;
      final billSummary = results[2] as _BillDashboardSummary;
      final activities = results[3] as List<ActivityItem>;

      if (!mounted) return;

      setState(() {
        _totalCustomer = newTotalCustomer;

        if (statsResult.status && statsResult.data != null) {
          final data = statsResult.data!;
          _totalLayanan = data['total_layanan'] ?? 0;
        }

        // Gunakan hitungan dari /payments langsung, bukan dari activities
        _pembayaranBelum = billSummary.pendingCount;
_totalPendapatan = billSummary.totalRevenue;
_revenueChartData = billSummary.chartData;
_revenueChartMonths = billSummary.chartMonths;

        _recentActivities = activities.take(_previewCount).toList();
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        AlertMessage.show(context, 'Gagal memuat data', false);
      }
    }
  }

  // ── BUILD ───────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: RefreshIndicator(
          color: _teal,
          onRefresh: () => _loadData(),
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF26C6A6)),
                )
              : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
const SizedBox(height: 24),
_buildStatCards(),
const SizedBox(height: 28),
_buildRevenueChart(),
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
                  Image.asset(
                    'assets/images/maskot.png',
                    width: 36,
                    height: 36,
                    errorBuilder: (_, __, ___) =>
                        const Text('👋', style: TextStyle(fontSize: 28)),
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
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                color: Color(0xFF1A202C),
                size: 22,
              ),
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
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
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
  Widget _buildRevenueChart() {
  double maxVal = _revenueChartData.isEmpty
      ? 500000
      : (_revenueChartData.reduce((a, b) => a > b ? a : b) == 0
          ? 500000
          : _revenueChartData.reduce((a, b) => a > b ? a : b));

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Grafik Pendapatan',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: Color(0xFF1A202C),
        ),
      ),
      const SizedBox(height: 4),
      Text(
        'Pendapatan dari pembayaran terverifikasi 6 bulan terakhir',
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey.shade600,
        ),
      ),
      const SizedBox(height: 14),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.trending_up_rounded,
                    color: Color(0xFF26C6A6),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Pendapatan',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      _formatRupiahAdmin(_totalPendapatan),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A202C),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 140,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatK(maxVal),
                        style: const TextStyle(
                          fontSize: 9,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        _formatK(maxVal * 0.6),
                        style: const TextStyle(
                          fontSize: 9,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        _formatK(maxVal * 0.3),
                        style: const TextStyle(
                          fontSize: 9,
                          color: Colors.grey,
                        ),
                      ),
                      const Text(
                        '0',
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(6, (i) {
                        final val = i < _revenueChartData.length
                            ? _revenueChartData[i]
                            : 0;

                        double heightFactor = maxVal > 0 ? val / maxVal : 0;

                        if (heightFactor < 0.05) {
                          heightFactor = 0.05;
                        }

                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: Container(
                              height: 110 * heightFactor,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color.fromARGB(255, 52, 119, 254),
                                    Color(0xFF5BC8F5),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(6),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _revenueChartMonths.map((m) {
                return Text(
                  m,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    ],
  );
}
String _formatK(double val) {
  if (val >= 1000000) {
    return '${(val / 1000000).toStringAsFixed(1)}M';
  }

  if (val >= 1000) {
    return '${(val / 1000).toStringAsFixed(0)}K';
  }

  return val.toStringAsFixed(0);
}

String _formatRupiahAdmin(double value) {
  final number = value.round().toString();

  final formatted = number.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (match) => '.',
  );

  return 'Rp $formatted';
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
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AllActivitiesScreen(),
                  ),
                );
              },
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
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: _recentActivities.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      'Belum ada aktivitas terbaru',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              : Column(
                  children: _recentActivities.asMap().entries.map((e) {
                    final idx = e.key;
                    final item = e.value;
                    final isLast = idx == _recentActivities.length - 1;
                    final isPayment = item.type == 'payment';

                    return _ActivityTile(
                      icon: isPayment
                          ? Icons.receipt_long_rounded
                          : Icons.people_rounded,
                      title: item.title,
                      subtitle: item.subtitle,
                      trailing: _activityTrailing(item),
                      trailingColor: _activityTrailingColor(item),
                      trailingBg: _activityTrailingBg(item),
                      createdAt: item.createdAt,
                      showDivider: !isLast,
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }

  Future<_BillDashboardSummary> _getBillDashboardSummary() async {
  try {
    final result = await _billService.getAll(search: '', quantity: 1000);

    if (result['status'] != true) {
      print('BILL SUMMARY ERROR: ${result['message']}');
      return const _BillDashboardSummary(
        pendingCount: 0,
        totalRevenue: 0,
        chartData: [0, 0, 0, 0, 0, 0],
        chartMonths: ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun'],
      );
    }

    final bills = List<BillModel>.from(result['data'] ?? []);

    final pendingBills = bills.where((b) {
      return _dashboardBillStatus(b) == 'belum_diverifikasi';
    }).toList();

    final now = DateTime.now();
    final currentMonth = now.month;
    final currentYear = now.year;

    final chartVals = List<double>.filled(6, 0);
    final months = <String>[];

    const monthNames = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];

    for (int i = 5; i >= 0; i--) {
      int m = currentMonth - i;
      int y = currentYear;

      if (m <= 0) {
        m += 12;
        y -= 1;
      }

      months.add(monthNames[m]);
      final index = 5 - i;

      for (final bill in bills) {
        final status = _dashboardBillStatus(bill);

        // Pendapatan admin hanya dari bill yang sudah lunas / verified
        if (bill.month == m && bill.year == y && status == 'lunas') {
          chartVals[index] += bill.amount.toDouble();
        }
      }
    }

    final totalRevenue = chartVals.fold<double>(
      0,
      (sum, value) => sum + value,
    );

    print('ADMIN REVENUE CHART: $chartVals');
    print('ADMIN REVENUE MONTHS: $months');
    print('ADMIN TOTAL REVENUE: $totalRevenue');
    print('ADMIN PENDING COUNT: ${pendingBills.length}');

    return _BillDashboardSummary(
      pendingCount: pendingBills.length,
      totalRevenue: totalRevenue,
      chartData: chartVals,
      chartMonths: months,
    );
  } catch (e) {
    print('GET BILL DASHBOARD SUMMARY ERROR: $e');

    return const _BillDashboardSummary(
      pendingCount: 0,
      totalRevenue: 0,
      chartData: [0, 0, 0, 0, 0, 0],
      chartMonths: ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun'],
    );
  }
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
            offset: const Offset(0, 3),
          ),
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
  final DateTime createdAt;
  final bool showDivider;

  const _ActivityTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.trailingColor,
    required this.trailingBg,
    required this.createdAt,
    required this.showDivider,
  });

  String get _timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inSeconds < 60) return '${diff.inSeconds} detik yang lalu';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit yang lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam yang lalu';
    if (diff.inDays < 30) return '${diff.inDays} hari yang lalu';
    return '${(diff.inDays / 30).floor()} bulan yang lalu';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A202C),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _timeAgo,
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
                  ),
                  if (trailing != null) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
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
            endIndent: 16,
          ),
      ],
    );
  }
  
}
class _BillDashboardSummary {
  final int pendingCount;
  final double totalRevenue;
  final List<double> chartData;
  final List<String> chartMonths;

  const _BillDashboardSummary({
    required this.pendingCount,
    required this.totalRevenue,
    required this.chartData,
    required this.chartMonths,
  });
}
