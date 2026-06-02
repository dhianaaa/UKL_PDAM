import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Halaman "Kontak Admin" — ditampilkan ketika customer
/// menekan "Belum Dapat Akun? Contact Admin".
/// Customer hanya bisa didaftarkan oleh Admin.
class ContactAdminView extends StatefulWidget {
  const ContactAdminView({super.key});

  @override
  State<ContactAdminView> createState() => _ContactAdminViewState();
}

class _ContactAdminViewState extends State<ContactAdminView>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tidak bisa membuka $url')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _backBtn(context),
                const SizedBox(height: 36),

                // ── Title ─────────────────────────────────────
                const Text(
                  'Kontak admin',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2D3748),
                  ),
                ),

                const SizedBox(height: 20),

                // ── Admin card ────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7FAFA),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 75,
                        height: 75,
                    
                        child: Image.asset('assets/admin.png', width: 75, height: 75),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Butuh Bantuan?',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2D3748),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Admin kami siap membantu Anda mendapatkan akun pelanggan dengan mudah dan cepat.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                Text(
                  'Hubungi Admin Melalui',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade600,
                    letterSpacing: 0.3,
                  ),
                ),

                const SizedBox(height: 14),

                // ── WhatsApp ──────────────────────────────────
                _ContactTile(
                  icon: Icons.chat_rounded,
                  iconColor: const Color(0xFF25D366),
                  title: 'WhatsApp',
                  subtitle: 'Chat langsung ke Admin',
                  trailingLabel: 'Obrolan',
                  onTap: () => _launchUrl('https://wa.me/6281246334803'),
                ),

                // ── Telepon ───────────────────────────────────
                _ContactTile(
                  icon: Icons.phone_rounded,
                  iconColor: const Color(0xFF26C6A6),
                  title: 'Telepon',
                  subtitle: 'Hubungi Admin via telepon',
                  trailingLabel: '0812 4633 4803',
                  onTap: () => _launchUrl('tel:+6281246334803'),
                ),

                // ── Email ─────────────────────────────────────
                _ContactTile(
                  icon: Icons.email_outlined,
                  iconColor: const Color(0xFF4285F4),
                  title: 'Email',
                  subtitle: 'Kirim email ke Admin',
                  trailingLabel: 'admin@amertapay.id',
                  onTap: () =>
                      _launchUrl('mailto:admin@amertapay.id'),
                ),

                // ── Jam Operasional ───────────────────────────
                const SizedBox(height: 8),
                _InfoTile(
                  icon: Icons.access_time_rounded,
                  iconColor: const Color(0xFFFFA726),
                  title: 'Jam Operasional',
                  content:
                      'Senin – Jumat: 08.00 – 16.00 WIB\nSabtu: 08.00 – 12.00 WIB',
                ),

                const SizedBox(height: 8),

                // ── Info ──────────────────────────────────────
                _InfoTile(
                  icon: Icons.info_outline_rounded,
                  iconColor: const Color(0xFF26C6A6),
                  title: 'Informasi',
                  content:
                      'Pastikan Anda menyiapkan data diri pelanggan (KTP) agar Admin dapat membuatkan akun dengan cepat.',
                ),

                const SizedBox(height: 40),
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

// ─── Contact tile ────────────────────────────────────────────────
class _ContactTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String trailingLabel;
  final VoidCallback onTap;

  const _ContactTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.trailingLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D3748))),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 11.5, color: Colors.grey.shade500)),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF26C6A6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                trailingLabel,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right_rounded,
                color: Color(0xFF26C6A6), size: 20),
          ],
        ),
      ),
    );
  }
}

// ─── Info tile (no onTap) ─────────────────────────────────────────
class _InfoTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String content;

  const _InfoTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: iconColor.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: iconColor)),
                const SizedBox(height: 4),
                Text(content,
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        height: 1.55)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}