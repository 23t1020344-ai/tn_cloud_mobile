import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'auth_state.dart';
import 'gpu_hourly_page.dart';

const _primary = Color(0xFF0B7FC7);
const _primaryDark = Color(0xFF0069AE);
const _dark = Color(0xFF0F1B2D);
const _muted = Color(0xFF5B6B80);
const _border = Color(0xFFDDE5EE);
const _console = Color(0xFF0E1A2E);
const _cyan = Color(0xFF2BC4E8);

const _navItems = {
  'Sản phẩm': 'usecases',
  'Bảng giá': 'pricing',
  'Giới thiệu': 'features',
  'Hỗ trợ': 'footer',
  'Liên hệ': 'contact',
};

const _facebookUrl = 'https://www.facebook.com/cachuon.23';

class _ProductItem {
  final String id;
  final IconData icon;
  final String title;
  final String subtitle;
  const _ProductItem(this.id, this.icon, this.title, this.subtitle);
}

const _productItems = [
  _ProductItem('hourly', Icons.memory, 'GPU Theo giờ',
      'Thuê GPU linh hoạt, trả theo giờ'),
  _ProductItem('docker', Icons.view_in_ar_outlined, 'Docker GPU',
      'Container GPU cho AI/ML workloads'),
];

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  final _keys = <String, GlobalKey>{
    'usecases': GlobalKey(),
    'features': GlobalKey(),
    'pricing': GlobalKey(),
    'footer': GlobalKey(),
  };

  Future<void> _openFacebook() async {
    final ok = await launchUrl(Uri.parse(_facebookUrl),
        mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không mở được liên kết Facebook')),
      );
    }
  }

  void _go(String id) {
    if (id == 'contact') {
      _openFacebook();
      return;
    }
    if (id == 'top') {
      _scroll.animateTo(0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut);
      return;
    }
    if (id == 'docker') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Docker GPU sắp ra mắt')),
      );
      return;
    }
    if (id == 'hourly') {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const GpuHourlyPage()),
      );
      return;
    }
    final ctx = _keys[id]?.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      alignment: 0.1, // chừa chỗ cho thanh menu nổi
    );
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width >= 960;
    return Scaffold(
      endDrawer: _MenuDrawer(onNav: _go),
      body: Stack(
        fit: StackFit.expand,
        children: [
          SingleChildScrollView(
            controller: _scroll,
            child: Column(
              children: [
                _HeroSection(wide: wide),
                _ProblemSection(onExplore: () => _go('usecases')),
                KeyedSubtree(
                    key: _keys['usecases'], child: const _UseCasesSection()),
                KeyedSubtree(
                    key: _keys['features'], child: const _FeaturesSection()),
                const _StatsSection(),
                KeyedSubtree(
                    key: _keys['pricing'], child: const _PricingSection()),
                _CtaSection(onPricing: () => _go('pricing')),
                KeyedSubtree(
                    key: _keys['footer'], child: const _FooterSection()),
              ],
            ),
          ),
          // Thanh menu nổi: luôn nằm trên cùng khi cuộn
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(wide ? 24 : 16, 16, wide ? 24 : 16, 0),
                child: Center(
                  heightFactor: 1,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1240),
                    child: _NavBar(wide: wide, onNav: _go),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  final bool wide;
  const _HeroSection({required this.wide});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top + (wide ? 120 : 100);
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE3F4FC), Colors.white, Color(0xFFFFFBF5)],
          stops: [0, 0.45, 1],
        ),
      ),
      padding: EdgeInsets.fromLTRB(wide ? 24 : 16, top, wide ? 24 : 16, wide ? 96 : 64),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: wide
              ? const Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(flex: 12, child: _HeroText()),
                    SizedBox(width: 40),
                    Expanded(flex: 10, child: _ConsoleMock(wide: true)),
                  ],
                )
              : const Column(
                  children: [
                    _HeroText(),
                    SizedBox(height: 40),
                    _ConsoleMock(wide: false),
                  ],
                ),
        ),
      ),
    );
  }
}

/* ------------------------------ Logo -------------------------------- */

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
                colors: [Color(0xFF29A8E8), _primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
          ),
          child: const Icon(Icons.cloud_outlined, color: Colors.white, size: 22),
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
    );
  }
}

/* ------------------------------ Navbar ------------------------------ */

void _logout(BuildContext context) {
  AuthState.logout();
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Đã đăng xuất')),
  );
}

class _Avatar extends StatelessWidget {
  final String name;
  const _Avatar(this.name);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 18,
      backgroundColor: _primary,
      child: Text(
        name.isEmpty ? '?' : name[0].toUpperCase(),
        style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
      ),
    );
  }
}

