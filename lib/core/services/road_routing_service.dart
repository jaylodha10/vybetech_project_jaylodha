import 'dart:convert';
import 'dart:io';
import 'package:latlong2/latlong.dart';
import '../utils/polyline_utils.dart';

class RoadRouteResult {
  final List<LatLng> coordinates;
  final double distanceKm;
  final int durationSeconds;

  const RoadRouteResult({
    required this.coordinates,
    required this.distanceKm,
    required this.durationSeconds,
  });
}

class RoadRoutingService {
  static const String _osrmBase =
      'https://router.project-osrm.org/route/v1/driving';
  static const String _userAgent = 'com.example.vybetech_project_jaylodha';

  /// Fetches the real road-following route between two points using OSRM.
  /// Falls back to smooth interpolation if offline or on network error.
  Future<RoadRouteResult> getRoadRoute(LatLng start, LatLng end) async {
    try {
      final url =
          '$_osrmBase/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson';
      final client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 4);

      final request = await client.getUrl(Uri.parse(url));
      request.headers.set('User-Agent', _userAgent);
      final response = await request.close().timeout(
            const Duration(seconds: 4),
          );

      if (response.statusCode == 200) {
        final jsonString = await response.transform(utf8.decoder).join();
        final data = jsonDecode(jsonString) as Map<String, dynamic>;

        if (data['code'] == 'Ok' && data['routes'] != null) {
          final routes = data['routes'] as List<dynamic>;
          if (routes.isNotEmpty) {
            final route = routes.first as Map<String, dynamic>;
            final geometry = route['geometry'] as Map<String, dynamic>;
            final rawCoords = geometry['coordinates'] as List<dynamic>;

            final points = rawCoords.map<LatLng>((coord) {
              final pair = coord as List<dynamic>;
              return LatLng(
                (pair[1] as num).toDouble(),
                (pair[0] as num).toDouble(),
              );
            }).toList();

            final distanceMeters =
                ((route['distance'] ?? 1000) as num).toDouble();
            final durationSecs = ((route['duration'] ?? 180) as num).toInt();

            if (points.isNotEmpty) {
              return RoadRouteResult(
                coordinates: points,
                distanceKm: double.parse(
                  (distanceMeters / 1000).toStringAsFixed(1),
                ),
                durationSeconds: durationSecs,
              );
            }
          }
        }
      }
    } catch (_) {}

    // Fallback: generate interpolated path between start and end
    final fallbackPoints = PolylineUtils.generateSubPoints([start, end], 12);
    final approxDist = const Distance().as(LengthUnit.Kilometer, start, end);
    return RoadRouteResult(
      coordinates: fallbackPoints,
      distanceKm: double.parse(approxDist.toStringAsFixed(1)),
      durationSeconds: (approxDist * 120).toInt().clamp(60, 3600),
    );
  }

  /// Calculates a realistic driver approach route starting ~1.2 km away on a real road
  Future<RoadRouteResult> getDriverApproachRoute(LatLng pickup) async {
    final driverStart = LatLng(
      pickup.latitude - 0.0085,
      pickup.longitude - 0.0075,
    );
    return getRoadRoute(driverStart, pickup);
  }

  /// Reverse geocode a position to a short readable street/area name using OpenStreetMap Nominatim
  Future<String?> reverseGeocode(LatLng pos) async {
    try {
      final url =
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=${pos.latitude}&lon=${pos.longitude}&zoom=18&addressdetails=1';
      final client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 3);
      final request = await client.getUrl(Uri.parse(url));
      request.headers.set('User-Agent', _userAgent);
      final response = await request.close().timeout(
            const Duration(seconds: 3),
          );

      if (response.statusCode == 200) {
        final jsonString = await response.transform(utf8.decoder).join();
        final data = jsonDecode(jsonString) as Map<String, dynamic>;
        final address = data['address'] as Map<String, dynamic>?;
        if (address != null) {
          final road = address['road'] ??
              address['suburb'] ??
              address['neighbourhood'] ??
              address['city_district'] ??
              address['city'] ??
              address['town'];
          final city = address['city'] ?? address['town'] ?? address['state'];
          if (road != null && city != null) {
            return '$road, $city';
          } else if (road != null) {
            return '$road';
          }
        }
        final displayName = data['display_name'] as String?;
        if (displayName != null) {
          final parts = displayName.split(',');
          return parts.take(2).join(',').trim();
        }
      }
    } catch (_) {}
    return null;
  }
}
