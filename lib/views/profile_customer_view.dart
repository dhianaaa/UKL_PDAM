import 'package:amerta_pay/app_widget.dart';
import 'package:amerta_pay/models/admin_model.dart';
import 'package:flutter/material.dart';
import '../../models/user_login.dart';
import '../../services/auth_service.dart';
import '../../services/customer_service.dart';

class CustomerProfileView extends StatefulWidget {
  const CustomerProfileView({super.key});

  @override
  State<CustomerProfileView> createState() => _CustomerProfileViewState();
}

class _CustomerProfileViewState extends State<CustomerProfileView> {
  final UserLogin _userLogin = UserLogin();
  final CustomerService _customerService = CustomerService();
  final AuthService _authService = AuthService();

  String _name = '';
  String _username = '';
  String _phone = '';
  String _address = '';
  String _customerId = '';
  String _role = 'Customer';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    var user = await _userLogin.getUserLogin();

    if (user.status != true) {
      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/role-picker',
        (route) => false,
      );

      return;
    }

    setState(() {
      _name = user.name ?? '';
      _username = user.username ?? '';
      _customerId = 'C-${(user.id ?? 0).toString().padLeft(5, '0')}';
    });

    final result = await _customerService.getMyProfile();

    if (result['status'] == true && mounted) {
      final data = Map<String, dynamic>.from(result['data'] ?? {});

      setState(() {
        _name = data['name']?.toString() ?? _name;

        _username = data['username']?.toString() ?? _username;

        _phone = data['phone']?.toString() ?? '-';

        _address = data['address']?.toString() ?? '-';

        _customerId =
            'C-${(data['id'] ?? user.id ?? 0).toString().padLeft(5, '0')}';

        _loading = false;
      });
    } else {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Apakah kamu yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Logout',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    await AuthModel.clearPrefs();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/role-picker',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chevron_left,
              color: Colors.white,
              size: 20,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Avatar
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Fields
                  _buildField(
                    'Nama Lengkap',
                    _name,
                    Icons.person_outline_rounded,
                  ),
                  const SizedBox(height: 12),
                  _buildField(
                    'Username',
                    _username,
                    Icons.person_outline_rounded,
                  ),
                  const SizedBox(height: 12),
                  _buildField('Role', _role, Icons.person_outline_rounded),
                  const SizedBox(height: 12),
                  _buildField(
                    'ID Customer',
                    _customerId,
                    Icons.person_outline_rounded,
                  ),
                  const SizedBox(height: 12),
                  _buildField(
                    'Phone Number',
                    _phone,
                    Icons.phone_android_rounded,
                    isPhone: true,
                  ),
                  const SizedBox(height: 12),
                  _buildField('Alamat', _address, Icons.location_on_outlined),
                  const SizedBox(height: 24),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: _logout,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.danger),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        foregroundColor: AppColors.danger,
                      ),
                      child: const Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.danger,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
      bottomNavigationBar: const CustomerBottomNav(activeIndex: 3),
    );
  }

  Widget _buildField(
    String label,
    String value,
    IconData icon, {
    bool isPhone = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              if (isPhone) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    children: [
                      Text('🇮🇩', style: TextStyle(fontSize: 16)),
                      SizedBox(width: 4),
                      Icon(
                        Icons.keyboard_arrow_down,
                        size: 16,
                        color: AppColors.textGrey,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
              ] else
                Icon(icon, color: AppColors.textGrey, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
