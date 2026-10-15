import 'api.dart';

class AuthService {
  /// Gửi email chứa liên kết đặt lại mật khẩu.
  /// Ném ApiException nếu lỗi mạng / server.
  static Future<void> sendPasswordReset(String email) async {
    await Api.post('/auth/forgot-password', {'email': email}, auth: false);
  }
}