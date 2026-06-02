import 'package:amerta_pay/app_theme.dart';
import 'package:amerta_pay/services/customer_service.dart';
import 'package:amerta_pay/services/url.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../services/bill_service.dart';
import '../../../services/payment_service.dart';

class DetailBillView extends StatefulWidget {
  final int billId;
  const DetailBillView({Key? key, required this.billId}) : super(key: key);

  @override
  State<DetailBillView> createState() => _DetailBillViewState();
}

class _DetailBillViewState extends State<DetailBillView> {
  Map<String, dynamic>? _billData;
  bool _loading = true;
  final BillService _billService = BillService();
  final PaymentService _paymentService = PaymentService();
  final CustomerService _customerService = CustomerService();
String _serviceNameFromCustomer = '-';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    final r = await _billService.getById(widget.billId);

    print('DETAIL BILL RESPONSE:');
    print(r);

    if (mounted) {
      setState(() {
        _loading = false;
        if (r['status'] == true) {
          _billData = r['data'] as Map<String, dynamic>;
        }
      });
    }
  }

  String get _status {
  final paid = _billData?['paid'] == true;
  final verified = _billData?['verified_payment'] == true;

  final paymentStatus = (_payment?['status'] ?? _billData?['payment_status'])
      ?.toString()
      .toUpperCase()
      .replaceAll(' ', '_');

  // 1. Kalau payment ditolak, status bill balik jadi belum dibayar
  if (paymentStatus == 'REJECTED' ||
      paymentStatus == 'DITOLAK' ||
      paymentStatus == 'FAILED' ||
      paymentStatus == 'CANCELED' ||
      paymentStatus == 'CANCELLED' ||
      paymentStatus == 'DECLINED' ||
      paymentStatus == 'DENIED') {
    return 'belum_dibayar';
  }

  // 2. Kalau sudah diverifikasi/lunas
  if (verified ||
      paymentStatus == 'VERIFIED' ||
      paymentStatus == 'SUCCESS' ||
      paymentStatus == 'LUNAS' ||
      paymentStatus == 'PAID' ||
      paymentStatus == 'APPROVED') {
    return 'lunas';
  }

  // 3. Kalau customer sudah upload bukti, harus jadi Menunggu Verifikasi
  // Ini wajib sebelum pengecekan !paid
  if (paymentStatus == 'PENDING' ||
      paymentStatus == 'WAITING' ||
      paymentStatus == 'BELUM_DIVERIFIKASI' ||
      paymentStatus == 'MENUNGGU_VERIFIKASI' ||
      paymentStatus == 'UNVERIFIED') {
    return 'belum_diverifikasi';
  }

  // 4. Fallback kalau backend set paid=true tapi verified=false
  if (paid && !verified) {
    return 'belum_diverifikasi';
  }

  return 'belum_dibayar';
}

  Map<String, dynamic>? get _payment {
    final p = _billData?['payments'];

    if (p is Map<String, dynamic>) {
      return p;
    }

    if (p is List && p.isNotEmpty) {
      final payments = p
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();

      if (payments.isEmpty) return null;

      payments.sort((a, b) {
        final aId = int.tryParse(a['id']?.toString() ?? '0') ?? 0;
        final bId = int.tryParse(b['id']?.toString() ?? '0') ?? 0;
        return bId.compareTo(aId);
      });

      return payments.first;
    }

    return null;
  }

  int? get _paymentId => _payment?['id'];
  String get _serviceName {
  final customer = _billData?['customer'];
  final service = _billData?['service'];

  if (service is Map) {
    final name = service['name'] ??
        service['service_name'] ??
        service['title'] ??
        service['type'];

    if (name != null && name.toString().trim().isNotEmpty) {
      return name.toString();
    }
  }

  if (customer is Map) {
    final customerService = customer['service'];

    if (customerService is Map) {
      final name = customerService['name'] ??
          customerService['service_name'] ??
          customerService['title'] ??
          customerService['type'];

      if (name != null && name.toString().trim().isNotEmpty) {
        return name.toString();
      }
    }

    final directName = customer['service_name'] ??
        customer['serviceName'] ??
        customer['layanan'] ??
        customer['service_type'];

    if (directName != null && directName.toString().trim().isNotEmpty) {
      return directName.toString();
    }
  }

  final rootName = _billData?['service_name'] ??
      _billData?['serviceName'] ??
      _billData?['layanan'] ??
      _billData?['service_type'];

  if (rootName != null && rootName.toString().trim().isNotEmpty) {
    return rootName.toString();
  }

  return '-';
}

  String _formatCurrency(dynamic val) {
    if (val == null) return '-';

    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return formatter.format(val);
  }

  String _monthName(int? month) {
    if (month == null) return '-';
    const months = [
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return month >= 1 && month <= 12 ? months[month] : '$month';
  }

  Future<void> _showVerifyDialog() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: 16, color: AppColors.textDark),
                  children: [
                    TextSpan(text: 'Apakah Anda yakin\nuntuk '),
                    TextSpan(
                      text: 'memverifikasi',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(text: '\npembayaran ini?'),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Image.asset(
              'assets/bayar.png',
              width: 48,
              height: 48,
              fit: BoxFit.contain,
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context, false),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.danger),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Tolak',
                style: TextStyle(color: AppColors.danger),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Verifikasi',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
    if (confirm != true || _paymentId == null) return;

    final r = await _paymentService.verify(_paymentId!);

    if (r['status'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pembayaran berhasil diverifikasi')),
      );

      await _load();

      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  String get _statusLabel {
    switch (_status) {
      case 'belum_dibayar':
        return 'Belum Dibayar';
      case 'belum_diverifikasi':
        return 'Menunggu Verifikasi';
      case 'lunas':
        return 'Lunas';
      default:
        return _status;
    }
  }

  Color get _statusBadgeColor {
    switch (_status) {
      case 'belum_dibayar':
        return AppColors.danger;
      case 'belum_diverifikasi':
        return AppColors.statusBelumDiverifikasi;
      case 'lunas':
        return AppColors.statusDibayar;
      default:
        return AppColors.textGrey;
    }
  }

  Future<void> _showRejectDialog() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: 16, color: AppColors.textDark),
                  children: [
                    TextSpan(text: 'Apakah Anda yakin\nuntuk '),
                    TextSpan(
                      text: 'menolak',
                      style: TextStyle(
                        color: AppColors.danger,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(text: '\npembayaran ini?'),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Image.asset(
              'assets/bayar.png',
              width: 48,
              height: 48,
              fit: BoxFit.contain,
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context, false),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.textGrey),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Batal',
                style: TextStyle(color: AppColors.textGrey),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Tolak', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && _paymentId != null) {
      final r = await _paymentService.reject(_paymentId!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(r['message'] ?? 'Pembayaran berhasil ditolak'),
          ),
        );

        await _load();

        if (mounted) {
          Navigator.pop(context, true);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Detail Bill',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _billData == null
          ? const Center(child: Text('Gagal memuat data'))
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Customer header card
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F0FB),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.people,
                                  color: Color(0xFF4A90D9),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _billData!['customer']?['name'] ?? '-',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      _billData!['customer']?['customer_number'] ??
                                          '-',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textGrey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _statusBadgeColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _statusLabel,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: _statusBadgeColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Info Tagihan
                        _SectionCard(
                          title: 'Informasi Tagihan',
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Bulan Tagihan',
                                  style: TextStyle(color: AppColors.textGrey),
                                ),
                                const Spacer(),
                                Text(
                                  '${_monthName(_billData!['month'])} ${_billData!['year'] ?? ''}',
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Text(
                                  'Layanan',
                                  style: TextStyle(color: AppColors.textGrey),
                                ),
                                const Spacer(),
                                Text(_serviceName),
                              ],
                            ),
                            Row(
                              children: [
                                const Text(
                                  'Pemakaian Air',
                                  style: TextStyle(color: AppColors.textGrey),
                                ),
                                const Spacer(),
                                Text('${_billData!['usage_value'] ?? '-'}m³'),
                              ],
                            ),
                            Row(
                              children: [
                                const Text(
                                  'Pemakaian Air',
                                  style: TextStyle(color: AppColors.textGrey),
                                ),
                                const Spacer(),
                                Text('${_billData!['usage_value'] ?? '-'}m³'),
                              ],
                            ),
                            Row(
                              children: [
                                const Text(
                                  'Total Tagihan',
                                  style: TextStyle(color: AppColors.textGrey),
                                ),
                                const Spacer(),
                                Text(_formatCurrency(_billData!['amount'])),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Info Pembayaran
                        _SectionCard(
                          title: 'Informasi Pembayaran',
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Tanggal Bayar',
                                  style: TextStyle(color: AppColors.textGrey),
                                ),
                                const Spacer(),
                                Text(
                                  _payment?['payment_date'] != null
                                      ? DateFormat(
                                          'dd MMM yyyy HH:mm',
                                          'id_ID',
                                        ).format(
                                          DateTime.parse(
                                            _payment!['payment_date'],
                                          ).toLocal(),
                                        )
                                      : '-',
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Text(
                                  'Metode',
                                  style: TextStyle(color: AppColors.textGrey),
                                ),
                                const Spacer(),
                                Text(_payment?['method'] ?? '-'),
                              ],
                            ),
                            Row(
                              children: [
                                const Text(
                                  'Jumlah di bayar',
                                  style: TextStyle(color: AppColors.textGrey),
                                ),
                                const Spacer(),
                                Text(
                                  _payment != null
                                      ? _formatCurrency(
                                          _payment!['total_amount'],
                                        )
                                      : '-',
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Bukti Pembayaran
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Bukti Pembayaran',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 12),
                              if (_payment == null ||
                                  _payment!['payment_proof'] == null)
                                const Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    child: Text(
                                      'Customer belum mengupload foto',
                                      style: TextStyle(
                                        color: AppColors.textGrey,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                )
                              else
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (_) => Dialog(
                                            backgroundColor: Colors.black,
                                            insetPadding: const EdgeInsets.all(
                                              10,
                                            ),
                                            child: InteractiveViewer(
                                              minScale: 0.5,
                                              maxScale: 4,
                                              child: Image.network(
                                                '$baseUrl/payment-proof/${_payment!['payment_proof']}',
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          '$baseUrl/payment-proof/${_payment!['payment_proof']}',
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              Container(
                                                width: 60,
                                                height: 60,
                                                color: Colors.grey.shade200,
                                                child: const Icon(
                                                  Icons.image,
                                                  color: AppColors.textGrey,
                                                ),
                                              ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _payment!['payment_proof'] ?? '',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const Text(
                                            'bukti pembayaran',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: AppColors.textGrey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.remove_red_eye_outlined,
                                        color: AppColors.textDark,
                                      ),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (_) => Dialog(
                                            backgroundColor: Colors.black,
                                            insetPadding: const EdgeInsets.all(
                                              10,
                                            ),
                                            child: InteractiveViewer(
                                              minScale: 0.5,
                                              maxScale: 4,
                                              child: Image.network(
                                                '$baseUrl/payment-proof/${_payment!['payment_proof']}',
                                                fit: BoxFit.contain,
                                                errorBuilder: (_, __, ___) =>
                                                    const Padding(
                                                      padding: EdgeInsets.all(
                                                        20,
                                                      ),
                                                      child: Text(
                                                        'Gagal memuat gambar',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom action buttons
                Container(
                  padding: const EdgeInsets.all(20),
                  color: AppColors.background,
                  child: _status == 'belum_diverifikasi'
                      ? Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _showRejectDialog,
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: AppColors.danger,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                                child: const Text(
                                  'Tolak',
                                  style: TextStyle(
                                    color: AppColors.danger,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _showVerifyDialog,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                                child: const Text(
                                  'Verifikasi',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Kembali',
                            style: TextStyle(color: AppColors.primary),
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}
