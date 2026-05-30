import 'package:flutter/material.dart';
import '../models/service_model.dart';
import '../services/service_service.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/alert.dart';
import 'service_detail_view.dart';
import 'service_form_view.dart';

class ServiceAdminView extends StatefulWidget {
  const ServiceAdminView({super.key});

  @override
  State<ServiceAdminView> createState() => _ServiceAdminViewState();
}

class _ServiceAdminViewState extends State<ServiceAdminView> {
  final ServiceService _svc = ServiceService();
  final _searchCtrl = TextEditingController();

  List<ServiceModel> _allServices = [];
  List<ServiceModel> _filtered   = [];
  bool _loading = true;

  static const _teal = Color(0xFF26C6A6);
  static const _bg   = Color(0xFFF0F4F8);

  @override
  void initState() {
    super.initState();
    _loadServices();
    _searchCtrl.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadServices() async {
    setState(() => _loading = true);
    final result = await _svc.getAll();
    if (result.status) {
      _allServices = List<ServiceModel>.from(result.data ?? []);
      _filtered    = List.from(_allServices);
    } else {
      if (mounted) AlertMessage.show(context, result.message, false);
    }
    if (mounted) setState(() => _loading = false);
  }

  void _onSearch() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = _allServices
          .where((s) => (s.name ?? '').toLowerCase().contains(q))
          .toList();
    });
  }

  String _formatPrice(int? price) {
    if (price == null) return 'Rp. 0/m³';
    final p = price.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
    return 'Rp. $p/m³';
  }

  Future<void> _deleteService(ServiceModel service) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Layanan',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text(
            'Apakah kamu yakin ingin menghapus layanan "${service.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    final result = await _svc.delete(service.id!);
    if (mounted) {
      AlertMessage.show(context, result.message, result.status);
      if (result.status) _loadServices();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                children: [
                  const Text(
                    'Kelola layanan',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A202C),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Search + Add
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: TextField(
                            controller: _searchCtrl,
                            decoration: InputDecoration(
                              hintText: 'Cari layanan..',
                              hintStyle: TextStyle(
                                  color: Colors.grey.shade400, fontSize: 14),
                              prefixIcon: Icon(Icons.search_rounded,
                                  color: Colors.grey.shade400),
                              border: InputBorder.none,
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 14),
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
                              builder: (_) =>
                                  const ServiceFormView(isEdit: false),
                            ),
                          );
                          _loadServices();
                        },
                        child: Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: _teal,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.add_rounded,
                              color: Colors.white, size: 26),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── List ─────────────────────────────────────────────
            Expanded(
              child: _loading
                  ? const Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFF26C6A6)))
                  : _filtered.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.water_drop_outlined,
                                  size: 60, color: Colors.grey.shade300),
                              const SizedBox(height: 12),
                              Text('Belum ada layanan',
                                  style: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontSize: 15)),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          color: _teal,
                          onRefresh: _loadServices,
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                            itemCount: _filtered.length,
                            itemBuilder: (ctx, i) =>
                                _ServiceCard(
                              service: _filtered[i],
                              formatPrice: _formatPrice,
                              onEdit: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ServiceFormView(
                                      isEdit: true,
                                      service: _filtered[i],
                                    ),
                                  ),
                                );
                                _loadServices();
                              },
                              onDelete: () => _deleteService(_filtered[i]),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ServiceDetailView(
                                      serviceId: _filtered[i].id!),
                                ),
                              ),
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavAdmin(1),
    );
  }
}

// ─── Service Card ────────────────────────────────────────────────
class _ServiceCard extends StatelessWidget {
  final ServiceModel service;
  final String Function(int?) formatPrice;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.service,
    required this.formatPrice,
    required this.onEdit,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final min = service.minUsage ?? 0;
    final max = service.maxUsage ?? 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            // Text info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.name ?? '-',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A202C),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$min – $max m³',
                    style: TextStyle(
                        fontSize: 13, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatPrice(service.price),
                    style: TextStyle(
                        fontSize: 13, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),

            // Action buttons
            Row(
              children: [
                // Edit
                GestureDetector(
                  onTap: onEdit,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: const Icon(Icons.edit_outlined,
                        color: Color(0xFF1A202C), size: 18),
                  ),
                ),
                const SizedBox(width: 8),
                // Delete
                GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFFCDD2)),
                    ),
                    child: const Icon(Icons.delete_outline_rounded,
                        color: Colors.red, size: 18),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}