import 'package:muslimdaily/app/core/cache/shard_pref/shardpref_obj.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPref {
  static const String _userObj = "userObj";
  // static const String _userSubjects = "userSubjects";
  static const String _language = "language_code";
  // static const String _deviceId = "device_id";
  static const String _intro = "intro";
  static String boardingKey = 'boardi';
  static const String favKey = 'favorites_key';

  ////////***  checkFirstSeen  ***///////////
  static checkFirstSeen() async {
    // TODO: checkFirstSeen .
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(boardingKey, true);
  }

  static Future<bool?> getOnBoardingBool() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(SharedPref.boardingKey);
  }

  static getFavorites() async {
    return SharedObj().prefs?.getBool(favKey);
  }

  static Future<bool>? setFavorites(bool? isFavorites) {
    return (SharedObj().prefs?.setBool(favKey, isFavorites ?? false));
  }

  static Future saveUserObj() async {
    return null;
  }

  static getUserObg() {
    if (SharedObj().prefs!.containsKey(_userObj)) {}
  }

  static bool isUserLogIn() {
    return SharedObj().prefs?.getString(_userObj) != null;
  }

  static Future<void> logOut() async {
    await SharedObj().prefs?.remove(_userObj);
  }

  static String? getCurrentLang() {
    return SharedObj().prefs?.getString(_language);
  }

  static Future<void> setCurrentLang({required String lang}) async {
    await SharedObj().prefs?.setString(_language, lang);
  }

  Future<String> getValueFromSharedPreferences(String key) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(key)) {
      return prefs.getString(key) ?? '';
    } else {
      return '';
    }
  }

  // // saving Device Id
  // static Future<void> setDeviceID({required String deviceID}) async {
  //   await SharedObj().prefs?.setString(_deviceId, deviceID);
  // }

  // getting Device Id
  // static String? getDeviceID() {
  //   return SharedObj().prefs?.getString(_deviceId);
  // }
  static String tokenKey = 'token';
  static String? token;
  static String uIdKey = 'uId';
  static String? uId;

  static Future<void> saveWatchIntro() async {
    await SharedObj().prefs?.setBool(_intro, true);
  }

  static bool isWatchIntro() {
    return SharedObj().prefs?.getBool(_intro) ?? false;
  }
}
