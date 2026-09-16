import 'package:equatable/equatable.dart';

class Driver extends Equatable {
  final String id;
  final String name;
  final String photoUrl;
  final double rating;
  final int totalTrips;
  final String carModel;
  final String carColor;
  final String carNumber;
  final String phoneNumber;

  const Driver({
    required this.id,
    required this.name,
    required this.photoUrl,
    required this.rating,
    required this.totalTrips,
    required this.carModel,
    required this.carColor,
    required this.carNumber,
    required this.phoneNumber,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    photoUrl,
    rating,
    totalTrips,
    carModel,
    carColor,
    carNumber,
    phoneNumber,
  ];
}
