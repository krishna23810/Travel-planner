import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsViewModel extends ChangeNotifier {
  String _openWeatherKey = '';
  String _openTripMapKey = '';

  String get openWeatherKey => _openWeatherKey;
  String get openTripMapKey => _openTripMapKey;

  SettingsViewModel() {
    loadKeys();
  }

  Future<void> loadKeys() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    _openWeatherKey = sp.getString('openweather_api_key') ?? '';
    _openTripMapKey = sp.getString('opentripmap_api_key') ?? '';
    notifyListeners();
  }

  Future<void> saveOpenWeatherKey(String key) async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setString('openweather_api_key', key);
    _openWeatherKey = key;
    notifyListeners();
  }

  Future<void> saveOpenTripMapKey(String key) async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setString('opentripmap_api_key', key);
    _openTripMapKey = key;
    notifyListeners();
  }

  Future<void> clearKeys() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.remove('openweather_api_key');
    await sp.remove('opentripmap_api_key');
    _openWeatherKey = '';
    _openTripMapKey = '';
    notifyListeners();
  }
}