class _NavBar extends StatelessWidget {
  final bool wide;
  final void Function(String) onNav;
  const _NavBar({required this.wide, required this.onNav});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: wide ? 18 : 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border.withOpacity(0.7)),
        boxShadow: [
          BoxShadow(
              color: _primary.withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, 8))
        ],
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => onNav('top'),
            borderRadius: BorderRadius.circular(12),
            child: const _Logo(),
          ),
          const Spacer(),
          if (wide) ...[
            _ProductMenu(onNav: onNav),
            _NavLink('Bảng giá', onTap: () => onNav('pricing')),
            _NavLink('Giới thiệu', onTap: () => onNav('features')),
            _NavLink('Hỗ trợ', onTap: () => onNav('footer')),
            _NavLink('Liên hệ', onTap: () => onNav('contact')),
            const Spacer(),
          ],
          // Đổi giao diện theo trạng thái đăng nhập
          ValueListenableBuilder<String?>(
            valueListenable: AuthState.userName,
            builder: (context, name, _) {
              if (name == null) {
                // Mobile: nút đăng nhập/đăng ký nằm trong menu bên phải.
                if (!wide) return const SizedBox.shrink();
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/login'),
                      child: const Text('Đăng nhập',
                          style: TextStyle(
                              color: _dark,
                              fontWeight: FontWeight.w700,
                              fontSize: 14)),
                    ),
                    const SizedBox(width: 8),
                    _GradientButton(
                      text: 'Bắt đầu',
                      height: 46,
                      onPressed: () =>
                          Navigator.pushNamed(context, '/register'),
                    ),
                  ],
                );
              }

              // Đã đăng nhập
              if (!wide) return _Avatar(name);
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _Avatar(name),
                  const SizedBox(width: 10),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 140),
                    child: Text(
                      name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: _dark,
                          fontWeight: FontWeight.w700,
                          fontSize: 14),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () => _logout(context),
                    icon: const Icon(Icons.logout, size: 16, color: _muted),
                    label: const Text('Đăng xuất',
                        style: TextStyle(
                            color: _muted,
                            fontWeight: FontWeight.w600,
                            fontSize: 13)),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 44),
                      side: const BorderSide(color: _border),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              );
            },
          ),
          if (!wide)
            IconButton(
              icon: const Icon(Icons.menu_rounded, color: _dark),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
        ],
      ),
    );
  }
}

class _ProductMenu extends StatefulWidget {
  final void Function(String) onNav;
  const _ProductMenu({required this.onNav});

  @override
  State<_ProductMenu> createState() => _ProductMenuState();
}

class _ProductMenuState extends State<_ProductMenu> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: '',
      offset: const Offset(-12, 44),
      color: Colors.white,
      elevation: 10,
      shadowColor: Colors.black.withOpacity(0.25),
      constraints: const BoxConstraints(minWidth: 300, maxWidth: 300),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: _border),
      ),
      onOpened: () => setState(() => _open = true),
      onCanceled: () => setState(() => _open = false),
      onSelected: (id) {
        setState(() => _open = false);
        widget.onNav(id);
      },
      itemBuilder: (_) => [
        for (final it in _productItems)
          PopupMenuItem<String>(
            value: it.id,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Icon(it.icon, color: _primary, size: 22),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(it.title,
                          style: const TextStyle(
                              color: _dark,
                              fontSize: 15,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(it.subtitle,
                          style: const TextStyle(
                              color: Color(0xFF8A97AB),
                              fontSize: 12.5,
                              height: 1.35)),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Sản phẩm',
                style: TextStyle(
                    color: _muted, fontWeight: FontWeight.w500, fontSize: 14)),
            Icon(_open ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                size: 16, color: _muted),
          ],
        ),
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  final String text;
  final bool dropdown;
  final VoidCallback onTap;
  const _NavLink(this.text, {this.dropdown = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Text(text,
                style: const TextStyle(
                    color: _muted, fontWeight: FontWeight.w500, fontSize: 14)),
            if (dropdown)
              const Icon(Icons.keyboard_arrow_down, size: 16, color: _muted),
          ],
        ),
      ),
    );
  }
}

/* ------------------------------ Drawer (mobile) ---------------------- */

