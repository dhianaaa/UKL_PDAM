

import 'package:amerta_pay/app_theme.dart';
import 'package:amerta_pay/models/admin_model.dart';
import 'package:amerta_pay/services/url.dart';
import 'package:amerta_pay/widgets/bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../../services/bill_service.dart';
import '../../../models/bill_model.dart';
import 'tambah_bill_view.dart';
import 'detail_bill_view.dart';
import 'dart:convert';

class KelolaBillView extends StatefulWidget {
  const KelolaBillView({Key? key}) : super(key: key);

  @override
  State<KelolaBillView> createState() => _KelolaBillViewState();
}

class _KelolaBillViewState extends State<KelolaBillView> {
  final BillService _service = BillService();
  List<BillModel> _bills = [];
  bool _loading = true;
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  // Map dari bill_id → status payment terbaru dari /payments
  // Ini yang jadi sumber kebenaran utama
  Map<int, String> _paymentStatusMap = {};

  // 0 = Semua, 1 = Belum Dibayar, 2 = Belum Diverifikasi, 3 = Lunas
  int _activeFilter = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Fetch semua payments dari /payments, lalu buat map bill_id → status terbaru
  Future<Map<int, String>> _fetchPaymentStatusMap() async {
  try {
    final auth = await AuthModel.getFromPrefs();
    final token = auth.token;

    final res = await http.get(
      Uri.parse('$baseUrl/payments?page=1&quantity=100'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        if (appKey.isNotEmpty) 'app-key': appKey,
      },
    );

    if (res.statusCode != 200) {
      print('PAYMENTS STATUS ERROR: ${res.statusCode}');
      print(res.body);
      return {};
    }

    final body = jsonDecode(res.body);

    List<dynamic> allPayments = [];

    if (body is List) {
      allPayments = body;
    } else if (body is Map) {
      final data = body['data'];

      if (data is List) {
        allPayments = data;
      } else if (data is Map) {
        final nested = data['data'] ?? data['items'] ?? data['payments'];
        if (nested is List) {
          allPayments = nested;
        }
      } else {
        final alt = body['payments'] ?? body['items'];
        if (alt is List) {
          allPayments = alt;
        }
      }
    }

    print('ALL PAYMENTS ADMIN: $allPayments');

    final Map<int, Map<String, dynamic>> latestByBill = {};

    for (final raw in allPayments) {
      if (raw is! Map) continue;

      final p = Map<String, dynamic>.from(raw);

      final billRaw = p['bill'];
      final billId = int.tryParse(
        (p['bill_id'] ??
                p['billId'] ??
                (billRaw is Map ? billRaw['id'] : null))
            ?.toString() ??
            '',
      );

      if (billId == null) continue;

      final paymentId = int.tryParse(p['id']?.toString() ?? '0') ?? 0;

      final oldPayment = latestByBill[billId];
      final oldPaymentId = int.tryParse(
            oldPayment?['id']?.toString() ?? '0',
          ) ??
          0;

      if (oldPayment == null || paymentId > oldPaymentId) {
        latestByBill[billId] = p;
      }
    }

    final result = latestByBill.map((billId, p) {
      final status = (p['status'] ??
              p['payment_status'] ??
              p['paymentStatus'] ??
              '')
          .toString()
          .toUpperCase()
          .replaceAll(' ', '_');

      return MapEntry(billId, status);
    });

    print('PAYMENT STATUS MAP ADMIN: $result');

    return result;
  } catch (e) {
    print('FETCH PAYMENT STATUS MAP ERROR: $e');
    return {};
  }
}

  Future<void> _loadData() async {
    setState(() => _loading = true);

    // Fetch bills DAN payment status map secara bersamaan
    final results = await Future.wait([
      _service.getAll(search: _searchQuery, quantity: 50),
      _fetchPaymentStatusMap(),
    ]);

    final billResult = results[0] as Map<String, dynamic>;
    final paymentMap = results[1] as Map<int, String>;

    if (mounted) {
      setState(() {
        _loading = false;
        if (billResult['status'] == true) {
          _bills = billResult['data'] as List<BillModel>;
        }
        _paymentStatusMap = paymentMap;
      });
    }
  }

