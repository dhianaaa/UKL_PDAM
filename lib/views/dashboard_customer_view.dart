import 'package:amerta_pay/app_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/user_login.dart';
import '../../models/bill_model.dart';
import '../../models/payment_model.dart';
import '../../services/bill_service.dart';
import '../../services/payment_service.dart';

class CustomerDashboardView extends StatefulWidget {
  const CustomerDashboardView({super.key});

  @override
  State<CustomerDashboardView> createState() => _CustomerDashboardViewState();
}

class _CustomerDashboardViewState extends State<CustomerDashboardView> {
  String _paymentStatus(PaymentModel p) {
  final s = p.status.toUpperCase();

  if (s == 'REJECTED' ||
      s == 'DITOLAK' ||
      s == 'FAILED' ||
      s == 'CANCELED' ||
      s == 'CANCELLED' ||
      s == 'DECLINED' ||
      s == 'DENIED') {
    return 'REJECTED';
  }

  if (s == 'VERIFIED' ||
      s == 'SUCCESS' ||
      s == 'LUNAS' ||
      s == 'PAID' ||
      s == 'APPROVED') {
    return 'VERIFIED';
  }

  if (s == 'PENDING' ||
      s == 'WAITING' ||
      s == 'BELUM_DIVERIFIKASI') {
    return 'PENDING';
  }

  return 'PENDING';
}
  PaymentModel? _latestPaymentForBill(BillModel bill, List<PaymentModel> payments) {
  final relatedPayments = payments.where((p) {
    return p.billId == bill.id || p.bill?.id == bill.id;
  }).toList();

  if (relatedPayments.isEmpty) return null;

  relatedPayments.sort((a, b) => b.id.compareTo(a.id));
  return relatedPayments.first;
}

String _billDashboardStatus(BillModel bill, List<PaymentModel> payments) {
  final latestPayment = _latestPaymentForBill(bill, payments);

  if (latestPayment != null) {
    final s = _paymentStatus(latestPayment);

    if (s == 'VERIFIED') return 'VERIFIED';
    if (s == 'PENDING') return 'PENDING';
    if (s == 'REJECTED') return 'REJECTED';
  }

  final paymentStatus = bill.paymentStatus?.toUpperCase();

  if (bill.verifiedPayment == true ||
      paymentStatus == 'VERIFIED' ||
      paymentStatus == 'SUCCESS' ||
      paymentStatus == 'LUNAS' ||
      paymentStatus == 'PAID') {
    return 'VERIFIED';
  }

  if (paymentStatus == 'PENDING' ||
      paymentStatus == 'WAITING' ||
      paymentStatus == 'BELUM_DIVERIFIKASI') {
    return 'PENDING';
  }

  if (paymentStatus == 'REJECTED' ||
      paymentStatus == 'DITOLAK' ||
      paymentStatus == 'FAILED') {
    return 'REJECTED';
  }

  return 'UNPAID';
}


  String _formatDate(String? value) {
    if (value == null || value.isEmpty) return '-';

    final date = DateTime.tryParse(value);
    if (date == null)
      return value.substring(0, value.length > 10 ? 10 : value.length);

    return DateFormat('dd MMM yyyy', 'id_ID').format(date.toLocal());
  }
  String _formatDateTime(String? value) {
  if (value == null || value.isEmpty) return '-';

  final date = DateTime.tryParse(value);
  if (date == null) return value;

  return DateFormat('dd MMM yyyy HH:mm', 'id_ID').format(date.toLocal());
}

  Color _paymentColor(String status) {
    switch (status) {
      case 'PENDING':
        return AppColors.warning;
      case 'VERIFIED':
        return AppColors.success;
      case 'REJECTED':
        return AppColors.danger;
      default:
        return AppColors.textGrey;
    }
  }

  Color _paymentBg(String status) {
    switch (status) {
      case 'PENDING':
        return AppColors.warningLight;
      case 'VERIFIED':
        return AppColors.successLight;
      case 'REJECTED':
        return AppColors.dangerLight;
      default:
        return AppColors.background;
    }
  }

  String _paymentLabel(String status) {
    switch (status) {
      case 'PENDING':
        return 'Menunggu Verifikasi';
      case 'VERIFIED':
        return 'Terverifikasi';
      case 'REJECTED':
        return 'Ditolak';
      default:
        return status;
    }
  }

