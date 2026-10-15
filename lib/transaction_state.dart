import 'package:flutter/foundation.dart';

enum TxnType { topup, rent }

enum TxnStatus { success, pending }

/// Một giao dịch trong lịch sử.
class Txn {
  final String code; // mã giao dịch / mã đơn
  final TxnType type;
  final TxnStatus status;
  final int amount; // dương = tiền vào, âm = tiền ra
  final int balanceAfter; // số dư sau giao dịch
  final String title;
  final DateTime time;

  const Txn({
    required this.code,
    required this.type,
    required this.status,
    required this.amount,
    required this.balanceAfter,
    required this.title,
    required this.time,
  });
}

/// Lịch sử giao dịch.
/// TODO: khi có API, tải lịch sử từ server thay vì lưu trong bộ nhớ app.
class TransactionState {
  static final ValueNotifier<List<Txn>> items = ValueNotifier<List<Txn>>([]);

  /// Thêm giao dịch mới lên đầu danh sách.
  static void add(Txn t) => items.value = [t, ...items.value];

  static void reset() => items.value = [];
}