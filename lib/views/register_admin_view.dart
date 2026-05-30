import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/alert.dart';

/// Halaman register ADMIN
/// Endpoint: POST /admins  — Header: app-key
/// Body: { username, password, name, phone }
class RegisterAdminView extends StatefulWidget {
  const RegisterAdminView({super.key});

  @override
  State<RegisterAdminView> createState() => _RegisterAdminViewState();
}

class _RegisterAdminViewState extends State<RegisterAdminView>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _loading = false;
  bool _obscure = true;

  late AnimationController _anim;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic));
    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    _usernameCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _doRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final result = await _authService.registerAdmin(
      username: _usernameCtrl.text.trim(),
      password: _passwordCtrl.text,
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
    );

    setState(() => _loading = false);

    if (!mounted) return;

    AlertMessage.show(context, result.message, result.status);

    if (result.status) {
      _usernameCtrl.clear();
      _nameCtrl.clear();
      _phoneCtrl.clear();
      _passwordCtrl.clear();

      await Future.delayed(const Duration(milliseconds: 900));
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login-admin');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: _slide,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _backBtn(context),
                    const SizedBox(height: 36),

                    const Text(
                      'Buat akun anda',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Daftarkan akun Admin baru untuk\nmengelola sistem AmertaPay.',
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                          height: 1.6),
                    ),

                    const SizedBox(height: 32),

                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _InputField(
                            controller: _usernameCtrl,
                            label: 'Username',
                            prefixIcon: Icons.person_outline_rounded,
                            hint: 'Masukkan Username Anda',
                            validator: (v) =>
                                v!.isEmpty ? 'Username harus diisi' : null,
                          ),
                          const SizedBox(height: 16),
                          _InputField(
                            controller: _nameCtrl,
                            label: 'Name',
                            prefixIcon: Icons.badge_outlined,
                            hint: 'Masukkan Name Anda',
                            validator: (v) =>
                                v!.isEmpty ? 'Nama harus diisi' : null,
                          ),
                          const SizedBox(height: 16),
                          _InputField(
                            controller: _passwordCtrl,
                            label: 'Password',
                            prefixIcon: Icons.lock_outline_rounded,
                            hint: 'Masukkan Password Anda',
                            obscure: _obscure,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: Colors.grey.shade400,
                                size: 20,
                              ),
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                            validator: (v) =>
                                v!.isEmpty ? 'Password harus diisi' : null,
                          ),
                          const SizedBox(height: 16),
                          _InputField(
                            controller: _phoneCtrl,
                            label: 'Phone Number',
                            prefixIcon: Icons.phone_outlined,
                            hint: '+62',
                            keyboardType: TextInputType.phone,
                            validator: (v) =>
                                v!.isEmpty ? 'Nomor HP harus diisi' : null,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    _GradientButton(
                      label: 'Buat',
                      loading: _loading,
                      onTap: _doRegister,
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _backBtn(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF26C6A6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.arrow_back_ios_new_rounded,
            color: Colors.white, size: 18),
      ),
    );
  }
}

// ─── Input field ──────────────────────────────────────────────────
class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData prefixIcon;
  final bool obscure;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;

  const _InputField({
    required this.controller,
    required this.label,
    required this.prefixIcon,
    required this.hint,
    this.obscure = false,
    this.suffixIcon,
    this.validator,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748))),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          validator: validator,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 14, color: Color(0xFF2D3748)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                TextStyle(color: Colors.grey.shade400, fontSize: 13.5),
            prefixIcon:
                Icon(prefixIcon, color: Colors.grey.shade400, size: 20),
            suffixIcon: suffixIcon,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            filled: true,
            fillColor: const Color(0xFFF7FAFA),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade200)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade200)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                    color: Color(0xFF26C6A6), width: 1.5)),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Colors.redAccent)),
          ),
        ),
      ],
    );
  }
}

// ─── Gradient button ─────────────────────────────────────────────
class _GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool loading;
  const _GradientButton(
      {required this.label, required this.onTap, this.loading = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFF26C6A6), Color(0xFF1A9B85)]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFF26C6A6).withOpacity(0.35),
                blurRadius: 16,
                offset: const Offset(0, 6))
          ],
        ),
        child: Center(
          child: loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.5))
              : Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(label,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded,
                      color: Colors.white, size: 18),
                ]),
        ),
      ),
    );
  }
}