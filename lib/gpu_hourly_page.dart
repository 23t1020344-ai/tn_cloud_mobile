import 'package:flutter/material.dart';
import 'api.dart';
import 'app_data.dart';
import 'auth_state.dart';
import 'balance_state.dart';
import 'topup_page.dart';
import 'rental_state.dart';
import 'my_gpus_page.dart';
import 'history_page.dart';
import 'referral_page.dart';
import 'guide_page.dart';
import 'support_page.dart';

const _primary = Color(0xFF0B7FC7);
const _primaryDark = Color(0xFF0069AE);
const _dark = Color(0xFF0F1B2D);
const _muted = Color(0xFF5B6B80);
const _border = Color(0xFFDDE5EE);
const _bg = Color(0xFFF5F8FB);
const _green = Color(0xFF16A37F);
const _amber = Color(0xFFE08A00);
const _red = Color(0xFFD93025);

String _fmt(int n) => formatVnd(n);

int _round100(double v) => (v / 100).round() * 100;

/* ------------------------------------------------------------------ */
/* Dữ liệu gói                                                         */
/* ------------------------------------------------------------------ */
// LƯU Ý: id của gói phải khớp với plans.js trên server.
// Giá hiển thị ở đây chỉ để xem; server tự tính giá khi thuê.
// TODO: lấy danh sách gói từ API (GET /plans) thay vì khai báo cứng.

enum _Badge { none, best, optimal }

class _Plan {
  final _Badge badge;
  final String id;
  final String name;
  final String gpu;
  final String nas;
  final String location;
  final int hourly;
  final int oldHourly;
  final String cpu;
  final String ram;
  final String cuda;
  final String ssd;
  final String net;
  final String os;
  final bool ubuntu;
  final bool inStock;

  const _Plan({
    this.badge = _Badge.none,
    required this.id,
    required this.name,
    required this.gpu,
    required this.nas,
    required this.location,
    required this.hourly,
    required this.oldHourly,
    required this.cpu,
    required this.ram,
    required this.cuda,
    required this.ssd,
    required this.net,
    required this.os,
    this.ubuntu = false,
    this.inStock = true,
  });

  int get day => _round100(hourly * 24 * 0.8);
  int get week => _round100(hourly * 24 * 7 * 0.7);
  int get month => _round100(hourly * 24 * 30 * 0.55);
  int get oldDay => oldHourly * 24;
  int get oldWeek => oldHourly * 24 * 7;
  int get oldMonth => oldHourly * 24 * 30;

  static int pct(int now, int old) => ((1 - now / old) * 100).round();
}

