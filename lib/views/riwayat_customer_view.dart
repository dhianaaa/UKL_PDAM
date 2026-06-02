import 'package:amerta_pay/app_theme.dart';
import 'package:amerta_pay/app_widget.dart' hide AppColors;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/payment_model.dart';
import '../../services/payment_service.dart';

class CustomerRiwayatView extends StatefulWidget {
  const CustomerRiwayatView({super.key});

  @override
  State<CustomerRiwayatView> createState() => _CustomerRiwayatViewState();
}

class _CustomerRiwayatViewState extends State<CustomerRiwayatView> {
  final PaymentService _paymentService = PaymentService();
  List<PaymentModel> _allPayments = [];
  List<PaymentModel> _filteredPayments = [];
  bool _loading = true;
  String _activeFilter = 'Semua';
  final TextEditingController _searchCtrl = TextEditingController();
  String _paymentStatus(PaymentModel p) {
    final s = (p.status ?? '').toUpperCase();

    if (s == 'PENDING' || s == 'WAITING' || s == 'BELUM_DIVERIFIKASI') {
      return 'PENDING';
    }

    if (s == 'VERIFIED' || s == 'SUCCESS' || s == 'LUNAS') {
      return 'VERIFIED';
    }

    if (s == 'REJECTED' || s == 'DITOLAK') {
      return 'REJECTED';
    }

    return 'PENDING';
  }

  final List<String> _filters = [
    'Semua',
    'Menunggu Verifikasi',
    'Berhasil',
    'Ditolak',
  ];

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  void _loadPayments() async {
  setState(() => _loading = true);

  final result = await _paymentService.getMyPayments();

  if (!mounted) return;

  setState(() {
    _allPayments = result.status
        ? List<PaymentModel>.from(result.data ?? [])
        : [];

    _loading = false;
  });

  _applyFilter();
}
        // String _paymentStatus(PaymentModel p) {
        //   final s = (p.status ?? '').toUpperCase();

        //   if (s == 'PENDING' || s == 'WAITING' || s == 'BELUM_DIVERIFIKASI') {
        //     return 'PENDING';
        //   }

        //   if (s == 'VERIFIED' || s == 'SUCCESS' || s == 'LUNAS') {
        //     return 'VERIFIED';
        //   }

        //   if (s == 'REJECTED' || s == 'DITOLAK') {
        //     return 'REJECTED';
        //   }

        //   return 'PENDING';
        // }

  //       void _applyFilter() {
  //         List<PaymentModel> temp = List.from(_allPayments);

  //         if (_activeFilter == 'Menunggu Verifikasi') {
  //           temp = temp.where((p) => _paymentStatus(p) == 'PENDING').toList();
  //         } else if (_activeFilter == 'Berhasil') {
  //           temp = temp.where((p) => _paymentStatus(p) == 'VERIFIED').toList();
  //         } else if (_activeFilter == 'Ditolak') {
  //           temp = temp.where((p) => _paymentStatus(p) == 'REJECTED').toList();
  //         }

  //         if (_searchCtrl.text.isNotEmpty) {
  //           final keyword = _searchCtrl.text.toLowerCase();

  //           temp = temp.where((p) {
  //             final month = p.bill?.monthName.toLowerCase() ?? '';
  //             final year = p.bill?.year.toString() ?? '';
  //             final service =
  //                 p.bill?.customer?.service?.name.toLowerCase() ?? '';

  //             return month.contains(keyword) ||
  //                 year.contains(keyword) ||
  //                 service.contains(keyword);
  //           }).toList();
  //         }

  //         setState(() {
  //           _filteredPayments = temp;
  //         });
  //       }

  //       _loading = false;
  //     });
  //   }
  // }

