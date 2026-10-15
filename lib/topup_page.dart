import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'api.dart';
import 'app_data.dart';
import 'auth_state.dart';
import 'balance_state.dart';

const _primary = Color(0xFF0B7FC7);
const _primaryDark = Color(0xFF0069AE);
const _dark = Color(0xFF0F1B2D);
const _muted = Color(0xFF5B6B80);
const _border = Color(0xFFDDE5EE);
const _bg = Color(0xFFF5F8FB);
const _green = Color(0xFF16A37F);

const _minAmount = 10000;
const _maxAmount = 50000000;
const _presets = [50000, 100000, 200000, 500000, 1000000, 2000000];

enum _Method { bank, momo, zalopay }

class TopUpPage extends StatefulWidget {
  const TopUpPage({super.key});

  @override
  State<TopUpPage> createState() => _TopUpPageState();
}

class _TopUpPageState extends State<TopUpPage> {
  final _custom = TextEditingController();
  int? _preset = 100000;
  _Method _method = _Method.bank;
  String? _error;

  // Bước 2: hiển thị thông tin chuyển khoản (dữ liệu do server trả về)
  bool _confirming = false;
  bool _creating = false;
  bool _checking = false;
  int _amount = 0;
  String _orderCode = '';
  String _qrUrl = '';
  Map<String, dynamic> _bank = {};
  Timer? _poll;

  @override
  void dispose() {
    _poll?.cancel();
    _custom.dispose();
    super.dispose();
  }