const _plans = <_Plan>[
  _Plan(
    id: 'p1',
    badge: _Badge.best,
    name: 'RTX 4060 Ti | Gaming',
    gpu: '1x NVIDIA RTX 4060 Ti (VRAM 16GB)',
    nas: 'no-nas',
    location: 'vn-03',
    hourly: 6000,
    oldHourly: 13000,
    cpu: 'Intel Core i5 12th Gen',
    ram: '28GB',
    cuda: '4352',
    ssd: '1500GB',
    net: '500Mbps',
    os: 'Windows 10',
  ),
  _Plan(
    id: 'p2',
    badge: _Badge.best,
    name: 'RTX 5060 Ti | Gaming',
    gpu: '1x NVIDIA RTX 5060 Ti (VRAM 16GB)',
    nas: 'no-nas',
    location: 'vn-04',
    hourly: 7000,
    oldHourly: 14000,
    cpu: 'Intel Core i5 14th Gen',
    ram: '28GB',
    cuda: '4608',
    ssd: '1500GB',
    net: '500Mbps',
    os: 'Windows 10',
  ),
  _Plan(
    id: 'p3',
    badge: _Badge.optimal,
    name: 'RTX 3090 | Standard AI',
    gpu: '1x NVIDIA RTX 3090 (VRAM 24GB)',
    nas: 'nas1',
    location: 'vn-01',
    hourly: 9000,
    oldHourly: 18000,
    cpu: 'Intel Core i5 12th Gen',
    ram: '56GB',
    cuda: '10496',
    ssd: '1500GB',
    net: '1Gbps',
    os: 'Windows 10',
  ),
  _Plan(
    id: 'p4',
    badge: _Badge.optimal,
    name: 'RTX 3090 | Standard AI',
    gpu: '1x NVIDIA RTX 3090 (VRAM 24GB)',
    nas: 'nas1',
    location: 'vn-04',
    hourly: 9000,
    oldHourly: 18000,
    cpu: 'Intel Core i5 12th Gen',
    ram: '56GB',
    cuda: '10496',
    ssd: '1500GB',
    net: '1Gbps',
    os: 'Ubuntu 24.04',
    ubuntu: true,
  ),
  _Plan(
    id: 'p5',
    name: 'RTX 5090 | Pro AI, Design',
    gpu: '1x NVIDIA RTX 5090 (VRAM 32GB)',
    nas: 'nas1',
    location: 'vn-01',
    hourly: 19000,
    oldHourly: 36000,
    cpu: 'Intel Core i7 14th Gen',
    ram: '88GB',
    cuda: '24575',
    ssd: '1500GB',
    net: '1Gbps',
    os: 'Windows 10/11',
  ),
  _Plan(
    id: 'p6',
    name: 'RTX 5090 | Pro AI, Design',
    gpu: '1x NVIDIA RTX 5090 (VRAM 32GB)',
    nas: 'no-nas',
    location: 'vn-03',
    hourly: 19000,
    oldHourly: 36000,
    cpu: 'Intel Core i7 14th Gen',
    ram: '88GB',
    cuda: '24575',
    ssd: '1500GB',
    net: '1Gbps',
    os: 'Ubuntu 24.04',
    ubuntu: true,
    inStock: false,
  ),
];

/* ------------------------------------------------------------------ */
/* Trang                                                               */
/* ------------------------------------------------------------------ */

class GpuHourlyPage extends StatefulWidget {
  const GpuHourlyPage({super.key});

  @override
  State<GpuHourlyPage> createState() => _GpuHourlyPageState();
}

class _GpuHourlyPageState extends State<GpuHourlyPage> {
  String? _loc;
  String? _nas;
  String? _gpu;

  List<String> _distinct(String Function(_Plan) pick) =>
      {for (final p in _plans) pick(p)}.toList()..sort();

  List<_Plan> get _filtered => [
        for (final p in _plans)
          if ((_loc == null || p.location == _loc) &&
              (_nas == null || p.nas == _nas) &&
              (_gpu == null || p.gpu == _gpu))
            p
      ];

  void _reset() => setState(() {
        _loc = null;
        _nas = null;
        _gpu = null;
      });

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width >= 960;
    final list = _filtered;