class _MenuDrawer extends StatelessWidget {
  final void Function(String) onNav;
  const _MenuDrawer({required this.onNav});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ValueListenableBuilder<String?>(
            valueListenable: AuthState.userName,
            builder: (context, name, _) {
              final loggedIn = name != null;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      onNav('top');
                    },
                    child: const _Logo(),
                  ),
                  const SizedBox(height: 24),
                  if (loggedIn) ...[
                    Row(
                      children: [
                        _Avatar(name),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: _dark,
                                fontWeight: FontWeight.w700,
                                fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                  for (final item in _navItems.entries)
                    if (item.key == 'Sản phẩm')
                      ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        shape: const Border(),
                        collapsedShape: const Border(),
                        title: const Text('Sản phẩm',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: _dark)),
                        children: [
                          for (final it in _productItems)
                            ListTile(
                              contentPadding: const EdgeInsets.only(left: 8),
                              leading: Icon(it.icon, color: _primary),
                              title: Text(it.title,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: _dark)),
                              subtitle: Text(it.subtitle,
                                  style: const TextStyle(fontSize: 12)),
                              onTap: () {
                                Navigator.pop(context);
                                onNav(it.id);
                              },
                            ),
                        ],
                      )
                    else
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(item.key,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: _dark)),
                        onTap: () {
                          Navigator.pop(context);
                          onNav(item.value);
                        },
                      ),
                  const Divider(height: 32),
                  if (loggedIn)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.logout, color: _muted),
                      title: const Text('Đăng xuất',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                      onTap: () {
                        Navigator.pop(context);
                        _logout(context);
                      },
                    )
                  else ...[
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Đăng nhập',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/login');
                      },
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: _GradientButton(
                        text: 'Bắt đầu',
                        expand: true,
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/register');
                        },
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String text;
  final double height;
  final bool expand;
  final VoidCallback onPressed;
  const _GradientButton({
    required this.text,
    required this.onPressed,
    this.height = 54,
    this.expand = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient:
            const LinearGradient(colors: [Color(0xFF14A0E6), _primaryDark]),
        boxShadow: [
          BoxShadow(
              color: _primary.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 6))
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Row(
              mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(text,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15)),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, color: Colors.white, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* ------------------------------ Hero text --------------------------- */

class _HeroText extends StatelessWidget {
  const _HeroText();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final wide = width >= 960;
    final size = wide ? 64.0 : (width < 380 ? 36.0 : 44.0);

    // Màn rộng: mỗi dòng tiêu đề co vừa khít (không bị rớt chữ "giây.")
    Widget headline(String text, Color color) {
      final t = Text(text,
          style: TextStyle(
              color: color,
              fontSize: size,
              fontWeight: FontWeight.w800,
              height: 1.08,
              letterSpacing: -1.5));
      return wide
          ? FittedBox(
              fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: t)
          : t;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: _primary.withOpacity(0.25)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_awesome_outlined, size: 14, color: _primary),
              SizedBox(width: 8),
              Flexible(
                child: Text('Hạ tầng GPU Cloud tại Việt Nam',
                    style: TextStyle(
                        color: _primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        headline('Sức mạnh GPU.', _dark),
        headline('Sẵn sàng trong 60 giây.', _primary),
        const SizedBox(height: 24),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Text(
            'Khởi tạo máy chủ GPU hiệu năng cao cho AI, Machine Learning và 3D Rendering. Trả phí theo giờ, mở rộng tức thì, không cần đầu tư phần cứng.',
            style: TextStyle(
                color: _muted, fontSize: wide ? 17 : 15, height: 1.7),
          ),
        ),
        const SizedBox(height: 32),
        Wrap(
          spacing: 14,
          runSpacing: 12,
          children: [
        _GradientButton(
  text: 'Khởi tạo GPU',
  onPressed: () => _startAction(context),
),
            OutlinedButton(
              onPressed: () => _openHourly(context),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 54),
                padding: const EdgeInsets.symmetric(horizontal: 26),
                backgroundColor: Colors.white,
                side: const BorderSide(color: _border),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Khám phá cấu hình',
                  style: TextStyle(
                      color: _dark, fontWeight: FontWeight.w700, fontSize: 15)),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Wrap(
          spacing: 28,
          runSpacing: 8,
          children: [
            _Check('Không cần thẻ tín dụng'),
            _Check('Hỗ trợ kỹ thuật 24/7'),
          ],
        ),
      ],
    );
  }
}

class _Check extends StatelessWidget {
  final String text;
  const _Check(this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check, size: 14, color: Color(0xFF16A37F)),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(color: _muted, fontSize: 12)),
      ],
    );
  }
}

/* ------------------------------ Console mock ------------------------ */

class _ConsoleMock extends StatelessWidget {
  final bool wide;
  const _ConsoleMock({required this.wide});

  @override
  Widget build(BuildContext context) {
    Widget card = const _ConsoleCard();
    if (wide) {
      card = Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.0008)
          ..rotateY(-0.1)
          ..rotateX(0.04),
        child: card,
      );
    }

    // Card quyết định chiều cao (không còn AspectRatio + Spacer nên không tràn).
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 24, 24, 36),
          child: card,
        ),
        const Positioned(
          top: 0,
          right: 0,
          child: _FloatChip(
              icon: Icons.bolt, title: 'Khởi tạo', subtitle: 'chỉ 60 giây'),
        ),
        // Giữa cạnh dưới: không đè lên "Thời gian chạy" (trái) và giá (phải).
        const Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Center(
            child: _FloatChip(
                icon: Icons.shield_outlined,
                title: 'Dữ liệu',
                subtitle: 'an toàn tuyệt đối'),
          ),
        ),
      ],
    );
  }
}

