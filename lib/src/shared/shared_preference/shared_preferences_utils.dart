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
  static Future<bool> saveBool({required String key, required bool value}) async {
    return (await _sharedPrefs()).setBool(key, value);
  }

  /// Saves an integer value with the given key to SharedPreferences
  static Future<bool> saveInt({required String key, required int value}) async {
    return (await _sharedPrefs()).setInt(key, value);
  }

  /// Saves a double value with the given key to SharedPreferences
  static Future<bool> saveDouble({required String key, required double value}) async {
    return (await _sharedPrefs()).setDouble(key, value);
  }

  /// Saves a string value with the given key to SharedPreferences
  static Future<bool> saveString({required String key, required String value}) async {
    return (await _sharedPrefs()).setString(key, value);
  }

  /// Saves a list of strings with the given key to SharedPreferences
  static Future<bool> saveStringList({required String key, required List<String> value}) async {
    return (await _sharedPrefs()).setStringList(key, value);
  }

  /// Retrieves a boolean value with the given key from SharedPreferences
  static Future<bool?> getBool({required String key}) async {
    return (await _sharedPrefs()).getBool(key);
  }

  /// Retrieves an integer value with the given key from SharedPreferences
  static Future<int?> getInt({required String key}) async {
    return (await _sharedPrefs()).getInt(key);
  }

  /// Retrieves a double value with the given key from SharedPreferences
  static Future<double?> getDouble({required String key}) async {
    return (await _sharedPrefs()).getDouble(key);
  }

  /// Retrieves a string value with the given key from SharedPreferences
  static Future<String?> getString({required String key}) async {
    return (await _sharedPrefs()).getString(key);
  }

  /// Retrieves a list of strings with the given key from SharedPreferences
  static Future<List<String>?> getStringList({required String key}) async {
    return (await _sharedPrefs()).getStringList(key);
  }

  /// Removing data from SharedPreferences
  static Future<void> removeData({required String key}) async {
    await (await _sharedPrefs()).remove(key);
  }

  /// Clearing all data from SharedPreferences
  static Future<void> clearData() async {
    await (await _sharedPrefs()).clear();
  }
}
