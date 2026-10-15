import 'dart:math';
import 'package:flutter/foundation.dart';

/// Thông tin truy cập máy vừa thuê.
/// TODO: dữ liệu thật phải do server trả về sau khi tạo máy.
class RentalAccess {
  final String host; // tên miền
  final String ip;
  final int port;
  final String user;
  final String password;
  final String supportId;
  final bool windows; // true: Windows (RDP), false: Ubuntu (SSH)

  const RentalAccess({
    required this.host,
    required this.ip,
    required this.port,
    required this.user,
    required this.password,
    required this.supportId,
    required this.windows,
  });

  String get address => '$host:$port';
  String get ipPort => '$ip:$port';

  /// Nội dung file .rdp (không chứa mật khẩu)
  String get rdpFile => 'full address:s:$ipPort\r\n'
      'username:s:$user\r\n'
      'prompt for credentials:i:1\r\n'
      'screen mode id:i:2\r\n';

  String get sshCommand => 'ssh $user@$ip -p $port';

  /// Dữ liệu GIẢ để demo giao diện.
  factory RentalAccess.demo(String location, {required bool windows}) {
    final r = Random.secure();
    const letters = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789';
    String pick(int n, [String chars = letters]) =>
        List.generate(n, (_) => chars[r.nextInt(chars.length)]).join();
    return RentalAccess(
      host: 'net${r.nextInt(9) + 1}.tncloud.vn',
      ip: '103.${r.nextInt(200) + 20}.${r.nextInt(250) + 1}.${r.nextInt(250) + 1}',
      port: 10000 + r.nextInt(50000),
      user: windows ? 'tncloud-admin' : 'ubuntu',
      password: pick(10),
      supportId: pick(8, 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'),
      windows: windows,
    );
  }
}

/// Một lượt thuê GPU.
class Rental {
  final String id;
  final String planName;
  final String gpu;
  final String location;
  final String os;
  final int paid; // số tiền đã trả (đồng)
  final String periodLabel; // ví dụ "3 giờ", "2 ngày"
  final RentalAccess access;
  final DateTime startedAt;
  final DateTime endsAt;

  const Rental({
    required this.id,
    required this.planName,
    required this.gpu,
    required this.location,
    required this.os,
    required this.paid,
    required this.periodLabel,
    required this.access,
    required this.startedAt,
    required this.endsAt,
  });

  Duration get remaining => endsAt.difference(DateTime.now());
  bool get expired => remaining.inSeconds <= 0;
}

/// Danh sách GPU đang thuê.
/// TODO: khi có API, tải danh sách từ server và gọi API tạo máy khi thuê.
class RentalState {
  static final ValueNotifier<List<Rental>> rentals =
      ValueNotifier<List<Rental>>([]);

  static int get activeCount => rentals.value.where((r) => !r.expired).length;

  static void add(Rental r) => rentals.value = [r, ...rentals.value];

  static void remove(String id) =>
      rentals.value = rentals.value.where((r) => r.id != id).toList();

  static void reset() => rentals.value = [];
}

String _two(int n) => n.toString().padLeft(2, '0');

/// 05/11 14:30
String fmtDateTime(DateTime d) =>
    '${_two(d.day)}/${_two(d.month)} ${_two(d.hour)}:${_two(d.minute)}';

/// "2 ngày 03:15:08" hoặc "03:15:08"
String fmtRemaining(Duration d) {
  if (d.inSeconds <= 0) return 'Đã hết hạn';
  final days = d.inDays;
  final h = _two(d.inHours % 24);
  final m = _two(d.inMinutes % 60);
  final s = _two(d.inSeconds % 60);
  return days > 0 ? '$days ngày $h:$m:$s' : '$h:$m:$s';
}