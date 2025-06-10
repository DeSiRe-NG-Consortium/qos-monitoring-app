import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_connectivity_test/src/service/background_service.dart';
import 'package:flutter_connectivity_test/src/service/local_notification_service.dart';
import 'package:flutter_connectivity_test/src/service/settings_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'src/app.dart';

const String actionDelete = 'delete';
const String actionSend = 'send';
const String actionResume = 'resume';

const int splashscreenTime = 3;
const int normalIdleTime = 1;

bool settingsUpdate = false;

NotificationService? notificationService;

// contains ul(0), dl(1), ping(2) and frontend server(3)
List<String> urls = SettingsStorage.defaultUrls;

bool isPausedOnReport = false;


Future<void> initializePlatformNotifications() async {
  notificationService = NotificationService();
  await notificationService
      ?.initializePlatformNotifications(notificationCallbackAndroid);
}

Future<void> notificationCallbackAndroid(NotificationResponse response) async {
  //print('${response.actionId}');
  if (response.actionId == actionSend) {
    //print('paused messurement');

    isPausedOnReport = true;

    final Uri url = Uri.parse(urls[3]);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
    NotificationService().cancelAllNotifications();
    NotificationService().showPausedNotification(
        id: 99,
        title: 'Info',
        body:
            'Warning Notifications are paused.',
        payload: '');
  }
  else if (response.actionId == actionResume) {
    //print('resume messurement');

    isPausedOnReport = false;
  }
}

Future<void> checkPermissions() async {
  Map<Permission, PermissionStatus> statuses = await [
    Permission.notification,
    Permission.phone,
    Permission.location,
    Permission.locationWhenInUse,
  ].request();

  statuses.forEach((permission, status) {
    /*if (status.isGranted) {
      //print('$permission isGranted');
    } else if (status.isDenied) {
      //print('$permission isDenied');
    } else*/

    if (status.isPermanentlyDenied) {
      //print('$permission isPermanentlyDenied');
      openAppSettings();
    }
  });
}

void openWiFiSettings() {
  final intent = AndroidIntent(
    action: 'android.settings.WIFI_SETTINGS',
    flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
  );
  intent.launch();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //DartPingFlutter.ensureInitialized(); // HINT: required for iOS

  urls = await SettingsStorage.loadUrlSettings();
  //print('ping server: ${urls[2] == '' ? SettingsStorage.defaultUrls[2] : urls[2]}');
  //print('frontend server: ${urls[3] == '' ? SettingsStorage.defaultUrls[3] : urls[3]}');

  // check permission here (notification, location, phone)
  await checkPermissions();
  //print('--> permissions complete!');

  // init notifications and create notification channel
  await initializePlatformNotifications();
  //print('--> notifications initalized!');

  BackgroundService.initializeService();
  //updateAppStatus(true);

  runApp(const MyApp());
}

/*
@override
void dispose() {
  updateAppStatus(false);
  //updateAppStatus(false);
  //dispose();
}
*/

/*
void updateAppStatus(bool isRunning) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isAppRunning', isRunning);
}
*/