  Future<void> _confirmDelete(BillModel b) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Tagihan?'),
        content: Text('Apakah yakin ingin menghapus ${b.invoiceNumber}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Hapus',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final r = await _service.delete(b.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(r['message']),
            backgroundColor:
                r['status'] == true ? AppColors.primary : AppColors.danger,
          ),
        );
        if (r['status'] == true) _loadData();
      }
    }
  }

  // Sumber kebenaran status bill:
  // 1. Cek _paymentStatusMap (dari /payments endpoint) — paling akurat
  // 2. Fallback ke field di BillModel jika tidak ada di map
  String _billDisplayStatus(BillModel b) {
  final mapStatus = _paymentStatusMap[b.id]
      ?.toString()
      .toUpperCase()
      .replaceAll(' ', '_');

  // 1. Prioritas utama: status payment terbaru dari /payments
  if (mapStatus != null && mapStatus.isNotEmpty) {
    if (mapStatus == 'REJECTED' ||
        mapStatus == 'DITOLAK' ||
        mapStatus == 'FAILED' ||
        mapStatus == 'CANCELED' ||
        mapStatus == 'CANCELLED' ||
        mapStatus == 'DECLINED' ||
        mapStatus == 'DENIED') {
      return 'belum_dibayar';
    }

    if (mapStatus == 'VERIFIED' ||
        mapStatus == 'SUCCESS' ||
        mapStatus == 'LUNAS' ||
        mapStatus == 'PAID' ||
        mapStatus == 'APPROVED') {
      return 'lunas';
    }

    if (mapStatus == 'PENDING' ||
        mapStatus == 'WAITING' ||
        mapStatus == 'BELUM_DIVERIFIKASI' ||
        mapStatus == 'MENUNGGU_VERIFIKASI' ||
        mapStatus == 'UNVERIFIED') {
      return 'belum_diverifikasi';
    }
  }

  // 2. Fallback dari BillModel
  final billPaymentStatus = b.paymentStatus
      ?.toString()
      .toUpperCase()
      .replaceAll(' ', '_');

  final billStatus = b.status
      .toString()
      .toUpperCase()
      .replaceAll(' ', '_');

  if (billPaymentStatus == 'REJECTED' ||
      billPaymentStatus == 'DITOLAK' ||
      billPaymentStatus == 'FAILED' ||
      billStatus == 'DITOLAK') {
    return 'belum_dibayar';
  }

  if (b.verifiedPayment == true ||
      billPaymentStatus == 'VERIFIED' ||
      billPaymentStatus == 'SUCCESS' ||
      billPaymentStatus == 'LUNAS' ||
      billPaymentStatus == 'PAID' ||
      billPaymentStatus == 'APPROVED' ||
      billStatus == 'LUNAS') {
    return 'lunas';
  }

  if (billPaymentStatus == 'PENDING' ||
      billPaymentStatus == 'WAITING' ||
      billPaymentStatus == 'BELUM_DIVERIFIKASI' ||
      billPaymentStatus == 'MENUNGGU_VERIFIKASI' ||
      billPaymentStatus == 'UNVERIFIED' ||
      billStatus == 'BELUM_DIVERIFIKASI') {
    return 'belum_diverifikasi';
  }

  // 3. Kalau backend set paid=true tapi verified=false, anggap menunggu verif
  if (b.paid == true && b.verifiedPayment == false) {
    return 'belum_diverifikasi';
  }

  return 'belum_dibayar';
}

  List<BillModel> get _filteredBills {
    if (_activeFilter == 0) return _bills;
    return _bills.where((b) {
      final st = _billDisplayStatus(b);
      switch (_activeFilter) {
        case 1:
          return st == 'belum_dibayar';
        case 2:
          return st == 'belum_diverifikasi';
        case 3:
          return st == 'lunas';
        default:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: const BottomNavAdmin(3),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header + Search + Tombol Tambah ──────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text('Kelola Bill', style: AppTextStyles.heading),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                              )
                            ],
                          ),
                          child: TextField(
                            controller: _searchCtrl,
                            onSubmitted: (v) {
                              _searchQuery = v;
                              _loadData();
                            },
                            onChanged: (v) {
                              if (v.isEmpty) {
                                _searchQuery = '';
                                _loadData();
                              }
                            },
                            decoration: const InputDecoration(
                              hintText: 'Cari bill...',
                              hintStyle: TextStyle(
                                color: AppColors.textGrey,
                                fontSize: 13,
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color: AppColors.textGrey,
                                size: 20,
                              ),
                              border: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const TambahBillView(),
                            ),
                          );
                          _loadData();
                        },
                        child: Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.add, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Filter Tab Row ────────────────────────────────
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _FilterTab(
                    label: 'Semua',
                    active: _activeFilter == 0,
                    onTap: () => setState(() => _activeFilter = 0),
                  ),
                  const SizedBox(width: 8),
                  _FilterTab(
                    label: 'Belum dibayar',
                    active: _activeFilter == 1,
                    onTap: () => setState(() => _activeFilter = 1),
                  ),
                  const SizedBox(width: 8),
                  _FilterTab(
                    label: 'Belum Diverifikasi',
                    active: _activeFilter == 2,
                    onTap: () => setState(() => _activeFilter = 2),
                  ),
                  const SizedBox(width: 8),
                  _FilterTab(
                    label: 'Lunas',
                    active: _activeFilter == 3,
                    onTap: () => setState(() => _activeFilter = 3),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ── Daftar Bill ───────────────────────────────────
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primary),
                    )
                  : _filteredBills.isEmpty
                      ? const Center(
                          child: Text(
                            'Belum ada tagihan',
                            style: TextStyle(color: AppColors.textGrey),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadData,
                          color: AppColors.primary,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 8),
                            itemCount: _filteredBills.length,
                            itemBuilder: (_, i) {
                              final b = _filteredBills[i];
                              final displayStatus = _billDisplayStatus(b);
                              return GestureDetector(
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          DetailBillView(billId: b.id),
                                    ),
                                  );
                                  // Refresh setelah kembali dari detail
                                  // (bisa saja status berubah setelah verif/tolak)
                                  _loadData();
                                },
                                child: _BillCard(
                                  bill: b,
                                  displayStatus: displayStatus,
                                  onEdit: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            DetailBillView(billId: b.id),
                                      ),
                                    );
                                    _loadData();
                                  },
                                  onDelete: () => _confirmDelete(b),
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Widget: Filter Tab
// ─────────────────────────────────────────────────────────────
class _FilterTab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _FilterTab(
      {required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? AppColors.primary : const Color(0xFFDDDDDD),
            width: 1.2,
          ),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.20),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : AppColors.textGrey,
            fontSize: 13,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Widget: Bill Card