  Widget _paymentBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _paymentBg(status),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _paymentLabel(status),
        style: TextStyle(
          color: _paymentColor(status),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  final UserLogin _userLogin = UserLogin();
  final BillService _billService = BillService();
  final PaymentService _paymentService = PaymentService();

  String _username = '';
  String _customerId = '';
  String _name = '';
  bool _loading = true;

  List<BillModel> _unpaidBills = [];
List<PaymentModel> _allPayments = [];
List<PaymentModel> _recentPayments = [];
  // FIX 4: chartData diisi dari data bills
  List<double> _chartData = [0, 0, 0, 0, 0, 0];
  List<String> _chartMonths = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    var user = await _userLogin.getUserLogin();
    if (!user.status!) {
      if (mounted) Navigator.pushReplacementNamed(context, '/login');
      return;
    }
    if (user.role?.toUpperCase() != 'CUSTOMER') {
      if (mounted) Navigator.pushReplacementNamed(context, '/admin-dashboard');
      return;
    }

    if (mounted) {
      setState(() {
        _username = user.username ?? '';
        _name = user.name ?? user.username ?? '';
        _customerId = 'C - ${user.id?.toString().padLeft(6, '0')}';
      });
    }

    // Load tagihan
    // Load tagihan dan pembayaran bersamaan
final billResult = await _billService.getMyBills(quantity: 100);
final payResult = await _paymentService.getMyPayments(quantity: 100);

if (!mounted) return;

final List<BillModel> allBills = billResult.status
    ? List<BillModel>.from(billResult.data ?? [])
    : [];

final List<PaymentModel> payments = payResult.status
    ? List<PaymentModel>.from(payResult.data ?? [])
    : [];

// Tagihan Saya hanya tampil kalau benar-benar perlu dibayar/upload ulang.
// PENDING disembunyikan karena sudah upload bukti dan menunggu admin.
final List<BillModel> unpaid = allBills.where((b) {
  final status = _billDashboardStatus(b, payments);
  return status == 'UNPAID' || status == 'REJECTED';
}).toList();

// Chart tetap dari semua bill
int currentMonth = DateTime.now().month;
int currentYear = DateTime.now().year;
List<double> chartVals = List.filled(6, 0);
List<String> months = [];

for (int i = 5; i >= 0; i--) {
  int m = currentMonth - i;
  int y = currentYear;

  if (m <= 0) {
    m += 12;
    y -= 1;
  }

  const names = [
    '',
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
  ];

  months.add(names[m]);

  int idx = 5 - i;

  for (var bill in allBills) {
    if (bill.month == m && bill.year == y) {
      chartVals[idx] += bill.amount.toDouble();
    }
  }
}

setState(() {
  _unpaidBills = unpaid;
  _allPayments = payments;
  _recentPayments = payments.take(5).toList();
  _chartMonths = months;
  _chartData = chartVals;
  _loading = false;
});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _loadData(),
          color: AppColors.primary,
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(child: _buildHeader()),
                    SliverToBoxAdapter(child: _buildBillCard()),
                    SliverToBoxAdapter(child: _buildChart()),
                    SliverToBoxAdapter(child: _buildRecentPayments()),
                    const SliverToBoxAdapter(child: SizedBox(height: 20)),
                  ],
                ),
        ),
      ),
      bottomNavigationBar: const CustomerBottomNav(activeIndex: 0),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Halo, $_name ,👋 ',
                    style: const TextStyle(
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                _customerId,
                style: TextStyle(
                  color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.8),
                  fontSize: 13,
                ),
              ),
            ],
          ),
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_outlined,
                  color: Color.fromARGB(255, 0, 0, 0),
                  size: 24,
                ),
              ),
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: _unpaidBills.isNotEmpty
                        ? Colors.red
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBillCard() {
    bool hasUnpaid = _unpaidBills.isNotEmpty;
    // FIX 2: Pakai field 'amount', bukan 'totalBill'
    double totalUnpaid = _unpaidBills.fold(
      0,
      (sum, b) => sum + b.amount.toDouble(),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // FIX 5: Tambahkan label judul di kiri
              const Text(
                'Tagihan Saya',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.textDark,
                ),
              ),
              if (hasUnpaid)
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/customer-bill'),
                  child: const Text(
                    'Lihat Semua',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: hasUnpaid
                ? () => Navigator.pushNamed(context, '/customer-bill')
                : null,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: hasUnpaid ? AppColors.dangerLight : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: hasUnpaid
                    ? Border.all(color: AppColors.danger.withOpacity(0.3))
                    : Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: hasUnpaid
                  ? Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.danger.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.receipt_long_rounded,
                            color: AppColors.danger,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Tagihan Belum Dibayar',
                                style: TextStyle(
                                  color: AppColors.danger,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                formatRupiah(totalUnpaid),
                                style: const TextStyle(
                                  color: AppColors.danger,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${_unpaidBills.length} Tagihan',
                                style: TextStyle(
                                  color: AppColors.danger.withOpacity(0.7),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.error_rounded,
                          color: AppColors.danger,
                          size: 24,
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.receipt_long_rounded,
                            color: AppColors.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Untuk Saat ini',
                              style: TextStyle(
                                color: AppColors.textGrey,
                                fontSize: 12,
                              ),
                            ),
                            const Text(
                              'Tidak Ada Tagihan',
                              style: TextStyle(
                                color: AppColors.textDark,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    double maxVal = _chartData.isEmpty
        ? 500000
        : (_chartData.reduce((a, b) => a > b ? a : b) == 0
              ? 500000
              : _chartData.reduce((a, b) => a > b ? a : b));

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Grafik Tagihan (6 Bulan Terakhir)',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 140,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Y axis labels
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _formatK(maxVal),
                            style: const TextStyle(
                              fontSize: 9,
                              color: AppColors.textGrey,
                            ),
                          ),
                          Text(
                            _formatK(maxVal * 0.6),
                            style: const TextStyle(
                              fontSize: 9,
                              color: AppColors.textGrey,
                            ),
                          ),
                          Text(
                            _formatK(maxVal * 0.3),
                            style: const TextStyle(
                              fontSize: 9,
                              color: AppColors.textGrey,
                            ),
                          ),
                          const Text(
                            '0',
                            style: TextStyle(
                              fontSize: 9,
                              color: AppColors.textGrey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 6),
                      // Bars
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(6, (i) {
                            // FIX 4: Pakai _chartData yang sudah terisi
                            double val = i < _chartData.length
                                ? _chartData[i]
                                : 0;
                            double heightFactor = maxVal > 0
                                ? (val / maxVal)
                                : 0;
                            if (heightFactor < 0.05) heightFactor = 0.05;
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 3,
                                ),
                                child: Container(
                                  height: 110 * heightFactor,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color.fromARGB(255, 52, 119, 254),
                                        Color(0xFF5BC8F5),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                    borderRadius: const BorderRadius.vertical(
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
                  children: _chartMonths
                      .map(
                        (m) => Text(
                          m,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textGrey,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatK(double val) {
    if (val >= 1000000) return '${(val / 1000000).toStringAsFixed(1)}M';
    if (val >= 1000) return '${(val / 1000).toStringAsFixed(0)}K';
    return val.toStringAsFixed(0);
  }

  Widget _buildRecentPayments() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Riwayat Pembayaran',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.textDark,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/customer-riwayat'),
                child: const Text(
                  'Lihat semua',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_recentPayments.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Belum ada riwayat pembayaran',
                  style: TextStyle(color: AppColors.textGrey),
                ),
              ),
            )
          else
            ..._recentPayments.map((p) => _buildPaymentItem(p)),
        ],
      ),
    );
  }

  Widget _buildPaymentItem(PaymentModel p) {
    final bill = p.bill;
    final status = _paymentStatus(p);

    final String title = bill != null
        ? 'Tagihan ${bill.monthName} ${bill.year}'
        : 'Tagihan #${p.billId ?? p.id}';

    final double amount = (p.amount ?? bill?.amount ?? 0).toDouble();

    final String date = _formatDate(p.paymentDate ?? p.createdAt);

    return GestureDetector(
      onTap: () => _showPaymentDetail(p),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: _paymentBg(status),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.receipt_rounded,
                color: _paymentColor(status),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatRupiah(amount),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    date,
                    style: TextStyle(fontSize: 11, color: AppColors.textGrey),
                  ),
                ],
              ),
            ),
            _paymentBadge(status),
          ],
        ),
      ),
    );
  }

  void _showPaymentDetail(PaymentModel p) {
    final status = _paymentStatus(p);
    final bill = p.bill;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Detail Pembayaran',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 16),
              _detailRow(
                'Tagihan',
                bill != null
                    ? 'Tagihan ${bill.monthName} ${bill.year}'
                    : 'Tagihan #${p.billId ?? p.id}',
              ),
              _detailRow(
                'Jumlah Bayar',
                formatRupiah((p.amount ?? 0).toDouble()),
              ),
              _detailRow(
  status == 'VERIFIED' ? 'Tanggal Bayar' : 'Tanggal Kirim',
  _formatDateTime(p.paymentDate ?? p.createdAt),
),
              _detailRow('Metode', p.method ?? 'Transfer Bank'),
              const SizedBox(height: 12),
              _paymentBadge(status),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Tutup',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.textGrey, fontSize: 13),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
