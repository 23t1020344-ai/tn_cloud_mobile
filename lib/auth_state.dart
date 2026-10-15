import 'package:flutter/foundation.dart';
import 'api.dart';
import 'app_data.dart';
import 'balance_state.dart';
import 'rental_state.dart';
import 'transaction_state.dart';

class AuthState {
  // null = chưa đăng nhập
  static final ValueNotifier<String?> userName = ValueNotifier<String?>(null);

  static bool get isLoggedIn => userName.value != null;

  static void login(String name) => userName.value = name;

  /// Gọi khi mở app: có token cũ thì tự đăng nhập lại.
  static Future<void> restore() async {
    await Api.loadToken();
    if (!Api.hasToken) return;
    try {
      final me = await Api.get('/me');
      userName.value = me['user']['name'];
    } on ApiException catch (e) {
      // Chỉ bỏ token khi server báo không hợp lệ; lỗi mạng thì giữ lại.
      // (401 đã được Api tự xử lý, đây là phòng hờ)
      if (e.status == 401) await Api.setToken(null);
      return;
    } catch (_) {
      return;
    }
    // Tải số dư / máy thuê / lịch sử; lỗi ở bước này không làm mất đăng nhập
    try {
      await AppData.refreshAll();
    } catch (_) {}
  }

  static void logout() {
    Api.setToken(null);
    userName.value = null;
    BalanceState.reset();
    RentalState.reset();
    TransactionState.reset();
  }
}