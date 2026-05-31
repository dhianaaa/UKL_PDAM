import 'package:amerta_pay/app_theme.dart';
import 'package:amerta_pay/models/service_model.dart';
import 'package:amerta_pay/services/service_service.dart';
import 'package:amerta_pay/views/detail_layanan_view.dart';
import 'package:amerta_pay/views/edit_layanan_view.dart';
import 'package:flutter/material.dart';

class KelolaLayananView extends StatefulWidget {
  const KelolaLayananView({Key? key}) : super(key: key);

  @override
  State<KelolaLayananView> createState() => _KelolaLayananViewState();
}

class _KelolaLayananViewState extends State<KelolaLayananView> {
  final ServiceService _service = ServiceService();
  List<ServiceModel> _services = [];
  List<ServiceModel> _filtered = [];
  bool _loading = true;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
  setState(() => _loading = true);

  final result = await _service.getAll();

  if (mounted) {
    setState(() {
      _loading = false;

      if (result.status == true) {
        _services = result.data as List<ServiceModel>;
        _filtered = _services;
      }
    });
  }
}

  void _onSearch(String q) {
    setState(() {
      _filtered = _services
          .where((s) => s.name.toLowerCase().contains(q.toLowerCase()))
          .toList();
    });
  }

  Future<void> _confirmDelete(ServiceModel s) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Layanan?'),
        content: Text('Apakah yakin ingin menghapus "${s.name}"?'),
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
  final r = await _service.delete(s.id);

  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(r.message),
        backgroundColor: r.status == true
            ? AppColors.primary
            : AppColors.danger,
      ),
    );

    if (r.status == true) _loadData();
  }
}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                children: [
                  const Text('Kelola Layanan', style: AppTextStyles.heading),
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
                            onChanged: _onSearch,
                            decoration: InputDecoration(
                              hintText: 'Cari layanan...',
                              hintStyle: const TextStyle(color: AppColors.textGrey, fontSize: 13),
                              prefixIcon: const Icon(Icons.search, color: AppColors.textGrey, size: 20),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () async {
                          await Navigator.push(context, MaterialPageRoute(builder: (_) => const KelolaLayananView()));
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
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : _filtered.isEmpty
                      ? const Center(child: Text('Belum ada layanan', style: TextStyle(color: AppColors.textGrey)))
                      : RefreshIndicator(
                          onRefresh: _loadData,
                          color: AppColors.primary,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            itemCount: _filtered.length,
                            itemBuilder: (_, i) {
                              final s = _filtered[i];
                              return GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => DetailLayananView(serviceId: s.id)),
                                ),
                                child: Container(
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
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryLight,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Icon(Icons.home_outlined, color: AppColors.primary, size: 22),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textDark)),
                                            Text('Rp ${s.price}/m³', style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.textGrey),
                                        onPressed: () async {
                                          await Navigator.push(context, MaterialPageRoute(builder: (_) => EditLayananView(service: s)));
                                          _loadData();
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.danger),
                                        onPressed: () => _confirmDelete(s),
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