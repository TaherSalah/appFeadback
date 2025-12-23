import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/MosqueModel.dart';

class MosqueService {
  static const String overpassUrl = 'https://overpass-api.de/api/interpreter';

  /// Fetch nearby mosques using Overpass API
  /// [latitude] and [longitude] are user's current location
  /// [radiusMeters] is the search radius (default 5000m = 5km)
  Future<List<Mosque>> fetchNearbyMosques({
    required double latitude,
    required double longitude,
    int radiusMeters = 5000,
  }) async {
    try {
      // Overpass QL query to find mosques
      final query = '''
[out:json];
(
  node["amenity"="place_of_worship"]["religion"="muslim"](around:$radiusMeters,$latitude,$longitude);
  way["amenity"="place_of_worship"]["religion"="muslim"](around:$radiusMeters,$latitude,$longitude);
);
out center;
''';

      final response = await http.post(
        Uri.parse(overpassUrl),
        body: {'data': query},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final elements = data['elements'] as List;

        List<Mosque> mosques = [];
        
        for (var element in elements) {
          try {
            // For ways, use center coordinates
            if (element['type'] == 'way' && element['center'] != null) {
              element['lat'] = element['center']['lat'];
              element['lon'] = element['center']['lon'];
            }
            
            // Parse mosque
            final mosque = Mosque.fromOverpassNode(element, latitude, longitude);
            mosques.add(mosque);
          } catch (e) {
            print('Error parsing mosque: $e');
          }
        }

        // Sort by distance
        mosques.sort((a, b) => a.distance.compareTo(b.distance));
        
        return mosques;
      } else {
        throw Exception('Failed to fetch mosques: ${response.statusCode}');
      }
    } catch (e) {
      print('MosqueService Error: $e');
      return [];
    }
  }

  /// Calculate distance between two points (Haversine formula)
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // km
    
    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);
    
    double a = (sin(dLat / 2) * sin(dLat / 2)) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }
}