  int get _currentAmount {
    final digits = _custom.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isNotEmpty) return int.parse(digits);
    return _preset ?? 0;
  }

  void _snack(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  void _pickPreset(int v) => setState(() {
        _preset = v;
        _custom.clear();
        _error = null;
      });

  void _backToChoose() {
    _poll?.cancel();
    setState(() => _confirming = false);
  }

  /// Bước 1 -> 2: tạo đơn nạp tiền trên server.
  Future<void> _continue() async {
    if (_creating) return;
    final a = _currentAmount;
    if (a < _minAmount) {
      setState(() => _error = 'Số tiền nạp tối thiểu ${formatVnd(_minAmount)}đ');
      return;
    }
    if (a > _maxAmount) {
      setState(
          () => _error = 'Số tiền nạp tối đa ${formatVnd(_maxAmount)}đ mỗi lần');
      return;
    }
    if (_method != _Method.bank) {
      _snack('Phương thức này sắp ra mắt');
      return;
    }

    setState(() => _creating = true);
    try {
      final r = await Api.post('/topups', {'amount': a});
      if (!mounted) return;
      setState(() {
        _amount = a;
        _orderCode = r['code'];
        _qrUrl = r['qrUrl'];
        _bank = Map<String, dynamic>.from(r['bank']);
        _confirming = true;
      });
      // Tự hỏi server mỗi 4 giây xem tiền đã về chưa
      _poll?.cancel();
      _poll = Timer.periodic(const Duration(seconds: 4), (_) => _check());
      // Lịch sử hiện ngay đơn "Chờ xác nhận"
      AppData.loadTransactions().catchError((_) {});
    } on ApiException catch (e) {
      _snack(e.message);
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  /// Hỏi server đơn đã có tiền chưa. Có tiền thì đóng trang.
  Future<void> _check({bool manual = false}) async {
    if (_checking || _orderCode.isEmpty) return;
    _checking = true;
    try {
      final r = await Api.get('/topups/$_orderCode');
      if (r['status'] == 'success') {
        _poll?.cancel();
        await AppData.refreshAll();
        if (!mounted) return;
        _snack('Đã nạp ${formatVnd(_amount)}đ vào tài khoản');
        Navigator.pop(context);
      } else if (manual) {
        _snack('Chưa nhận được tiền, vui lòng đợi 1-5 phút rồi thử lại');
      }
    } on ApiException catch (e) {
      if (manual) _snack(e.message);
    } finally {
      _checking = false;
    }
  }

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
          onPressed: () {
            if (_confirming) {
              _backToChoose();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: const Text('Nạp tiền',
            style: TextStyle(
                color: _dark, fontWeight: FontWeight.w800, fontSize: 20)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: _confirming ? _stepTransfer() : _stepChoose(),
          ),
        ),
      ),
    );
  }

  /* ---------------------------- Bước 1 ---------------------------- */

  Widget _stepChoose() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _card(
          child: Row(
            children: [
              const Icon(Icons.account_balance_wallet_outlined,
                  color: _primary),
              const SizedBox(width: 12),
              const Text('Số dư hiện tại',
                  style: TextStyle(color: _muted, fontSize: 14)),
              const Spacer(),
              ValueListenableBuilder<int>(
                valueListenable: BalanceState.balance,
                builder: (_, b, __) => Text('${formatVnd(b)}đ',
                    style: const TextStyle(
                        color: _dark,
                        fontSize: 20,
                        fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _title('Chọn số tiền'),
              const SizedBox(height: 14),
              LayoutBuilder(builder: (context, c) {
                final cols = c.maxWidth >= 480 ? 3 : 2;
                const gap = 10.0;
                final w = (c.maxWidth - gap * (cols - 1)) / cols;
                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: [
                    for (final v in _presets)
                      SizedBox(
                        width: w,
                        height: 48,
                        child: _PresetTile(
                          label: '${formatVnd(v)}đ',
                          selected: _preset == v && _custom.text.isEmpty,
                          onTap: () => _pickPreset(v),
                        ),
                      ),
                  ],
                );
              }),
              const SizedBox(height: 16),
              TextField(
                controller: _custom,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) => setState(() {
                  _preset = null;
                  _error = null;
                }),
                decoration: InputDecoration(
                  labelText: 'Hoặc nhập số tiền khác',
                  hintText: 'Tối thiểu ${formatVnd(_minAmount)}',
                  suffixText: 'đ',
                  errorText: _error,
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: _border)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: _primary)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _title('Phương thức thanh toán'),
              const SizedBox(height: 12),
              _MethodTile(
                icon: Icons.account_balance_outlined,
                title: 'Chuyển khoản ngân hàng',
                subtitle: 'Quét mã VietQR hoặc chuyển khoản thủ công',
                selected: _method == _Method.bank,
                onTap: () => setState(() => _method = _Method.bank),
              ),
              const SizedBox(height: 10),
              _MethodTile(
                icon: Icons.phone_android,
                title: 'Ví MoMo',
                subtitle: 'Sắp ra mắt',
                selected: _method == _Method.momo,
                disabled: true,
                onTap: () => setState(() => _method = _Method.momo),
              ),
              const SizedBox(height: 10),
              _MethodTile(
                icon: Icons.account_balance_wallet_outlined,
                title: 'ZaloPay',
                subtitle: 'Sắp ra mắt',
                selected: _method == _Method.zalopay,
                disabled: true,
                onTap: () => setState(() => _method = _Method.zalopay),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: FilledButton(
            onPressed: _creating ? null : _continue,
            style: FilledButton.styleFrom(
              backgroundColor: _primaryDark,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: _creating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : Text(
                    _currentAmount >= _minAmount
                        ? 'Tiếp tục • ${formatVnd(_currentAmount)}đ'
                        : 'Tiếp tục',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15),
                  ),
          ),
        ),
      ],
    );
  }

  /* ---------------------------- Bước 2 ---------------------------- */

  Widget _stepTransfer() {
    final user = AuthState.userName.value ?? '';
    final content = _orderCode; // nội dung chuyển khoản để server đối soát
    final qrUrl = _qrUrl; // link QR do server tạo sẵn

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _card(
          child: Column(
            children: [
              const Text('Số tiền cần chuyển',
                  style: TextStyle(color: _muted, fontSize: 13)),
              const SizedBox(height: 4),
              Text('${formatVnd(_amount)}đ',
                  style: const TextStyle(
                      color: _primary,
                      fontSize: 34,
                      fontWeight: FontWeight.w800)),
              if (user.isNotEmpty)
                Text('Tài khoản: $user',
                    style: const TextStyle(color: _muted, fontSize: 12)),
              const SizedBox(height: 16),
              Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _border),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    qrUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (_, child, p) => p == null
                        ? child
                        : const Center(child: CircularProgressIndicator()),
                    errorBuilder: (_, __, ___) => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                            'Không tải được mã QR.\nVui lòng chuyển khoản thủ công.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: _muted, fontSize: 12)),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _card(
          child: Column(
            children: [
              _InfoRow('Ngân hàng', '${_bank['name']}'),
              _InfoRow('Số tài khoản', '${_bank['account']}', copy: true),
              _InfoRow('Chủ tài khoản', '${_bank['owner']}'),
              _InfoRow('Số tiền', '$_amount',
                  copy: true, display: '${formatVnd(_amount)}đ'),
              _InfoRow('Nội dung CK', content, copy: true, highlight: true),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E6),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFF3DFA6)),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, size: 16, color: Color(0xFFB07A00)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                    'Vui lòng nhập ĐÚNG nội dung chuyển khoản để hệ thống tự động cộng tiền. Số dư thường được cập nhật sau 1-5 phút, trang này sẽ tự đóng khi tiền về.',
                    style: TextStyle(
                        color: Color(0xFF7A5600), fontSize: 12.5, height: 1.5)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: FilledButton.icon(
            onPressed: () => _check(manual: true),
            icon: const Icon(Icons.check_circle_outline, size: 18),
            label: const Text('Kiểm tra giao dịch',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            style: FilledButton.styleFrom(
              backgroundColor: _green,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: TextButton(
            onPressed: _backToChoose,
            child: const Text('Đổi số tiền / phương thức',
                style: TextStyle(color: _muted)),
          ),
        ),
      ],
    );
  }

  /* ---------------------------- Helpers ---------------------------- */

  Widget _card({required Widget child}) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border),
        ),
        child: child,
      );

  Widget _title(String t) => Text(t,
      style: const TextStyle(
          color: _dark, fontSize: 16, fontWeight: FontWeight.w800));
}

