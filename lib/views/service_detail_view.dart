import 'package:flutter/material.dart';
import '../models/service_model.dart';
import '../services/service_service.dart';
import '../widgets/alert.dart';
import 'service_form_view.dart';

class ServiceDetailView extends StatefulWidget {
  final int serviceId;
  const ServiceDetailView({super.key, required this.serviceId});

  @override
  State<ServiceDetailView> createState() => _ServiceDetailViewState();
}

class _ServiceDetailViewState extends State<ServiceDetailView> {
  final ServiceService _svc = ServiceService();
  ServiceModel? _service;
  bool _loading = true;

  static const _teal = Color(0xFF26C6A6);
  static const _bg   = Color(0xFFF0F4F8);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final result = await _svc.getById(widget.serviceId);
    if (result.status && result.data != null) {
      _service = ServiceModel.fromJson(
          Map<String, dynamic>.from(result.data!));
    } else {
      if (mounted) AlertMessage.show(context, result.message, false);
    }
    if (mounted) setState(() => _loading = false);
  }

  String _formatPrice(int? price) {
    if (price == null) return 'Rp. 0/m³';
    final p = price.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
    return 'Rp. $p/m³';
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '-';
    try {
      final dt = DateTime.parse(raw).toLocal();
      const months = [
        '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
      ];
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '${dt.day.toString().padLeft(2, '0')} ${months[dt.month]} ${dt.year} $h:$m';
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF26C6A6)))
            : _service == null
                ? const Center(child: Text('Data tidak ditemukan'))
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── AppBar row ────────────────────────
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: _teal,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    color: Colors.white, size: 18),
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Text(
                              'Detail layanan',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1A202C),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // ── Icon ──────────────────────────────
                        Center(
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD4F5EC),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: const Icon(Icons.water_drop_rounded,
                                color: Color(0xFF26C6A6), size: 52),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // ── Detail rows ───────────────────────
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4))
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _DetailRow(
                                  label: 'Nama', value: _service!.name ?? '-'),
                              _DetailRow(
                                  label: 'Pemakaian Minimum',
                                  value: '${_service!.minUsage ?? 0} m³'),
                              _DetailRow(
                                  label: 'Pemakaian Maksimum',
                                  value: '${_service!.maxUsage ?? 0} m³'),
                              _DetailRow(
                                  label: 'Harga',
                                  value: _formatPrice(_service!.price)),
                              _DetailRow(
                                  label: 'Dibuat',
                                  value: _formatDate(_service!.createdAt)),
                              if (_service!.updatedAt != null &&
                                  _service!.updatedAt != _service!.createdAt)
                                _DetailRow(
                                    label: 'Di Update',
                                    value: _formatDate(_service!.updatedAt),
                                    isLast: true),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ── Edit button ───────────────────────
                        GestureDetector(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ServiceFormView(
                                    isEdit: true, service: _service),
                              ),
                            );
                            _load();
                          },
                          child: Container(
                            width: double.infinity,
                            height: 54,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF26C6A6),
                                    Color(0xFF1A9B85)
                                  ]),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                    color: const Color(0xFF26C6A6)
                                        .withOpacity(0.35),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6))
                              ],
                            ),
                            child: const Center(
                              child: Text('Edit Layanan',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  )),
                            ),
                          ),
                        ),

                        // ── Mascot decoration ─────────────────
                        Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Image.asset(
                              'assets/images/maskot.png',
                              width: 100,
                              errorBuilder: (_, __, ___) =>
                                  const SizedBox.shrink(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;

  const _DetailRow(
      {required this.label, required this.value, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A202C))),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.4)),
        ],
      ),
    );
  }
}