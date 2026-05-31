import 'package:amerta_pay/app_theme.dart';
import 'package:amerta_pay/views/edit_customer_view.dart';
import 'package:amerta_pay/views/tambah_customer_view.dart';
import 'package:amerta_pay/widgets/bottom_nav.dart';
import 'package:flutter/material.dart';
import '../../../services/customer_service.dart';
import '../../../models/customer_model.dart';

class KelolaCustomerView extends StatefulWidget {
  const KelolaCustomerView({Key? key}) : super(key: key);

  @override
  State<KelolaCustomerView> createState() => _KelolaCustomerViewState();
}

class _KelolaCustomerViewState extends State<KelolaCustomerView> {
  final CustomerService _service = CustomerService();
  List<CustomerModel> _customers = [];
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
          _customers = result['data'] as List<CustomerModel>;
        }
      });
    }
  }

  Future<void> _confirmDelete(CustomerModel c) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Customer?'),
        content: Text('Apakah yakin ingin menghapus "${c.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final r = await _service.delete(c.id);
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

  bottomNavigationBar: const BottomNavAdmin(2),

  body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                children: [
                  const Text('Kelola layanan', style: AppTextStyles.heading),
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
                            onSubmitted: (v) {
                              _searchQuery = v;
                              _loadData();
                            },
                            onChanged: (v) {
                              if (v.isEmpty) { _searchQuery = ''; _loadData(); }
                            },
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
                          await Navigator.push(context, MaterialPageRoute(builder: (_) => const TambahCustomerView()));
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
                  : _customers.isEmpty
                      ? const Center(child: Text('Belum ada customer', style: TextStyle(color: AppColors.textGrey)))
                      : RefreshIndicator(
                          onRefresh: _loadData,
                          color: AppColors.primary,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            itemCount: _customers.length,
                            itemBuilder: (_, i) {
                              final c = _customers[i];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44, height: 44,
                                      decoration: BoxDecoration(color: const Color(0xFFE8F0FB), borderRadius: BorderRadius.circular(12)),
                                      child: const Icon(Icons.home_outlined, color: Color(0xFF4A90D9), size: 22),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(c.customerNumber, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textDark)),
                                          Text(c.name, style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
                                          Text(c.service?.name ?? '-', style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.textGrey),
                                      onPressed: () async {
                                        await Navigator.push(context, MaterialPageRoute(builder: (_) => EditCustomerView(customer: c)));
                                        _loadData();
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.danger),
                                      onPressed: () => _confirmDelete(c),
                                    ),
                                  ],
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