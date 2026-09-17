import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Provides dynamic, high-speed map tiles (Voyager & Dark Matter) that render
/// seamlessly on top of GoogleMap without requiring Google Cloud Billing setup.
class VybeMapTileProvider implements TileProvider {
  final bool isDark;
  final HttpClient _client = HttpClient();

  VybeMapTileProvider({this.isDark = false});

  @override
  Future<Tile> getTile(int x, int y, int? zoom) async {
    if (zoom == null) return TileProvider.noTile;
    try {
      final style = isDark ? 'dark_all' : 'rastertiles/voyager';
      final url = 'https://basemaps.cartocdn.com/$style/$zoom/$x/$y.png';
      final request = await _client.getUrl(Uri.parse(url));
      request.headers.set('User-Agent', 'VybeCabs/1.0 (Ride App)');
      final response = await request.close();
      if (response.statusCode == 200) {
        final bytes = await consolidateHttpClientResponseBytes(response);
        return Tile(256, 256, bytes);
      }
    } catch (_) {}
    return TileProvider.noTile;
  }
}
