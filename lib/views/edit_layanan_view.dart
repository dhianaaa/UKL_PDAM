import 'package:amerta_pay/app_theme.dart';
import 'package:amerta_pay/widgets/pdam.dart';
import 'package:flutter/material.dart';
import 'package:amerta_pay/services/service_service.dart';
import '../../../models/service_model.dart';


class EditLayananView extends StatefulWidget {
  final ServiceModel service;
  const EditLayananView({Key? key, required this.service}) : super(key: key);

  @override
  State<EditLayananView> createState() => _EditLayananViewState();
}

class _EditLayananViewState extends State<EditLayananView> {
  late TextEditingController _namaCtrl;
  late TextEditingController _minCtrl;
  late TextEditingController _maxCtrl;
  late TextEditingController _hargaCtrl;

  bool _isLoading = false;
  final ServiceService _service = ServiceService();

  @override
  void initState() {
    super.initState();
    _namaCtrl = TextEditingController(text: widget.service.name);
    _minCtrl = TextEditingController(text: widget.service.minUsage.toString());
    _maxCtrl = TextEditingController(text: widget.service.maxUsage.toString());
    _hargaCtrl = TextEditingController(text: widget.service.price.toString());
  }

  Future<void> _update() async {
  setState(() => _isLoading = true);

  final result = await _service.update(
  id: widget.service.id,
  name: _namaCtrl.text.trim(),
  minUsage: int.tryParse(_minCtrl.text),
  maxUsage: int.tryParse(_maxCtrl.text),
  price: int.tryParse(_hargaCtrl.text),
);

  setState(() => _isLoading = false);

  if (!mounted) return;

  final bool success = result.status == true;
  final String message = result.message;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor:
          success ? AppColors.primary : AppColors.danger,
    ),
  );

  if (success) {
    Navigator.pop(context);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Edit layanan',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
  PdamTextField(
    label: 'Nama layanan',
    controller: _namaCtrl,
  ),
  const SizedBox(height: 16),

  PdamTextField(
    label: 'Pemakaian Minimum ( m³ )',
    controller: _minCtrl,
    keyboardType: TextInputType.number,
  ),
  const SizedBox(height: 16),

  PdamTextField(
    label: 'Pemakaian Maksimum ( m³ )',
    controller: _maxCtrl,
    keyboardType: TextInputType.number,
  ),
  const SizedBox(height: 16),

  PdamTextField(
    label: 'Harga per ( m³ )',
    controller: _hargaCtrl,
    keyboardType: TextInputType.number,
  ),
  const SizedBox(height: 32),

  // BUTTON UPDATE (BASIC FLUTTER)
  SizedBox(
    width: double.infinity,
    height: 50,
    child: ElevatedButton(
      onPressed: _isLoading ? null : _update,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.teal,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: _isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : const Text(
              'Update',
              style: TextStyle(color: Colors.white),
            ),
    ),
  ),

  const SizedBox(height: 12),

  // BUTTON BATAL (BASIC FLUTTER)
  SizedBox(
    width: double.infinity,
    height: 50,
    child: OutlinedButton(
      onPressed: () => Navigator.pop(context),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.teal),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const Text(
        'Batal',
        style: TextStyle(color: Colors.teal),
      ),
    ),
  ),
],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _minCtrl.dispose();
    _maxCtrl.dispose();
    _hargaCtrl.dispose();
    super.dispose();
  }
}