import 'package:amerta_pay/app_theme.dart';
import 'package:amerta_pay/services/service_service.dart';
import 'package:flutter/material.dart';
import '../../../models/customer_model.dart';
import '../../../models/service_model.dart';
import '../../../services/customer_service.dart';

class EditCustomerView extends StatefulWidget {
  final CustomerModel customer;
  const EditCustomerView({Key? key, required this.customer}) : super(key: key);

  @override
  State<EditCustomerView> createState() => _EditCustomerViewState();
}

class _EditCustomerViewState extends State<EditCustomerView> {
  late TextEditingController _usernameCtrl;
  late TextEditingController _namaCtrl;
  late TextEditingController _noPlgCtrl;
  late TextEditingController _hpCtrl;
  late TextEditingController _alamatCtrl;
  late TextEditingController _passwordCtrl;

  ServiceModel? _selectedService;
  List<ServiceModel> _services = [];

  bool _isLoading = false;
  bool _showDropdown = false;

  // State untuk field yang sedang bisa diedit
  bool _editingHp = false;
  bool _editingAlamat = false;

  final CustomerService _custService = CustomerService();
  final ServiceService _layananService = ServiceService();

  @override
  void initState() {
    super.initState();
    final c = widget.customer;

    _usernameCtrl = TextEditingController(text: c.username);
    _namaCtrl = TextEditingController(text: c.name);
    _noPlgCtrl = TextEditingController(text: c.customerNumber);
    _hpCtrl = TextEditingController(text: c.phone);
    _alamatCtrl = TextEditingController(text: c.address);
    _passwordCtrl = TextEditingController(text: '••••••••••••••');

    _selectedService = c.service;
    _loadServices();
  }

  Future<void> _loadServices() async {
    final r = await _layananService.getAll();
    if (!mounted) return;
    setState(() {
      if (r.status == true) {
        final raw = r.data;
        if (raw is List) {
          _services = raw.map((e) => e as ServiceModel).toList();
        }
        if (_selectedService != null) {
          try {
            _selectedService =
                _services.firstWhere((s) => s.id == _selectedService!.id);
          } catch (_) {}
        }
      }
    });
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);

    final body = <String, dynamic>{
      'name': _namaCtrl.text.trim(),
      'phone': _hpCtrl.text.trim(),
      'address': _alamatCtrl.text.trim(),
    };

    if (_selectedService != null) {
      body['service_id'] = _selectedService!.id;
    }

