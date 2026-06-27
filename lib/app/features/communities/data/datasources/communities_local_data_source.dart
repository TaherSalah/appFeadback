import 'package:shared_preferences/shared_preferences.dart';

class CommunitiesLocalDataSource {
  static const String _keyName = 'community_user_name';
  static const String _keyGender = 'community_user_gender'; // 'male' or 'female'
  static const String _keyEmail = 'community_user_email';
  static const String _keyPhone = 'community_user_phone';
  static const String _keyLocation = 'community_user_location';

  static const String _keyIsTeacher = 'community_user_is_teacher';

  Future<bool> hasProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_keyName) && prefs.containsKey(_keyGender);
  }

  Future<void> saveProfile(String name, String gender, {String? email, String? phone, String? location, bool isTeacher = false}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyName, name);
    await prefs.setString(_keyGender, gender);
    await prefs.setBool(_keyIsTeacher, isTeacher);
    if (email != null) await prefs.setString(_keyEmail, email);
    if (phone != null) await prefs.setString(_keyPhone, phone);
    if (location != null) await prefs.setString(_keyLocation, location);
  }

  Future<Map<String, String>?> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_keyName);
    final gender = prefs.getString(_keyGender);
    final email = prefs.getString(_keyEmail);
    final phone = prefs.getString(_keyPhone);
    final location = prefs.getString(_keyLocation);
    final isTeacher = prefs.getBool(_keyIsTeacher) ?? false;
    
    if (name != null && gender != null) {
      return {
        'name': name, 
        'gender': gender,
        'is_teacher': isTeacher.toString(),
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
        if (location != null) 'location': location,
      };
    }
    return null;
  }

  Future<void> clearProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyName);
    await prefs.remove(_keyGender);
    await prefs.remove(_keyIsTeacher);
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyPhone);
    await prefs.remove(_keyLocation);
    await prefs.remove('communities_user_id'); // Clear UUID to create new user on next register
  }
}
