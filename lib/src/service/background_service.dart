import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

class BackgroundService {
  static ServiceInstance? _serviceInstance;

  static Timer? _timer;

  static Future<FlutterBackgroundService> initializeService() async {
    final service = FlutterBackgroundService();

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        isForegroundMode: true,
        notificationChannelId: 'my_foreground',
        initialNotificationTitle: 'DeSiRe-NG Service',
        initialNotificationContent: 'Running',
        foregroundServiceNotificationId: 888,
        foregroundServiceTypes: [AndroidForegroundType.location],
      ),
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );

    return service;
  }

  @pragma('vm:entry-point')
  static Future<bool> onIosBackground(ServiceInstance service) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();
    return true;
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    
    /*
    print("---> service-onstart");
    final prefs = await SharedPreferences.getInstance();
    bool isAppRunning = prefs.getBool('isAppRunning') ?? false;
    print("---> $isAppRunning");
    */

    DartPluginRegistrant.ensureInitialized();
    _serviceInstance = service;

    if (service is AndroidServiceInstance) {
      service.on('setAsForeground').listen((event) async {
        await service.setAsForegroundService();
      });

      service.on('setAsBackground').listen((event) async {
        await service.setAsBackgroundService();
      });
    }

    service.on('stopService').listen((event) async {
      await stopService();
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (service is AndroidServiceInstance) {
        if (await service.isForegroundService()) {
          service.invoke('update', {"data": 0});

          /*
          service.setForegroundNotificationInfo(
            title: "My App Service",
            content: "Updated at ${DateTime.now()}",
          );
          */
        }
      }
    });
  }

  static stopService() async {
    //print('🔴 Stopping Background Service...');

    _timer?.cancel();
    await _serviceInstance?.stopSelf();
    _serviceInstance = null;
  }
}