    return Scaffold(
      backgroundColor: _bg,
      drawer: wide ? null : const Drawer(child: _Sidebar(inDrawer: true)),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (wide) const SizedBox(width: 270, child: _Sidebar()),
            Expanded(
              child: Column(
                children: [
                  _TopBar(wide: wide),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(wide ? 28 : 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Triển khai máy ảo GPU hiệu năng cao cho nhu cầu của bạn, tính phí theo giờ và thanh toán theo gói thuê.',
                            style: TextStyle(
                                color: _muted, fontSize: 14, height: 1.5),
                          ),
                          const SizedBox(height: 16),
                          _notice(),
                          const SizedBox(height: 16),
                          _balanceCard(),
                          const SizedBox(height: 16),
                          _filterBar(list.length),
                          const SizedBox(height: 28),
                          _grid(list),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _notice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F0),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFF5B5B0)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, size: 18, color: _red),
          SizedBox(width: 10),
          Expanded(
            child: Text.rich(TextSpan(
              style: TextStyle(color: _red, fontSize: 13.5, height: 1.5),
              children: [
                TextSpan(
                    text: 'Lưu ý quan trọng: ',
                    style: TextStyle(fontWeight: FontWeight.w800)),
                TextSpan(
                    text:
                        'Hệ điều hành Ubuntu chỉ phù hợp cho AI/ML, KHÔNG TƯƠNG THÍCH ĐỂ CHƠI GAME, RENDER. Vui lòng chọn đúng hệ điều hành trước khi thuê.'),
              ],
            )),
          ),
        ],
      ),
    );
  }

  Widget _balanceCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
                color: const Color(0xFFE6F4FC),
                borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.account_balance_wallet_outlined,
                color: _primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Số dư tài khoản',
                    style: TextStyle(color: _muted, fontSize: 14)),
                const SizedBox(height: 2),
                ValueListenableBuilder<int>(
                  valueListenable: BalanceState.balance,
                  builder: (_, b, __) => Text('${formatVnd(b)}đ',
                      style: const TextStyle(
                          color: _dark,
                          fontSize: 28,
                          fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          ),
          FilledButton.icon(
            onPressed: () => _openTopUp(context),
            icon: const Icon(Icons.add_card, size: 18),
            label: const Text('Nạp tiền',
                style: TextStyle(fontWeight: FontWeight.w700)),
            style: FilledButton.styleFrom(
              backgroundColor: _primaryDark,
              minimumSize: const Size(0, 46),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterBar(int count) {
    Widget dd(String hint, String? value, List<String> items,
        ValueChanged<String?> onChanged) {
      return SizedBox(
        width: 190,
        height: 44,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String?>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down,
                  size: 18, color: _muted),
              style: const TextStyle(color: _dark, fontSize: 14),
              items: [
                DropdownMenuItem<String?>(value: null, child: Text(hint)),
                for (final i in items)
                  DropdownMenuItem<String?>(
                      value: i,
                      child: Text(i, overflow: TextOverflow.ellipsis)),
              ],
              onChanged: onChanged,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Text('Lọc:',
              style: TextStyle(
                  color: _dark, fontSize: 14, fontWeight: FontWeight.w700)),
          dd('Tất cả Location', _loc, _distinct((p) => p.location),
              (v) => setState(() => _loc = v)),
          dd('Tất cả NAS', _nas, _distinct((p) => p.nas),
              (v) => setState(() => _nas = v)),
          dd('Tất cả GPU', _gpu, _distinct((p) => p.gpu),
              (v) => setState(() => _gpu = v)),
          OutlinedButton.icon(
            onPressed: _reset,
            icon: const Icon(Icons.refresh, size: 16, color: _dark),
            label: const Text('Đặt lại',
                style: TextStyle(color: _dark, fontWeight: FontWeight.w600)),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 44),
              side: const BorderSide(color: _border),
              backgroundColor: const Color(0xFFF1F4F8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
          Text.rich(TextSpan(
            style: const TextStyle(color: _muted, fontSize: 13),
            children: [
              TextSpan(
                  text: '$count',
                  style: const TextStyle(
                      color: _dark, fontWeight: FontWeight.w800)),
              TextSpan(text: ' / ${_plans.length} gói'),
            ],
          )),
        ],
      ),
    );
  }

  Widget _grid(List<_Plan> list) {
    if (list.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 48),
        decoration: _cardDecoration(),
        child: const Center(
          child: Text('Không có gói nào phù hợp với bộ lọc.',
              style: TextStyle(color: _muted, fontSize: 14)),
        ),
      );
    }
    return LayoutBuilder(builder: (context, c) {
      const gap = 16.0;
      final w = c.maxWidth;
      final cols = w >= 1250 ? 4 : (w >= 900 ? 3 : (w >= 560 ? 2 : 1));
      final cardW = (w - gap * (cols - 1)) / cols;
      return Wrap(
        spacing: gap,
        runSpacing: 28,
        children: [
          for (final p in list) SizedBox(width: cardW, child: _PlanTile(p)),
        ],
      );
    });
  }
}

