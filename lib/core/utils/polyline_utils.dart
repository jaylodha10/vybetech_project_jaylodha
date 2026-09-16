import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PolylineUtils {
  /// Interpolate between two LatLng points
  static LatLng interpolate(LatLng from, LatLng to, double fraction) {
    final lat = from.latitude + (to.latitude - from.latitude) * fraction;
    final lng = from.longitude + (to.longitude - from.longitude) * fraction;
    return LatLng(lat, lng);
  }

  /// Generate intermediate sub-points between each consecutive pair in waypoints
  static List<LatLng> generateSubPoints(List<LatLng> waypoints, int subSteps) {
    final result = <LatLng>[];
    for (int i = 0; i < waypoints.length - 1; i++) {
      for (int j = 0; j < subSteps; j++) {
        result.add(interpolate(waypoints[i], waypoints[i + 1], j / subSteps));
      }
    }
    result.add(waypoints.last);
    return result;
  }

  /// Calculate compass bearing between two points
  static double getBearing(LatLng from, LatLng to) {
    final lat1 = from.latitude * pi / 180;
    final lat2 = to.latitude * pi / 180;
    final dLng = (to.longitude - from.longitude) * pi / 180;
    final y = sin(dLng) * cos(lat2);
    final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLng);
    final bearing = atan2(y, x) * 180 / pi;
    return (bearing + 360) % 360;
  }
}
