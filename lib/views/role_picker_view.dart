import 'package:flutter/material.dart';

class RolePickerView extends StatefulWidget {
  const RolePickerView({super.key});

  @override
  State<RolePickerView> createState() => _RolePickerViewState();
}

class _RolePickerViewState extends State<RolePickerView>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;

  String? _selected; // customer | admin

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 12),

                // ── Back Button ─────────────────────────────
                Align(
                  alignment: Alignment.centerLeft,
                  child: _backBtn(context),
                ),

                const SizedBox(height: 10),

                // ── Header Image ────────────────────────────
                Container(
  width: double.infinity,
  alignment: Alignment.center,
  child: Image.asset(
    'assets/role_header.png',
    width: MediaQuery.of(context).size.width,
    fit: BoxFit.fitWidth,
  ),
),

                const SizedBox(height: 8),

                // ── Title ───────────────────────────────────
                const Text(
                  'Pilih Role anda!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2D3748),
                    fontFamily: 'Poppins',
                  ),
                ),

                const SizedBox(height: 10),

                // ── Subtitle ────────────────────────────────
                Text(
                  'Masuk sebagai Admin untuk mengelola\nsistem atau Customer untuk melakukan\npembayaran.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                    height: 1.6,
                    fontFamily: 'Poppins',
                  ),
                ),

                const SizedBox(height: 34),

                // ── Role Cards ─────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: _RoleCard(
                        label: 'Customer',
                        image: 'assets/costumer.png',
                        selected: _selected == 'customer',
                        onTap: () {
                          setState(() {
                            _selected = 'customer';
                          });
                        },
                      ),
                    ),

                    const SizedBox(width: 18),

                    Expanded(
                      child: _RoleCard(
                        label: 'Admin',
                        image: 'assets/admin.png',
                        selected: _selected == 'admin',
                        onTap: () {
                          setState(() {
                            _selected = 'admin';
                          });
                        },
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // ── Button ─────────────────────────────────
                _GradientButton(
                  label: 'Mulai & Simpan',
                  enabled: _selected != null,
                  onTap: _selected == null
                      ? null
                      : () {
                          if (_selected == 'admin') {
                            Navigator.pushNamed(context, '/login-admin');
                          } else {
                            Navigator.pushNamed(context, '/login-customer');
                          }
                        },
                ),

                const SizedBox(height: 32),
              ],
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
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: const Color(0xFF26C6A6),
          borderRadius: BorderRadius.circular(14),
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

// ─────────────────────────────────────────────
// ROLE CARD
// ─────────────────────────────────────────────
class _RoleCard extends StatelessWidget {
  final String label;
  final String image;
  final bool selected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.label,
    required this.image,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE8FAF5) : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected ? const Color(0xFF26C6A6) : Colors.grey.shade200,
            width: selected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            // ── Role Image ─────────────────────
            Image.asset(
              image,
              height: 80,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 33, 172, 145).withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  color: Color.fromARGB(255, 33, 172, 145),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // ── Label ──────────────────────────
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: selected
                    ? Color.fromARGB(255, 33, 172, 145)
                    : const Color(0xFF2D3748),
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// BUTTON
// ─────────────────────────────────────────────
class _GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool enabled;

  const _GradientButton({
    required this.label,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: enabled
              ? const LinearGradient(
                  colors: [
                    Color.fromARGB(255, 33, 172, 145),
                    Color.fromARGB(255, 26, 155, 133),
                  ],
                )
              : null,
          color: enabled ? null : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(18),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: Color.fromARGB(255, 33, 172, 145).withOpacity(0.30),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                color: enabled ? Colors.white : Colors.grey.shade500,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                fontFamily: 'Poppins',
              ),
            ),

            const SizedBox(width: 8),

            Icon(
              Icons.arrow_forward_rounded,
              color: enabled ? Colors.white : Colors.grey.shade500,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
