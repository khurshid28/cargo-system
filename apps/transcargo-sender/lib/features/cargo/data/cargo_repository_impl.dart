import '../domain/cargo_repository.dart';
import 'cargo_remote_data_source.dart';

class CargoRepositoryImpl implements CargoRepository {
  CargoRepositoryImpl(this._remote);
  final CargoRemoteDataSource _remote;

  @override
  Future<List<CargoRequestItem>> myRequests() async {
    final list = await _remote.myRequests();
    return list.map(CargoRequestItem.fromJson).toList();
  }

  @override
  Future<void> create({
    required String pickupAddress,
    required double pickupLat,
    required double pickupLng,
    required String dropoffAddress,
    required double dropoffLat,
    required double dropoffLng,
    required String cargoType,
    required double weightKg,
  }) async {
    await _remote.create({
      'pickup': {'address': pickupAddress, 'lat': pickupLat, 'lng': pickupLng},
      'dropoff': {'address': dropoffAddress, 'lat': dropoffLat, 'lng': dropoffLng},
      'cargoType': cargoType,
      'weightKg': weightKg,
    });
  }
}
