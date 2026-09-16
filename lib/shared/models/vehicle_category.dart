import 'package:equatable/equatable.dart';

class VehicleCategory extends Equatable {
  final String id;
  final String name;
  final String tagLine;
  final double basePrice;
  final double pricePerKm;
  final int capacity;
  final String iconAsset;
  final int etaMinutes;

  const VehicleCategory({
    required this.id,
    required this.name,
    required this.tagLine,
    required this.basePrice,
    required this.pricePerKm,
    required this.capacity,
    required this.iconAsset,
    this.etaMinutes = 3,
  });

  double calculateFare(double distanceKm) {
    return basePrice + (distanceKm * pricePerKm);
  }

  @override
  List<Object?> get props => [
    id,
    name,
    tagLine,
    basePrice,
    pricePerKm,
    capacity,
    iconAsset,
    etaMinutes,
  ];
}
