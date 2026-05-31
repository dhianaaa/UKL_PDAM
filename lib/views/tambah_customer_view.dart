import 'dart:developer';

import 'package:amerta_pay/app_theme.dart';
import 'package:amerta_pay/services/service_service.dart';
import 'package:amerta_pay/widgets/pdam.dart';
import 'package:flutter/material.dart';
import '../../../models/service_model.dart';
import '../../../services/customer_service.dart';

class TambahCustomerView extends StatefulWidget {
  const TambahCustomerView({Key? key}) : super(key: key);

  @override
  State<TambahCustomerView> createState() => _TambahCustomerViewState();
}

class _TambahCustomerViewState extends State<TambahCustomerView> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _noPlgCtrl = TextEditingController();
  final _namaCtrl = TextEditingController();
  final _hpCtrl = TextEditingController();
  final _alamatCtrl = TextEditingController();
  ServiceModel? _selectedService;
  List<ServiceModel> _services = [];
  bool _isLoading = false;
  bool _loadingServices = true;
  bool _showDropdown = false;

  final CustomerService _custService = CustomerService();
  final ServiceService _serviceService = ServiceService();

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
  final r = await _serviceService.getAll();

  if (mounted) {
    setState(() {
      _loadingServices = false;
      if (r.status == true) {
        _services = r.data as List<ServiceModel>;
      }
    });
  }
}

  Future<void> _save() async {
    if (_usernameCtrl.text.isEmpty || _passwordCtrl.text.isEmpty ||
        _noPlgCtrl.text.isEmpty || _namaCtrl.text.isEmpty ||
        _hpCtrl.text.isEmpty || _alamatCtrl.text.isEmpty || _selectedService == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Semua field wajib diisi'), backgroundColor: AppColors.danger));
      return;
    }
    setState(() => _isLoading = true);
    final r = await _custService.create(
      username: _usernameCtrl.text.trim(),
      password: _passwordCtrl.text,
      customerNumber: _noPlgCtrl.text.trim(),
      name: _namaCtrl.text.trim(),
      phone: _hpCtrl.text.trim(),
      address: _alamatCtrl.text.trim(),
      serviceId: _selectedService!.id,
    );
    setState(() => _isLoading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(r['message']), backgroundColor: r['status'] == true ? AppColors.primary : AppColors.danger),
      );
      if (r['status'] == true) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Tambah Customer', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            PdamTextField(label: 'Username', hint: 'Contoh: Budi145', controller: _usernameCtrl),
            const SizedBox(height: 16),
            PdamTextField(label: 'Password', hint: 'Buat Password', controller: _passwordCtrl, obscureText: true),
            const SizedBox(height: 16),
            PdamTextField(label: 'No. Pelanggan', hint: 'Contoh: C - 100001', controller: _noPlgCtrl),
            const SizedBox(height: 16),
            PdamTextField(label: 'Nama Lengkap', hint: 'Contoh: Budi Setiawan', controller: _namaCtrl),
            const SizedBox(height: 16),
            PdamTextField(label: 'Nomor Hp', hint: '08xxxxxxxxxx', controller: _hpCtrl, keyboardType: TextInputType.phone),
            const SizedBox(height: 16),
            PdamTextField(label: 'Alamat', hint: 'Contoh: Jl. Melati No. 12, Kepanjen, Malang', controller: _alamatCtrl),
            const SizedBox(height: 16),

            // Layanan dropdown
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Layanan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textDark)),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () => setState(() => _showDropdown = !_showDropdown),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _selectedService?.name ?? 'Pilih layanan',
                            style: TextStyle(fontSize: 13, color: _selectedService == null ? AppColors.textGrey : AppColors.textDark),
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down, color: AppColors.textGrey),
                      ],
                    ),
                  ),
                ),
                if (_showDropdown)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: _loadingServices
                        ? const Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator())
                        : Column(
                            children: _services.map((s) => ListTile(
                              title: Text(s.name, style: const TextStyle(fontSize: 13)),
                              onTap: () => setState(() {
                                _selectedService = s;
                                _showDropdown = false;
                              }),
                            )).toList(),
                          ),
                  ),
              ],
            ),
            const SizedBox(height: 32),
            PdamPrimaryButton(text: 'Simpan', onPressed: _save, isLoading: _isLoading),
            const SizedBox(height: 12),
            PdamOutlineButton(text: 'Batal', onPressed: () => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _noPlgCtrl.dispose();
    _namaCtrl.dispose();
    _hpCtrl.dispose();
    _alamatCtrl.dispose();
    super.dispose();
  }
}