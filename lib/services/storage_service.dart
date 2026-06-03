import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_data.dart';

class StorageService {
  static const String _userKey = 'empower_user_data';
  static const String _apiKeyKey = 'openrouter_api_key';
  static const String _modelKey = 'openrouter_model';

  static StorageService? _instance;
  SharedPreferences? _prefs;

  StorageService._();

  factory StorageService() {
    _instance ??= StorageService._();
    return _instance!;
  }

  /// Call once at app startup before runApp()
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ── User Data ─────────────────────────────────────

  UserData loadUserData() {
    final data = _prefs?.getString(_userKey);
    if (data == null) return UserData();
    try {
      return UserData.fromJson(jsonDecode(data));
    } catch (_) {
      return UserData();
    }
  }

  Future<void> saveUserData(UserData user) async {
    await _prefs?.setString(_userKey, jsonEncode(user.toJson()));
  }

  // ── API Key & Model ──────────────────────────────

  String getApiKey() => _prefs?.getString(_apiKeyKey) ?? '';

  Future<void> saveApiKey(String key) async {
    await _prefs?.setString(_apiKeyKey, key);
  }

  String getModel() => _prefs?.getString(_modelKey) ?? 'google/gemma-4-31b-it:free';

  Future<void> saveModel(String model) async {
    await _prefs?.setString(_modelKey, model);
  }

  // ── Generic Bool Storage (Settings) ───────────────

  bool getBool(String key, {bool defaultValue = false}) {
    return _prefs?.getBool(key) ?? defaultValue;
  }

  Future<void> setBool(String key, bool value) async {
    await _prefs?.setBool(key, value);
  }

  // ── Reset ─────────────────────────────────────────

  Future<void> eraseAll() async {
    await _prefs?.clear();
  }
}
