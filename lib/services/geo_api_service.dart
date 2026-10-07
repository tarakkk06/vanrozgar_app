import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/village.dart';

class GeoPlace {
  final double latitude;
  final double longitude;
  final String displayName;
  final String source;

  const GeoPlace({
    required this.latitude,
    required this.longitude,
    required this.displayName,
    required this.source,
  });
}

class OsmMapFeature {
  final String name;
  final String kind;
  final double latitude;
  final double longitude;

  const OsmMapFeature({
    required this.name,
    required this.kind,
    required this.latitude,
    required this.longitude,
  });
}

class GeoApiService {
  static final GeoApiService _instance = GeoApiService._internal();
  factory GeoApiService() => _instance;
  GeoApiService._internal();

  static const _userAgent = 'VanRozgar/2.0 (village livelihood planning; contact@vanrozgar.local)';

  Future<GeoPlace?> geocodeVillage(Village village) async {
    final query = '${village.name}, ${village.taluka}, ${village.district}, Maharashtra, India';
    try {
      final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
        'q': query,
        'format': 'json',
        'limit': '1',
        'countrycodes': 'in',
      });
      final response = await http.get(uri, headers: {'User-Agent': _userAgent, 'Accept': 'application/json'}).timeout(
        const Duration(seconds: 8),
      );
      if (response.statusCode != 200) return null;
      final list = json.decode(response.body);
      if (list is List && list.isNotEmpty) {
        final first = list.first as Map<String, dynamic>;
        return GeoPlace(
          latitude: double.parse(first['lat'].toString()),
          longitude: double.parse(first['lon'].toString()),
          displayName: first['display_name']?.toString() ?? village.name,
          source: 'OpenStreetMap Nominatim',
        );
      }
    } catch (_) {}
    return null;
  }

  Future<List<OsmMapFeature>> fetchNearbyMapFeatures(double lat, double lon) async {
    final body = '''
[out:json][timeout:18];
(
  way["natural"="water"](around:4000,$lat,$lon);
  way["waterway"="dam"](around:4000,$lat,$lon);
  way["landuse"="forest"](around:4000,$lat,$lon);
  node["place"="village"](around:4000,$lat,$lon);
);
out center 20;
''';
    try {
      final response = await http
          .post(
            Uri.parse('https://overpass-api.de/api/interpreter'),
            headers: {'User-Agent': _userAgent, 'Content-Type': 'text/plain'},
            body: body,
          )
          .timeout(const Duration(seconds: 18));
      if (response.statusCode != 200) return const [];
      final data = json.decode(response.body) as Map<String, dynamic>;
      final elements = data['elements'] as List? ?? const [];
      final features = <OsmMapFeature>[];
      for (final raw in elements) {
        final el = raw as Map<String, dynamic>;
        final tags = (el['tags'] as Map?)?.cast<String, dynamic>() ?? {};
        double? fLat = (el['lat'] as num?)?.toDouble();
        double? fLon = (el['lon'] as num?)?.toDouble();
        final center = el['center'] as Map?;
        fLat ??= (center?['lat'] as num?)?.toDouble();
        fLon ??= (center?['lon'] as num?)?.toDouble();
        if (fLat == null || fLon == null) continue;
        String kind = 'feature';
        if (tags.containsKey('waterway') || tags['natural'] == 'water') kind = 'water';
        if (tags['landuse'] == 'forest') kind = 'forest';
        if (tags['place'] == 'village') kind = 'settlement';
        features.add(OsmMapFeature(
          name: (tags['name'] ?? tags['name:en'] ?? kind).toString(),
          kind: kind,
          latitude: fLat,
          longitude: fLon,
        ));
      }
      return features;
    } catch (_) {
      return const [];
    }
  }
}
