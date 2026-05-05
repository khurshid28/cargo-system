import 'package:dio/dio.dart';

class OrderSummary {
  OrderSummary({
    required this.id,
    required this.status,
    required this.total,
    required this.address,
    required this.createdAt,
    this.driverName,
    this.driverPhone,
  });
  final String id;
  String status;
  final int total;
  final String address;
  final DateTime createdAt;
  String? driverName;
  String? driverPhone;

  factory OrderSummary.fromJson(Map<String, dynamic> j) => OrderSummary(
        id: j['id'],
        status: j['status'],
        total: (j['totalAmount'] as num).toInt(),
        address: j['deliveryAddress'],
        createdAt: DateTime.parse(j['createdAt']),
        driverName: j['driverName'],
        driverPhone: j['driverPhone'],
      );
}

abstract class OrdersRemoteDataSource {
  Future<List<OrderSummary>> mine();
  Future<OrderSummary> create({
    required String address,
    required double lat,
    required double lng,
    required List<Map<String, dynamic>> items,
  });
}

class OrdersRemoteDataSourceImpl implements OrdersRemoteDataSource {
  OrdersRemoteDataSourceImpl(this._dio);
  final Dio _dio;
  @override
  Future<List<OrderSummary>> mine() async {
    final r = await _dio.get('/orders/mine');
    return (r.data as List).map((e) => OrderSummary.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  @override
  Future<OrderSummary> create({
    required String address,
    required double lat,
    required double lng,
    required List<Map<String, dynamic>> items,
  }) async {
    final r = await _dio.post('/orders', data: {
      'deliveryAddress': address,
      'deliveryLat': lat,
      'deliveryLng': lng,
      'items': items,
    });
    return OrderSummary.fromJson(Map<String, dynamic>.from(r.data));
  }
}

class OrdersMockDataSource implements OrdersRemoteDataSource {
  final List<OrderSummary> _store = [
    OrderSummary(
      id: 'o1',
      status: 'SHIPPING',
      total: 4500000,
      address: 'Toshkent, Yashnobod, 12-uy',
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      driverName: 'Akmal Karimov',
      driverPhone: '+998901234511',
    ),
  ];

  @override
  Future<List<OrderSummary>> mine() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return List.from(_store.reversed);
  }

  @override
  Future<OrderSummary> create({
    required String address,
    required double lat,
    required double lng,
    required List<Map<String, dynamic>> items,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final total = items.fold<int>(
      0,
      (s, it) => s + ((it['unitPrice'] as num) * (it['quantity'] as num)).toInt(),
    );
    final order = OrderSummary(
      id: 'o-${DateTime.now().millisecondsSinceEpoch}',
      status: 'CREATED',
      total: total,
      address: address,
      createdAt: DateTime.now(),
    );
    _store.add(order);
    return order;
  }
}
