import 'package:dio/dio.dart';

class EarningEntry {
  EarningEntry({
    required this.id,
    required this.date,
    required this.route,
    required this.amount,
    required this.status,
  });
  final String id;
  final DateTime date;
  final String route;
  final int amount;
  final String status; // PAID, PENDING

  factory EarningEntry.fromJson(Map<String, dynamic> j) => EarningEntry(
        id: j['id'],
        date: DateTime.parse(j['date']),
        route: j['route'],
        amount: (j['amount'] as num).toInt(),
        status: j['status'],
      );
}

class EarningsSummary {
  EarningsSummary({
    required this.balance,
    required this.todayAmount,
    required this.weekAmount,
    required this.monthAmount,
    required this.completedTrips,
    required this.entries,
  });
  final int balance;
  final int todayAmount;
  final int weekAmount;
  final int monthAmount;
  final int completedTrips;
  final List<EarningEntry> entries;
}

abstract class EarningsRemoteDataSource {
  Future<EarningsSummary> summary();
  Future<void> requestPayout(int amount);
}

class EarningsRemoteDataSourceImpl implements EarningsRemoteDataSource {
  EarningsRemoteDataSourceImpl(this._dio);
  final Dio _dio;
  @override
  Future<EarningsSummary> summary() async {
    final r = await _dio.get('/driver/earnings');
    final d = Map<String, dynamic>.from(r.data);
    return EarningsSummary(
      balance: (d['balance'] as num).toInt(),
      todayAmount: (d['todayAmount'] as num).toInt(),
      weekAmount: (d['weekAmount'] as num).toInt(),
      monthAmount: (d['monthAmount'] as num).toInt(),
      completedTrips: (d['completedTrips'] as num).toInt(),
      entries: (d['entries'] as List)
          .map((e) => EarningEntry.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  @override
  Future<void> requestPayout(int amount) async {
    await _dio.post('/driver/payout', data: {'amount': amount});
  }
}

class EarningsMockDataSource implements EarningsRemoteDataSource {
  @override
  Future<EarningsSummary> summary() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final now = DateTime.now();
    return EarningsSummary(
      balance: 4350000,
      todayAmount: 850000,
      weekAmount: 3200000,
      monthAmount: 12450000,
      completedTrips: 47,
      entries: [
        EarningEntry(id: 'e1', date: now.subtract(const Duration(hours: 3)),
          route: 'Yunusobod → Samarqand', amount: 950000, status: 'PAID'),
        EarningEntry(id: 'e2', date: now.subtract(const Duration(days: 1)),
          route: 'Sergeli → Buxoro', amount: 2100000, status: 'PAID'),
        EarningEntry(id: 'e3', date: now.subtract(const Duration(days: 2, hours: 4)),
          route: 'Chilonzor → Andijon', amount: 850000, status: 'PAID'),
        EarningEntry(id: 'e4', date: now.subtract(const Duration(days: 3)),
          route: 'Yashnobod → Namangan', amount: 1100000, status: 'PAID'),
        EarningEntry(id: 'e5', date: now.subtract(const Duration(days: 5)),
          route: 'Mirzo Ulug‘bek → Toshkent vil.', amount: 450000, status: 'PENDING'),
      ],
    );
  }

  @override
  Future<void> requestPayout(int amount) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
  }
}
