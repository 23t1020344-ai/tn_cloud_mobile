import 'package:flutter/material.dart';
import 'app_data.dart';
import 'balance_state.dart';
import 'rental_state.dart';
import 'transaction_state.dart';

const _primary = Color(0xFF0B7FC7);
const _dark = Color(0xFF0F1B2D);
const _muted = Color(0xFF5B6B80);
const _border = Color(0xFFDDE5EE);
const _bg = Color(0xFFF5F8FB);
const _green = Color(0xFF16A37F);
const _amber = Color(0xFFE08A00);
const _red = Color(0xFFD93025);

enum _Filter { all, topup, rent }

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  _Filter _filter = _Filter.all;

  @override
  void initState() {
    super.initState();
    // Làm mới lịch sử từ server khi mở trang
    AppData.refreshAll().catchError((_) {});
  }

  List<Txn> _apply(List<Txn> all) {
    switch (_filter) {
      case _Filter.all:
        return all;
      case _Filter.topup:
        return all.where((t) => t.type == TxnType.topup).toList();
      case _Filter.rent:
        return all.where((t) => t.type == TxnType.rent).toList();
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
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Lịch sử giao dịch',
            style: TextStyle(
                color: _dark, fontWeight: FontWeight.w800, fontSize: 20)),
      ),
      body: ValueListenableBuilder<List<Txn>>(
        valueListenable: TransactionState.items,
        builder: (context, all, _) {
          final list = _apply(all);
          return RefreshIndicator(
            onRefresh: () async {
              try {
                await AppData.loadTransactions();
              } catch (_) {}
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          children: [
                            for (final f in _Filter.values)
                              ChoiceChip(
                                label: Text(const {
                                  _Filter.all: 'Tất cả',
                                  _Filter.topup: 'Nạp tiền',
                                  _Filter.rent: 'Thuê GPU',
                                }[f]!),
                                selected: _filter == f,
                                onSelected: (_) =>
                                    setState(() => _filter = f),
                              ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        if (list.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 60),
                            child: Center(
                              child: Text('Chưa có giao dịch nào.',
                                  style: TextStyle(
                                      color: _muted, fontSize: 14)),
                            ),
                          )
                        else
                          for (final t in list) ...[
                            _TxnTile(t),
                            const SizedBox(height: 10),
                          ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TxnTile extends StatelessWidget {
  final Txn t;
  const _TxnTile(this.t);

  @override
  Widget build(BuildContext context) {
    final isTopup = t.type == TxnType.topup;
    final pending = t.status == TxnStatus.pending;
    final positive = t.amount > 0;
    final amountColor = pending ? _amber : (positive ? _green : _red);
    final sign = positive ? '+' : '-';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: (isTopup ? _green : _primary).withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(isTopup ? Icons.add_card : Icons.memory,
                color: isTopup ? _green : _primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: _dark,
                        fontSize: 14,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text('${t.code} • ${fmtDateTime(t.time)}',
                    style: const TextStyle(color: _muted, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$sign${formatVnd(t.amount.abs())}đ',
                  style: TextStyle(
                      color: amountColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 3),
              Text(
                  pending
                      ? 'Chờ xác nhận'
                      : 'Số dư: ${formatVnd(t.balanceAfter)}đ',
                  style: TextStyle(
                      color: pending ? _amber : _muted,
                      fontSize: 11.5,
                      fontWeight: pending ? FontWeight.w700 : FontWeight.w400)),
            ],
          ),
        ],
      ),
    );
  }
}