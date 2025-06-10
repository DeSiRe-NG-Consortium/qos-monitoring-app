import 'dart:typed_data';

import 'package:flutter_connectivity_test/main.dart';
import 'package:flutter_connectivity_test/src/service/settings_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/subjects.dart';

class NotificationService {
  NotificationService();

  final _localNotifications = FlutterLocalNotificationsPlugin();
  final BehaviorSubject<String> behaviorSubject = BehaviorSubject();

  getPlugIn() {
    return _localNotifications;
  }

  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
    //exit(0);
  }

  Future<void> initializePlatformNotifications(
    Function(NotificationResponse) onDidReceiveANDROID,
    /*Function(int,String?,String?,String?) onDidReceiveIOS*/
  ) async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('icon');

    DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
        macOS: initializationSettingsIOS);

    await _localNotifications.initialize(initializationSettings,
        onDidReceiveNotificationResponse: onDidReceiveANDROID,
        onDidReceiveBackgroundNotificationResponse: onDidReceiveANDROID);

    // CREATE CHANNEL (NEEDED FOR BACKGROUND SERVICE, DONT REMOVE, ELSE SERVICE WONT START AFTER PERMISSIONS SET)
    AndroidNotificationChannel channel = AndroidNotificationChannel(
      'my_foreground', // id
      'MY FOREGROUND SERVICE', // title
      description: 'This channel is used for important notifications.',
      importance: Importance.max, // importance must be at low or higher level
      playSound: true,
      sound: RawResourceAndroidNotificationSound('slow_spring_board'),
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 500, 200, 500, 200, 1000]),
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    required String payload,
  }) async {
    final platformChannelSpecifics = await _notificationDetails();
    await _localNotifications.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  Future<NotificationDetails> _notificationDetails() async {
    //final bigPicture = await DownloadUtil.downloadAndSaveFile(
    //    "https://images.unsplash.com/photo-1624948465027-6f9b51067557?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1470&q=80",
    //    "drinkwater");

    //http.Response response = await http.get(
    //    Uri.parse('https://flutter.io/images/flutter-mark-square-100.png'));
    //AndroidBitmap androidBitmap = ByteArrayAndroidBitmap.fromBase64String(base64.encode(response.bodyBytes));

    bool updateNotifications = await SettingsStorage.loadNotificationSettings();
    //print('should update notifications: $updateNotifications');
    
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'my_foreground', //'channel id',
      'channel name',
      groupKey: 'com.example.flutter_push_notifications',
      channelDescription: 'channel description',
      ticker: 'ticker next not defined',
      importance: Importance.max,
      priority: Priority.max,
      onlyAlertOnce: updateNotifications, //TODO: POPUP EACH WARNING INSTEAD OF UPDATING EXISITING
      playSound: true,
      //sound: RawResourceAndroidNotificationSound('slow_spring_board'),
      enableVibration: false,
      //silent: true,
      autoCancel: false,
      //setAsGroupSummary: true, //kinda grouped somehow
      //groupAlertBehavior: GroupAlertBehavior.all,
      largeIcon: const DrawableResourceAndroidBitmap('icon'),
      actions: const [
        AndroidNotificationAction(actionDelete, 'remove',
            showsUserInterface: true),
        AndroidNotificationAction(actionSend, 'send report',
            showsUserInterface: true),
      ],
      //styleInformation: BigPictureStyleInformation(
      //  FilePathAndroidBitmap(bigPicture),
      //  hideExpandedLargeIcon: false,
      //),
      //color: Color(0xff2196f3),
    );

    DarwinNotificationDetails iosNotificationDetails =
        const DarwinNotificationDetails(
            threadIdentifier: "thread1",
            attachments: <DarwinNotificationAttachment>[
          //DarwinNotificationAttachment(bigPicture)
        ]);

    final NotificationAppLaunchDetails? details =
        await _localNotifications.getNotificationAppLaunchDetails();
    if (details != null && details.didNotificationLaunchApp) {
      behaviorSubject.add(details.notificationResponse!.payload!);
    }
    NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics, iOS: iosNotificationDetails);

    return platformChannelSpecifics;
  }





  Future<void> showPausedNotification({
    required int id,
    required String title,
    required String body,
    required String payload,
  }) async {
    final platformChannelSpecifics = await _notificationPauseDetails();
    await _localNotifications.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  Future<NotificationDetails> _notificationPauseDetails() async {
    //final bigPicture = await DownloadUtil.downloadAndSaveFile(
    //    "https://images.unsplash.com/photo-1624948465027-6f9b51067557?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1470&q=80",
    //    "drinkwater");

    //http.Response response = await http.get(
    //    Uri.parse('https://flutter.io/images/flutter-mark-square-100.png'));
    //AndroidBitmap androidBitmap = ByteArrayAndroidBitmap.fromBase64String(base64.encode(response.bodyBytes));

    //bool updateNotifications = await SettingsStorage.loadNotificationSettings();
    //print('should update notifications: $updateNotifications');
    
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'my_foreground', //'channel id',
      'channel name',
      groupKey: 'com.example.flutter_push_notifications',
      channelDescription: 'channel description',
      ticker: 'ticker next not defined',
      importance: Importance.max,
      priority: Priority.max,
      onlyAlertOnce: true, //TODO: POPUP EACH WARNING INSTEAD OF UPDATING EXISITING
      playSound: true,
      //sound: RawResourceAndroidNotificationSound('slow_spring_board'),
      enableVibration: false,
      //silent: true,
      autoCancel: false,
      //setAsGroupSummary: true, //kinda grouped somehow
      //groupAlertBehavior: GroupAlertBehavior.all,
      largeIcon: const DrawableResourceAndroidBitmap('icon'),
      actions: const [
        /*
        AndroidNotificationAction(actionDelete, 'remove',
            showsUserInterface: true),
        */
        AndroidNotificationAction(actionResume, 'continue',
            showsUserInterface: true),
      ],
      //styleInformation: BigPictureStyleInformation(
      //  FilePathAndroidBitmap(bigPicture),
      //  hideExpandedLargeIcon: false,
      //),
      //color: Color(0xff2196f3),
    );

    DarwinNotificationDetails iosNotificationDetails =
        const DarwinNotificationDetails(
            threadIdentifier: "thread1",
            attachments: <DarwinNotificationAttachment>[
          //DarwinNotificationAttachment(bigPicture)
        ]);

    final NotificationAppLaunchDetails? details =
        await _localNotifications.getNotificationAppLaunchDetails();
    if (details != null && details.didNotificationLaunchApp) {
      behaviorSubject.add(details.notificationResponse!.payload!);
    }
    NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics, iOS: iosNotificationDetails);

    return platformChannelSpecifics;
  }
}
