import 'package:equatable/equatable.dart';

class CargoRequestItem extends Equatable {
  const CargoRequestItem({
    required this.id,
    required this.status,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.cargoType,
    required this.weightKg,
    required this.createdAt,
  });
  final String id;
  final String status;
  final String pickupAddress;
  final String dropoffAddress;
  final String cargoType;
  final double weightKg;
  final DateTime createdAt;

  factory CargoRequestItem.fromJson(Map<String, dynamic> j) => CargoRequestItem(
        id: j['id'] as String,
        status: j['status'] as String,
        pickupAddress: j['pickupAddress'] as String,
        dropoffAddress: j['dropoffAddress'] as String,
        cargoType: j['cargoType'] as String,
        weightKg: (j['weightKg'] as num).toDouble(),
        createdAt: DateTime.parse(j['createdAt'] as String),
      );

  @override
  List<Object?> get props => [id, status];
}

abstract class CargoRepository {
  Future<List<CargoRequestItem>> myRequests();
  Future<void> create({
    required String pickupAddress,
    required double pickupLat,
    required double pickupLng,
    required String dropoffAddress,
    required double dropoffLat,
    required double dropoffLng,
    required String cargoType,
    required double weightKg,
  });
}
