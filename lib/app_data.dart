import 'api.dart';
import 'balance_state.dart';
import 'rental_state.dart';
import 'transaction_state.dart';

class AppData {
  static DateTime _t(dynamic ms) =>
      DateTime.fromMillisecondsSinceEpoch((ms as num).toInt());

  static Rental _rental(Map r) {
    final a = r['access'] as Map?; // null khi máy đã hết hạn
    return Rental(
      id: r['id'],
      planName: r['planName'],
      gpu: r['gpu'],
      location: r['location'],
      os: r['os'],
      paid: r['paid'],
      periodLabel: r['periodLabel'],
      access: RentalAccess(
        host: a?['host'] ?? '',
        ip: a?['ip'] ?? '',
        port: a?['port'] ?? 0,
        user: a?['user'] ?? '',
        password: a?['password'] ?? '',
        supportId: a?['supportId'] ?? '',
        windows: a?['windows'] ?? true,
      ),
      startedAt: _t(r['startedAt']),
      endsAt: _t(r['endsAt']),
    );
  }

  static Txn _txn(Map t) => Txn(
        code: t['code'],
        type: t['type'] == 'rent' ? TxnType.rent : TxnType.topup,
        status: t['status'] == 'success' ? TxnStatus.success : TxnStatus.pending,
        amount: t['amount'],
        balanceAfter: t['balanceAfter'],
        title: t['title'],
        time: _t(t['time']),
      );

  static Future<void> loadBalance() async {
    final me = await Api.get('/me');
    BalanceState.balance.value = me['user']['balance'] as int;
  }

  static Future<void> loadRentals() async {
    final r = await Api.get('/rentals');
    RentalState.rentals.value = [for (final x in r['rentals']) _rental(x)];
  }

  static Future<void> loadTransactions() async {
    final r = await Api.get('/transactions');
    TransactionState.items.value = [for (final x in r['transactions']) _txn(x)];
  }

  static Future<void> refreshAll() async {
    await Future.wait([loadBalance(), loadRentals(), loadTransactions()]);
  }
}