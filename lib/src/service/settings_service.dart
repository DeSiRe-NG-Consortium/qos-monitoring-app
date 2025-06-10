import 'dart:convert';
import 'package:flutter_connectivity_test/src/models/customsetting.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsStorage {


  // THRESHOLD SETTINGS

  static const String _key = 'custom_settings';
  
  static Future<void> saveSettings(List<CustomSetting> settings) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> encodedSettings =
        settings.map((setting) => jsonEncode(setting.toMap())).toList();
    await prefs.setStringList(_key, encodedSettings);
  }

  static Future<List<CustomSetting>> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? encodedSettings = prefs.getStringList(_key);

    if (encodedSettings == null) return [];

    return encodedSettings
        .map((encoded) => CustomSetting.fromMap(jsonDecode(encoded)))
        .toList();
  }

  static Future<List<CustomSetting>> defaultSettings() async {
    return [
      CustomSetting(
          id: 0,
          showNotification: true,
          value: -95,
          defaultValue: -95,
          showError: false,
          lowerIsBetter: false),
      CustomSetting(
          id: 1,
          showNotification: true,
          value: -10,
          defaultValue: -10,
          showError: false,
          lowerIsBetter: false),
      CustomSetting(
          id: 2,
          showNotification: true,
          value: 25,
          defaultValue: 25,
          showError: false,
          lowerIsBetter: true),
      CustomSetting(
          id: 3,
          showNotification: true,
          value: 50,
          defaultValue: 50,
          showError: false,
          lowerIsBetter: true),
      CustomSetting(
          id: 4,
          showNotification: true,
          value: 20,
          defaultValue: 20,
          showError: false,
          lowerIsBetter: true),
      CustomSetting(
          id: 5,
          showNotification: true,
          value: 25,
          defaultValue: 25,
          showError: false,
          lowerIsBetter: false),
      CustomSetting(
          id: 6,
          showNotification: true,
          value: 10,
          defaultValue: 10,
          showError: false,
          lowerIsBetter: false),
    ];
  }

  static Future<void> clearSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }


  // URL SETTINGS

  static const String _urlKey = 'custom_url_settings';

  static const List<String> defaultUrls = [
    'http://speedtest.serverius.net', //'http://ping.online.net',
    'http://nl.iperf.014.fr',
    '8.8.8.8',
    'https://frontend.dev.desire-ng.net/map',
  ];

  static Future<void> saveUrlSettings(List<String> settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_urlKey, settings);
  }

  static Future<List<String>> loadUrlSettings() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? encodedSettings = prefs.getStringList(_urlKey);
    if (encodedSettings == null) return defaultUrlSettings();
    return encodedSettings;
  }
  
  static Future<List<String>> defaultUrlSettings() async {
    return defaultUrls;
  }

  static Future<void> clearUrlSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_urlKey);
  }


  // NOTIFICATION TYPE -> each time new one, or update exisiting

  static const String _notificationKey = 'custom_notification_settings';

  static const bool notificationUpdate = true;

  static Future<void> saveNotificationSettings(bool settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationKey, settings);
  }

  static Future<bool> loadNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    bool? encodedSettings = prefs.getBool(_notificationKey);
    if (encodedSettings == null) return defaultNotificationSettings();
    return encodedSettings;
  }
  
  static Future<bool> defaultNotificationSettings() async {
    return true;
  }

  static Future<void> clearNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_notificationKey);
  }

}
