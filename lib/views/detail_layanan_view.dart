import 'package:amerta_pay/app_theme.dart';
import 'package:amerta_pay/models/service_model.dart';
import 'package:amerta_pay/services/service_service.dart';
import 'package:flutter/material.dart';
import 'edit_layanan_view.dart';
import 'package:intl/intl.dart';

class DetailLayananView extends StatefulWidget {
  final int serviceId;
  const DetailLayananView({Key? key, required this.serviceId})
    : super(key: key);

  @override
  State<DetailLayananView> createState() => _DetailLayananViewState();
}

class _DetailLayananViewState extends State<DetailLayananView> {
  ServiceModel? _service;
  bool _loading = true;
  final ServiceService _svc = ServiceService();

  @override
  void initState() {
    super.initState();
    _load();
  }

 Future<void> _load() async {
  setState(() => _loading = true);

  final r = await _svc.getById(widget.serviceId);

  if (mounted) {
    setState(() {
      _loading = false;

      if (r.status) {
        _service = r.data as ServiceModel;
      }
    });
  }
}

  String _formatDate(String? date) {
    if (date == null) return '-';
    try {
      final d = DateTime.parse(date);
      return DateFormat('dd MMM yyyy HH:mm').format(d);
    } catch (_) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Detail layanan',
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
          : _service == null
          ? const Center(child: Text('Gagal memuat data'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Icon
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.water_drop,
                      color: AppColors.primary,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Info Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _DetailItem(label: 'Nama', value: _service!.name),
                        _DetailItem(
                          label: 'Pemakaian Minimum',
                          value: '${_service!.minUsage} m³',
                        ),
                        _DetailItem(
                          label: 'Pemakaian Maksimum',
                          value: '${_service!.maxUsage} m³',
                        ),
                        _DetailItem(
                          label: 'Harga',
                          value:
                              'Rp ${NumberFormat('#,###').format(_service!.price)}/m³',
                        ),
                        _DetailItem(
                          label: 'Dibuat',
                          value: _formatDate(_service!.createdAt),
                        ),
                        _DetailItem(
                          label: 'Di Update',
                          value: _formatDate(_service!.updatedAt),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditLayananView(service: _service!),
                          ),
                        );
                        _load();
                      },
                      child: const Text(
                        'Edit Layanan',
                        style: TextStyle(
                          color: Colors.white,
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

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;
  const _DetailItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontSize: 14, color: AppColors.textDark),
          ),
          const Divider(height: 16),
        ],
      ),
    );
  }
}
