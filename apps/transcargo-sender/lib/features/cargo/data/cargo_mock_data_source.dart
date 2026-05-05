import 'cargo_remote_data_source.dart';

/// In-memory mock cargo data — survives during app session only.
class CargoMockDataSource implements CargoRemoteDataSource {
  final List<Map<String, dynamic>> _store = [
    {
      'id': 'mock-1',
      'status': 'DELIVERED',
      'pickupAddress': 'Toshkent, Chilonzor',
      'dropoffAddress': 'Samarqand, Registon',
      'cargoType': 'Mebel',
      'weightKg': 850.0,
      'createdAt': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
    },
    {
      'id': 'mock-2',
      'status': 'IN_TRANSIT',
      'pickupAddress': 'Toshkent, Yunusobod',
      'dropoffAddress': 'Buxoro, Markaz',
      'cargoType': 'Qurilish materiallari',
      'weightKg': 2400.0,
      'createdAt': DateTime.now().subtract(const Duration(hours: 6)).toIso8601String(),
    },
    {
      'id': 'mock-3',
      'status': 'CREATED',
      'pickupAddress': 'Toshkent, Sergeli',
      'dropoffAddress': 'Andijon, Bosh ko‘cha',
      'cargoType': 'Maishiy texnika',
      'weightKg': 320.0,
      'createdAt': DateTime.now().subtract(const Duration(minutes: 15)).toIso8601String(),
    },
  ];

  @override
  Future<List<Map<String, dynamic>>> myRequests() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return List<Map<String, dynamic>>.from(_store.reversed);
  }

  @override
  Future<Map<String, dynamic>> create(Map<String, dynamic> body) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final pickup = body['pickup'] as Map?;
    final dropoff = body['dropoff'] as Map?;
    final newReq = {
      'id': 'mock-${DateTime.now().millisecondsSinceEpoch}',
      'status': 'CREATED',
      'pickupAddress': pickup?['address'] ?? '—',
      'dropoffAddress': dropoff?['address'] ?? '—',
      'cargoType': body['cargoType'] ?? 'general',
      'weightKg': (body['weightKg'] as num?)?.toDouble() ?? 0,
      'createdAt': DateTime.now().toIso8601String(),
    };
    _store.add(newReq);
    return newReq;
  }
}
