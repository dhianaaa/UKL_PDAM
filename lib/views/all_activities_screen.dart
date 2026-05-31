import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ─── KONSTANTA ────────────────────────────────────────────────────────────────
const String baseUrl = 'https://learn.smktelkom-mlg.sch.id/pdam';
const String appKey = '9d8f8047067d5fc7e8d4575645c19b7fd06ccbde';

// ─── MODEL ───────────────────────────────────────────────────────────────────
class ActivityItem {
  final String type;
  final String title;
  final String subtitle;
  final String? status;
  final DateTime createdAt;

  ActivityItem({
    required this.type,
    required this.title,
    required this.subtitle,
    this.status,
    required this.createdAt,
  });
}

// ─── SERVICE ─────────────────────────────────────────────────────────────────
class ActivityService {
  final String token;

  ActivityService({required this.token});

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        if (appKey.isNotEmpty) 'app-key': appKey,
      };

  static Future<String> login() async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth'),
      headers: {
        'Content-Type': 'application/json',
        if (appKey.isNotEmpty) 'app-key': appKey,
      },
      body: jsonEncode({"username": "Adhiana", "password": "Dhiana1004"}),
    );

    print("LOGIN STATUS: ${res.statusCode}");
    print("LOGIN BODY: ${res.body}");

    if (res.statusCode == 200 || res.statusCode == 201) {
      final data = jsonDecode(res.body);
      return data['token'] ?? data['access_token'] ?? '';
    }
    throw Exception("Login gagal");
  }

  Future<List<ActivityItem>> fetchPayments() async {
    final res = await http.get(
      Uri.parse('$baseUrl/payments?page=1&quantity=50'),
      headers: _headers,
    );

    print("PAYMENTS STATUS: ${res.statusCode}");
    print("PAYMENTS BODY: ${res.body}");

    if (res.statusCode != 200) throw Exception("Gagal ambil payments");

    final body = jsonDecode(res.body);
    final List list = body is List ? body : (body['data'] ?? body['payments'] ?? []);

    return list.map<ActivityItem>((p) {
      final date =
          DateTime.tryParse(p['created_at'] ?? p['createdAt'] ?? '') ?? DateTime.now();
      final invoice =
          p['invoice_number'] ?? p['invoice'] ?? p['code'] ?? 'INV-${p['id']}';
      final verified = p['is_verified'] == true ||
          p['status'] == 'verified' ||
          p['verified_at'] != null;

      return ActivityItem(
        type: 'payment',
        title: 'Pembayaran baru',
        subtitle: invoice,
        status: verified ? 'verified' : 'unverified',
        createdAt: date,
      );
    }).toList();
  }

  Future<List<ActivityItem>> fetchCustomers() async {
    final res = await http.get(
      Uri.parse('$baseUrl/customers?page=1&quantity=50'),
      headers: _headers,
    );

    print("CUSTOMERS STATUS: ${res.statusCode}");
    print("CUSTOMERS BODY: ${res.body}");

    if (res.statusCode != 200) throw Exception("Gagal ambil customers");

    final body = jsonDecode(res.body);
    final List list = body is List ? body : (body['data'] ?? body['customers'] ?? []);

    return list.map<ActivityItem>((c) {
      final date =
          DateTime.tryParse(c['created_at'] ?? c['createdAt'] ?? '') ?? DateTime.now();
      final code = c['customer_number'] ?? c['code'] ?? 'C-${c['id']}';
      final name = c['name'] ?? '-';

      return ActivityItem(
        type: 'customer',
        title: 'Customer baru',
        subtitle: '$code - $name',
        createdAt: date,
      );
    }).toList();
  }

  Future<List<ActivityItem>> fetchAll() async {
    final results = await Future.wait([fetchPayments(), fetchCustomers()]);
    final all = [...results[0], ...results[1]];
    all.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return all;
  }
}

// ─── TIME FORMAT ─────────────────────────────────────────────────────────────
String timeAgo(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inSeconds < 60) return '${diff.inSeconds} detik yang lalu';
  if (diff.inMinutes < 60) return '${diff.inMinutes} menit yang lalu';
  if (diff.inHours < 24) return '${diff.inHours} jam yang lalu';
  return '${diff.inDays} hari yang lalu';
}

// ─── SCREEN ───────────────────────────────────────────────────────────────────
class AllActivitiesScreen extends StatefulWidget {
  const AllActivitiesScreen({super.key});

  @override
  State<AllActivitiesScreen> createState() => _AllActivitiesScreenState();
}

class _AllActivitiesScreenState extends State<AllActivitiesScreen> {
  List<ActivityItem> items = [];
  bool loading = true;
  String? error;
  ActivityService? service;

  @override
  void initState() {
    super.initState();
    Future.microtask(init);
  }

  Future<void> init() async {
    try {
      setState(() { loading = true; error = null; });
      final token = await ActivityService.login();
      service = ActivityService(token: token);
      await load();
    } catch (e) {
      setState(() { error = e.toString(); loading = false; });
    }
  }

  Future<void> load() async {
    try {
      setState(() { loading = true; error = null; });
      final data = await service!.fetchAll();
      setState(() { items = data; loading = false; });
    } catch (e) {
      setState(() { error = e.toString(); loading = false; });
    }
  }

  // ── BUILD ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF4F6),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  // ── HEADER ─────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Row(
        children: [
          // Tombol back
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                color: Color(0xFF3DBFA0),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chevron_left_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'Semua Aktivitas',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          // Tombol refresh
          GestureDetector(
            onTap: load,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.refresh_rounded,
                color: Color(0xFF3DBFA0),
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── BODY ───────────────────────────────────────────────────────────────────
  Widget _buildBody() {
    if (loading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF3DBFA0),
          strokeWidth: 3,
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEEEE),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.wifi_off_rounded,
                  size: 36,
                  color: Color(0xFFE05252),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Gagal memuat data',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 140,
                child: ElevatedButton(
                  onPressed: load,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3DBFA0),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Coba Lagi',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFECF9F6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.inbox_rounded,
                size: 36,
                color: Color(0xFF3DBFA0),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Belum ada aktivitas',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF3DBFA0),
      onRefresh: load,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        itemCount: items.length,
        itemBuilder: (context, i) => _ActivityTile(item: items[i]),
      ),
    );
  }
}

// ─── TILE ─────────────────────────────────────────────────────────────────────
class _ActivityTile extends StatelessWidget {
  final ActivityItem item;
  const _ActivityTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final isPayment = item.type == 'payment';
    final isVerified = item.status == 'verified';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Ikon ──────────────────────────────────────────────────────────
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFEEEEEE),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isPayment
                  ? Icons.receipt_long_rounded
                  : Icons.group_rounded,
              color: Colors.black87,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),

          // ── Teks ──────────────────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // ── Waktu + Badge ──────────────────────────────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                timeAgo(item.createdAt),
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
              if (isPayment && item.status != null) ...[
                const SizedBox(height: 6),
                _StatusBadge(verified: isVerified),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ─── STATUS BADGE ─────────────────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final bool verified;
  const _StatusBadge({required this.verified});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: verified
            ? const Color(0xFFD4F5EB)
            : const Color(0xFFFFE5E5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        verified ? 'Diverifikasi' : 'Belum Diverifikasi',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: verified
              ? const Color(0xFF1DAA7A)
              : const Color(0xFFE05252),
        ),
      ),
    );
  }
}

// ─── MAIN ────────────────────────────────────────────────────────────────────
void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: AllActivitiesScreen(),
  ));
}