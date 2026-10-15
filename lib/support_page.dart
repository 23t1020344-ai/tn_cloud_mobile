import 'package:flutter/material.dart';
import 'links.dart';

const _primary = Color(0xFF0B7FC7);
const _primaryDark = Color(0xFF0069AE);
const _dark = Color(0xFF0F1B2D);
const _muted = Color(0xFF5B6B80);
const _border = Color(0xFFDDE5EE);
const _bg = Color(0xFFF5F8FB);
const _amber = Color(0xFFE08A00);

class _Faq {
  final String title;
  final String desc;
  final String tag;
  final String url; // TODO: thay bằng bài viết/video của bạn
  const _Faq(this.title, this.desc, this.tag, this.url);
}

const _faqs = [
  _Faq('Không kết nối được máy', 'Kiểm tra IP, cổng, tài khoản và mật khẩu; thử khởi động lại máy.', 'Bài viết', 'https://example.com/ket-noi'),
  _Faq('Máy bị giật, lag', 'Kiểm tra mạng của bạn và cấu hình chất lượng hình ảnh khi stream.', 'Bài viết', 'https://example.com/lag'),
  _Faq('Không có âm thanh / micro', 'Cách bật micro và chọn thiết bị âm thanh trên máy thuê.', 'Video', 'https://example.com/mic'),
  _Faq('Quên mật khẩu máy', 'Mật khẩu hiện trong mục Quản lý GPU, bấm biểu tượng con mắt để xem.', 'Bài viết', 'https://example.com/matkhau'),
  _Faq('Nạp tiền chưa thấy cộng', 'Kiểm tra đúng nội dung chuyển khoản, đợi 1-5 phút rồi bấm Kiểm tra giao dịch.', 'Bài viết', 'https://example.com/naptien'),
  _Faq('Hết hạn thuê', 'Máy hết hạn sẽ bị xóa dữ liệu; hãy sao lưu trước khi hết giờ.', 'Bài viết', 'https://example.com/hethan'),
];

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

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
        title: const Text('Hỗ trợ',
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
                const Text('Chúng tôi luôn sẵn sàng hỗ trợ bạn nhanh nhất có thể.',
                    style: TextStyle(color: _muted, fontSize: 14)),
                const SizedBox(height: 16),
                _urgent(context),
                const SizedBox(height: 24),
                const Text('Lỗi thường gặp',
                    style: TextStyle(color: _dark, fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                LayoutBuilder(builder: (context, c) {
                  final cols = c.maxWidth >= 900 ? 3 : (c.maxWidth >= 560 ? 2 : 1);
                  const gap = 14.0;
                  final w = (c.maxWidth - gap * (cols - 1)) / cols;
                  return Wrap(
                    spacing: gap,
                    runSpacing: gap,
                    children: [for (final f in _faqs) SizedBox(width: w, child: _faqCard(context, f))],
                  );
                }),
                const SizedBox(height: 24),
                const Text('Kênh hỗ trợ',
                    style: TextStyle(color: _dark, fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                _channel(context, Icons.facebook, 'Facebook', 'Nhắn tin trực tiếp cho đội ngũ hỗ trợ', facebookUrl),
                const SizedBox(height: 10),
                _channel(context, Icons.forum_outlined, 'Discord', 'Cộng đồng và hỗ trợ kỹ thuật', discordUrl),
                const SizedBox(height: 8),
                const Text('Thời gian phản hồi: 8:00 - 21:00 hằng ngày.',
                    style: TextStyle(color: _muted, fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _urgent(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF3DFA6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Icon(Icons.warning_amber_rounded, color: _amber),
            SizedBox(width: 8),
            Text('Hỗ trợ khẩn cấp',
                style: TextStyle(color: _dark, fontSize: 17, fontWeight: FontWeight.w800)),
          ]),
          const SizedBox(height: 8),
          const Text(
              'Nếu gặp sự cố nghiêm trọng ảnh hưởng đến dịch vụ, hãy liên hệ ngay để được ưu tiên xử lý.',
              style: TextStyle(color: Color(0xFF7A5600), fontSize: 13.5, height: 1.5)),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => openLink(context, facebookUrl),
            style: FilledButton.styleFrom(
              backgroundColor: _primaryDark,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Liên hệ khẩn cấp', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _faqCard(BuildContext context, _Faq f) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.help_outline, size: 20, color: _primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(f.title,
                  style: const TextStyle(color: _dark, fontSize: 15, fontWeight: FontWeight.w800)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(f.tag,
                  style: const TextStyle(color: _primary, fontSize: 11, fontWeight: FontWeight.w700)),
            ),
          ]),
          const SizedBox(height: 8),
          Text(f.desc, style: const TextStyle(color: _muted, fontSize: 13, height: 1.45)),
          const SizedBox(height: 10),
          InkWell(
            onTap: () => openLink(context, f.url),
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

  Widget _channel(BuildContext context, IconData icon, String title, String sub, String url) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => openLink(context, url),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _border),
        ),
        child: Row(children: [
          Icon(icon, color: _primary, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: const TextStyle(color: _dark, fontSize: 15, fontWeight: FontWeight.w800)),
              Text(sub, style: const TextStyle(color: _muted, fontSize: 12.5)),
            ]),
          ),
          const Icon(Icons.chevron_right, color: _muted),
        ]),
      ),
    );
  }
}
