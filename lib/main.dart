import 'dart:async';
import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'auth_state.dart';
import 'landing_page.dart';
import 'gpu_hourly_page.dart';
import 'topup_page.dart';
import 'api.dart';      
import 'app_data.dart';  

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Api.onUnauthorized = AuthState.logout; // token hết hạn thì tự đăng xuất
  await AuthState.restore();
  runApp(const TnCloudApp());
}

const kPrimary = Color(0xFF0077B6);
const kDark = Color(0xFF0F1B2D);
const kMuted = Color(0xFF6B7A90);
const kBorder = Color(0xFFE2E8F0);
const kPanelBg = Color(0xFFE6F1FB);

class TnCloudApp extends StatelessWidget {
  const TnCloudApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TN CLOUD',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: kPrimary,
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const LandingPage(),
        '/login': (_) => const LoginPage(),
        '/forgot': (_) => const ForgotPasswordPage(),
        '/register': (_) => const RegisterPage(),
        '/gpu-hourly': (_) => const GpuHourlyPage(),
        '/topup': (_) => const TopUpPage(),
      },
    );
  }
}

/* ------------------------------------------------------------------ */
/* Khung chung: header + panel trái + form phải + footer               */
/* ------------------------------------------------------------------ */

class AuthShell extends StatelessWidget {
  final _PanelData panel;
  final Widget form;
  const AuthShell({super.key, required this.panel, required this.form});

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width >= 900;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _Header(wide: wide),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(wide ? 24 : 8, 8, wide ? 24 : 8, 0),
                child: Row(
                  children: [
                    if (wide) Expanded(child: _LeftPanel(data: panel)),
                    Expanded(
                      child: Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 420),
                            child: form,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _Footer(wide: wide),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final bool wide;
  const _Header({required this.wide});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: wide ? 32 : 16, vertical: 16),
      child: Row(
        children: [
          const Icon(Icons.cloud_outlined, color: kPrimary),
          const SizedBox(width: 8),
          const Text('TN CLOUD',
              style: TextStyle(
                  color: kPrimary, fontWeight: FontWeight.w800, fontSize: 18)),
          const Spacer(),
          TextButton.icon(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
                context, '/', (route) => false),
            icon: const Icon(Icons.arrow_back, size: 14, color: kMuted),
            label: const Text('Về trang chủ',
                style: TextStyle(color: kMuted, fontSize: 12)),
          ),
          // Trên màn hẹp chỉ để icon cho đỡ chật
          if (wide)
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.help_outline, size: 16),
              label: const Text('Trung tâm hỗ trợ',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
            )
          else
            IconButton(
              onPressed: () {},
              tooltip: 'Trung tâm hỗ trợ',
              icon: const Icon(Icons.help_outline, size: 20, color: kPrimary),
            ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  final bool wide;
  const _Footer({required this.wide});

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(color: kMuted, fontSize: 11);
    const copyright =
        Text('© 2026 TN CLOUD. Bảo lưu mọi quyền.', style: style);
    final links = Wrap(
      alignment: WrapAlignment.center,
      children: [
        TextButton(
            onPressed: () {},
            child: const Text('Chính sách bảo mật', style: style)),
        TextButton(
            onPressed: () {},
            child: const Text('Điều khoản dịch vụ', style: style)),
      ],
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: wide ? 32 : 16, vertical: 12),
      child: wide
          ? Row(children: [copyright, const Spacer(), links])
          : Column(children: [copyright, links]),
    );
  }
}

/* ------------------------------------------------------------------ */
/* Panel bên trái                                                      */
/* ------------------------------------------------------------------ */

class _PanelData {
  final String title1;
  final String title2;
  final String desc;
  final String centerLabel;
  final IconData centerIcon;
  final String chipTop;
  final IconData chipTopIcon;
  final String chipBottom;
  final String chipBottomSub;
  final IconData chipBottomIcon;
  final String slogan;
  final List<String> bullets;

  const _PanelData({
    required this.title1,
    required this.title2,
    required this.desc,
    required this.centerLabel,
    required this.centerIcon,
    required this.chipTop,
    required this.chipTopIcon,
    required this.chipBottom,
    required this.chipBottomSub,
    required this.chipBottomIcon,
    required this.slogan,
    required this.bullets,
  });
}