class _ConsoleCard extends StatelessWidget {
  const _ConsoleCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _console,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: _dark.withOpacity(0.35),
              blurRadius: 40,
              offset: const Offset(0, 24))
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              for (final c in const [
                Color(0xFFFF5F57),
                Color(0xFFFEBC2E),
                Color(0xFF28C840)
              ])
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(color: c, shape: BoxShape.circle),
                ),
              const Spacer(),
              const Text('TN CLOUD CONSOLE',
                  style: TextStyle(
                      color: Color(0xFF6E7F99),
                      fontSize: 9,
                      letterSpacing: 1.5)),
              const Spacer(),
              const SizedBox(width: 50),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _cyan.withOpacity(0.35)),
                  color: _cyan.withOpacity(0.08),
                ),
                child: const Icon(Icons.memory, color: _cyan),
              ),
              const SizedBox(width: 14),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('GPU INSTANCE',
                      style: TextStyle(
                          color: Color(0xFF6E7F99),
                          fontSize: 9,
                          letterSpacing: 1)),
                  SizedBox(height: 2),
                  Text('RTX 4090 Pro',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 17)),
                ],
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF16A37F).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('Running',
                    style: TextStyle(color: Color(0xFF3DDC97), fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
              color: Colors.white.withOpacity(0.03),
            ),
            child: const Column(
              children: [
                _Metric(label: 'GPU LOAD', value: '87%', progress: 0.87),
                SizedBox(height: 16),
                _Metric(
                    label: 'VRAM', value: '18.4 / 24 GB', progress: 18.4 / 24),
                SizedBox(height: 16),
                _Metric(label: 'TEMPERATURE', value: '62°C', progress: 0.62),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Thời gian chạy',
                      style: TextStyle(color: Color(0xFF6E7F99), fontSize: 10)),
                  SizedBox(height: 2),
                  Text('02:48:16',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14)),
                ],
              ),
              Spacer(),
              Text('9.000đ',
                  style: TextStyle(
                      color: _cyan, fontWeight: FontWeight.w800, fontSize: 22)),
              Text(' / giờ',
                  style: TextStyle(color: Color(0xFF6E7F99), fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  final double progress;
  const _Metric(
      {required this.label, required this.value, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(label,
                style: const TextStyle(
                    color: Color(0xFF6E7F99), fontSize: 10, letterSpacing: 1)),
            const Spacer(),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 4,
            backgroundColor: Colors.white.withOpacity(0.08),
            valueColor: const AlwaysStoppedAnimation(_cyan),
          ),
        ),
      ],
    );
  }
}

class _FloatChip extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _FloatChip(
      {required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8))
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: _primary),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: _primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 12)),
              Text(subtitle,
                  style: const TextStyle(color: _muted, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}

/* ======================================================================= */
/* Các phần của trang chủ                                                   */
/* ======================================================================= */

const _sectionMax = 1100.0;
const _darkBg1 = Color(0xFF08111F);
const _darkBg2 = Color(0xFF0F2038);
const _softText = Color(0xFF9FB0C7);

bool _isWide(BuildContext c) => MediaQuery.of(c).size.width >= 960;

void _openHourly(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => const GpuHourlyPage()),
  );
}

void _startAction(BuildContext context) {
  if (AuthState.isLoggedIn) {
    _openHourly(context);
  } else {
    Navigator.pushNamed(context, '/register');
  }
}

/// Khung chung cho mỗi phần: nền, padding, giới hạn bề ngang.
class _SectionFrame extends StatelessWidget {
  final Widget child;
  final Color? color;
  final Gradient? gradient;
  final double vertical;
  const _SectionFrame({
    required this.child,
    this.color,
    this.gradient,
    this.vertical = 80,
  });

  @override
  Widget build(BuildContext context) {
    final wide = _isWide(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: color, gradient: gradient),
      padding: EdgeInsets.symmetric(
        vertical: wide ? vertical : vertical * 0.7,
        horizontal: wide ? 24 : 16,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _sectionMax),
          child: SizedBox(width: double.infinity, child: child),
        ),
      ),
    );
  }
}

class _TagPill extends StatelessWidget {
  final String text;
  final bool dark;
  const _TagPill(this.text, {this.dark = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: dark ? _cyan.withOpacity(0.12) : const Color(0xFFDDF0FB),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text,
          style: TextStyle(
              color: dark ? _cyan : _primary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8)),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  final String? tag;
  final String title;
  final String? subtitle;
  final bool dark;
  const _SectionHeading({
    this.tag,
    required this.title,
    this.subtitle,
    this.dark = false,
  });

  @override
  Widget build(BuildContext context) {
    final wide = _isWide(context);
    return Column(
      children: [
        if (tag != null) ...[
          _TagPill(tag!, dark: dark),
          const SizedBox(height: 16),
        ],
        Text(title,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: dark ? Colors.white : _dark,
                fontSize: wide ? 40 : 28,
                fontWeight: FontWeight.w800,
                height: 1.2,
                letterSpacing: -0.5)),
        if (subtitle != null) ...[
          const SizedBox(height: 14),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Text(subtitle!,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: dark ? _softText : _muted,
                    fontSize: 15,
                    height: 1.6)),
          ),
        ],
      ],
    );
  }
}

/// Lưới thẻ: 3 cột trên màn rộng, 2 cột màn vừa, 1 cột trên điện thoại.
/// Các thẻ cùng hàng luôn cao bằng nhau.
class _CardGrid extends StatelessWidget {
  final List<Widget> children;
  final int columns;
  final double gap;
  const _CardGrid({required this.children, this.columns = 3, this.gap = 20});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final cols = c.maxWidth >= 760
          ? columns
          : (c.maxWidth >= 520 && columns > 2 ? 2 : 1);
      final rows = <Widget>[];
      for (var i = 0; i < children.length; i += cols) {
        final slice = <Widget>[...children.skip(i).take(cols)];
        while (slice.length < cols) {
          slice.add(const SizedBox.shrink());
        }
        rows.add(IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var j = 0; j < slice.length; j++) ...[
                if (j > 0) SizedBox(width: gap),
                Expanded(child: slice[j]),
              ],
            ],
          ),
        ));
        if (i + cols < children.length) rows.add(SizedBox(height: gap));
      }
      return Column(children: rows);
    });
  }
}

/* ------------------------- 1. Vấn đề -------------------------------- */

class _ProblemSection extends StatelessWidget {
  final VoidCallback onExplore;
  const _ProblemSection({required this.onExplore});

