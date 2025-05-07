import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications_plus/flutter_local_notifications_plus.dart';
import 'package:timezone/timezone.dart' as tz;

import '../main.dart';
import 'NotificationPlugin.dart';
//
// class ReceivedNotification {
//   ReceivedNotification({
//     required this.id,
//     required this.title,
//     required this.body,
//     required this.payload,
//   });
//
//   final int id;
//   final String title;
//   final String body;
//   final String payload;
// }

class LocalNotification {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  static final DarwinInitializationSettings initializationSettingsIOS =
  DarwinInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: true,
    onDidReceiveLocalNotification: (
      int id,
      String? title,
      String? body,
      String? payload,
    ) =>
        didReceiveLocalNotificationSubject.add(
      ReceivedNotification(
        id: id,
        title: title!,
        body: body!,
        payload: payload!,
      ),
    ),
  );

  static const DarwinInitializationSettings initializationSettingsMacOS =
      DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false);

  final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: initializationSettingsMacOS);

  initialize() async {
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (payload) async {
      selectedNotificationPayload = payload.toString();
      selectNotificationSubject.add(payload.toString());
    });
    // repeatNotification();
  }

  Future<void> showDailyAtTime() async {
    print('timer start');
    var time = TimeOfDay(hour: 8, minute: 0);
    var androidChannelSpecifics = AndroidNotificationDetails(
      'CHANNEL_ID 4',
      'CHANNEL_NAME 4',
      channelDescription: "CHANNEL_DESCRIPTION 4",
      importance: Importance.max,
      priority: Priority.high,
    );
    var iosChannelSpecifics = DarwinNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        android: androidChannelSpecifics, iOS: iosChannelSpecifics);
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'HFNMeditate App Reminder',
      'Have you logged into practice HFNMeditate App today?',
      _nextInstanceOfTime(time.hour, time.minute),
      platformChannelSpecifics,
      payload: 'Test Payload',
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  void requestPermissions() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  void configureDidReceiveLocalNotificationSubject(context) {
    didReceiveLocalNotificationSubject.stream
        .listen((ReceivedNotification receivedNotification) async {
      await showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: receivedNotification.title != null
              ? Text(receivedNotification.title)
              : null,
          content: receivedNotification.body != null
              ? Text(receivedNotification.body)
              : null,
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () async {},
              child: const Text('Ok'),
            )
          ],
        ),
      );
    });
  }

  void configureSelectNotificationSubject() {
    selectNotificationSubject.stream.listen((String? payload) async {
      // await Navigator.pushNamed(context, '/secondPage');
    });
  }

  tz.TZDateTime _nextInstanceOfTenAM() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, 14, 45);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  Future<void> zonedScheduleNotification() async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'scheduled title',
        'scheduled body',
        tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
        const NotificationDetails(
            android: AndroidNotificationDetails(
                'your channel id', 'your channel name',
                channelDescription: 'your channel description')),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
  }

  Future<void> repeatNotification() async {
    print('start repeatNotification');
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
            'repeating channel id', 'repeating channel name',
            channelDescription: 'repeating description');
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.periodicallyShow(0, 'repeating title',
        'repeating body', RepeatInterval.everyMinute, platformChannelSpecifics,
        androidAllowWhileIdle: false);
  }

  Future<void> scheduleDailyTenAMNotification() async {
    print('sout');
    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'daily scheduled notification title',
        'daily scheduled notification body',
        _nextInstanceOfTenAM(),
        const NotificationDetails(
          android: AndroidNotificationDetails('daily notification channel id',
              'daily notification channel name',
              channelDescription: 'daily notification description'),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time);
  }

  // Future<void> zonedScheduleNotification() async {
  //   await flutterLocalNotificationsPlugin.zonedSchedule(
  //     0,
  //     'scheduled title',
  //     'scheduled body',
  //     tz.TZDateTime.now(tz.local).add(
  //       const Duration(seconds: 5),
  //     ),
  //     const NotificationDetails(
  //       android: AndroidNotificationDetails(
  //         'id',
  //         'name',
  //         importance: Importance.max,
  //         priority: Priority.high,
  //         icon: '@drawable/logo',
  //         playSound: true,
  //       ),
  //     ),
  //     androidAllowWhileIdle: true,
  //     uiLocalNotificationDateInterpretation:
  //         UILocalNotificationDateInterpretation.absoluteTime,
  //   );
  // }

  // Future<void> repeatNotification() async {
  //   const AndroidNotificationDetails androidPlatformChannelSpecifics =
  //       AndroidNotificationDetails(
  //           'repeating channel id', 'repeating channel name',
  //           importance: Importance.max,
  //           priority: Priority.high,
  //           icon: '@drawable/logo',
  //           channelDescription: 'repeating description');
  //   const NotificationDetails platformChannelSpecifics =
  //       NotificationDetails(android: androidPlatformChannelSpecifics);
  //   await flutterLocalNotificationsPlugin.periodicallyShow(
  //     0,
  //     'repeating title',
  //     'repeating body',
  //     RepeatInterval.everyMinute,
  //     platformChannelSpecifics,
  //     androidAllowWhileIdle: true,
  //   );
  // }
// Future<void> scheduleDailyTenAMNotification() async {
//   await flutterLocalNotificationsPlugin.zonedSchedule(
//     0,
//     'daily scheduled notification title',
//     'daily scheduled notification body',
//     _nextInstanceOfTenAM(),
//     const NotificationDetails(
//       android: AndroidNotificationDetails(
//         'daily notification channel id',
//         'daily notification channel name',
//         channelDescription: 'daily notification description',
//       ),
//     ),
//     androidAllowWhileIdle: true,
//     uiLocalNotificationDateInterpretation:
//         UILocalNotificationDateInterpretation.absoluteTime,
//     matchDateTimeComponents: DateTimeComponents.time,
//   );
// }

}
