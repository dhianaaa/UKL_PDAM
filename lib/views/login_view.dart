import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/alert.dart';

class LoginView extends StatefulWidget {
  final bool isAdmin;

  const LoginView({
    super.key,
    required this.isAdmin,
  });

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameCtrl =
      TextEditingController();

  final TextEditingController _passwordCtrl =
      TextEditingController();

  final AuthService _authService = AuthService();

  bool _loading = false;
  bool _obscure = true;

  late AnimationController _anim;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fade = CurvedAnimation(
      parent: _anim,
      curve: Curves.easeOut,
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _anim,
        curve: Curves.easeOutCubic,
      ),
    );

    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _doLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _loading = true;
    });

    final result = await _authService.login(
      _usernameCtrl.text.trim(),
      _passwordCtrl.text,
    );

    if (mounted) {
      setState(() {
        _loading = false;
      });
    }

    if (!mounted) return;

    if (result.status) {
      AlertMessage.show(
        context,
        result.message,
        true,
      );

      String role =
          result.data?['role']?.toString().toUpperCase() ??
              result.data?['data']?['role']
                  ?.toString()
                  .toUpperCase() ??
              '';

      await Future.delayed(
        const Duration(milliseconds: 800),
      );

      if (!mounted) return;

      if (role == 'ADMIN') {
        Navigator.pushReplacementNamed(
          context,
          '/dashboard-admin',
        );
      } else {
        Navigator.pushReplacementNamed(
          context,
          '/dashboard-customer',
        );
      }
    } else {
      AlertMessage.show(
        context,
        result.message,
        false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    const teal = Color.fromARGB(
      255,
      33,
      172,
      145,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: size.height,
            ),
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      _backBtn(context),

                      const SizedBox(height: 36),

                      const Text(
                        'Selamat datang',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF2D3748),
                        ),
                      ),

                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'di ',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight:
                                    FontWeight.w500,
                                color:
                                    Color(0xFF2D3748),
                              ),
                            ),
                            TextSpan(
                              text: 'Amerta',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight:
                                    FontWeight.w700,
                                color: Color.fromARGB(
                                  255,
                                  33,
                                  172,
                                  145,
                                ),
                              ),
                            ),
                            TextSpan(
                              text: 'Pay',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight:
                                    FontWeight.w800,
                                color: Color.fromARGB(
                                  255,
                                  0,
                                  208,
                                  255,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _InputField(
                              controller:
                                  _usernameCtrl,
                              label: 'Username',
                              hint:
                                  'Masukkan Username Anda',
                              prefixIcon: Icons
                                  .person_outline_rounded,
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty) {
                                  return 'Username harus diisi';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(
                              height: 16,
                            ),

                            _InputField(
                              controller:
                                  _passwordCtrl,
                              label: 'Password',
                              hint:
                                  'Masukkan Password Anda',
                              prefixIcon: Icons
                                  .lock_outline_rounded,
                              obscure: _obscure,
                              suffixIcon:
                                  IconButton(
                                icon: Icon(
                                  _obscure
                                      ? Icons
                                          .visibility_outlined
                                      : Icons
                                          .visibility_off_outlined,
                                  color: Colors
                                      .grey.shade400,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscure =
                                        !_obscure;
                                  });
                                },
                              ),
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty) {
                                  return 'Password harus diisi';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 350),

                      _GradientButton(
                        label: 'Mulai',
                        loading: _loading,
                        onTap: _doLogin,
                      ),

                      const SizedBox(height: 25),

                      if (widget.isAdmin)
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/register-admin',
                              );
                            },
                            child: RichText(
                              text: TextSpan(
                                text:
                                    'Belum Punya Akun? ',
                                style: TextStyle(
                                  color: Colors
                                      .grey.shade500,
                                  fontSize: 13,
                                ),
                                children: [
                                  TextSpan(
                                    text:
                                        'Sign up',
                                    style:
                                        TextStyle(
                                      color:
                                          teal,
                                      fontWeight:
                                          FontWeight
                                              .w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                      if (!widget.isAdmin)
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/contact-admin',
                              );
                            },
                            child: RichText(
                              text: TextSpan(
                                text:
                                    'Belum Dapat Akun? ',
                                style: TextStyle(
                                  color: Colors
                                      .grey.shade500,
                                  fontSize: 13,
                                ),
                                children: [
                                  TextSpan(
                                    text:
                                        'Contact Admin',
                                    style:
                                        TextStyle(
                                      color:
                                          teal,
                                      fontWeight:
                                          FontWeight
                                              .w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
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
          color: const Color.fromARGB(
            255,
            33,
            172,
            145,
          ),
          borderRadius:
              BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData prefixIcon;
  final bool obscure;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  const _InputField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.prefixIcon,
    this.obscure = false,
    this.suffixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(prefixIcon),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor:
                const Color(0xFFF7FAFA),
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(14),
            ),
            enabledBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(14),
            ),
            focusedBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(14),
              borderSide:
                  const BorderSide(
                color: Color.fromARGB(
                  255,
                  33,
                  172,
                  145,
                ),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool loading;

  const _GradientButton({
    required this.label,
    required this.onTap,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color.fromARGB(
                255,
                33,
                172,
                145,
              ),
              Color.fromARGB(
                255,
                26,
                155,
                133,
              ),
            ],
          ),
          borderRadius:
              BorderRadius.circular(16),
        ),
        child: Center(
          child: loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child:
                      CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Row(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: const [
                    Text(
                      'Mulai',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}