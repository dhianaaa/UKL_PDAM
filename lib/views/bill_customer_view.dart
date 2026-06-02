import 'package:amerta_pay/app_widget.dart';
import 'package:amerta_pay/models/payment_model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/bill_model.dart';
import '../../services/bill_service.dart';
import '../../services/payment_service.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';

// =============================================
// Bill List View (Tab: Bill)
// =============================================
class CustomerBillView extends StatefulWidget {
  const CustomerBillView({super.key});

  @override
  State<CustomerBillView> createState() => _CustomerBillViewState();
}

class _CustomerBillViewState extends State<CustomerBillView> {
  
  String _activeTab = 'Semua';
  final TextEditingController _searchCtrl = TextEditingController();

  final BillService _billService = BillService();
  final PaymentService _paymentService = PaymentService();

  List<BillModel> _bills = [];
  List<PaymentModel> _payments = [];

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadBills();
    _searchCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadBills() async {
    setState(() => _loading = true);

    final billResult = await _billService.getMyBills(quantity: 100);
    final paymentResult = await _paymentService.getMyPayments(quantity: 100);

    if (!mounted) return;

    setState(() {
      _bills = billResult.status
          ? List<BillModel>.from(billResult.data ?? [])
          : [];

      _payments = paymentResult.status
          ? List<PaymentModel>.from(paymentResult.data ?? [])
          : [];

      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<BillModel> displayed;

    if (_activeTab == 'Belum Dibayar') {
      displayed = _bills.where((b) => _billStatus(b) == 'UNPAID').toList();
    } else if (_activeTab == 'Dibayar') {
      displayed = _bills.where((b) => _billStatus(b) == 'VERIFIED').toList();
    } else {
      // Semua: tampilkan semua tagihan
      displayed = List<BillModel>.from(_bills);
    }

    if (_searchCtrl.text.isNotEmpty) {
      displayed = displayed
          .where(
            (b) =>
                b.monthName.toLowerCase().contains(
                  _searchCtrl.text.toLowerCase(),
                ) ||
                b.year.toString().contains(_searchCtrl.text),
          )
          .toList();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Bill Saya',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A2B4A),
            fontSize: 18,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : RefreshIndicator(
              onRefresh: () async => _loadBills(),
              color: AppColors.primary,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildSearchAndTabs()),
                  displayed.isEmpty
                      ? SliverFillRemaining(child: _buildEmpty())
                      : SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) =>
                                  _buildBillCard(displayed[index]),
                              childCount: displayed.length,
                            ),
                          ),
                        ),
                ],
              ),
            ),
      bottomNavigationBar: const CustomerBottomNav(activeIndex: 1),
    );
  }

  Widget _buildSearchAndTabs() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar + add button row
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F4F8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF1A2B4A),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Cari bill...',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: Colors.grey.shade400,
                        size: 20,
                      ),
                      suffixIcon: _searchCtrl.text.isNotEmpty
                          ? GestureDetector(
                              onTap: () => _searchCtrl.clear(),
                              child: Icon(
                                Icons.close_rounded,
                                color: Colors.grey.shade400,
                                size: 18,
                              ),
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 4,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Tab row
          Row(
            children: ['Semua', 'Belum Dibayar', 'Dibayar'].map((tab) {
              final isActive = _activeTab == tab;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _activeTab = tab),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isActive
                            ? AppColors.primary
                            : const Color(0xFFDDE3EC),
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      tab,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isActive
                            ? Colors.white
                            : const Color(0xFF8A9BB5),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF4FB),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.water_drop_outlined,
              color: Colors.grey.shade300,
              size: 60,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Kosong! Tidak ada apa apa disini!',
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFF8A9BB5),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  PaymentModel? _latestPaymentForBill(BillModel bill) {
  final relatedPayments = _payments.where((p) {
    return p.billId == bill.id || p.bill?.id == bill.id;
  }).toList();

  if (relatedPayments.isEmpty) return null;

  relatedPayments.sort((a, b) => b.id.compareTo(a.id));
  return relatedPayments.first;
}

  String _billStatus(BillModel bill) {
    final payment = _latestPaymentForBill(bill);

    if (payment != null) {
      final s = payment.status.toUpperCase().replaceAll(' ', '_');

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
          s == 'BELUM_DIVERIFIKASI' ||
          s == 'MENUNGGU_VERIFIKASI' ||
          s == 'UNVERIFIED') {
        return 'PENDING';
      }
    }

    final paymentStatus = bill.paymentStatus?.toUpperCase().replaceAll(
      ' ',
      '_',
    );

    if (paymentStatus == 'REJECTED' ||
        paymentStatus == 'DITOLAK' ||
        paymentStatus == 'FAILED') {
      return 'REJECTED';
    }

    if (bill.verifiedPayment == true ||
        paymentStatus == 'VERIFIED' ||
        paymentStatus == 'SUCCESS' ||
        paymentStatus == 'LUNAS' ||
        paymentStatus == 'PAID' ||
        paymentStatus == 'APPROVED') {
      return 'VERIFIED';
    }

    if (paymentStatus == 'PENDING' ||
        paymentStatus == 'WAITING' ||
        paymentStatus == 'BELUM_DIVERIFIKASI' ||
        paymentStatus == 'MENUNGGU_VERIFIKASI' ||
        paymentStatus == 'UNVERIFIED') {
      return 'PENDING';
    }

    return 'UNPAID';
  }

  Widget _buildBillCard(BillModel bill) {
    final status = _billStatus(bill);
    final statusLabel = _statusLabel(status);
    final statusColor = _statusColor(status);
    final statusBg = _statusBg(status);
    final description = _statusDescription(status);

    return GestureDetector(
      onTap: () {
  final latestPayment = _latestPaymentForBill(bill);

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => DetailBillView(
        billId: bill.id!,
        initialBill: bill,
        initialPayment: latestPayment,
      ),
    ),
  ).then((_) => _loadBills());
},
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Text(
                  'Total Tagihan',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Date
            Text(
              'Tagihan ${_formatDate(bill)}',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF4A5568),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            // Amount
            Text(
              formatRupiah(bill.amount.toDouble()),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A2B4A),
              ),
            ),
            const SizedBox(height: 6),
            // Description
            Text(
              description,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(BillModel bill) {
    // Format: "23 Mei 2026"
    const months = [
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
    // bill.monthName is the month name, bill.year is the year
    // We try to build a date like "01 Mei 2026"
    return '01 ${bill.monthName} ${bill.year}';
  }

  String _statusLabel(String status) {
    if (status == 'PENDING') return 'Menunggu Verifikasi';
    if (status == 'REJECTED') return 'Ditolak';
    if (status == 'VERIFIED') return 'Dibayar';
    return 'Belum Dibayar';
  }

  String _statusDescription(String status) {
    if (status == 'VERIFIED') return 'Anda sudah membayar tagihan ini';
    if (status == 'PENDING') return 'Menunggu verifikasi admin';
    if (status == 'REJECTED') return 'Pembayaran ditolak, upload ulang bukti';
    return 'Anda belum membayar tagihan ini';
  }

  Color _statusColor(String status) {
    if (status == 'PENDING') return AppColors.warning;
    if (status == 'REJECTED') return AppColors.danger;
    if (status == 'VERIFIED') return AppColors.success;
    return AppColors.danger;
  }

  Color _statusBg(String status) {
    if (status == 'PENDING') return AppColors.warningLight;
    if (status == 'REJECTED') return AppColors.dangerLight;
    if (status == 'VERIFIED') return AppColors.successLight;
    return AppColors.dangerLight;
  }
}

// =============================================
// Detail Bill View
// =============================================
class DetailBillView extends StatefulWidget {
  final int billId;
  final BillModel? initialBill;
  final PaymentModel? initialPayment;

  const DetailBillView({
    super.key,
    required this.billId,
    this.initialBill,
    this.initialPayment,
  });

  @override
  State<DetailBillView> createState() => _DetailBillViewState();
}

class _DetailBillViewState extends State<DetailBillView> {
  
  final BillService _billService = BillService();
  PaymentModel? _latestPaymentForBill(BillModel bill) {
  final allPayments = <PaymentModel>[
    ..._payments,
    if (widget.initialPayment != null) widget.initialPayment!,
  ];

  final relatedPayments = allPayments.where((p) {
    return p.billId == bill.id || p.bill?.id == bill.id;
  }).toList();

  if (relatedPayments.isEmpty) return null;

  relatedPayments.sort((a, b) => b.id.compareTo(a.id));
  return relatedPayments.first;
}
  final PaymentService _paymentService = PaymentService();
  List<PaymentModel> _payments = [];
  BillModel? _bill;
  bool _loading = true;

  @override
void initState() {
  super.initState();

  _bill = widget.initialBill;

  if (widget.initialPayment != null) {
    _payments = [widget.initialPayment!];
  }

  _loadDetail();
}

  void _loadDetail() async {
    setState(() => _loading = true);

    final billResult = await _billService.getMyBillDetail(widget.billId);
    final paymentResult = await _paymentService.getMyPayments(quantity: 100);

    print('DETAIL BILL DATA: ${billResult.data}');
    print('MY PAYMENTS DATA: ${paymentResult.data}');

    if (!mounted) return;

    setState(() {
      if (billResult.status && billResult.data != null) {
        _bill = BillModel.fromJson(Map<String, dynamic>.from(billResult.data!));
      }

      _payments = [
  if (widget.initialPayment != null) widget.initialPayment!,
  if (paymentResult.status)
    ...List<PaymentModel>.from(paymentResult.data ?? []),
];

      _loading = false;
    });
  }

  String _billStatus(BillModel bill) {
  final payment = _latestPaymentForBill(bill);

  // 1. Prioritas utama: payment terbaru
  if (payment != null) {
    final s = payment.status.toUpperCase().replaceAll(' ', '_');

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
        s == 'BELUM_DIVERIFIKASI' ||
        s == 'MENUNGGU_VERIFIKASI' ||
        s == 'UNVERIFIED') {
      return 'PENDING';
    }
  }

  // 2. Fallback ke bill dari endpoint detail
  final initialBill = widget.initialBill?.id == bill.id ? widget.initialBill : null;

  final paymentStatus = (bill.paymentStatus ?? initialBill?.paymentStatus)
      ?.toUpperCase()
      .replaceAll(' ', '_');

  final verified = bill.verifiedPayment == true ||
      initialBill?.verifiedPayment == true;

  final paid = bill.paid == true || initialBill?.paid == true;

  if (paymentStatus == 'REJECTED' ||
      paymentStatus == 'DITOLAK' ||
      paymentStatus == 'FAILED') {
    return 'REJECTED';
  }

  if (verified ||
      paymentStatus == 'VERIFIED' ||
      paymentStatus == 'SUCCESS' ||
      paymentStatus == 'LUNAS' ||
      paymentStatus == 'PAID' ||
      paymentStatus == 'APPROVED') {
    return 'VERIFIED';
  }

  if (paymentStatus == 'PENDING' ||
      paymentStatus == 'WAITING' ||
      paymentStatus == 'BELUM_DIVERIFIKASI' ||
      paymentStatus == 'MENUNGGU_VERIFIKASI' ||
      paymentStatus == 'UNVERIFIED') {
    return 'PENDING';
  }

  if (paid && !verified) {
    return 'PENDING';
  }

  return 'UNPAID';
}

  bool get _showPayButton {
  if (_bill == null) return false;
  final status = _billStatus(_bill!);
  return status == 'UNPAID' || status == 'REJECTED';
}

bool get _isPending {
  return _bill != null && _billStatus(_bill!) == 'PENDING';
}

bool get _isRejected {
  return _bill != null && _billStatus(_bill!) == 'REJECTED';
}

bool get _isVerified {
  return _bill != null && _billStatus(_bill!) == 'VERIFIED';
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Detail Bill',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chevron_left,
              color: Colors.white,
              size: 20,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _bill == null
          ? const Center(child: Text('Gagal memuat data'))
          : _buildDetail(),
      bottomNavigationBar: _bill != null
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_showPayButton) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BayarBillView(bill: _bill!),
                          ),
                        ).then((_) => _loadDetail()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          _isRejected ? 'Upload Ulang Bukti' : 'Bayar Sekarang',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    
                  ],
                  if (_isVerified) ...[
  SizedBox(
    width: double.infinity,
    height: 52,
    child: ElevatedButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DownloadResiView(
              bill: _bill!,
              payment: _latestPaymentForBill(_bill!),
            ),
          ),
        );
      },
      icon: const Icon(Icons.download_rounded, color: Colors.white),
      label: const Text(
        'Download Resi',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    ),
  ),
  const SizedBox(height: 10),
],
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/customer-riwayat'),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Lihat Riwayat',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  Widget _buildDetail() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tagihan Bulan',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        '${_bill!.monthName} ${_bill!.year}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.water_drop, color: Colors.white, size: 50),
              ],
            ),
          ),

          const SizedBox(height: 16),

          _buildCard('Informasi Tagihan', Icons.receipt_long_rounded, [
            _buildRow('ID Tagihan', 'Bill #${_bill!.id}'),
            _buildRow('Nama Pelanggan', _bill!.customer?.name ?? '-'),
            _buildRow('Alamat', _bill!.customer?.address ?? '-'),
            _buildRow('Layanan', _bill!.customer?.service?.name ?? '-'),
            _buildRow('Pemakaian Air', '${_bill!.usageValue ?? 0} m³'),
          ]),

          const SizedBox(height: 12),

          _buildCard('Total Tagihan', Icons.payments_rounded, [
            Row(
              children: [
                const Icon(
                  Icons.payments_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  formatRupiah(_bill!.amount.toDouble()),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ]),

          const SizedBox(height: 12),

          _buildStatusBox(),

          if (_isRejected && _bill!.rejectionReason != null) ...[
            const SizedBox(height: 12),
            _buildRejectionBox(_bill!.rejectionReason!),
          ],

          const SizedBox(height: 80),
        ],
      ),
    );
  }

 Widget _buildStatusBox() {
  Color borderColor;
  Color bgColor;
  Color dotColor;
  String statusText;
  String statusLabel;

  if (_isVerified) {
    bgColor = AppColors.successLight;
    borderColor = AppColors.success.withOpacity(0.3);
    dotColor = AppColors.success;
    statusLabel = 'Status';
    statusText = 'Dibayar';
  } else if (_isPending) {
    bgColor = AppColors.warningLight;
    borderColor = AppColors.warning.withOpacity(0.3);
    dotColor = AppColors.warning;
    statusLabel = 'Status';
    statusText = 'Menunggu Verifikasi';
  } else if (_isRejected) {
    bgColor = AppColors.dangerLight;
    borderColor = AppColors.danger.withOpacity(0.3);
    dotColor = AppColors.danger;
    statusLabel = 'Status';
    statusText = 'Pembayaran Ditolak';
  } else {
    bgColor = AppColors.dangerLight;
    borderColor = AppColors.danger.withOpacity(0.3);
    dotColor = AppColors.danger;
    statusLabel = 'Status';
    statusText = 'Belum Dibayar';
  }

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: borderColor),
    ),
    child: Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              statusLabel,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: dotColor,
              ),
            ),
            Text(
              statusText,
              style: TextStyle(color: dotColor),
            ),
          ],
        ),
      ],
    ),
  );
}

  Widget _buildRejectionBox(String reason) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.dangerLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.danger.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: AppColors.danger, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Alasan Penolakan',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.danger,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  reason,
                  style: const TextStyle(color: AppColors.danger, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(String title, IconData icon, List<Widget> children) {
    return Container(
      width: double.infinity,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: AppColors.textGrey, fontSize: 13),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: AppColors.textDark,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
class DownloadResiView extends StatefulWidget {
  final BillModel bill;
  final PaymentModel? payment;

  const DownloadResiView({
    super.key,
    required this.bill,
    this.payment,
  });

  @override
  State<DownloadResiView> createState() => _DownloadResiViewState();
}

class _DownloadResiViewState extends State<DownloadResiView> {
  final GlobalKey _receiptKey = GlobalKey();
  bool _saving = false;

  String get _serviceName {
    final name = widget.bill.customer?.service?.name;

    if (name != null && name.trim().isNotEmpty) {
      return name;
    }

    return 'PDAM';
  }

  String get _customerName {
    final name = widget.bill.customer?.name;

    if (name != null && name.trim().isNotEmpty) {
      return name;
    }

    return '-';
  }

  String get _customerNumber {
    if (widget.bill.invoiceNumber.trim().isNotEmpty) {
      return widget.bill.invoiceNumber;
    }

    return 'Bill #${widget.bill.id}';
  }

  String get _paymentMethod {
    final fromPayment = widget.payment?.method;
    if (fromPayment != null && fromPayment.trim().isNotEmpty) {
      return fromPayment;
    }

    final fromBill = widget.bill.paymentMethod;
    if (fromBill != null && fromBill.trim().isNotEmpty) {
      return fromBill;
    }

    return 'Transfer Bank';
  }

  double get _paymentAmount {
    return (widget.payment?.amount ?? widget.bill.amount).toDouble();
  }

  String get _paymentDateText {
    final raw = widget.payment?.paymentDate ??
        widget.payment?.createdAt ??
        widget.bill.paymentDate ??
        widget.bill.createdAt;

    return _formatDateTime(raw);
  }

  String _formatDateTime(String? value) {
    if (value == null || value.isEmpty) return '-';

    final date = DateTime.tryParse(value);
    if (date == null) return value;

    final local = date.toLocal();
    final tanggal = DateFormat('dd MMM yyyy', 'id_ID').format(local);
    final jam = DateFormat('HH:mm', 'id_ID').format(local);

    return '$tanggal\n$jam WIB';
  }

  Future<void> _downloadReceipt() async {
  try {
    setState(() => _saving = true);

    await Future.delayed(const Duration(milliseconds: 100));

    final boundary = _receiptKey.currentContext?.findRenderObject()
    as RenderRepaintBoundary?;

    if (boundary == null) {
      throw Exception('Gagal membaca tampilan resi');
    }

    final image = await boundary.toImage(pixelRatio: 3);

    final byteData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );

    if (byteData == null) {
      throw Exception('Gagal membuat gambar resi');
    }

    final bytes = byteData.buffer.asUint8List();

    final hasAccess = await Gal.hasAccess();

    if (!hasAccess) {
      await Gal.requestAccess();
    }

    await Gal.putImageBytes(
      bytes,
      name:
          'resi_amertapay_bill_${widget.bill.id}_${DateTime.now().millisecondsSinceEpoch}.png',
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Resi berhasil disimpan ke galeri'),
        backgroundColor: AppColors.primary,
      ),
    );
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Gagal menyimpan resi ke galeri: $e'),
        backgroundColor: AppColors.danger,
      ),
    );
  } finally {
    if (mounted) {
      setState(() => _saving = false);
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 24, 28, 140),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.chevron_left_rounded,
                            color: Colors.white,
                            size: 34,
                          ),
                        ),
                      ),
                      const SizedBox(width: 22),
                      const Text(
                        'Download Resi',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  RepaintBoundary(
                    key: _receiptKey,
                    child: _buildReceiptCard(),
                  ),

                  const SizedBox(height: 26),

                  Text(
                    'Terimakasih telah melakukan pembayaran. Simpan resi\nini sebagai bukti pembayaran yang sah.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              right: -42,
              bottom: -18,
              child: Image.asset(
                'assets/images/maskot.png',
                width: 155,
                errorBuilder: (_, __, ___) => const SizedBox(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(28, 12, 28, 22),
        child: SizedBox(
          width: double.infinity,
          height: 58,
          child: ElevatedButton(
            onPressed: _saving ? null : _downloadReceipt,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _saving
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.4,
                    ),
                  )
                : const Text(
                    'Download Resi',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 34),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildLogo(),

          const SizedBox(height: 28),

          _dashedDivider(),

          const SizedBox(height: 18),

          _resiRow('Tanggal Bayar', _paymentDateText),
          _thinDivider(),
          _resiRow('Layanan', _serviceName),
          _thinDivider(),
          _resiRow('Nama Pelanggan', _customerName),
          _thinDivider(),
          _resiRow('No.Pelanggan', _customerNumber),
          _thinDivider(),
          _resiRow(
            'Total Pembayaran',
            formatRupiah(_paymentAmount),
            highlight: true,
          ),

          const SizedBox(height: 22),

          _thinDivider(),
          _resiRow('Bank Tujuan', 'PDAM'),
          _thinDivider(),
          _resiRow('Metode Pembayaran', _paymentMethod),
          _thinDivider(),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Image.asset(
      'assets/logo2.png',
      height: 48,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.water_drop_rounded,
              color: AppColors.primary,
              size: 42,
            ),
            const SizedBox(width: 6),
            RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: 'Amerta',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  TextSpan(
                    text: 'Pay',
                    style: TextStyle(
                      color: Color(0xFF5BC8F5),
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _resiRow(
    String label,
    String value, {
    bool highlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.textGrey,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: highlight ? AppColors.primary : AppColors.textDark,
                fontSize: 13,
                height: 1.15,
                fontWeight: highlight ? FontWeight.bold : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _thinDivider() {
    return Container(
      height: 1,
      color: const Color(0xFFE0E0E0),
    );
  }

  Widget _dashedDivider() {
    return LayoutBuilder(
      builder: (context, constraints) {
        const dashWidth = 8.0;
        const dashSpace = 6.0;

        final count = (constraints.maxWidth / (dashWidth + dashSpace)).floor();

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(count, (_) {
            return Container(
              width: dashWidth,
              height: 1.4,
              color: const Color(0xFFD7D7D7),
            );
          }),
        );
      },
    );
  }
}

// =============================================
// Bayar Bill View (Upload Bukti Pembayaran)
// =============================================
class BayarBillView extends StatefulWidget {
  final BillModel bill;

  const BayarBillView({super.key, required this.bill});

  @override
  State<BayarBillView> createState() => _BayarBillViewState();
}

class _BayarBillViewState extends State<BayarBillView> {
  File? _selectedFile;
  bool _loading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _confirmDeleteFile() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                            height: 1.25,
                          ),
                          children: [
                            TextSpan(text: 'Apakah Anda yakin\nuntuk '),
                            TextSpan(
                              text: 'menghapus\n',
                              style: TextStyle(color: AppColors.danger),
                            ),
                            TextSpan(text: 'Foto ini?'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.water_drop_rounded,
                      color: AppColors.primary,
                      size: 80,
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: AppColors.danger,
                            width: 1.5,
                          ),
                          foregroundColor: AppColors.danger,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Tidak',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Hapus',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirm == true && mounted) {
      setState(() {
        _selectedFile = null;
      });

      showSnackbar(context, 'Foto berhasil dihapus', isError: false);
    }
  }

  void _pickFile() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Pilih Sumber File',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _pickOption(Icons.camera_alt_rounded, 'Kamera', () async {
                  Navigator.pop(context);
                  final XFile? img = await _picker.pickImage(
                    source: ImageSource.camera,
                    imageQuality: 80,
                  );
                  if (img != null)
                    setState(() => _selectedFile = File(img.path));
                }),
                _pickOption(Icons.photo_library_rounded, 'Galeri', () async {
                  Navigator.pop(context);
                  final XFile? img = await _picker.pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 80,
                  );
                  if (img != null)
                    setState(() => _selectedFile = File(img.path));
                }),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _pickOption(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppColors.primary, size: 30),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  void _submit() async {
    if (_selectedFile == null) {
      showSnackbar(
        context,
        'Pilih file bukti pembayaran terlebih dahulu!',
        isError: true,
      );
      return;
    }
    setState(() => _loading = true);

    final paymentService = PaymentService();
    var result = await paymentService.createPayment(
      billId: widget.bill.id!,
      file: _selectedFile!,
    );

    setState(() => _loading = false);
    if (!mounted) return;

    if (result.status) {
      final paymentData = result.data;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BerhasilBayarView(
            bill: widget.bill,
            paymentId: paymentData?['id'],
            createdAt: paymentData?['created_at'] != null
                ? DateTime.tryParse(paymentData!['created_at'])
                : null,
          ),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => GagalBayarView(
            errors: [result.message ?? 'Gagal mengirim bukti pembayaran'],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Bayar Bill',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chevron_left,
              color: Colors.white,
              size: 20,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tagihan Bulan',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        '${widget.bill.monthName} ${widget.bill.year}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Icon(Icons.water_drop, color: Colors.white, size: 50),
                ],
              ),
            ),

            const SizedBox(height: 16),

            _buildInfoCard(),
            const SizedBox(height: 12),

            _buildBankCard(),
            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.warning,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Setelah melakukan transfer, harap upload bukti pembayaran untuk diverifikasi oleh admin.',
                      style: TextStyle(color: AppColors.warning, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            _buildUploadSection(),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _loading ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: _loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : const Text(
                    'Bayar Sekarang',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Informasi Tagihan',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          _rowItem(
            'Jumlah Dibayar',
            formatRupiah(widget.bill.amount.toDouble()),
          ),
          _rowItem('Metode Pembayaran', 'Transfer Bank'),
          _rowItem('Tanggal Pembayaran', _todayStr()),
          _rowItem('Layanan', widget.bill.customer?.service?.name ?? '-'),
          _rowItem('Pemakaian Air', '${widget.bill.usageValue} m³'),
        ],
      ),
    );
  }

  Widget _buildBankCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.account_balance,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Transfer ke Rekening PDAM',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _rowItemColored('Bank', 'BCA'),
          _rowItemColored('Nomor Rekening', '1234567890'),
          _rowItemColored('Atas Nama', 'PDAM AmertaPay'),
        ],
      ),
    );
  }

  Widget _buildUploadSection() {
    return Container(
      width: double.infinity,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upload Bukti Pembayaran',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            'Format file: JPG, JPEG, PNG, PDF. Maks 5 MB',
            style: TextStyle(color: AppColors.textGrey, fontSize: 12),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _pickFile,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.cloud_upload_outlined,
                    color: AppColors.primary,
                    size: 36,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Klik untuk pilih file',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Atau seret file ke sini',
                    style: TextStyle(color: AppColors.textGrey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          if (_selectedFile != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.successLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.success.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.insert_drive_file_rounded,
                    color: AppColors.success,
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedFile!.path.split('/').last,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          _formatFileSize(_selectedFile!.lengthSync()),
                          style: TextStyle(
                            color: AppColors.textGrey,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: _confirmDeleteFile,
                    child: const Text(
                      'Hapus',
                      style: TextStyle(
                        color: AppColors.danger,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _rowItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: AppColors.textGrey, fontSize: 13),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _rowItemColored(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.remove, color: AppColors.primary, size: 14),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(color: AppColors.textGrey, fontSize: 13),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  String _todayStr() {
    final now = DateTime.now();
    const months = [
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
    return '${now.day} ${months[now.month]} ${now.year}';
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

// =============================================
// Berhasil Bayar View
// =============================================
class BerhasilBayarView extends StatelessWidget {
  final BillModel bill;
  final int? paymentId;
  final DateTime? createdAt;

  const BerhasilBayarView({
    super.key,
    required this.bill,
    this.paymentId,
    this.createdAt,
  });

  String _formatDateTime(DateTime dt) {
    const months = [
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
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${months[dt.month]} ${dt.year}\n$h:$m WIB';
  }

  @override
  Widget build(BuildContext context) {
    final sentAt = createdAt ?? DateTime.now();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chevron_left,
              color: Colors.white,
              size: 20,
            ),
          ),
          onPressed: () =>
              Navigator.pushReplacementNamed(context, '/customer-dashboard'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Spacer(),

            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.successLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.check_rounded,
                color: AppColors.success,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Pembayaran\nBerhasil Dikirim',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Bukti pembayaran Anda telah berhasil dikirim dan sedang menunggu verifikasi dari admin PDAM.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textGrey,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),

            Container(
              width: double.infinity,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Status',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.warningLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Text(
                        'Menunggu Verifikasi',
                        style: TextStyle(
                          color: AppColors.warning,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.receipt_long_rounded,
                          color: AppColors.primary,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Informasi Tagihan',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  _infoRow('ID Tagihan', 'Bill #${bill.id}'),
                  _infoRow(
                    'Total Tagihan',
                    formatRupiah(bill.amount.toDouble()),
                  ),
                  _infoRow('Tanggal Kirim', _formatDateTime(sentAt)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: AppColors.primary,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Anda akan menerima pembaruan status setelah pembayaran selesai diverifikasi oleh admin.',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.pushReplacementNamed(
                  context,
                  '/customer-riwayat',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Lihat riwayat Pembayaran',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: AppColors.textGrey, fontSize: 13),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: AppColors.textDark,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================
// Gagal Kirim View
// =============================================
class GagalBayarView extends StatelessWidget {
  final List<String> errors;

  const GagalBayarView({super.key, this.errors = const []});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chevron_left,
              color: Colors.white,
              size: 20,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Spacer(),

            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.dangerLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.close_rounded,
                color: AppColors.danger,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Pembayaran Gagal Dikirim',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Terjadi kendala saat mengirim bukti pembayaran. Silakan periksa kembali dan coba lagi.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textGrey,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),

            if (errors.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.dangerLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.danger.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Kemungkinan Penyebab',
                      style: TextStyle(
                        color: AppColors.danger,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...errors.map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.danger,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                e,
                                style: const TextStyle(
                                  color: AppColors.danger,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Coba Lagi',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () => Navigator.pushReplacementNamed(
                  context,
                  '/customer-riwayat',
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Lihat riwayat Pembayaran',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================
// Pembayaran Ditolak View
// =============================================
class PembayaranDitolakView extends StatelessWidget {
  final BillModel bill;
  final String? rejectionReason;
  final DateTime? sentAt;

  const PembayaranDitolakView({
    super.key,
    required this.bill,
    this.rejectionReason,
    this.sentAt,
  });

  String _formatDateTime(DateTime dt) {
    const months = [
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
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${months[dt.month]} ${dt.year}\n$h:$m WIB';
  }

  @override
  Widget build(BuildContext context) {
    final displayDate = sentAt ?? DateTime.now();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chevron_left,
              color: Colors.white,
              size: 20,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Spacer(),

            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.dangerLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.close_rounded,
                color: AppColors.danger,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Pembayaran Ditolak',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Bukti pembayaran yang Anda kirim belum dapat diverifikasi oleh admin PDAM.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textGrey,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.dangerLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.danger.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: AppColors.danger,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Silahkan Unggah Bukti pembayaran yang valid',
                      style: TextStyle(color: AppColors.danger, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            Container(
              width: double.infinity,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.receipt_long_rounded,
                          color: AppColors.primary,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Informasi Tagihan',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  _infoRow('ID Tagihan', 'Bill #${bill.id}'),
                  _infoRow(
                    'Total Tagihan',
                    formatRupiah(bill.amount.toDouble()),
                  ),
                  _infoRow('Tanggal Kirim', _formatDateTime(displayDate)),
                ],
              ),
            ),

            if (rejectionReason != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Alasan Penolakan',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      rejectionReason!,
                      style: TextStyle(color: AppColors.textGrey, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => BayarBillView(bill: bill)),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Upload ulang bukti',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: AppColors.textGrey, fontSize: 13),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: AppColors.textDark,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
  
}