    final r = await _custService.update(widget.customer.id, body);
    setState(() => _isLoading = false);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(r['message'] ?? '-'),
        backgroundColor:
            r['status'] == true ? AppColors.primary : AppColors.danger,
      ),
    );
    if (r['status'] == true) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Edit Customer',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_ios_new,
                color: Colors.white, size: 18),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Username (readonly) ──────────────────────────
            _fieldLabel('Username'),
            _readonlyBox(_usernameCtrl.text),
            const SizedBox(height: 16),

            // ── Password (readonly + Reset button) ───────────
            _fieldLabel('Password'),
            _inlineActionBox(
              text: '••••••••••••••',
              actionLabel: 'Reset Password',
              actionColor: AppColors.primary,
              onAction: () {
                // Implementasi reset password sesuai kebutuhan
              },
            ),
            const SizedBox(height: 16),

            // ── No. Pelanggan (readonly) ─────────────────────
            _fieldLabel('No. Pelanggan'),
            _readonlyBox(_noPlgCtrl.text),
            const SizedBox(height: 16),

            // ── Nama Lengkap (editable) ──────────────────────
            _fieldLabel('Nama Lengkap'),
            _editableBox(_namaCtrl, hint: ''),
            const SizedBox(height: 16),

            // ── Nomor HP (readonly default + Ganti button) ───
            _fieldLabel('Nomor Hp'),
            _editingHp
                ? _editableBox(_hpCtrl, hint: '08xxxxxxxxxx')
                : _inlineActionBox(
                    text: _hpCtrl.text.isNotEmpty
                        ? '••••••••••••••'
                        : '08xxxxxxxxxx',
                    actionLabel: 'Ganti Nomor Hp',
                    actionColor: AppColors.primary,
                    onAction: () => setState(() => _editingHp = true),
                  ),
            const SizedBox(height: 16),

            // ── Alamat (readonly default + Ubah button) ──────
            _fieldLabel('Alamat'),
            _editingAlamat
                ? _editableBox(_alamatCtrl, hint: '')
                : _inlineActionBox(
                    text: _alamatCtrl.text.isNotEmpty
                        ? _alamatCtrl.text
                        : 'Belum ada alamat',
                    actionLabel: 'Ubah',
                    actionColor: AppColors.primary,
                    onAction: () => setState(() => _editingAlamat = true),
                  ),
            const SizedBox(height: 16),

            // ── Layanan (dropdown split) ─────────────────────
            _fieldLabel('Layanan'),
            _dropdownService(),
            const SizedBox(height: 36),

            // ── Simpan ───────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: _isLoading ? null : _save,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Simpan',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
              ),
            ),
            const SizedBox(height: 12),

            // ── Batal ────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFCCCCCC)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helper Widgets ─────────────────────────────────────────

  Widget _fieldLabel(String label) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(label,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textDark)),
      );

  /// Box readonly biasa
  Widget _readonlyBox(String value) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFDDDDDD)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(value,
            style: const TextStyle(fontSize: 14, color: AppColors.textDark)),
      );

  /// Box dengan teks di kiri + tombol aksi di kanan (Password, HP, Alamat)
  Widget _inlineActionBox({
    required String text,
    required String actionLabel,
    required Color actionColor,
    required VoidCallback onAction,
  }) =>
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFDDDDDD)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(text,
                  style: const TextStyle(
                      fontSize: 14, color: AppColors.textDark),
                  overflow: TextOverflow.ellipsis),
            ),
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 4)),
              child: Text(actionLabel,
                  style: TextStyle(
                      fontSize: 13,
                      color: actionColor,
                      fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      );

  /// TextField editable biasa
  Widget _editableBox(TextEditingController ctrl, {String hint = ''}) =>
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFDDDDDD)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: TextField(
          controller: ctrl,
          style: const TextStyle(fontSize: 14, color: AppColors.textDark),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                const TextStyle(color: AppColors.textGrey, fontSize: 14),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
        ),
      );

  /// Dropdown layanan: box kiri (nama) + panah di kanan (terpisah border)
  Widget _dropdownService() => Column(
        children: [
          Row(
            children: [
              // Bagian kiri: teks layanan terpilih
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFDDDDDD)),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                    ),
                  ),
                  child: Text(
                    _selectedService?.name ?? 'Pilih layanan',
                    style: TextStyle(
                        fontSize: 14,
                        color: _selectedService != null
                            ? AppColors.textDark
                            : AppColors.textGrey),
                  ),
                ),
              ),
              // Bagian kanan: tombol panah
              GestureDetector(
                onTap: () => setState(() => _showDropdown = !_showDropdown),
                child: Container(
                  width: 50,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFDDDDDD)),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                  ),
                  child: const Icon(Icons.arrow_drop_down,
                      color: AppColors.textDark),
                ),
              ),
            ],
          ),
          // Dropdown list
          if (_showDropdown)
            Container(
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFDDDDDD)),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2))
                ],
              ),
              child: Column(
                children: _services.map((s) {
                  final isLast = s == _services.last;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedService = s;
                        _showDropdown = false;
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        border: isLast
                            ? null
                            : const Border(
                                bottom: BorderSide(
                                    color: Color(0xFFF0F0F0), width: 1)),
                      ),
                      child: Text(s.name,
                          style: const TextStyle(
                              fontSize: 14, color: AppColors.textDark)),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      );

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _namaCtrl.dispose();
    _noPlgCtrl.dispose();
    _hpCtrl.dispose();
    _alamatCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }
}