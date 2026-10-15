import 'package:flutter/material.dart';
import 'links.dart';

const _primary = Color(0xFF0B7FC7);
const _dark = Color(0xFF0F1B2D);
const _muted = Color(0xFF5B6B80);
const _border = Color(0xFFDDE5EE);
const _bg = Color(0xFFF5F8FB);

class _Item {
  final String title;
  final String desc;
  final String tag; // Video / Bài viết
  final String url; // TODO: thay bằng link của bạn
  const _Item(this.title, this.desc, this.tag, this.url);
}

class _Section {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<_Item> items;
  const _Section(this.icon, this.title, this.subtitle, this.items);
}

const _sections = [
  _Section(Icons.link, 'Kết nối & truy cập', 'Cách vào máy GPU bạn đã thuê', [
    _Item('Remote Desktop (RDP)', 'Kết nối vào máy Windows bằng file .rdp hoặc thông tin IP, user, pass.', 'Video', 'https://example.com/rdp'),
    _Item('Kết nối SSH (Ubuntu)', 'Dùng lệnh ssh để vào máy Ubuntu cho AI/ML.', 'Bài viết', 'https://example.com/ssh'),
  ]),
  _Section(Icons.sports_esports_outlined, 'Chơi game từ xa', 'Stream game với độ trễ thấp', [
    _Item('Parsec trên Windows', 'Cài đặt và cấu hình Parsec.', 'Video', 'https://example.com/parsec-win'),
    _Item('Parsec trên macOS', 'Dùng Parsec để stream từ máy Mac.', 'Video', 'https://example.com/parsec-mac'),
    _Item('Moonlight', 'Stream game về PC hoặc điện thoại.', 'Video', 'https://example.com/moonlight'),
    _Item('Steam Link', 'Stream qua Steam Link trên nhiều thiết bị.', 'Video', 'https://example.com/steamlink'),
  ]),
  _Section(Icons.psychology_outlined, 'AI & Machine Learning', 'Bắt đầu với máy Ubuntu', [
    _Item('Cài PyTorch / TensorFlow', 'Thiết lập môi trường và kiểm tra GPU bằng nvidia-smi.', 'Bài viết', 'https://example.com/pytorch'),
    _Item('Chuyển dữ liệu lên máy', 'Dùng scp hoặc rsync để tải dữ liệu lên và tải kết quả về.', 'Bài viết', 'https://example.com/scp'),
  ]),
];

class GuidePage extends StatelessWidget {
  const GuidePage({super.key});

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
        title: const Text('Hướng dẫn',
            style: TextStyle(color: _dark, fontWeight: FontWeight.w800, fontSize: 20)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tìm hiểu cách sử dụng và tận dụng tối đa dịch vụ GPU cloud của chúng tôi.',
                    style: TextStyle(color: _muted, fontSize: 14)),
                const SizedBox(height: 16),
                for (final s in _sections) ...[_section(context, s), const SizedBox(height: 16)],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _section(BuildContext context, _Section s) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFE6F4FC),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(s.icon, color: _primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(s.title,
                    style: const TextStyle(color: _dark, fontSize: 17, fontWeight: FontWeight.w800)),
                Text(s.subtitle, style: const TextStyle(color: _muted, fontSize: 13)),
              ]),
            ),
          ]),
          const SizedBox(height: 14),
          LayoutBuilder(builder: (context, c) {
            final cols = c.maxWidth >= 800 ? 3 : (c.maxWidth >= 520 ? 2 : 1);
            const gap = 12.0;
            final w = (c.maxWidth - gap * (cols - 1)) / cols;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [for (final it in s.items) SizedBox(width: w, child: _card(context, it))],
            );
          }),
        ],
      ),
    );
  }

  Widget _card(BuildContext context, _Item it) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F8FB),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
              child: Text(it.title,
                  style: const TextStyle(color: _dark, fontSize: 14.5, fontWeight: FontWeight.w800)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(it.tag,
                  style: const TextStyle(color: _primary, fontSize: 11, fontWeight: FontWeight.w700)),
            ),
          ]),
          const SizedBox(height: 6),
          Text(it.desc, style: const TextStyle(color: _muted, fontSize: 12.5, height: 1.45)),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => openLink(context, it.url),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Text('Xem hướng dẫn',
                  style: TextStyle(color: _primary, fontSize: 13, fontWeight: FontWeight.w700)),
              SizedBox(width: 4),
              Icon(Icons.open_in_new, size: 14, color: _primary),
            ]),
          ),
        ],
      ),
    );
  }
}