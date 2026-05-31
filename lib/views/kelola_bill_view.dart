import 'package:amerta_pay/app_theme.dart';
import 'package:amerta_pay/widgets/bottom_nav.dart';
import 'package:amerta_pay/widgets/pdam.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../services/bill_service.dart';
import '../../../models/bill_model.dart';
import 'tambah_bill_view.dart';
import 'detail_bill_view.dart';

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

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final result = await _service.getAll(search: _searchQuery, quantity: 50);
    if (mounted) {
      setState(() {
        _loading = false;
        if (result['status'] == true) {
          _bills = result['data'] as List<BillModel>;
        }
      });
    }
  }

  Future<void> _confirmDelete(BillModel b) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Tagihan?'),
        content: Text('Apakah yakin ingin menghapus ${b.invoiceNumber}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus', style: TextStyle(color: AppColors.danger))),
        ],
      ),
    );
    if (confirm == true) {
      final r = await _service.delete(b.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(r['message']), backgroundColor: r['status'] == true ? AppColors.primary : AppColors.danger),
        );
        if (r['status'] == true) _loadData();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  backgroundColor: AppColors.background,

  bottomNavigationBar: const BottomNavAdmin(3),

  body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                children: [
                  const Text('Kelola Bill', style: AppTextStyles.heading),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
                          ),
                          child: TextField(
                            controller: _searchCtrl,
                            onSubmitted: (v) { _searchQuery = v; _loadData(); },
                            onChanged: (v) { if (v.isEmpty) { _searchQuery = ''; _loadData(); } },
                            decoration: const InputDecoration(
                              hintText: 'Cari layanan...',
                              hintStyle: TextStyle(color: AppColors.textGrey, fontSize: 13),
                              prefixIcon: Icon(Icons.search, color: AppColors.textGrey, size: 20),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () async {
                          await Navigator.push(context, MaterialPageRoute(builder: (_) => const TambahBillView()));
                          _loadData();
                        },
                        child: Container(
                          width: 46, height: 46,
                          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.add, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : _bills.isEmpty
                      ? const Center(child: Text('Belum ada tagihan', style: TextStyle(color: AppColors.textGrey)))
                      : RefreshIndicator(
                          onRefresh: _loadData,
                          color: AppColors.primary,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            itemCount: _bills.length,
                            itemBuilder: (_, i) {
                              final b = _bills[i];
                              return GestureDetector(
                                onTap: () async {
                                  await Navigator.push(context, MaterialPageRoute(builder: (_) => DetailBillView(billId: b.id)));
                                  _loadData();
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(b.invoiceNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark)),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.textGrey),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            onPressed: () async {
                                              await Navigator.push(context, MaterialPageRoute(builder: (_) => DetailBillView(billId: b.id)));
                                              _loadData();
                                            },
                                          ),
                                          const SizedBox(width: 8),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.danger),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            onPressed: () => _confirmDelete(b),
                                          ),
                                        ],
                                      ),
                                      Text(b.customer?.name ?? '-', style: const TextStyle(fontSize: 13, color: AppColors.textDark)),
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '${b.monthName} ${b.year} - Rp ${NumberFormat('#,###').format(b.amount)}',
                                            style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
                                          ),
                                          StatusBadge(status: b.status),
                                        ],
                                      ),
                                    ],
                                  ),
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