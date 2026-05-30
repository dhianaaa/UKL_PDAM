import 'package:flutter/material.dart';
import '../models/service_model.dart';
import '../services/service_service.dart';
import '../widgets/alert.dart';

class ServiceFormView extends StatefulWidget {
  final bool isEdit;
  final ServiceModel? service;

  const ServiceFormView({super.key, required this.isEdit, this.service});

  @override
  State<ServiceFormView> createState() => _ServiceFormViewState();
}

class _ServiceFormViewState extends State<ServiceFormView> {
  final _formKey  = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _minCtrl  = TextEditingController();
  final _maxCtrl  = TextEditingController();
  final _priceCtrl = TextEditingController();

  bool _loading = false;
  final ServiceService _svc = ServiceService();

  static const _teal = Color(0xFF26C6A6);
  static const _bg   = Color(0xFFF0F4F8);

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.service != null) {
      _nameCtrl.text  = widget.service!.name ?? '';
      _minCtrl.text   = (widget.service!.minUsage ?? '').toString();
      _maxCtrl.text   = (widget.service!.maxUsage ?? '').toString();
      _priceCtrl.text = (widget.service!.price ?? '').toString();
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _minCtrl.dispose();
    _maxCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final name  = _nameCtrl.text.trim();
    final min   = int.tryParse(_minCtrl.text.trim()) ?? 0;
    final max   = int.tryParse(_maxCtrl.text.trim()) ?? 0;
    final price = int.tryParse(_priceCtrl.text.trim()) ?? 0;

    late final dynamic result;
    if (widget.isEdit) {
      result = await _svc.update(
        id: widget.service!.id!,
        name: name,
        minUsage: min,
        maxUsage: max,
        price: price,
      );
    } else {
      result = await _svc.create(
        name: name,
        minUsage: min,
        maxUsage: max,
        price: price,
      );
    }

    setState(() => _loading = false);
    if (!mounted) return;

    AlertMessage.show(context, result.message, result.status);
    if (result.status) {
      await Future.delayed(const Duration(milliseconds: 700));
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── AppBar row ──────────────────────────────────
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
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 18),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    widget.isEdit ? 'Edit layanan' : 'Tambah Layanan',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A202C),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // ── Form ────────────────────────────────────────
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FormField(
                      controller: _nameCtrl,
                      label: 'Nama layanan',
                      hint: 'Contoh : Rumah tangga A',
                      validator: (v) =>
                          v!.isEmpty ? 'Nama wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    _FormField(
                      controller: _minCtrl,
                      label: 'Pemakaian Minimum ( m³ )',
                      hint: 'Contoh : 11',
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          v!.isEmpty ? 'Pemakaian minimum wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    _FormField(
                      controller: _maxCtrl,
                      label: 'Pemakaian Maksimum ( m³ )',
                      hint: 'Contoh : 20',
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          v!.isEmpty ? 'Pemakaian maksimum wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    _FormField(
                      controller: _priceCtrl,
                      label: 'Harga per ( m³ )',
                      hint: 'Contoh : 2000',
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          v!.isEmpty ? 'Harga wajib diisi' : null,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // ── Simpan / Update button ───────────────────────
              GestureDetector(
                onTap: _loading ? null : _submit,
                child: Container(
                  width: double.infinity,
                  height: 54,
                  decoration: BoxDecoration(
                    color: _teal,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: _loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5))
                        : Text(
                            widget.isEdit ? 'Update' : 'Simpan',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ── Batal button ─────────────────────────────────
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: double.infinity,
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: const Center(
                    child: Text(
                      'Batal',
                      style: TextStyle(
                        color: Color(0xFF1A202C),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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

// ─── Form Field Widget ────────────────────────────────────────────
class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const _FormField({
    required this.controller,
    required this.label,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A202C))),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(fontSize: 15, color: Color(0xFF1A202C)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                TextStyle(color: Colors.grey.shade400, fontSize: 14),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                    color: Color(0xFF26C6A6), width: 1.5)),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Colors.red)),
          ),
        ),
      ],
    );
  }
}