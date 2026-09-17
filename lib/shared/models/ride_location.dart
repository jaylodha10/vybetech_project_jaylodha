import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

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
