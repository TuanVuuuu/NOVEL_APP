import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefUtils {
  SharedPrefUtils._();

  static late SharedPreferences _prefsInstance;
  static bool _initialized = false;

  static Future<SharedPreferences> _sharedPrefs() async {
    if (!_initialized) {
      _prefsInstance = await SharedPreferences.getInstance();
      _initialized = true;
    }
    return _prefsInstance;
  }

  /// Saves a boolean value with the given key to SharedPreferences
  static Future<void> saveBool({required String key, required bool value}) async {
    final SharedPreferences prefs = await _sharedPrefs();
    await prefs.setBool(key, value);
  }

  /// Saves an integer value with the given key to SharedPreferences
  static Future<void> saveInt({required String key, required int value}) async {
    final SharedPreferences prefs = await _sharedPrefs();
    await prefs.setInt(key, value);
  }

  /// Saves a double value with the given key to SharedPreferences
  static Future<void> saveDouble({required String key, required double value}) async {
    final SharedPreferences prefs = await _sharedPrefs();
    await prefs.setDouble(key, value);
  }

  /// Saves a string value with the given key to SharedPreferences
  static Future<void> saveString({required String key, required String value}) async {
    final SharedPreferences prefs = await _sharedPrefs();
    await prefs.setString(key, value);
  }

  /// Saves a list of strings with the given key to SharedPreferences
  static Future<void> saveStringList({required String key, required List<String> value}) async {
    final SharedPreferences prefs = await _sharedPrefs();
    await prefs.setStringList(key, value);
  }

  /// Retrieves a boolean value with the given key from SharedPreferences
  static Future<bool?> getBool({required String key}) async {
    final SharedPreferences prefs = await _sharedPrefs();
    return prefs.getBool(key);
  }

  /// Retrieves an integer value with the given key from SharedPreferences
  static Future<int?> getInt({required String key}) async {
    final SharedPreferences prefs = await _sharedPrefs();
    return prefs.getInt(key);
  }

  /// Retrieves a double value with the given key from SharedPreferences
  static Future<double?> getDouble({required String key}) async {
    final SharedPreferences prefs = await _sharedPrefs();
    return prefs.getDouble(key);
  }

  /// Retrieves a string value with the given key from SharedPreferences
  static Future<String?> getString({required String key}) async {
    final SharedPreferences prefs = await _sharedPrefs();
    return prefs.getString(key);
  }

  /// Retrieves a list of strings with the given key from SharedPreferences
  static Future<List<String>?> getStringList({required String key}) async {
    final SharedPreferences prefs = await _sharedPrefs();
    return prefs.getStringList(key);
  }

  /// Removing data from SharedPreferences
  static Future<void> removeData({required String key}) async {
    final SharedPreferences prefs = await _sharedPrefs();
    await prefs.remove(key);
  }

  /// Clearing all data from SharedPreferences
  static Future<void> clearData() async {
    final SharedPreferences prefs = await _sharedPrefs();
    await prefs.clear();
  }
}