// ─────────────────────────────────────────────────────────────
class _BillCard extends StatelessWidget {
  final BillModel bill;
  final String displayStatus;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _BillCard({
    required this.bill,
    required this.displayStatus,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  bill.invoiceNumber,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              _ActionButton(
                icon: Icons.edit_outlined,
                iconColor: AppColors.textGrey,
                borderColor: const Color(0xFFDDDDDD),
                onTap: onEdit,
              ),
              const SizedBox(width: 8),
              _ActionButton(
                icon: Icons.delete_outline,
                iconColor: AppColors.danger,
                borderColor: const Color(0xFFFFCDD2),
                backgroundColor: const Color(0xFFFFF0F0),
                onTap: onDelete,
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            bill.customer?.name ?? '-',
            style: const TextStyle(fontSize: 13, color: AppColors.textDark),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${bill.monthName} ${bill.year} - Rp ${NumberFormat('#,###').format(bill.amount)}',
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textGrey),
              ),
              _StatusBadgeCustom(status: displayStatus),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Widget: Action Button (Edit / Delete)
// ─────────────────────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color borderColor;
  final Color backgroundColor;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.iconColor,
    required this.borderColor,
    this.backgroundColor = Colors.white,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor, width: 1.2),
        ),
        child: Icon(icon, size: 17, color: iconColor),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Widget: Status Badge
// ─────────────────────────────────────────────────────────────
class _StatusBadgeCustom extends StatelessWidget {
  final String status;
  const _StatusBadgeCustom({required this.status});

  @override
  Widget build(BuildContext context) {
    late Color bgColor;
    late Color textColor;
    late String label;

    switch (status) {
      case 'lunas':
        bgColor = const Color(0xFFE8F5E9);
        textColor = const Color(0xFF2E7D32);
        label = 'Dibayar';
        break;
      case 'belum_diverifikasi':
        bgColor = const Color(0xFFFFF8E1);
        textColor = const Color(0xFFE65100);
        label = 'Belum Diverifikasi';
        break;
      case 'belum_dibayar':
      default:
        bgColor = const Color(0xFFFFEBEE);
        textColor = const Color(0xFFC62828);
        label = 'Belum Dibayar';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}