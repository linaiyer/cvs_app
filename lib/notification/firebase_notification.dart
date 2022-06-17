// import 'dart:io';
//
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:resarch_csv/notification/push_notification_handler.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../main.dart';
//
// class FirebaseNotifications extends ChangeNotifier {
//   final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
//
//   void firebaseInitialization() {
//     _firebaseMessaging.getToken().then((token) {
//       setToken(token);
//     });
//     FirebaseMessaging.instance.getInitialMessage().then((message) {
//       if (message != null) {
//         notificationClick(message);
//       }
//     });
//     FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       print('OnMessage ${message.data}');
//       notificationDialogManage(message);
//     });
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       notificationClick(message);
//     });
//   }
//
//   Future setToken(token) async {
//     if (token == null) {
//     } else {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       prefs.setString('fcm_token', token.toString());
//     }
//   }
//
//   Future<void> notificationDialogManage(RemoteMessage message) async {
//     print('message get or not yet');
//     var title = message.notification!.title;
//     var body = message.notification!.body;
//     print('message ${message}');
//     print('message ${message.data['action_type']}');
//     // String type = "${message.data["type"]},${message.data["reference_id"]}";
//     if (Platform.isAndroid) {
//       // if (message.data['action_type'] == 'message') {
//       //   LocalNotification().showNotification(title!, message, body!, 0);
//       // } else if (message.data['action_type'] == 'comment') {
//       //   LocalNotification().showNotification(title!, message, body!, 0);
//       // } else if (message.data['action_type'] == 'unReveal') {
//       //   LocalNotification().showNotification(title!, message, body!, 0);
//       // } else if (message.data['action_type'] == 'normal') {
//       //   LocalNotification().showNotification(title!, message, body!, 0);
//       // } else if (message.data['action_type'] == 'Reveal') {
//       //   showDialog(
//       //     context: navigatorKey.currentContext!,
//       //     builder: (context) {
//       //       return WillPopScope(
//       //         onWillPop: null,
//       //         child: FriendBlockUnBlock(
//       //           message: message,
//       //         ),
//       //       );
//       //     },
//       //   );
//       // } else {
//       LocalNotification().showNotification(title!, message, body!, 0);
//       // }
//     }
//
//     if (Platform.isIOS) {
//       print('notification get');
//       // LocalNotification().showNotification(title!, message, body!, 0);
//       showDialog(
//         context: navigatorKey.currentContext!,
//         builder: (BuildContext context) => CupertinoAlertDialog(
//           title: Text(title!),
//           content: Text(body!),
//           actions: <Widget>[
//             CupertinoDialogAction(
//               isDefaultAction: true,
//               onPressed: () {
//                 // notificationClickIos(message);
//               },
//               child: const Text('Ok'),
//             )
//           ],
//         ),
//       );
//     }
//   }
// }
//
// Future<void> notificationClick(var payload) async {
//   // String _notificationType = payload.substring(0, payload.indexOf(","));
// String? _refrenceId;
//
//   SharedPreferences pref = await SharedPreferences.getInstance();
//   print('screen');
//   print(pref.getString('screen'));
//   switch (payload.data['action_type']) {
//     case "friend":
//       Navigator.push(
//         navigatorKey.currentContext!,
//         MaterialPageRoute(
//           builder: (context) => tabsPage(index: 1),
//         ),
//       );
//       break;
//     case "message":
//       if (pref.getString('screen') != null &&
//           pref.getString('screen') != 'chat') {
//         Navigator.push(
//           navigatorKey.currentContext!,
//           MaterialPageRoute(
//             builder: (context) => chat(
//               peerId: payload.data['sender_id'],
//               peerAvatar: '',
//             ),
//           ),
//         );
//       }
//       break;
//     case "comment":
//       Navigator.push(
//         navigatorKey.currentContext!,
//         MaterialPageRoute(
//           builder: (context) => tabsPage(index: 0),
//         ),
//       );
//       break;
//     case "Reveal":
//       Navigator.push(
//         navigatorKey.currentContext!,
//         MaterialPageRoute(
//           builder: (context) => chat(
//             peerId: payload.data['sender_id'],
//             peerAvatar: '',
//           ),
//         ),
//       );
//       showDialog(
//         context: navigatorKey.currentContext!,
//         builder: (context) {
//           return WillPopScope(
//             onWillPop: null,
//             child: FriendBlockUnBlock(
//               message: payload,
//             ),
//           );
//         },
//       );
//       break;
//     case "normal":
//       Navigator.push(
//         navigatorKey.currentContext!,
//         MaterialPageRoute(
//           builder: (context) => tabsPage(index: 1),
//         ),
//       );
//       break;
//   }
//
//
// }
