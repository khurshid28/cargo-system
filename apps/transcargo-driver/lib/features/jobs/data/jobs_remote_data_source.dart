import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

class JobItem extends Equatable {
  const JobItem({
    required this.id,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.cargoType,
    required this.weightKg,
    required this.distanceKm,
    required this.priceUzs,
    required this.status,
  });
  final String id;
  final String pickupAddress;
  final String dropoffAddress;
  final String cargoType;
  final double weightKg;
  final double distanceKm;
  final int priceUzs;
  final String status;

  factory JobItem.fromJson(Map<String, dynamic> j) => JobItem(
        id: j['id'] as String,
        pickupAddress: j['pickupAddress'] as String,
        dropoffAddress: j['dropoffAddress'] as String,
        cargoType: j['cargoType'] as String,
        weightKg: (j['weightKg'] as num).toDouble(),
        distanceKm: (j['distanceKm'] as num? ?? 0).toDouble(),
        priceUzs: (j['priceAmount'] as num? ?? 0).toInt(),
        status: j['status'] as String,
      );

  @override
  List<Object?> get props => [id, status];
}

abstract class JobsRemoteDataSource {
  Future<List<JobItem>> available();
  Future<List<JobItem>> active();
  Future<void> accept(String id);
  Future<void> updateStatus(String id, String status);
}

class JobsRemoteDataSourceImpl implements JobsRemoteDataSource {
  JobsRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  @override
  Future<List<JobItem>> available() async {
    final r = await _dio.get('/cargo-requests', queryParameters: {'status': 'CREATED'});
    return (r.data as List).map((e) => JobItem.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  @override
  Future<List<JobItem>> active() async {
    final r = await _dio.get('/cargo-requests/assigned-to-me');
    return (r.data as List).map((e) => JobItem.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  @override
  Future<void> accept(String id) => _dio.post('/cargo-requests/$id/accept');

  @override
  Future<void> updateStatus(String id, String status) =>
      _dio.patch('/cargo-requests/$id/status', data: {'status': status});
}

class JobsMockDataSource implements JobsRemoteDataSource {
  final List<JobItem> _available = [
    const JobItem(
      id: 'job-1',
      pickupAddress: 'Toshkent, Yunusobod',
      dropoffAddress: 'Samarqand, Markaz',
      cargoType: 'Mebel',
      weightKg: 1200,
      distanceKm: 308,
      priceUzs: 950000,
      status: 'CREATED',
    ),
    const JobItem(
      id: 'job-2',
      pickupAddress: 'Toshkent, Sergeli',
      dropoffAddress: 'Buxoro, Markaz',
      cargoType: 'Qurilish materiallari',
      weightKg: 3400,
      distanceKm: 562,
      priceUzs: 2100000,
      status: 'CREATED',
    ),
    const JobItem(
      id: 'job-3',
      pickupAddress: 'Toshkent, Chilonzor',
      dropoffAddress: 'Andijon, Bosh ko‘cha',
      cargoType: 'Maishiy texnika',
      weightKg: 480,
      distanceKm: 343,
      priceUzs: 850000,
      status: 'CREATED',
    ),
  ];
  final List<JobItem> _active = [
    const JobItem(
      id: 'job-active-1',
      pickupAddress: 'Toshkent, Yashnobod',
      dropoffAddress: 'Namangan, Markaz',
      cargoType: 'Sovutgich',
      weightKg: 220,
      distanceKm: 287,
      priceUzs: 780000,
      status: 'PICKED_UP',
    ),
  ];

  @override
  Future<List<JobItem>> available() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return List.from(_available);
  }

  @override
  Future<List<JobItem>> active() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return List.from(_active);
  }

  @override
  Future<void> accept(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final idx = _available.indexWhere((j) => j.id == id);
    if (idx >= 0) {
      final j = _available.removeAt(idx);
      _active.add(JobItem(
        id: j.id,
        pickupAddress: j.pickupAddress,
        dropoffAddress: j.dropoffAddress,
        cargoType: j.cargoType,
        weightKg: j.weightKg,
        distanceKm: j.distanceKm,
        priceUzs: j.priceUzs,
        status: 'ASSIGNED',
      ));
    }
  }

  @override
  Future<void> updateStatus(String id, String status) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final i = _active.indexWhere((j) => j.id == id);
    if (i >= 0) {
      final j = _active[i];
      _active[i] = JobItem(
        id: j.id,
        pickupAddress: j.pickupAddress,
        dropoffAddress: j.dropoffAddress,
        cargoType: j.cargoType,
        weightKg: j.weightKg,
        distanceKm: j.distanceKm,
        priceUzs: j.priceUzs,
        status: status,
      );
    }
  }
}
