import 'package:shared_preferences/shared_preferences.dart';

class KidsPointsService {
  static const String _starsKey = 'kids_total_stars_v2';
  static const String _gamesKey = 'completed_games';

  static Future<void> addPoints(int points) async {
    if (points <= 0) return;
    final prefs = await SharedPreferences.getInstance();
    final currentStars = prefs.getInt(_starsKey) ?? 0;
    await prefs.setInt(_starsKey, currentStars + points);
    
    // Also increment completed games if first time or per session
    final currentGames = prefs.getInt(_gamesKey) ?? 0;
    await prefs.setInt(_gamesKey, currentGames + 1);
  }

  static Future<int> getTotalStars() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_starsKey) ?? 0;
  }
}
