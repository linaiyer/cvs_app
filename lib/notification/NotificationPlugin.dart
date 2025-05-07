import 'dart:io' show File, Platform;

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications_plus/flutter_local_notifications_plus.dart';
import 'package:rxdart/subjects.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationPlugin {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final BehaviorSubject<ReceivedNotification>
      didReceivedLocalNotificationSubject =
      BehaviorSubject<ReceivedNotification>();
  var initializationSettings;

  static const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  init() async {
    if (Platform.isIOS) {
      _requestIOSPermission();
    }
    initializePlatformSpecifics();
  }

  initializePlatformSpecifics() {
    var initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: false,
      onDidReceiveLocalNotification: (id, title, body, payload) async {
        ReceivedNotification receivedNotification = ReceivedNotification(
            id: id, title: title!, body: body!, payload: payload!);
        didReceivedLocalNotificationSubject.add(receivedNotification);
      },
    );
    initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    // showDailyAtTime();
  }

  _requestIOSPermission() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()!
        .requestPermissions(
          alert: false,
          badge: true,
          sound: true,
        );
  }

  setListenerForLowerVersions(Function onNotificationInLowerVersions) {
    didReceivedLocalNotificationSubject.listen((receivedNotification) {
      onNotificationInLowerVersions(receivedNotification);
    });
  }

  setOnNotificationClick(Function onNotificationClick) async {
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (details) {
      onNotificationClick(details);
    });
  }

  Future<void> showNotification() async {
    var androidChannelSpecifics = AndroidNotificationDetails(
      'CHANNEL_ID',
      'CHANNEL_NAME',
      channelDescription: "CHANNEL_DESCRIPTION",
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      timeoutAfter: 5000,
      styleInformation: DefaultStyleInformation(true, true),
    );
    var iosChannelSpecifics = DarwinNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        android: androidChannelSpecifics, iOS: iosChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'Test Title',
      'Test Body', //null
      platformChannelSpecifics,
      payload: 'New Payload',
    );
  }

  Future<void> showWeeklyAtDayTime() async {
    var time = TimeOfDay(hour: 21, minute: 5);
    var androidChannelSpecifics = AndroidNotificationDetails(
      'CHANNEL_ID 5',
      'CHANNEL_NAME 5',
      channelDescription: "CHANNEL_DESCRIPTION 5",
      importance: Importance.max,
      priority: Priority.high,
    );
    var iosChannelSpecifics = DarwinNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        android: androidChannelSpecifics, iOS: iosChannelSpecifics);
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Test Title at ${time.hour}:${time.minute}',
      'Test Body',
      _nextInstanceOfWeekdayAndTime(time, Day.saturday),
      platformChannelSpecifics,
      payload: 'Test Payload',
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  tz.TZDateTime _nextInstanceOfWeekdayAndTime(TimeOfDay time, Day day) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, time.hour, time.minute);
    while (scheduledDate.weekday != day.value) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 7));
    }
    return scheduledDate;
  }

  Future<void> repeatNotification() async {
    var androidChannelSpecifics = AndroidNotificationDetails(
      'CHANNEL_ID 3',
      'CHANNEL_NAME 3',
      channelDescription: "CHANNEL_DESCRIPTION 3",
      importance: Importance.max,
      priority: Priority.high,
      styleInformation: DefaultStyleInformation(true, true),
    );
    var iosChannelSpecifics = DarwinNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        android: androidChannelSpecifics, iOS: iosChannelSpecifics);
    await flutterLocalNotificationsPlugin.periodicallyShow(
      0,
      'Repeating Test Title',
      'Repeating Test Body',
      RepeatInterval.everyMinute,
      platformChannelSpecifics,
      payload: 'Test Payload',
    );
  }

  Future<void> scheduleNotification() async {
    var scheduleNotificationDateTime = tz.TZDateTime.now(tz.local).add(Duration(seconds: 5));
    var androidChannelSpecifics = AndroidNotificationDetails(
      'CHANNEL_ID 1',
      'CHANNEL_NAME 1',
      channelDescription: "CHANNEL_DESCRIPTION 1",
      icon: 'secondary_icon',
      sound: RawResourceAndroidNotificationSound('my_sound'),
      largeIcon: DrawableResourceAndroidBitmap('large_notf_icon'),
      enableLights: true,
      color: const Color.fromARGB(255, 255, 0, 0),
      ledColor: const Color.fromARGB(255, 255, 0, 0),
      ledOnMs: 1000,
      ledOffMs: 500,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      timeoutAfter: 5000,
      styleInformation: DefaultStyleInformation(true, true),
    );
    var iosChannelSpecifics = DarwinNotificationDetails(
      sound: 'my_sound.aiff',
    );
    var platformChannelSpecifics = NotificationDetails(
      android: androidChannelSpecifics,
      iOS: iosChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Test Title',
      'Test Body',
      scheduleNotificationDateTime,
      platformChannelSpecifics,
      payload: 'Test Payload',
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<int> getPendingNotificationCount() async {
    List<PendingNotificationRequest> p =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    return p.length;
  }

  Future<void> cancelNotification() async {
    await flutterLocalNotificationsPlugin.cancel(0);
  }

  Future<void> cancelAllNotification() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}

class ReceivedNotification {
  final int id;
  final String title;
  final String body;
  final String payload;

  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });
}