BoxDecoration _cardDecoration() => BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: _border),
    );

void _soon(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Tính năng đang phát triển')),
  );
}

/// Mở trang nạp tiền; chưa đăng nhập thì chuyển sang đăng nhập.
void _openTopUp(BuildContext context) {
  if (AuthState.isLoggedIn) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const TopUpPage()),
    );
  } else {
    Navigator.pushNamed(context, '/login');
  }
}

/* ------------------------------------------------------------------ */
/* Thanh trên                                                          */
/* ------------------------------------------------------------------ */

class _TopBar extends StatelessWidget {
  final bool wide;
  const _TopBar({required this.wide});

  @override
  Widget build(BuildContext context) {
    Widget chip(IconData icon, String label, String value, {bool hi = false}) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: hi ? const Color(0xFFE6F4FC) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: hi ? _primary.withOpacity(0.4) : _border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: hi ? _primary : _muted),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        color: hi ? _primary : _muted,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
                Text(value,
                    style: TextStyle(
                        color: hi ? _primary : _dark,
                        fontSize: 14,
                        fontWeight: FontWeight.w800)),
              ],
            ),
          ],
        ),
      );
    }

    return Container(
      height: 68,
      padding: EdgeInsets.symmetric(horizontal: wide ? 28 : 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: _border)),
      ),
      child: Row(
        children: [
          if (!wide)
            Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu_rounded, color: _dark),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),
          Expanded(
            child: Text('Thuê GPU theo giờ',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: _dark,
                    fontSize: wide ? 22 : 18,
                    fontWeight: FontWeight.w800)),
          ),
          if (wide) ...[
            ValueListenableBuilder<List<Rental>>(
              valueListenable: RentalState.rentals,
              builder: (_, __, ___) =>
                  chip(Icons.memory, 'GPU', '${RentalState.activeCount}'),
            ),
            const SizedBox(width: 12),
            // Bấm vào chip số dư để nạp tiền
            InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => _openTopUp(context),
              child: ValueListenableBuilder<int>(
                valueListenable: BalanceState.balance,
                builder: (_, b, __) => chip(
                    Icons.account_balance_wallet_outlined,
                    'Số dư',
                    '${formatVnd(b)}đ',
                    hi: true),
              ),
            ),
            const SizedBox(width: 16),
          ],
          ValueListenableBuilder<String?>(
            valueListenable: AuthState.userName,
            builder: (context, name, _) {
              if (name == null) {
                return TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  child: const Text('Đăng nhập',
                      style: TextStyle(
                          color: _primary, fontWeight: FontWeight.w700)),
                );
              }
              return PopupMenuButton<String>(
                tooltip: '',
                offset: const Offset(0, 44),
                onSelected: (v) {
                  if (v == 'topup') {
                    _openTopUp(context);
                  } else if (v == 'manage') {
                    _openMyGpus(context);
                  } else if (v == 'history') {
                    _openHistory(context);
                  } else if (v == 'logout') {
                    AuthState.logout();
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/', (route) => false);
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'topup', child: Text('Nạp tiền')),
                  PopupMenuItem(value: 'manage', child: Text('Quản lý GPU')),
                  PopupMenuItem(
                      value: 'history', child: Text('Lịch sử giao dịch')),
                  PopupMenuItem(value: 'logout', child: Text('Đăng xuất')),
                ],
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: _primary,
                      child: Text(name.isEmpty ? '?' : name[0].toUpperCase(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14)),
                    ),
                    const Icon(Icons.keyboard_arrow_down,
                        size: 18, color: _muted),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/* ------------------------------------------------------------------ */
/* Thanh bên                                                           */
/* ------------------------------------------------------------------ */

class _NavEntry {
  final IconData icon;
  final String label;
  final String id;
  const _NavEntry(this.icon, this.label, this.id);
}

const _sideItems = [
  _NavEntry(Icons.memory, 'Thuê GPU theo giờ', 'hourly'),
  _NavEntry(Icons.view_in_ar_outlined, 'Thuê Docker GPU', 'docker'),
  _NavEntry(Icons.cloud_outlined, 'Quản lý GPU', 'manage'),
  _NavEntry(Icons.credit_card_outlined, 'Thanh toán', 'payment'),
  _NavEntry(Icons.receipt_long_outlined, 'Lịch sử giao dịch', 'history'),
  _NavEntry(Icons.card_giftcard_outlined, 'Giới thiệu bạn bè', 'refer'),
  _NavEntry(Icons.menu_book_outlined, 'Hướng dẫn', 'guide'),
  _NavEntry(Icons.support_outlined, 'Hỗ trợ', 'support'),
  _NavEntry(Icons.home_outlined, 'Về trang chủ', 'home'),
];

class _Sidebar extends StatelessWidget {
  final bool inDrawer;
  const _Sidebar({this.inDrawer = false});

  void _tap(BuildContext context, String id) {
    if (inDrawer) Navigator.pop(context);
    if (id == 'hourly') return;
    if (id == 'home') {
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      return;
    }
    if (id == 'docker') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Docker GPU sắp ra mắt')),
      );
      return;
    }
    if (id == 'payment') {
      _openTopUp(context);
      return;
    }
    if (id == 'manage') {
      _openMyGpus(context);
      return;
    }
    if (id == 'history') {
      _openHistory(context);
      return;
    }
        if (id == 'refer') {
      if (!AuthState.isLoggedIn) {
        Navigator.of(context).pushNamed('/login');
        return;
      }
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const ReferralPage()));
      return;
    }
    if (id == 'guide') {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const GuidePage()));
      return;
    }
    if (id == 'support') {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const SupportPage()));
      return;
    }
    _soon(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: _border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 68,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            alignment: Alignment.centerLeft,
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: _border)),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: const LinearGradient(
                        colors: [Color(0xFF29A8E8), _primaryDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight),
                  ),
                  child: const Icon(Icons.cloud_outlined,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                const Text.rich(TextSpan(
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                  children: [
                    TextSpan(text: 'TN ', style: TextStyle(color: _dark)),
                    TextSpan(text: 'CLOUD', style: TextStyle(color: _primary)),
                  ],
                )),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(14),
              children: [
                for (final it in _sideItems)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: _SideTile(
                      entry: it,
                      active: it.id == 'hourly',
                      onTap: () => _tap(context, it.id),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1, color: _border),
          const Padding(
            padding: EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('© 2026 TN CLOUD',
                    style: TextStyle(
                        color: _dark,
                        fontSize: 13,
                        fontWeight: FontWeight.w700)),
                SizedBox(height: 2),
                Text('Cloud GPU linh hoạt và mạnh mẽ.',
                    style: TextStyle(color: _muted, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SideTile extends StatelessWidget {
  final _NavEntry entry;
  final bool active;
  final VoidCallback onTap;
  const _SideTile(
      {required this.entry, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? const Color(0xFFE6F4FC) : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color:
                    active ? _primary.withOpacity(0.35) : Colors.transparent),
          ),
          child: Row(
            children: [
              Icon(entry.icon, size: 20, color: active ? _primary : _muted),
              const SizedBox(width: 12),
              Expanded(
                child: Text(entry.label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: active ? _primary : _dark,
                        fontSize: 15,
                        fontWeight:
                            active ? FontWeight.w700 : FontWeight.w500)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ------------------------------------------------------------------ */
/* Thẻ gói                                                             */
/* ------------------------------------------------------------------ */

class _PlanTile extends StatelessWidget {
  final _Plan p;
  const _PlanTile(this.p);

  @override
  Widget build(BuildContext context) {
    final hasBadge = p.badge != _Badge.none;
    final badgeColor = p.badge == _Badge.best ? _primaryDark : _amber;
    final borderColor = p.badge == _Badge.best
        ? _primary
        : (p.badge == _Badge.optimal ? _amber.withOpacity(0.7) : _border);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 12),
          padding: EdgeInsets.fromLTRB(16, hasBadge ? 24 : 16, 16, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: hasBadge ? 1.6 : 1),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4))
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(p.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: _dark,
                            fontSize: 17,
                            fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(width: 8),
                  _StockPill(p.inStock),
                ],
              ),
              const SizedBox(height: 8),
              Text(p.gpu,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: _primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                      child: _MiniChip(
                          Icons.storage_outlined, p.nas, p.nas != 'no-nas')),
                  const SizedBox(width: 8),
                  Expanded(
                      child: _MiniChip(
                          Icons.location_on_outlined, p.location, true)),
                ],
              ),
              const SizedBox(height: 12),
              _priceBox(),
              const SizedBox(height: 14),
              _spec(Icons.developer_board, 'CPU', p.cpu),
              _spec(Icons.sd_storage_outlined, 'RAM', p.ram),
              _spec(Icons.bolt, 'CUDA', p.cuda),
              _spec(Icons.save_outlined, 'SSD', p.ssd),
              _spec(Icons.wifi, 'Mạng', p.net),
              const SizedBox(height: 10),
              _osPill(),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: FilledButton(
                  onPressed: p.inStock ? () => _rentNow(context, p) : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: _primaryDark,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(p.inStock ? 'Thuê ngay' : 'Hết slot',
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
        if (hasBadge)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(20)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (p.badge == _Badge.best) ...[
                      const Icon(Icons.bolt, size: 14, color: Colors.white),
                      const SizedBox(width: 4),
                    ],
                    Text(
                        p.badge == _Badge.best
                            ? 'Lựa chọn tốt nhất'
                            : 'Lựa chọn tối ưu',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _priceBox() {
    Widget period(String label, int now, int old) {
      return Expanded(
        child: Column(
          children: [
            Text(label,
                style: const TextStyle(
                    color: _muted, fontSize: 11, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(_fmt(now),
                  style: const TextStyle(
                      color: _dark, fontSize: 15, fontWeight: FontWeight.w800)),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(_fmt(old),
                  style: const TextStyle(
                      color: Color(0xFF9AA5B4),
                      fontSize: 11,
                      decoration: TextDecoration.lineThrough)),
            ),
            Text('-${_Plan.pct(now, old)}%',
                style: const TextStyle(
                    color: _green, fontSize: 11, fontWeight: FontWeight.w800)),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F8FC),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(_fmt(p.hourly),
                  style: const TextStyle(
                      color: _primary,
                      fontSize: 30,
                      fontWeight: FontWeight.w800)),
              const Text(' đ/giờ',
                  style: TextStyle(
                      color: _dark, fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_fmt(p.oldHourly),
                  style: const TextStyle(
                      color: Color(0xFF9AA5B4),
                      fontSize: 13,
                      decoration: TextDecoration.lineThrough)),
              const SizedBox(width: 10),
              Text('-${_Plan.pct(p.hourly, p.oldHourly)}%',
                  style: const TextStyle(
                      color: _green,
                      fontSize: 13,
                      fontWeight: FontWeight.w800)),
            ],
          ),
          const Divider(height: 20, color: _border),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              period('NGÀY', p.day, p.oldDay),
              period('TUẦN', p.week, p.oldWeek),
              period('THÁNG', p.month, p.oldMonth),
            ],
          ),
        ],
      ),
    );
  }

  Widget _spec(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 15, color: _muted),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: _muted, fontSize: 13)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(value,
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: _dark, fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _osPill() {
    final color = p.ubuntu ? _amber : _primary;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.desktop_windows_outlined, size: 16, color: color),
          const SizedBox(width: 8),
          Text(p.os,
              style: TextStyle(
                  color: color, fontSize: 13, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _StockPill extends StatelessWidget {
  final bool inStock;
  const _StockPill(this.inStock);

  @override
  Widget build(BuildContext context) {
    final c = inStock ? _green : _muted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: c.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: c, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(inStock ? 'Còn slot' : 'Hết slot',
              style: TextStyle(
                  color: c, fontSize: 11, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool highlight;
  const _MiniChip(this.icon, this.text, this.highlight);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: highlight ? const Color(0xFFE6F4FC) : const Color(0xFFF1F4F8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: highlight ? _primary : _muted),
          const SizedBox(width: 6),
          Expanded(
            child: Text(text,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: highlight ? _dark : _muted,
                    fontSize: 13,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

/* ------------------------------------------------------------------ */
/* Thuê ngay                                                           */
/* ------------------------------------------------------------------ */

void _openHistory(BuildContext context) {
  if (!AuthState.isLoggedIn) {
    Navigator.of(context).pushNamed('/login');
    return;
  }
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => const HistoryPage()),
  );
}

void _openMyGpus(BuildContext context) {
  if (!AuthState.isLoggedIn) {
    Navigator.of(context).pushNamed('/login');
    return;
  }
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => const MyGpusPage()),
  );
}

void _rentNow(BuildContext context, _Plan p) {
  if (!AuthState.isLoggedIn) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Vui lòng đăng nhập để thuê GPU')),
    );
    Navigator.of(context).pushNamed('/login');
    return;
  }
  showDialog(context: context, builder: (_) => _RentDialog(plan: p));
}

enum _Unit { hour, day, week, month }

class _RentDialog extends StatefulWidget {
  final _Plan plan;
  const _RentDialog({required this.plan});

  @override
  State<_RentDialog> createState() => _RentDialogState();
}

class _RentDialogState extends State<_RentDialog> {
  _Unit _unit = _Unit.hour;
  int _qty = 1;
  bool _busy = false;

  _Plan get p => widget.plan;

  // Chỉ để hiển thị; server tự tính lại giá khi thuê.
  int get _unitPrice {
    switch (_unit) {
      case _Unit.hour:
        return p.hourly;
      case _Unit.day:
        return p.day;
      case _Unit.week:
        return p.week;
      case _Unit.month:
        return p.month;
    }
  }

  int get _maxQty {
    switch (_unit) {
      case _Unit.hour:
        return 72;
      case _Unit.day:
        return 30;
      case _Unit.week:
        return 12;
      case _Unit.month:
        return 12;
    }
  }

  Duration get _duration {
    switch (_unit) {
      case _Unit.hour:
        return Duration(hours: _qty);
      case _Unit.day:
        return Duration(days: _qty);
      case _Unit.week:
        return Duration(days: 7 * _qty);
      case _Unit.month:
        return Duration(days: 30 * _qty);
    }
  }

  String get _unitName {
    switch (_unit) {
      case _Unit.hour:
        return 'giờ';
      case _Unit.day:
        return 'ngày';
      case _Unit.week:
        return 'tuần';
      case _Unit.month:
        return 'tháng';
    }
  }

  int get _total => _unitPrice * _qty;

  /// Gửi yêu cầu thuê lên server. Server kiểm tra số dư, trừ tiền,
  /// tạo máy và ghi lịch sử; app chỉ tải lại dữ liệu sau đó.
  Future<void> _confirm() async {
    if (_busy) return;
    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);

    try {
      await Api.post('/rentals', {
        'planId': p.id,
        'unit': _unit.name, // hour | day | week | month
        'qty': _qty,
      });
    } on ApiException catch (e) {
      if (mounted) setState(() => _busy = false);
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
      return;
    }

    // Thuê đã thành công; lỗi khi tải lại dữ liệu không được báo là lỗi thuê
    try {
      await AppData.refreshAll();
    } catch (_) {}

    nav.pop();
    messenger.showSnackBar(SnackBar(
      content: const Text('Thuê GPU thành công'),
      action: SnackBarAction(
        label: 'Quản lý GPU',
        onPressed: () => nav.push(
          MaterialPageRoute(builder: (_) => const MyGpusPage()),
        ),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    Widget row(String label, String value, {bool bold = false, Color? color}) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Text(label, style: const TextStyle(color: _muted, fontSize: 13)),
            const Spacer(),
            Text(value,
                style: TextStyle(
                    color: color ?? _dark,
                    fontSize: bold ? 16 : 13,
                    fontWeight: bold ? FontWeight.w800 : FontWeight.w600)),
          ],
        ),
      );
    }

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ValueListenableBuilder<int>(
            valueListenable: BalanceState.balance,
            builder: (context, bal, _) {
              final total = _total;
              final enough = bal >= total;
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.name,
                      style: const TextStyle(
                          color: _dark,
                          fontSize: 18,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text('${p.gpu} • ${p.location} • ${p.os}',
                      style: const TextStyle(
                          color: _primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                  if (p.ubuntu) ...[
                    const SizedBox(height: 10),
                    const Text(
                        'Ubuntu chỉ phù hợp cho AI/ML, không dùng để chơi game, render.',
                        style: TextStyle(color: _red, fontSize: 12.5)),
                  ],
                  const SizedBox(height: 16),
                  const Text('Thời hạn thuê',
                      style: TextStyle(
                          color: _dark,
                          fontSize: 14,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final u in _Unit.values)
                        ChoiceChip(
                          label: Text(const {
                            _Unit.hour: 'Theo giờ',
                            _Unit.day: 'Theo ngày',
                            _Unit.week: 'Theo tuần',
                            _Unit.month: 'Theo tháng',
                          }[u]!),
                          selected: _unit == u,
                          onSelected: _busy
                              ? null
                              : (_) => setState(() {
                                    _unit = u;
                                    _qty = 1;
                                  }),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('Số lượng',
                          style: TextStyle(color: _muted, fontSize: 13)),
                      const Spacer(),
                      IconButton(
                        onPressed: (!_busy && _qty > 1)
                            ? () => setState(() => _qty--)
                            : null,
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      SizedBox(
                        width: 70,
                        child: Text('$_qty $_unitName',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: _dark,
                                fontSize: 15,
                                fontWeight: FontWeight.w800)),
                      ),
                      IconButton(
                        onPressed: (!_busy && _qty < _maxQty)
                            ? () => setState(() => _qty++)
                            : null,
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                  const Divider(height: 24, color: _border),
                  row('Đơn giá', '${formatVnd(_unitPrice)}đ / $_unitName'),
                  row('Dùng đến', fmtDateTime(DateTime.now().add(_duration))),
                  row('Tổng thanh toán', '${formatVnd(total)}đ',
                      bold: true, color: _primary),
                  const SizedBox(height: 4),
                  row('Số dư hiện tại', '${formatVnd(bal)}đ'),
                  if (!enough)
                    row('Còn thiếu', '${formatVnd(total - bal)}đ',
                        color: _red),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      TextButton(
                        onPressed: _busy ? null : () => Navigator.pop(context),
                        child: const Text('Hủy',
                            style: TextStyle(color: _muted)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SizedBox(
                          height: 46,
                          child: FilledButton(
                            onPressed: _busy
                                ? null
                                : (enough
                                    ? _confirm
                                    : () => _openTopUp(context)),
                            style: FilledButton.styleFrom(
                              backgroundColor: enough ? _primaryDark : _amber,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            child: _busy
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white),
                                  )
                                : Text(
                                    enough
                                        ? 'Xác nhận thuê • ${formatVnd(total)}đ'
                                        : 'Nạp tiền để thuê',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}