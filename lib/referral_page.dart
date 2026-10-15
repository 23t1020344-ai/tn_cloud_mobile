import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'api.dart';
import 'app_data.dart';
import 'balance_state.dart';

const _primary = Color(0xFF0B7FC7);
const _primaryDark = Color(0xFF0069AE);
const _dark = Color(0xFF0F1B2D);
const _muted = Color(0xFF5B6B80);
const _border = Color(0xFFDDE5EE);
const _bg = Color(0xFFF5F8FB);
const _green = Color(0xFF16A37F);

class ReferralPage extends StatefulWidget {
  const ReferralPage({super.key});

  @override
  State<ReferralPage> createState() => _ReferralPageState();
}

class _ReferralPageState extends State<ReferralPage> {
  final _input = TextEditingController();
  Map<String, dynamic>? _data;
  bool _loading = true;
  bool _applying = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _snack(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  Future<void> _load() async {
    try {
      final r = await Api.get('/referral');
      if (!mounted) return;
      setState(() {
        _data = Map<String, dynamic>.from(r);
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _snack(e.message);
    }
  }

  Future<void> _apply() async {
    final code = _input.text.trim();
    if (code.isEmpty || _applying) return;
    setState(() => _applying = true);
    try {
      await Api.post('/referral/apply', {'code': code});
      _input.clear();
      _snack('Đã áp dụng mã. Nạp tiền lần đầu để nhận thưởng.');
      await _load();
    } on ApiException catch (e) {
      _snack(e.message);
    } finally {
      if (mounted) setState(() => _applying = false);
    }
  }

  Widget _card({required Widget child}) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border),
        ),
        child: child,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        shape: const Border(bottom: BorderSide(color: _border)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _dark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Giới thiệu bạn bè',
            style: TextStyle(color: _dark, fontWeight: FontWeight.w800, fontSize: 20)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 760),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Mời bạn bè dùng TN CLOUD, cả hai cùng nhận thưởng vào số dư.',
                              style: TextStyle(color: _muted, fontSize: 14)),
                          const SizedBox(height: 16),
                          _myCode(),
                          const SizedBox(height: 16),
                          _terms(),
                          const SizedBox(height: 16),
                          _enterCode(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _myCode() {
    final d = _data;
    final unlocked = d?['unlocked'] == true;
    if (!unlocked) {
      return _card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(children: [
              Icon(Icons.lock_outline, color: _muted),
              SizedBox(width: 10),
              Text('Thuê máy để mở khóa giới thiệu',
                  style: TextStyle(color: _dark, fontSize: 17, fontWeight: FontWeight.w800)),
            ]),
            const SizedBox(height: 8),
            const Text('Mã giới thiệu có sau lần thuê máy đầu tiên của bạn.',
                style: TextStyle(color: _muted, fontSize: 13.5)),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              style: FilledButton.styleFrom(
                backgroundColor: _primaryDark,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Thuê máy', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );
    }
    final code = '${d!['code']}';
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Mã giới thiệu của bạn',
              style: TextStyle(color: _muted, fontSize: 13)),
          const SizedBox(height: 6),
          Row(children: [
            Text(code,
                style: const TextStyle(
                    color: _primary, fontSize: 30, fontWeight: FontWeight.w800, letterSpacing: 2)),
            const SizedBox(width: 8),
            IconButton(
              tooltip: 'Sao chép',
              icon: const Icon(Icons.copy, size: 20, color: _muted),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: code));
                _snack('Đã sao chép mã giới thiệu');
              },
            ),
          ]),
          const Divider(height: 24, color: _border),
          Row(children: [
            Expanded(child: _stat('Lượt giới thiệu', '${d['invited']}')),
            Expanded(child: _stat('Tổng thưởng nhận', '${formatVnd((d['totalReward'] as num).toInt())}đ')),
          ]),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: _muted, fontSize: 12.5)),
          const SizedBox(height: 2),
          Text(value,
              style: const TextStyle(color: _green, fontSize: 20, fontWeight: FontWeight.w800)),
        ],
      );

  Widget _terms() {
    // Giữ khớp với hằng số REF trong server.js
    const rules = [
      'Bạn nhận 10% giá trị lần nạp đầu của bạn bè (tối đa 1,000,000đ).',
      'Bạn bè nhận 5% giá trị lần nạp đầu (tối đa 500,000đ).',
      'Lần nạp đầu phải từ 100,000đ trở lên.',
      'Bạn bè nhập mã trong 30 ngày kể từ khi đăng ký và trước lần nạp đầu tiên.',
      'Mỗi người được thưởng tối đa 20 lượt giới thiệu.',
      'Tiền thưởng được cộng vào số dư tài khoản.',
    ];
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Điều khoản',
              style: TextStyle(color: _dark, fontSize: 17, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          for (final r in rules)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('•  ', style: TextStyle(color: _muted)),
                Expanded(
                  child: Text(r,
                      style: const TextStyle(color: _dark, fontSize: 13.5, height: 1.45)),
                ),
              ]),
            ),
        ],
      ),
    );
  }

  Widget _enterCode() {
    final applied = _data?['alreadyApplied'] == true;
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Nhập mã giới thiệu',
              style: TextStyle(color: _dark, fontSize: 17, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(
              applied
                  ? 'Bạn đã nhập mã giới thiệu. Nạp tiền lần đầu (từ 100,000đ) để nhận thưởng.'
                  : 'Nhập mã của người đã giới thiệu bạn. Mã chỉ áp dụng một lần.',
              style: const TextStyle(color: _muted, fontSize: 13.5)),
          if (!applied) ...[
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: TextField(
                  controller: _input,
                  textCapitalization: TextCapitalization.characters,
                  onSubmitted: (_) => _apply(),
                  decoration: InputDecoration(
                    hintText: 'Ví dụ: AB3K7QMP',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: _border)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: _primary)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              FilledButton(
                onPressed: _applying ? null : _apply,
                style: FilledButton.styleFrom(
                  backgroundColor: _primaryDark,
                  minimumSize: const Size(110, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: _applying
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Áp dụng mã', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ]),
          ],
        ],
      ),
    );
  }
}