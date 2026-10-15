import 'package:flutter/foundation.dart';

/// Số dư tài khoản (đơn vị: đồng).
/// TODO: khi có API, nạp số dư thật từ server sau khi đăng nhập.
class BalanceState {
  static final ValueNotifier<int> balance = ValueNotifier<int>(0);

  static void add(int amount) => balance.value += amount;
  /// Trừ tiền; trả về false nếu số dư không đủ.
  static bool spend(int amount) {
    if (amount > balance.value) return false;
    balance.value -= amount;
    return true;
  }

  static void reset() => balance.value = 0;
}

/// 1234567 -> "1,234,567"
String formatVnd(int n) {
  final s = n.toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
    b.write(s[i]);
  }
  return b.toString();
}