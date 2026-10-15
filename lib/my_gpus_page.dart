import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'api.dart';
import 'app_data.dart';
import 'balance_state.dart';
import 'rental_state.dart';

const _primary = Color(0xFF0B7FC7);
const _primaryDark = Color(0xFF0069AE);
const _dark = Color(0xFF0F1B2D);
const _muted = Color(0xFF5B6B80);
const _border = Color(0xFFDDE5EE);
const _bg = Color(0xFFF5F8FB);
const _green = Color(0xFF16A37F);
const _red = Color(0xFFD93025);

class MyGpusPage extends StatefulWidget {
  const MyGpusPage({super.key});

  @override
  State<MyGpusPage> createState() => _MyGpusPageState();
}

class _MyGpusPageState extends State<MyGpusPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Mở trang là tải dữ liệu mới nhất từ server
    AppData.refreshAll().catchError((_) {});
    // Cập nhật đồng hồ đếm ngược mỗi giây
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _terminate(Rental r) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Kết thúc phiên thuê?'),
        content: const Text(
            'Máy sẽ bị tắt và toàn bộ dữ liệu trên máy bị xóa. Số tiền đã trả không được hoàn lại.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Hủy')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: _red),
            child: const Text('Kết thúc'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    try {
      await Api.delete('/rentals/${r.id}');
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
      return;
    }
    // Đã kết thúc thành công; lỗi tải lại danh sách không quan trọng
    try {
      await AppData.refreshAll();
    } catch (_) {}
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
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Quản lý GPU',
            style: TextStyle(
                color: _dark, fontWeight: FontWeight.w800, fontSize: 20)),
      ),
      body: ValueListenableBuilder<List<Rental>>(
        valueListenable: RentalState.rentals,
        builder: (context, list, _) {
          if (list.isEmpty) return _empty(context);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Column(
                  children: [
                    for (final r in list) ...[
                      _RentalCard(
                          key: ValueKey(r.id),
                          rental: r,
                          onTerminate: () => _terminate(r)),
                      const SizedBox(height: 14),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _empty(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.memory, size: 56, color: Color(0xFF9AA5B4)),
            const SizedBox(height: 14),
            const Text('Bạn chưa thuê GPU nào',
                style: TextStyle(
                    color: _dark, fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            const Text('Chọn một gói và bấm "Thuê ngay" để bắt đầu.',
                style: TextStyle(color: _muted, fontSize: 14)),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              style: FilledButton.styleFrom(
                backgroundColor: _primaryDark,
                minimumSize: const Size(0, 46),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Xem các gói GPU',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}

class _RentalCard extends StatefulWidget {
  final Rental rental;
  final VoidCallback onTerminate;
  const _RentalCard({super.key, required this.rental, required this.onTerminate});

  @override
  State<_RentalCard> createState() => _RentalCardState();
}

class _RentalCardState extends State<_RentalCard> {
  bool _showPass = false;
  bool _restarting = false;

  void _copy(String label, String value) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('Đã sao chép $label'),
          duration: const Duration(seconds: 1)),
    );
  }

  void _copyAll(RentalAccess a) {
    _copy(
        'thông tin đăng nhập',
        'Địa chỉ: ${a.address}\nIP: ${a.ipPort}\n'
            'User: ${a.user}\nPass: ${a.password}');
  }

  void _connectFile(RentalAccess a) {
    if (a.windows) {
      // Web không tự tải file được nếu chưa dùng thêm package,
      // nên sao chép nội dung để người dùng dán vào Notepad, lưu thành .rdp
      _copy('nội dung file .rdp (dán vào Notepad, lưu thành may.rdp)',
          a.rdpFile);
    } else {
      _copy('lệnh SSH', a.sshCommand);
    }
  }

  Future<void> _restart() async {
    if (_restarting) return;
    setState(() => _restarting = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await Api.post('/rentals/${widget.rental.id}/restart', {});
      messenger.showSnackBar(const SnackBar(
          content: Text('Đang khởi động lại, vui lòng đợi 3-5 phút')));
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _restarting = false);
    }
  }

  Widget _cred(String label, String value,
      {String? shown, Widget? extra, required String copyLabel}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(label,
                style: const TextStyle(color: _muted, fontSize: 13)),
          ),
          Expanded(
            child: SelectableText(shown ?? value,
                style: const TextStyle(
                    color: _dark,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'monospace')),
          ),
          if (extra != null) extra,
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: 'Sao chép',
            icon: const Icon(Icons.copy, size: 16, color: _muted),
            onPressed: () => _copy(copyLabel, value),
          ),
        ],
      ),
    );
  }

  Widget _accessBox(RentalAccess a) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F8FC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _primary.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.vpn_key_outlined, size: 16, color: _primary),
              const SizedBox(width: 6),
              Text(
                  a.windows
                      ? 'Thông tin kết nối (Remote Desktop)'
                      : 'Thông tin kết nối (SSH)',
                  style: const TextStyle(
                      color: _primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 6),
          ...[
            _cred('Địa chỉ', a.address, copyLabel: 'địa chỉ'),
            _cred('IP', a.ipPort, copyLabel: 'IP'),
            _cred('User', a.user, copyLabel: 'user'),
            _cred(
              'Pass',
              a.password,
              shown: _showPass ? a.password : '••••••••••',
              copyLabel: 'mật khẩu',
              extra: IconButton(
                visualDensity: VisualDensity.compact,
                tooltip: _showPass ? 'Ẩn' : 'Hiện',
                icon: Icon(
                    _showPass
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 16,
                    color: _muted),
                onPressed: () => setState(() => _showPass = !_showPass),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: () => _connectFile(a),
                icon: Icon(a.windows ? Icons.download : Icons.terminal,
                    size: 15),
                label: Text(a.windows ? 'Tải file RDP' : 'Lệnh SSH',
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700)),
                style: FilledButton.styleFrom(backgroundColor: _green),
              ),
              OutlinedButton.icon(
                onPressed: () => _copyAll(a),
                icon: const Icon(Icons.copy_all, size: 15, color: _dark),
                label: const Text('Sao chép tất cả',
                    style: TextStyle(color: _dark, fontSize: 13)),
              ),
              OutlinedButton.icon(
                onPressed: _restarting ? null : _restart,
                icon: _restarting
                    ? const SizedBox(
                        width: 15,
                        height: 15,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.refresh, size: 15, color: _dark),
                label: const Text('Khởi động lại',
                    style: TextStyle(color: _dark, fontSize: 13)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.rental;
    final a = r.access;
    final expired = r.expired;
    final statusColor = expired ? _muted : _green;

    Widget row(String label, String value) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Text(label, style: const TextStyle(color: _muted, fontSize: 13)),
              const Spacer(),
              Flexible(
                child: Text(value,
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: _dark,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(r.planName,
                    style: const TextStyle(
                        color: _dark,
                        fontSize: 17,
                        fontWeight: FontWeight.w800)),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(expired ? 'Hết hạn' : 'Đang chạy',
                    style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(r.gpu,
              style: const TextStyle(
                  color: _primary, fontSize: 13, fontWeight: FontWeight.w600)),
          if (!expired) ...[
            const SizedBox(height: 4),
            Text('Support ID: ${a.supportId}',
                style: const TextStyle(color: _muted, fontSize: 12)),
          ],
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F8FC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                const Text('Thời gian còn lại',
                    style: TextStyle(color: _muted, fontSize: 12)),
                const SizedBox(height: 2),
                Text(fmtRemaining(r.remaining),
                    style: TextStyle(
                        color: expired ? _muted : _dark,
                        fontSize: 24,
                        fontWeight: FontWeight.w800)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (!expired) ...[
            _accessBox(a),
            const SizedBox(height: 10),
          ],
          row('Mã máy', r.id),
          row('Location', r.location),
          row('Hệ điều hành', r.os),
          row('Gói thuê', r.periodLabel),
          row('Tạo máy', fmtDateTime(r.startedAt)),
          row('Hết hạn', fmtDateTime(r.endsAt)),
          row('Đã thanh toán', '${formatVnd(r.paid)}đ'),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: widget.onTerminate,
              icon: Icon(
                  expired ? Icons.delete_outline : Icons.power_settings_new,
                  size: 16,
                  color: _red),
              label: Text(expired ? 'Xóa' : 'Kết thúc',
                  style: const TextStyle(
                      color: _red, fontWeight: FontWeight.w700)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: _red),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}