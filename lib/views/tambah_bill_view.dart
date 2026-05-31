import 'package:amerta_pay/app_theme.dart';
import 'package:amerta_pay/widgets/pdam.dart';
import 'package:flutter/material.dart';
import '../../../models/customer_model.dart';
import '../../../services/bill_service.dart';
import '../../../services/customer_service.dart';

class TambahBillView extends StatefulWidget {
  const TambahBillView({Key? key}) : super(key: key);

  @override
  State<TambahBillView> createState() => _TambahBillViewState();
}

class _TambahBillViewState extends State<TambahBillView> {
  final _customerSearchCtrl = TextEditingController();
  final _meterCtrl = TextEditingController();
  final _pemakaianCtrl = TextEditingController();
  CustomerModel? _selectedCustomer;
  List<CustomerModel> _customerResults = [];
  int? _selectedMonth;
  int? _selectedYear;
  bool _isLoading = false;
  bool _searchingCustomer = false;

  final BillService _billService = BillService();
  final CustomerService _custService = CustomerService();

  final List<String> _months = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];

  Future<void> _searchCustomer(String q) async {
    if (q.isEmpty) { setState(() => _customerResults = []); return; }
    setState(() => _searchingCustomer = true);
    final r = await _custService.getAll(search: q, quantity: 10);
    if (mounted) {
      setState(() {
        _searchingCustomer = false;
        _customerResults = r['status'] == true ? r['data'] as List<CustomerModel> : [];
      });
    }
  }

  Future<void> _save() async {
    if (_selectedCustomer == null || _selectedMonth == null || _selectedYear == null ||
        _meterCtrl.text.isEmpty || _pemakaianCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Semua field wajib diisi'), backgroundColor: AppColors.danger));
      return;
    }
    setState(() => _isLoading = true);
    final r = await _billService.create(
      customerId: _selectedCustomer!.id,
      month: _selectedMonth!,
      year: _selectedYear!,
      measurementNumber: _meterCtrl.text.trim(),
      usageValue: int.tryParse(_pemakaianCtrl.text) ?? 0,
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
    final years = List.generate(5, (i) => DateTime.now().year - 2 + i);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Tambah Bill', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customer search
            const Text('Customer', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textDark)),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _customerSearchCtrl,
                    onChanged: _searchCustomer,
                    decoration: InputDecoration(
                      hintText: _selectedCustomer?.name ?? 'Cari Customer',
                      hintStyle: const TextStyle(color: AppColors.textGrey, fontSize: 13),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 46, height: 46,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade300)),
                  child: _searchingCustomer ? const Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.search, color: AppColors.textGrey),
                ),
              ],
            ),
            if (_customerResults.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade300)),
                child: Column(
                  children: _customerResults.map((c) => ListTile(
                    title: Text(c.name, style: const TextStyle(fontSize: 13)),
                    subtitle: Text(c.customerNumber, style: const TextStyle(fontSize: 11)),
                    onTap: () => setState(() {
                      _selectedCustomer = c;
                      _customerSearchCtrl.text = c.name;
                      _customerResults = [];
                    }),
                  )).toList(),
                ),
              ),
            const SizedBox(height: 16),

            // Bulan dropdown
            const Text('Bulan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textDark)),
            const SizedBox(height: 6),
            DropdownButtonFormField<int>(
              value: _selectedMonth,
              hint: const Text('Cari Bulan', style: TextStyle(color: AppColors.textGrey, fontSize: 13)),
              decoration: InputDecoration(
                filled: true, fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              items: List.generate(12, (i) => DropdownMenuItem(value: i + 1, child: Text(_months[i], style: const TextStyle(fontSize: 13)))),
              onChanged: (v) => setState(() => _selectedMonth = v),
            ),
            const SizedBox(height: 16),

            // Tahun dropdown
            const Text('Tahun', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textDark)),
            const SizedBox(height: 6),
            DropdownButtonFormField<int>(
              value: _selectedYear,
              hint: const Text('Cari Tahun', style: TextStyle(color: AppColors.textGrey, fontSize: 13)),
              decoration: InputDecoration(
                filled: true, fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              items: years.map((y) => DropdownMenuItem(value: y, child: Text(y.toString(), style: const TextStyle(fontSize: 13)))).toList(),
              onChanged: (v) => setState(() => _selectedYear = v),
            ),
            const SizedBox(height: 16),

            PdamTextField(label: 'Nomor Meter', hint: 'Contoh: MTR-10001', controller: _meterCtrl),
            const SizedBox(height: 16),
            PdamTextField(label: 'Pemakaian Air ( m³ )', hint: 'Contoh: 15', controller: _pemakaianCtrl, keyboardType: TextInputType.number),
            const SizedBox(height: 32),
            PdamPrimaryButton(text: 'Simpan', onPressed: _save, isLoading: _isLoading),
            const SizedBox(height: 12),
            PdamOutlineButton(text: 'Batal', onPressed: () => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }
}