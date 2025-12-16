import 'dart:math';

class Mosque {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final double distance; // in km
  final double? userRating; // local user rating

  Mosque({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.distance,
    this.userRating,
  });

  factory Mosque.fromOverpassNode(Map<String, dynamic> node, double userLat, double userLon) {
    final double lat = node['lat'];
    final double lon = node['lon'];
    final tags = node['tags'] as Map<String, dynamic>? ?? {};
    
    // Extract name - fallback to "مسجد" if no name
    final String name = tags['name'] ?? tags['name:ar'] ?? 'مسجد';
    
    // Extract address components
    final String address = _buildAddress(tags);
    
    // Calculate distance
    final double distance = _calculateDistance(userLat, userLon, lat, lon);

    return Mosque(
      id: node['id'].toString(),
      name: name,
      address: address,
      latitude: lat,
      longitude: lon,
      distance: distance,
    );
  }

  static String _buildAddress(Map<String, dynamic> tags) {
    List<String> parts = [];
    
    if (tags['addr:street'] != null) parts.add(tags['addr:street']);
    if (tags['addr:city'] != null) parts.add(tags['addr:city']);
    
    return parts.isEmpty ? 'لا يوجد عنوان' : parts.join(', ');
  }

  // Haversine formula for distance calculation
  static double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
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

  static double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'distance': distance,
      'userRating': userRating,
    };
  }
}