  void _applyFilter() {
    List<PaymentModel> temp = List.from(_allPayments);

    // Filter by status
    if (_activeFilter == 'Menunggu Verifikasi') {
      temp = temp.where((p) => p.status?.toUpperCase() == 'PENDING').toList();
    } else if (_activeFilter == 'Berhasil') {
      temp = temp.where((p) => p.status?.toUpperCase() == 'VERIFIED').toList();
    } else if (_activeFilter == 'Ditolak') {
      temp = temp.where((p) => p.status?.toUpperCase() == 'REJECTED').toList();
    }

    // Filter by search
    if (_searchCtrl.text.isNotEmpty) {
      temp = temp
          .where(
            (p) =>
                (p.bill?.monthName.toLowerCase().contains(
                      _searchCtrl.text.toLowerCase(),
                    ) ??
                    false) ||
                (p.bill?.year.toString().contains(_searchCtrl.text) ?? false),
          )
          .toList();
    }

    setState(() => _filteredPayments = temp);
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
          'Riwayat Bill',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
            fontSize: 18,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Search & filter bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (_) => _applyFilter(),
                    decoration: InputDecoration(
                      hintText: 'Cari layanan...',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.textGrey,
                        size: 20,
                      ),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/customer-bayar'),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 22),
                  ),
                ),
              ],
            ),
          ),

          // Filter chips
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((f) => _buildFilterChip(f)).toList(),
              ),
            ),
          ),

          // List
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : RefreshIndicator(
                    onRefresh: () async => _loadPayments(),
                    color: AppColors.primary,
                    child: _filteredPayments.isEmpty
                        ? _buildEmpty()
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredPayments.length,
                            itemBuilder: (context, index) =>
                                _buildPaymentCard(_filteredPayments[index]),
                          ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomerBottomNav(activeIndex: 2),
    );
  }

  Widget _buildFilterChip(String label) {
    bool isActive = _activeFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() => _activeFilter = label);
        _applyFilter();
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppColors.primary : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : AppColors.textGrey,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.25),
        Center(
          child: Column(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.water_drop_outlined,
                  color: Colors.grey.shade400,
                  size: 50,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Kosong! Tidak ada apa apa disini!',
                style: TextStyle(color: AppColors.textGrey, fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentCard(PaymentModel p) {
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
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.receipt_rounded,
                color: Color(0xFF4CAF50),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tagihan ${p.bill?.monthName} ${p.bill?.year}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    formatRupiah(p.amount?.toDouble() ?? 0),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _formatDate(p.paymentDate ?? p.createdAt),
                    style: TextStyle(fontSize: 11, color: AppColors.textGrey),
                  ),
                ],
              ),
            ),
            _paymentBadge(_paymentStatus(p)),
          ],
        ),
      ),
    );
  }

  void _showPaymentDetail(PaymentModel p) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PaymentDetailSheet(payment: p),
    );
  }
}

class _PaymentDetailSheet extends StatelessWidget {
  final PaymentModel payment;
  const _PaymentDetailSheet({required this.payment});

  String _statusLabel(String? s) {
    switch (s?.toUpperCase()) {
      case 'PENDING':
        return 'Menunggu Verifikasi';
      case 'VERIFIED':
        return 'Diverifikasi';
      case 'REJECTED':
        return 'Ditolak';
      default:
        return s ?? '-';
    }
  }

  Color _statusColor(String? s) {
    switch (s?.toUpperCase()) {
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

  Color _statusBg(String? s) {
    switch (s?.toUpperCase()) {
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

  String _formatDateTime(String? value) {
    if (value == null || value.isEmpty) return '-';

    final date = DateTime.tryParse(value);
    if (date == null) return value;

    return DateFormat('dd MMM yyyy HH:mm', 'id_ID').format(date.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    final p = payment;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
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
          _row(
            'Tagihan',
            'Tagihan ${p.bill?.monthName ?? '-'} ${p.bill?.year ?? '-'}',
          ),
          _row('Jumlah Bayar', formatRupiah(p.amount?.toDouble() ?? 0)),
          _row(
            p.status.toUpperCase() == 'VERIFIED'
                ? 'Tanggal Bayar'
                : 'Tanggal Kirim',
            _formatDateTime(p.paymentDate ?? p.createdAt),
          ),
          _row('Metode', p.method ?? 'Transfer Bank'),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: _statusBg(p.status),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                _statusLabel(p.status),
                style: TextStyle(
                  color: _statusColor(p.status),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          if (p.rejectionNote != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.dangerLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.danger.withOpacity(0.3)),
              ),
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
                    p.rejectionNote!,
                    style: const TextStyle(
                      color: AppColors.danger,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
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
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
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

Widget _paymentBadge(String status) {
  Color color;
  Color bg;
  String label;

  switch (status) {
    case 'PENDING':
      color = AppColors.warning;
      bg = AppColors.warningLight;
      label = 'Menunggu Verifikasi';
      break;
    case 'VERIFIED':
      color = AppColors.success;
      bg = AppColors.successLight;
      label = 'Terverifikasi';
      break;
    case 'REJECTED':
      color = AppColors.danger;
      bg = AppColors.dangerLight;
      label = 'Ditolak';
      break;
    default:
      color = AppColors.textGrey;
      bg = AppColors.background;
      label = status;
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
    ),
  );
}

String _formatDate(String? value) {
  if (value == null || value.isEmpty) return '-';

  final date = DateTime.tryParse(value);
  if (date == null) return value;

  return DateFormat('dd MMM yyyy', 'id_ID').format(date.toLocal());
}
