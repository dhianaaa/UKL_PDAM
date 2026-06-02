
import 'package:amerta_pay/services/admin_service.dart';
import 'package:flutter/material.dart';
import '../models/auth_model.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/alert.dart';

class ProfileAdminView extends StatefulWidget {
  const ProfileAdminView({super.key});

  @override
  State<ProfileAdminView> createState() => _ProfileAdminViewState();
}

class _ProfileAdminViewState extends State<ProfileAdminView> {
  final AdminService _adminSvc = AdminService();

  int? _adminId;
  String _name = '';
  String _username = '';
  String _role = 'ADMIN';
  String _phone = '';
  String _token = '';
  bool _loading = true;
  bool _showToken = false;

  static const _teal = Color(0xFF26C6A6);
  static const _bg = Color(0xFFF0F4F8);

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _loading = true);
    try {
      final auth = await AuthModel.getFromPrefs();
      _adminId = auth.id;
      _token = auth.token ?? '';

      final result = await _adminSvc.getMe();
      if (result.status && result.data != null) {
        final data = result.data!;
        _name = data['name'] ?? auth.name ?? '';
        _username = data['username'] ?? auth.username ?? '';
        _role = data['role'] ?? 'ADMIN';
        _phone = data['phone'] ?? '';
      }
    } catch (e) {
      if (mounted) AlertMessage.show(context, 'Gagal memuat profil', false);
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Logout',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text('Apakah kamu yakin ingin keluar?'),
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
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Logout'),
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
      backgroundColor: _bg,
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF26C6A6)),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Back + Avatar row ──────────────────────
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
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                        const Spacer(),
                        // Avatar
                        Stack(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.person_rounded,
                                size: 48,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: _teal,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.edit_rounded,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        const SizedBox(width: 40),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // ── Fields ─────────────────────────────────
                    _ProfileField(
                      label: 'Nama Lengkap',
                      value: _name,
                      icon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 14),
                    _ProfileField(
                      label: 'Username',
                      value: _username,
                      icon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 14),
                    _ProfileField(
                      label: 'Role',
                      value: _role,
                      icon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 14),

                    // Token (obscured with toggle)
                    _TokenField(
                      token: _token,
                      show: _showToken,
                      onToggle: () => setState(() => _showToken = !_showToken),
                    ),
                    const SizedBox(height: 14),

                    // Phone
                    _PhoneField(phone: _phone),

                    const SizedBox(height: 32),

                    // ── Logout button ──────────────────────────
                    GestureDetector(
                      onTap: _logout,
                      child: Container(
                        width: double.infinity,
                        height: 54,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.red.shade300),
                        ),
                        child: const Center(
                          child: Text(
                            'Logout',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: const BottomNavAdmin(4),
    );
  }
}

// ─── Profile Field ────────────────────────────────────────────────
class _ProfileField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _ProfileField({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A202C),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.grey.shade400, size: 20),
              const SizedBox(width: 12),
              Text(
                value,
                style: const TextStyle(fontSize: 14, color: Color(0xFF1A202C)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Token Field ─────────────────────────────────────────────────
class _TokenField extends StatelessWidget {
  final String token;
  final bool show;
  final VoidCallback onToggle;

  const _TokenField({
    required this.token,
    required this.show,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final display = show
        ? (token.length > 20 ? '${token.substring(0, 20)}...' : token)
        : '●' * 14;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Owner Token',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A202C),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              const Icon(Icons.key_rounded, color: Color(0xFF9E9E9E), size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  display,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1A202C),
                  ),
                ),
              ),
              GestureDetector(
                onTap: onToggle,
                child: Icon(
                  show
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Phone Field ──────────────────────────────────────────────────
class _PhoneField extends StatelessWidget {
  final String phone;
  const _PhoneField({required this.phone});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Phone Number',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A202C),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            // Country code
            Container(
              width: 72,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  const Text('🇮🇩', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_drop_down_rounded,
                    color: Colors.grey.shade500,
                    size: 18,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Phone number
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Text(
                  phone.isEmpty ? '-' : phone,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1A202C),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