  @override
  Widget build(BuildContext context) {
    final wide = _isWide(context);
    return _SectionFrame(
      color: Colors.white,
      child: Column(
        children: [
          Text.rich(
            TextSpan(
              style: TextStyle(
                  fontSize: wide ? 44 : 28,
                  fontWeight: FontWeight.w800,
                  height: 1.25,
                  letterSpacing: -1),
              children: const [
                TextSpan(
                    text: 'Mua GPU đắt đỏ, cấu hình phức tạp,\n',
                    style: TextStyle(color: _dark)),
                TextSpan(
                    text: 'bảo trì tốn kém?',
                    style: TextStyle(color: Color(0xFF9AA5B4))),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: const Text(
              'Đầu tư hàng trăm triệu cho GPU nhưng chỉ dùng vài giờ một ngày. Các giải pháp truyền thống quá đắt hoặc quá phức tạp.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _muted, fontSize: 16, height: 1.7),
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: onExplore,
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Text('Khám phá cách thông minh hơn.',
                  style: TextStyle(
                      color: _primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 48),
          const _CardGrid(
            children: [
              _ProblemCard(
                icon: Icons.attach_money,
                iconColor: Color(0xFFE11D48),
                iconBg: Color(0xFFFFD9E0),
                bg: Color(0xFFFFF3F5),
                border: Color(0xFFFBD5DC),
                title: 'Chi phí khổng lồ',
                desc: 'GPU cao cấp có thể tốn 50-200 triệu VND',
              ),
              _ProblemCard(
                icon: Icons.wifi,
                iconColor: Color(0xFFD99A00),
                iconBg: Color(0xFFFFEFB8),
                bg: Color(0xFFFFFCEB),
                border: Color(0xFFF7EBB8),
                title: 'Lãng phí tài nguyên',
                desc: 'GPU chỉ sử dụng 10-20% thời gian',
              ),
              _ProblemCard(
                icon: Icons.settings_outlined,
                iconColor: Color(0xFFD99A00),
                iconBg: Color(0xFFFFEFB8),
                bg: Color(0xFFFFFCEB),
                border: Color(0xFFF7EBB8),
                title: 'Bảo trì phức tạp',
                desc: 'Cấu hình, driver, cooling, điện năng',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProblemCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final Color bg;
  final Color border;
  final String title;
  final String desc;
  const _ProblemCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.bg,
    required this.border,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
                color: iconBg, borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: iconColor, size: 26),
          ),
          const SizedBox(height: 16),
          Text(title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: _dark, fontSize: 17, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(desc,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _muted, fontSize: 13, height: 1.5)),
        ],
      ),
    );
  }
}

/* ------------------------- 2. Giải pháp theo ngành ------------------ */

class _UseCasesSection extends StatelessWidget {
  const _UseCasesSection();

  @override
  Widget build(BuildContext context) {
    return const _SectionFrame(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [_darkBg1, _darkBg2],
      ),
      child: Column(
        children: [
          _SectionHeading(
            tag: 'GIẢI PHÁP CHO MỌI NHU CẦU',
            dark: true,
            title: 'GPU Cloud Computing cho mọi ngành nghề',
            subtitle:
                'Từ startup AI, studio 3D rendering đến game developer - TN CLOUD cung cấp hiệu năng GPU cao cấp cho machine learning, deep learning và high-performance computing.',
          ),
          SizedBox(height: 48),
          _CardGrid(
            children: [
              _UseCaseCard(
                badge: 'Phổ biến nhất',
                icon: Icons.psychology_outlined,
                title: 'AI & Machine Learning Training',
                desc:
                    'Huấn luyện và triển khai các mô hình AI/ML phức tạp với TensorFlow, PyTorch, CUDA. Phù hợp cho deep learning, computer vision, xử lý ngôn ngữ tự nhiên (NLP) và mạng neural.',
              ),
              _UseCaseCard(
                badge: 'Pro',
                icon: Icons.movie_creation_outlined,
                title: '3D Rendering & Video Production',
                desc:
                    'Render video 4K/8K, thiết kế 3D với Blender, Maya, Cinema 4D, After Effects. Tăng tốc quy trình sáng tạo với CUDA và OptiX ray tracing.',
              ),
              _UseCaseCard(
                badge: 'Hot',
                icon: Icons.sports_esports_outlined,
                title: 'Cloud Gaming & Game Streaming',
                desc:
                    'Chơi game AAA với ray tracing, cloud gaming độ trễ thấp. Hỗ trợ NVIDIA GeForce Experience, DLSS, RTX, game server hosting.',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UseCaseCard extends StatelessWidget {
  final String badge;
  final IconData icon;
  final String title;
  final String desc;
  const _UseCaseCard({
    required this.badge,
    required this.icon,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: _cyan, borderRadius: BorderRadius.circular(12)),
            child: Text(badge,
                style: const TextStyle(
                    color: _darkBg1, fontSize: 10, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _cyan.withOpacity(0.3)),
                  color: _cyan.withOpacity(0.08),
                ),
                child: Icon(icon, color: _cyan, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        height: 1.25)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(desc,
              style:
                  const TextStyle(color: _softText, fontSize: 13, height: 1.65)),
          const SizedBox(height: 18),
          const Spacer(),
          InkWell(
            onTap: () => _startAction(context),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Khám phá ngay',
                    style: TextStyle(
                        color: _cyan, fontSize: 13, fontWeight: FontWeight.w700)),
                SizedBox(width: 6),
                Icon(Icons.arrow_forward, size: 14, color: _cyan),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/* ------------------------- 3. Tính năng nổi bật --------------------- */

class _FeaturesSection extends StatelessWidget {
  const _FeaturesSection();

  @override
  Widget build(BuildContext context) {
    return const _SectionFrame(
      color: Color(0xFFF8FAFC),
      child: Column(
        children: [
          _SectionHeading(
            tag: 'TÍNH NĂNG NỔI BẬT',
            title: 'Nền tảng GPU mạnh mẽ & tin cậy',
            subtitle:
                'Mọi tính năng GPU cloud bạn cần để tối ưu hóa hiệu suất AI training, machine learning, deep learning, 3D rendering và high-performance computing.',
          ),
          SizedBox(height: 48),
          _CardGrid(
            children: [
              _FeatureCard(
                icon: Icons.memory,
                title: 'GPU hiệu năng cao',
                desc:
                    'Truy cập sức mạnh từ các dòng card đồ họa NVIDIA mới nhất như RTX 5090, RTX 5060 Ti, sẵn sàng cho mọi workload AI, ML, render đồ họa phức tạp và gaming tối ưu.',
              ),
              _FeatureCard(
                icon: Icons.shield_outlined,
                title: 'Dữ liệu riêng tư',
                desc:
                    'Toàn bộ dữ liệu trên máy thuê được xóa sau khi phiên thuê kết thúc, không lưu lại trên hệ thống của chúng tôi.',
              ),
              _FeatureCard(
                icon: Icons.bolt,
                title: 'Triển khai nhanh chóng',
                desc:
                    'Chỉ cần vài cú click chuột, bạn đã có thể triển khai GPU cho dự án của mình trong vòng 60 giây mà không cần lo lắng về việc cấu hình phần cứng.',
              ),
              _FeatureCard(
                icon: Icons.schedule,
                title: 'Thanh toán linh hoạt theo giờ',
                desc:
                    'Chi trả tiền cho những gì bạn sử dụng với mô hình tính phí GPU theo giờ, không ràng buộc dài hạn, hỗ trợ nhiều phương thức thanh toán: chuyển khoản ngân hàng, ví điện tử.',
              ),
              _FeatureCard(
                icon: Icons.groups_outlined,
                title: 'Hỗ trợ đa kênh',
                desc:
                    'Đội ngũ kỹ thuật chuyên nghiệp sẵn sàng hỗ trợ bạn qua nhiều kênh: Email, Discord, Facebook,... với thời gian phản hồi nhanh nhất có thể (8 AM - 9 PM).',
              ),
              _FeatureCard(
                icon: Icons.workspace_premium_outlined,
                title: 'Hiệu suất đảm bảo',
                desc:
                    'Cam kết performance monitoring real-time và đảm bảo chất lượng dịch vụ cao nhất cho mọi dự án của bạn.',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  const _FeatureCard(
      {required this.icon, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 6))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
                color: const Color(0xFFE6F4FC),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: _primary, size: 22),
          ),
          const SizedBox(height: 20),
          Text(title,
              style: const TextStyle(
                  color: _dark, fontSize: 17, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          Text(desc,
              style: const TextStyle(color: _muted, fontSize: 13, height: 1.65)),
        ],
      ),
    );
  }
}

/* ------------------------- 4. Số liệu ------------------------------- */

class _StatsSection extends StatelessWidget {
  const _StatsSection();

  @override
  Widget build(BuildContext context) {
    // TODO: thay bằng số liệu thật của TN CLOUD
    return _SectionFrame(
      vertical: 72,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [_darkBg2, _darkBg1],
      ),
      child: Column(
        children: [
          const _CardGrid(
            gap: 32,
            children: [
              _Stat('5,000+', 'Người dùng tin tưởng',
                  'Từ freelancer đến studio sáng tạo đều tin tưởng sử dụng dịch vụ của chúng tôi'),
              _Stat('425,000+', 'Giờ GPU đã phục vụ',
                  'Tổng số giờ GPU hiệu suất cao đã được sử dụng cho các nhu cầu khác nhau'),
              _Stat('~65%', 'Tiết kiệm chi phí',
                  'Giảm chi phí đáng kể so với việc đầu tư mua và bảo trì GPU riêng'),
            ],
          ),
          const SizedBox(height: 40),
          Divider(color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 24),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: const Text(
              'Được tin tưởng bởi các developer, data scientist, game thủ và studio sáng tạo khắp Việt Nam. Tham gia cộng đồng của chúng tôi để trải nghiệm sức mạnh GPU cloud ngay hôm nay.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _softText, fontSize: 15, height: 1.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  final String caption;
  const _Stat(this.value, this.label, this.caption);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(value,
              style: const TextStyle(
                  color: _cyan,
                  fontSize: 52,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1)),
        ),
        const SizedBox(height: 8),
        Text(label,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text(caption,
            textAlign: TextAlign.center,
            style:
                const TextStyle(color: _softText, fontSize: 13, height: 1.55)),
      ],
    );
  }
}

/* ------------------------- 5. Bảng giá ------------------------------ */

class _PricingSection extends StatelessWidget {
  const _PricingSection();

  @override
  Widget build(BuildContext context) {
    // TODO: thay bằng cấu hình & giá thật của TN CLOUD
    return _SectionFrame(
      color: Colors.white,
      child: Column(
        children: [
          const _SectionHeading(
            title: 'Bảng giá thuê GPU Cloud\nminh bạch - Không phí ẩn',
            subtitle:
                'Các tùy chọn linh hoạt để đáp ứng mọi quy mô dự án và ngân sách. Chỉ trả tiền cho những gì bạn sử dụng.',
          ),
          const SizedBox(height: 48),
          _CardGrid(
            gap: 24,
            children: [
              _PlanCard(
                badge: 'GAMING',
                name: 'Gaming GPU',
                gpu: 'NVIDIA RTX 4060 Ti/5060 Ti',
                price: '6.000',
                features: const [
                  '01 GPU NVIDIA RTX 4060 Ti/5060 Ti 16GB',
                  'Intel Core i5 12th Gen',
                  '28 GB RAM DDR4',
                  '4352/4608 CUDA cores',
                  '1.5TB SSD NVME',
                  'Network port 500Mbps',
                  'Không giới hạn băng thông',
                  'Hệ điều hành Windows 10 Pro',
                  'Hỗ trợ Ray Tracing',
                  'NVIDIA DLSS 3.0',
                ],
                button: 'Bắt đầu Gaming',
                onPressed: () => _startAction(context),
              ),
              _PlanCard(
                badge: 'CÂN BẰNG TỐT',
                name: 'Standard AI GPU',
                gpu: 'NVIDIA RTX 3090',
                price: '9.000',
                features: const [
                  '01 GPU NVIDIA RTX 3090 24GB',
                  'Intel Core i5 12th Gen',
                  '56 GB RAM DDR4',
                  '10496 CUDA cores',
                  '1.5TB SSD NVME',
                  'Network port 1Gbps',
                  'Không giới hạn băng thông',
                  'Hệ điều hành Windows 10 Pro',
                  'CUDA & cuDNN support',
                  'TensorFlow, PyTorch ready',
                ],
                button: 'Chọn Standard AI',
                onPressed: () => _startAction(context),
              ),
              _PlanCard(
                badge: 'KHUYÊN DÙNG',
                highlight: true,
                name: 'Pro AI, Design GPU',
                gpu: 'NVIDIA RTX 5090',
                price: '19.000',
                features: const [
                  '01 GPU NVIDIA RTX 5090 32GB',
                  'Intel Core i7 14th Gen',
                  '88 GB RAM DDR5',
                  '24575 CUDA cores',
                  '1.5TB SSD NVME Gen4',
                  'Network port 1Gbps',
                  'Không giới hạn băng thông',
                  'Hệ điều hành Windows 10 Pro',
                  'RT Cores Gen 3, Tensor Cores Gen 4',
                  'TensorFlow, PyTorch ready',
                ],
                button: 'Chọn Pro AI, Design',
                onPressed: () => _startAction(context),
              ),
            ],
          ),
          const SizedBox(height: 40),
          const Text('Cần cấu hình đặc biệt hoặc thuê số lượng lớn?',
              textAlign: TextAlign.center,
              style: TextStyle(color: _muted, fontSize: 13)),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () {},
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Liên hệ tư vấn miễn phí',
                    style: TextStyle(
                        color: _primary, fontWeight: FontWeight.w700)),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, size: 16, color: _primary),
              ],
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 46),
              padding: const EdgeInsets.symmetric(horizontal: 22),
              side: const BorderSide(color: _primary),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String badge;
  final bool highlight;
  final String name;
  final String gpu;
  final String price;
  final List<String> features;
  final String button;
  final VoidCallback onPressed;
  const _PlanCard({
    required this.badge,
    this.highlight = false,
    required this.name,
    required this.gpu,
    required this.price,
    required this.features,
    required this.button,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: highlight ? _cyan : _border, width: highlight ? 2 : 1),
        boxShadow: [
          BoxShadow(
              color: (highlight ? _primary : Colors.black)
                  .withOpacity(highlight ? 0.18 : 0.05),
              blurRadius: highlight ? 32 : 16,
              offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: highlight ? _cyan : const Color(0xFF1F2A3D),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(badge,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6)),
          ),
          const SizedBox(height: 16),
          Text(name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: _dark, fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(gpu,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _muted, fontSize: 13)),
          const SizedBox(height: 18),
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                    text: 'Từ ',
                    style: TextStyle(color: _muted, fontSize: 13)),
                TextSpan(
                    text: price,
                    style: const TextStyle(
                        color: _dark,
                        fontSize: 38,
                        fontWeight: FontWeight.w800)),
                const TextSpan(
                    text: ' VNĐ/giờ',
                    style: TextStyle(color: _muted, fontSize: 12)),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          for (final f in features)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 1),
                    child: Icon(Icons.check_circle_outline,
                        size: 16, color: _primary),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(f,
                        style: const TextStyle(
                            color: Color(0xFF2B3A4F), fontSize: 13, height: 1.4)),
                  ),
                ],
              ),
            ),
          const Spacer(),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: highlight
                ? FilledButton(
                    onPressed: onPressed,
                    style: FilledButton.styleFrom(
                      backgroundColor: _primaryDark,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(button,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                  )
                : OutlinedButton(
                    onPressed: onPressed,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color(0xFFF1F4F8),
                      side: const BorderSide(color: _border),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(button,
                        style: const TextStyle(
                            color: _dark, fontWeight: FontWeight.w700)),
                  ),
          ),
        ],
      ),
    );
  }
}

/* ------------------------- 6. Kêu gọi hành động --------------------- */

class _CtaSection extends StatelessWidget {
  final VoidCallback onPricing;
  const _CtaSection({required this.onPricing});

  @override
  Widget build(BuildContext context) {
    final wide = _isWide(context);
    return _SectionFrame(
      vertical: 88,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0B2A4A), _darkBg1],
      ),
      child: Column(
        children: [
          Text('Sẵn sàng tăng tốc dự án của bạn?',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: wide ? 40 : 28,
                  fontWeight: FontWeight.w800,
                  height: 1.2)),
          const SizedBox(height: 14),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: const Text(
              'Tham gia cùng các AI Developer, Data Scientist, Game thủ, Designer đang trải nghiệm sức mạnh GPU cloud với TN CLOUD',
              textAlign: TextAlign.center,
              style: TextStyle(color: _softText, fontSize: 15, height: 1.6),
            ),
          ),
          const SizedBox(height: 32),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 14,
            runSpacing: 12,
            children: [
              _GradientButton(
                text: 'Bắt đầu trải nghiệm',
                onPressed: () => _startAction(context),
              ),
              OutlinedButton(
                onPressed: onPricing,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 54),
                  padding: const EdgeInsets.symmetric(horizontal: 26),
                  backgroundColor: Colors.white.withOpacity(0.08),
                  side: BorderSide(color: Colors.white.withOpacity(0.2)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Xem bảng giá',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15)),
              ),
            ],
          ),
          const SizedBox(height: 28),
          const Wrap(
            alignment: WrapAlignment.center,
            spacing: 28,
            runSpacing: 10,
            children: [
              _CtaCheck(Icons.local_offer_outlined, 'Ưu đãi cho người dùng mới'),
              _CtaCheck(Icons.verified_user_outlined, 'Không cần thẻ tín dụng'),
              _CtaCheck(Icons.timer_outlined, 'Thiết lập trong 60 giây'),
            ],
          ),
        ],
      ),
    );
  }
}

class _CtaCheck extends StatelessWidget {
  final IconData icon;
  final String text;
  const _CtaCheck(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: _cyan),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(color: _softText, fontSize: 12.5)),
      ],
    );
  }
}

/* ------------------------- 7. Footer -------------------------------- */

class _FooterSection extends StatelessWidget {
  const _FooterSection();

