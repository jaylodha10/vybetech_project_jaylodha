import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RideLocation extends Equatable {
  final String id;
  final String title;
  final String subtitle;
  final LatLng coordinates;
  final double distanceKm;
  final int etaMinutes;

  const RideLocation({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.coordinates,
    required this.distanceKm,
    required this.etaMinutes,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    subtitle,
    coordinates,
    distanceKm,
    etaMinutes,
  ];
}