class _LeftPanel extends StatelessWidget {
  final _PanelData data;
  const _LeftPanel({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kPanelBg, Color(0xFFF3F9FE)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
                color: const Color(0xFFD4E8F7),
                borderRadius: BorderRadius.circular(20)),
            child: const Text('Nền tảng GPU Cloud tại Việt Nam',
                style: TextStyle(
                    color: kPrimary, fontSize: 11, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 20),
          Text(data.title1,
              style: const TextStyle(
                  color: kDark, fontSize: 32, fontWeight: FontWeight.w800)),
          Text(data.title2,
              style: const TextStyle(
                  color: kPrimary, fontSize: 32, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Text(data.desc,
              style: const TextStyle(color: kMuted, fontSize: 13, height: 1.5)),
          // FittedBox: màn thấp thì hình minh hoạ tự co lại, không bị tràn
          Expanded(
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: _Illustration(data: data),
              ),
            ),
          ),
          const Divider(color: kBorder),
          const SizedBox(height: 8),
          Text(data.slogan,
              style: const TextStyle(
                  color: kDark, fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 6,
            children: [
              for (final b in data.bullets)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check, size: 14, color: kPrimary),
                    const SizedBox(width: 4),
                    Text(b,
                        style: const TextStyle(color: kMuted, fontSize: 11)),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Illustration extends StatelessWidget {
  final _PanelData data;
  const _Illustration({required this.data});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 300,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: kPrimary.withOpacity(0.12)),
            ),
          ),
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                    color: kPrimary.withOpacity(0.15),
                    blurRadius: 24,
                    offset: const Offset(0, 8))
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                      color: kPrimary, borderRadius: BorderRadius.circular(14)),
                  child: Icon(data.centerIcon, color: Colors.white, size: 28),
                ),
                const SizedBox(height: 8),
                Text(data.centerLabel,
                    style: const TextStyle(
                        color: kDark,
                        fontWeight: FontWeight.w700,
                        fontSize: 12)),
              ],
            ),
          ),
          Positioned(
            top: 6,
            right: 0,
            child: _Chip(
                icon: data.chipTopIcon, title: data.chipTop, subtitle: null),
          ),
          Positioned(
            bottom: 6,
            left: 0,
            child: _Chip(
                icon: data.chipBottomIcon,
                title: data.chipBottom,
                subtitle: data.chipBottomSub),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  const _Chip({required this.icon, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12)
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: kPrimary),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w700, color: kDark)),
              if (subtitle != null)
                Text(subtitle!,
                    style: const TextStyle(fontSize: 9, color: kMuted)),
            ],
          ),
        ],
      ),
    );
  }
}

/* ------------------------------------------------------------------ */
/* Widget dùng chung cho form                                          */
/* ------------------------------------------------------------------ */

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6, top: 14),
        child: Text.rich(TextSpan(
          text: text,
          style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600, color: kDark),
          children: const [
            TextSpan(text: ' *', style: TextStyle(color: Colors.red))
          ],
        )),
      );
}

class _Field extends StatefulWidget {
  final String hint;
  final IconData icon;
  final bool password;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  const _Field({
    required this.hint,
    required this.icon,
    this.password = false,
    this.controller,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
  });

  @override
  State<_Field> createState() => _FieldState();
}

class _FieldState extends State<_Field> {
  bool _obscure = true;

  OutlineInputBorder _border(Color c) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: c));

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onSubmitted,
      obscureText: widget.password && _obscure,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: const TextStyle(color: Color(0xFF9AA7B8), fontSize: 13),
        prefixIcon: Icon(widget.icon, size: 18, color: kMuted),
        suffixIcon: widget.password
            ? IconButton(
                icon: Icon(
                    _obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 18,
                    color: kMuted),
                onPressed: () => setState(() => _obscure = !_obscure),
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        enabledBorder: _border(kBorder),
        focusedBorder: _border(kPrimary),
        errorBorder: _border(Colors.red),
        focusedErrorBorder: _border(Colors.red),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool loading;
  const _PrimaryButton(
      {required this.text, this.onPressed, this.loading = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: kPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: loading ? null : onPressed,
        child: loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(text,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, size: 16),
                ],
              ),
      ),
    );
  }
}

