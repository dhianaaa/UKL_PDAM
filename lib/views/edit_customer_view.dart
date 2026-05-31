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

  ServiceModel? _selectedService;
  List<ServiceModel> _services = [];

  bool _isLoading = false;
  bool _showDropdown = false;

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
            _selectedService = _services.firstWhere(
              (s) => s.id == _selectedService!.id,
            );
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

    if (r['status'] == true) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Edit Customer',
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
            _textField('Username', _usernameCtrl, readOnly: true),
            const SizedBox(height: 16),

            _textField('Nama Lengkap', _namaCtrl),
            const SizedBox(height: 16),

            _textField('No. Pelanggan', _noPlgCtrl, readOnly: true),
            const SizedBox(height: 16),

            _textField('Nomor HP', _hpCtrl),
            const SizedBox(height: 16),

            _textField('Alamat', _alamatCtrl),
            const SizedBox(height: 16),

            _dropdownService(),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _isLoading ? null : _save,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Simpan'),
              ),
            ),

            const SizedBox(height: 10),

            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _textField(
    String label,
    TextEditingController controller, {
    bool readOnly = false,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _dropdownService() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Layanan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        GestureDetector(
          onTap: () => setState(() => _showDropdown = !_showDropdown),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedService?.name ?? 'Pilih layanan',
                  ),
                ),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),

        if (_showDropdown)
          Container(
            margin: const EdgeInsets.only(top: 5),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: _services
                  .map(
                    (s) => ListTile(
                      title: Text(s.name),
                      onTap: () {
                        setState(() {
                          _selectedService = s;
                          _showDropdown = false;
                        });
                      },
                    ),
                  )
                  .toList(),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _namaCtrl.dispose();
    _noPlgCtrl.dispose();
    _hpCtrl.dispose();
    _alamatCtrl.dispose();
    super.dispose();
  }
}