  Widget _linkColumn(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
        const SizedBox(height: 16),
        for (final i in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () {},
              child: Text(i,
                  style: const TextStyle(color: _softText, fontSize: 13.5)),
            ),
          ),
      ],
    );
  }

  Widget _contactRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: _softText),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    color: Colors.white, fontSize: 13.5, height: 1.4)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wide = _isWide(context);

    const brand = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('TN CLOUD',
            style: TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
        SizedBox(height: 14),
        Text(
          'TN CLOUD cung cấp dịch vụ thuê GPU chất lượng cao. Chúng tôi kết nối khách hàng khai thác hiệu suất render video/gaming vượt trội và tối ưu hóa khả năng xử lý AI một cách hiệu quả nhất.',
          style: TextStyle(color: _softText, fontSize: 13.5, height: 1.65),
        ),
      ],
    );

    final quick = _linkColumn(
        'Liên kết nhanh', const ['Giới thiệu', 'Liên hệ', 'Blog', 'Thuê GPU']);
    final policy = _linkColumn('Chính sách, điều khoản', const [
      'Điều khoản sử dụng',
      'Chính sách bảo mật',
      'Chính sách khiếu nại',
      'Chính sách thanh toán',
    ]);

    // TODO: thay bằng thông tin liên hệ thật
    final contact = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Thông tin liên hệ',
            style: TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
        const SizedBox(height: 16),
        _contactRow(Icons.mail_outline, 'support@tncloud.vn'),
        _contactRow(Icons.phone_outlined, 'Hotline: (+84) 000 000 000'),
        _contactRow(Icons.location_on_outlined, 'TP. Hồ Chí Minh, Việt Nam'),
      ],
    );

    return _SectionFrame(
      color: _darkBg1,
      vertical: 64,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (wide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(flex: 4, child: brand),
                const SizedBox(width: 40),
                Expanded(flex: 2, child: quick),
                const SizedBox(width: 24),
                Expanded(flex: 3, child: policy),
                const SizedBox(width: 24),
                Expanded(flex: 3, child: contact),
              ],
            )
          else ...[
            brand,
            const SizedBox(height: 32),
            quick,
            const SizedBox(height: 20),
            policy,
            const SizedBox(height: 20),
            contact,
          ],
          const SizedBox(height: 24),
          Divider(color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 16),
          const Text('© 2026 TN CLOUD. Bảo lưu mọi quyền.',
              style: TextStyle(color: _softText, fontSize: 12)),
        ],
      ),
    );
  }
}