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

  RideLocation copyWith({
    String? id,
    String? title,
    String? subtitle,
    LatLng? coordinates,
    double? distanceKm,
    int? etaMinutes,
  }) {
    return RideLocation(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      coordinates: coordinates ?? this.coordinates,
      distanceKm: distanceKm ?? this.distanceKm,
      etaMinutes: etaMinutes ?? this.etaMinutes,
    );
  }

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