String? _validateEmail(String? v) {
  if (v == null || v.trim().isEmpty) return 'Vui lòng nhập email';
  final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim());
  return ok ? null : 'Email không hợp lệ';
}

/* ------------------------------------------------------------------ */
/* Trang Đăng nhập                                                     */
/* ------------------------------------------------------------------ */

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _remember = false;
    bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

   Future<void> _submit() async {
    if (_loading || !_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final r = await Api.post(
          '/auth/login',
          {'email': _email.text.trim(), 'password': _pass.text},
          auth: false);
      await Api.setToken(r['token']);
      AuthState.login(r['user']['name']);
      await AppData.refreshAll();
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Đăng nhập thành công')));
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      panel: const _PanelData(
        title1: 'Sẵn sàng kết nối.',
        title2: 'Tiếp tục vươn xa.',
        desc:
            'Trở lại không gian làm việc của bạn, khai mở sức mạnh GPU và tiếp nối những ý tưởng lớn cùng TN CLOUD.',
        centerLabel: 'TN CLOUD',
        centerIcon: Icons.cloud_outlined,
        chipTop: 'Triển khai tức thì',
        chipTopIcon: Icons.check_circle_outline,
        chipBottom: 'GPU hiệu năng cao',
        chipBottomSub: 'Sẵn sàng cho mọi tác vụ',
        chipBottomIcon: Icons.memory,
        slogan: 'Hạ tầng vững vàng. Ý tưởng vươn xa.',
        bullets: ['Linh hoạt tài nguyên', 'Hỗ trợ tiếng Việt'],
      ),
      form: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Đăng nhập',
                style: TextStyle(
                    fontSize: 28, fontWeight: FontWeight.w800, color: kDark)),
            const SizedBox(height: 6),
            const Text(
                'Chào mừng bạn trở lại! Đăng nhập để tiếp tục cùng TN CLOUD.',
                style: TextStyle(color: kMuted, fontSize: 12)),
            const _Label('Địa chỉ email'),
            _Field(
              hint: 'Nhập địa chỉ email của bạn',
              icon: Icons.mail_outline,
              controller: _email,
              validator: _validateEmail,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
            ),
            const _Label('Mật khẩu'),
            _Field(
              hint: 'Nhập mật khẩu của bạn',
              icon: Icons.lock_outline,
              password: true,
              controller: _pass,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(), // nhấn Enter để đăng nhập
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Vui lòng nhập mật khẩu' : null,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                SizedBox(
                  width: 24,
                  child: Checkbox(
                    value: _remember,
                    onChanged: (v) => setState(() => _remember = v ?? false),
                  ),
                ),
                const SizedBox(width: 6),
                const Flexible(
                  child: Text('Ghi nhớ đăng nhập',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: kMuted, fontSize: 12)),
                ),
                const Spacer(),
                InkWell(
                  onTap: () => Navigator.pushNamed(context, '/forgot'),
                  child: const Text('Quên mật khẩu?',
                      style: TextStyle(
                          color: kPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: 18),
                       _PrimaryButton(text: 'Đăng nhập', loading: _loading, onPressed: _submit),
            const SizedBox(height: 18),
            Center(
              child: Text.rich(TextSpan(
                text: 'Chưa có tài khoản? ',
                style: const TextStyle(color: kMuted, fontSize: 12),
                children: [
                  WidgetSpan(
                    alignment: PlaceholderAlignment.baseline,
                    baseline: TextBaseline.alphabetic,
                    child: InkWell(
                      onTap: () => Navigator.pushNamed(context, '/register'),
                      child: const Text('Đăng ký',
                          style: TextStyle(
                              color: kPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              )),
            ),
          ],
        ),
      ),
    );
  }
}

/* ------------------------------------------------------------------ */
/* Trang Quên mật khẩu                                                 */
/* ------------------------------------------------------------------ */

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();

  bool _loading = false;
  bool _sent = false;
  int _cooldown = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _email.dispose();
    super.dispose();
  }

  void _startCooldown() {
    _timer?.cancel();
    setState(() => _cooldown = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      setState(() => _cooldown--);
      if (_cooldown <= 0) t.cancel();
    });
  }

  Future<void> _submit() async {
    if (_loading || _cooldown > 0) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      await AuthService.sendPasswordReset(_email.text.trim());
      if (!mounted) return;
      setState(() => _sent = true);
      _startCooldown();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Không gửi được liên kết. Vui lòng thử lại.')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      panel: const _PanelData(
        title1: 'An tâm kết nối.',
        title2: 'Tiếp nối mọi dự án.',
        desc:
            'Chỉ vài bước để lấy lại quyền truy cập và trở về không gian làm việc của bạn.',
        centerLabel: 'Bảo vệ tài khoản',
        centerIcon: Icons.shield_outlined,
        chipTop: 'Khôi phục dễ dàng',
        chipTopIcon: Icons.mail_outline,
        chipBottom: 'Truy cập an toàn',
        chipBottomSub: 'Thông tin được bảo vệ',
        chipBottomIcon: Icons.lock_outline,
        slogan: 'Luôn ở đây khi bạn cần.',
        bullets: ['Bảo mật thông tin', 'Hỗ trợ tận tâm'],
      ),
      form: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  color: kPanelBg, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.vpn_key_outlined, color: kPrimary),
            ),
            const SizedBox(height: 16),
            const Text('Quên mật khẩu?',
                style: TextStyle(
                    fontSize: 28, fontWeight: FontWeight.w800, color: kDark)),
            const SizedBox(height: 6),
            const Text(
                'Đừng lo, hãy nhập email bạn đã dùng để đăng ký. Chúng tôi sẽ gửi liên kết để bạn đặt lại mật khẩu.',
                style: TextStyle(color: kMuted, fontSize: 12, height: 1.5)),
            const _Label('Địa chỉ email'),
            _Field(
              hint: 'Nhập email đã đăng ký',
              icon: Icons.mail_outline,
              controller: _email,
              validator: _validateEmail,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 18),
            if (_sent) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: const Color(0xFFE8F6EE),
                    borderRadius: BorderRadius.circular(10)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle_outline,
                        size: 16, color: Color(0xFF1E8E4E)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                          'Nếu ${_email.text.trim()} đã đăng ký, bạn sẽ nhận được email hướng dẫn đặt lại mật khẩu trong ít phút.',
                          style: const TextStyle(
                              color: Color(0xFF1E6B41), fontSize: 11)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            _PrimaryButton(
              text: _cooldown > 0
                  ? 'Gửi lại sau ${_cooldown}s'
                  : (_sent
                      ? 'Gửi lại liên kết'
                      : 'Gửi liên kết đặt lại mật khẩu'),
              loading: _loading,
              onPressed: _cooldown > 0 ? null : _submit,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: const Color(0xFFF3F7FB),
                  borderRadius: BorderRadius.circular(10)),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, size: 16, color: kPrimary),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                        'Kiểm tra cả hộp thư rác nếu bạn chưa được email sau vài phút.',
                        style: TextStyle(color: kMuted, fontSize: 11)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Center(
              child: TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, size: 14),
                label: const Text('Quay lại đăng nhập',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ------------------------------------------------------------------ */
/* Trang Đăng ký                                                       */
/* ------------------------------------------------------------------ */

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _confirm = TextEditingController();
  bool _agree = false;
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _pass.dispose();
    _confirm.dispose();
    super.dispose();
  }

    Future<void> _submit() async {
    if (_loading || !_formKey.currentState!.validate()) return;
    if (!_agree) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text('Vui lòng đồng ý Điều khoản dịch vụ và Chính sách bảo mật')));
      return;
    }
    setState(() => _loading = true);
    try {
      final r = await Api.post(
          '/auth/register',
          {
            'name': _name.text.trim(),
            'email': _email.text.trim(),
            'password': _pass.text,
          },
          auth: false);
      await Api.setToken(r['token']);
      AuthState.login(r['user']['name']);
      await AppData.refreshAll();
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Đăng ký thành công')));
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      panel: const _PanelData(
        title1: 'Sức mạnh đám mây.',
        title2: 'Khởi đầu trong tầm tay.',
        desc:
            'Từ ý tưởng đến triển khai, TN CLOUD đồng hành cùng bạn với hạ tầng GPU mạnh mẽ, linh hoạt.',
        centerLabel: 'TN CLOUD',
        centerIcon: Icons.cloud_outlined,
        chipTop: 'Triển khai tức thì',
        chipTopIcon: Icons.check_circle_outline,
        chipBottom: 'GPU hiệu năng cao',
        chipBottomSub: 'Sẵn sàng cho mọi tác vụ',
        chipBottomIcon: Icons.memory,
        slogan: 'Hạ tầng vững vàng. Ý tưởng vươn xa.',
        bullets: ['Linh hoạt tài nguyên', 'Hỗ trợ tiếng Việt'],
      ),
      form: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tạo tài khoản mới',
                style: TextStyle(
                    fontSize: 28, fontWeight: FontWeight.w800, color: kDark)),
            const SizedBox(height: 6),
            const Text('Bắt đầu hành trình của bạn cùng TN CLOUD.',
                style: TextStyle(color: kMuted, fontSize: 12)),
            const _Label('Họ và tên'),
            _Field(
              hint: 'Nhập họ và tên của bạn',
              icon: Icons.person_outline,
              controller: _name,
              textInputAction: TextInputAction.next,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Vui lòng nhập họ và tên'
                  : null,
            ),
            const _Label('Địa chỉ email'),
            _Field(
              hint: 'Nhập địa chỉ email của bạn',
              icon: Icons.mail_outline,
              controller: _email,
              validator: _validateEmail,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
            ),
            const _Label('Mật khẩu'),
            _Field(
              hint: 'Tạo mật khẩu',
              icon: Icons.lock_outline,
              password: true,
              controller: _pass,
              textInputAction: TextInputAction.next,
              validator: (v) {
                if (v == null || v.length < 8) return 'Tối thiểu 8 ký tự';
                if (!RegExp(r'[A-Za-z]').hasMatch(v) ||
                    !RegExp(r'\d').hasMatch(v)) {
                  return 'Gồm chữ và số';
                }
                return null;
              },
            ),
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text('Sử dụng ít nhất 8 ký tự, gồm chữ và số.',
                  style: TextStyle(color: kMuted, fontSize: 10)),
            ),
            const _Label('Xác nhận mật khẩu'),
            _Field(
              hint: 'Nhập lại mật khẩu',
              icon: Icons.lock_outline,
              password: true,
              controller: _confirm,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              validator: (v) => v != _pass.text ? 'Mật khẩu không khớp' : null,
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 24,
                  child: Checkbox(
                    value: _agree,
                    onChanged: (v) => setState(() => _agree = v ?? false),
                  ),
                ),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text.rich(TextSpan(
                    style: TextStyle(color: kMuted, fontSize: 11, height: 1.5),
                    children: [
                      TextSpan(text: 'Tôi đồng ý với '),
                      TextSpan(
                          text: 'Điều khoản dịch vụ',
                          style: TextStyle(
                              color: kPrimary, fontWeight: FontWeight.w700)),
                      TextSpan(text: ' và '),
                      TextSpan(
                          text: 'Chính sách bảo mật',
                          style: TextStyle(
                              color: kPrimary, fontWeight: FontWeight.w700)),
                      TextSpan(text: ' của TN CLOUD.'),
                    ],
                  )),
                ),
              ],
            ),
            const SizedBox(height: 16),
                      _PrimaryButton(text: 'Đăng ký', loading: _loading, onPressed: _submit),
            const SizedBox(height: 16),
            Center(
              child: Text.rich(TextSpan(
                text: 'Đã có tài khoản? ',
                style: const TextStyle(color: kMuted, fontSize: 12),
                children: [
                  WidgetSpan(
                    alignment: PlaceholderAlignment.baseline,
                    baseline: TextBaseline.alphabetic,
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      child: const Text('Đăng nhập',
                          style: TextStyle(
                              color: kPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              )),
            ),
          ],
        ),
      ),
    );
  }
}