class _PresetTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _PresetTile(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFFE6F4FC) : Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: selected ? _primary : _border, width: selected ? 1.6 : 1),
          ),
          child: Text(label,
              style: TextStyle(
                  color: selected ? _primary : _dark,
                  fontWeight: FontWeight.w700,
                  fontSize: 14)),
        ),
      ),
    );
  }
}

class _MethodTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final bool disabled;
  final VoidCallback onTap;
  const _MethodTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: disabled ? 0.55 : 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: selected ? const Color(0xFFF1F9FE) : Colors.white,
            border: Border.all(
                color: selected ? _primary : _border, width: selected ? 1.6 : 1),
          ),
          child: Row(
            children: [
              Icon(icon, color: selected ? _primary : _muted),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            color: _dark,
                            fontWeight: FontWeight.w700,
                            fontSize: 14)),
                    Text(subtitle,
                        style: const TextStyle(color: _muted, fontSize: 12)),
                  ],
                ),
              ),
              Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  size: 20,
                  color: selected ? _primary : _muted),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value; // giá trị được copy
  final String? display; // giá trị hiển thị (nếu khác)
  final bool copy;
  final bool highlight;
  const _InfoRow(this.label, this.value,
      {this.display, this.copy = false, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: const TextStyle(color: _muted, fontSize: 13)),
          ),
          Expanded(
            child: Text(display ?? value,
                textAlign: TextAlign.right,
                style: TextStyle(
                    color: highlight ? _primary : _dark,
                    fontWeight: FontWeight.w800,
                    fontSize: 14)),
          ),
          if (copy)
            IconButton(
              visualDensity: VisualDensity.compact,
              tooltip: 'Sao chép',
              icon: const Icon(Icons.copy, size: 16, color: _muted),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: value));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Đã sao chép $label'),
                      duration: const Duration(seconds: 1)),
                );
              },
            )
          else
            const SizedBox(width: 40),
        ],
      ),
    );
  }
}