import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:resarch_csv/auth_screen/login.dart';
import 'package:resarch_csv/bottom_shet/bottom_navigation.dart';
import 'package:resarch_csv/main.dart';
import 'package:resarch_csv/main_screen/admin_screen/admin_home_screen.dart';
import 'package:resarch_csv/main_screen/super_admin_screen/super_admin_home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class splash_screen extends StatefulWidget {
  @override
  _splash_screen createState() => _splash_screen();
}

class _splash_screen extends State<splash_screen> with WidgetsBindingObserver {
  @override
  void initState() {
    // LocalNotification().requestPermissions();
    // LocalNotification().configureDidReceiveLocalNotificationSubject(context);
    // LocalNotification().configureSelectNotificationSubject();
    startTimer();
    WidgetsBinding.instance!.addObserver(this);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print("DidChangeDependencies");
  }

  @override
  void setState(fn) {
    print("SetState");
    super.setState(fn);
  }

  @override
  void deactivate() {
    print("Deactivate");
    super.deactivate();
  }

  @override
  void dispose() {
    print("Dispose");
    super.dispose();
    selectNotificationSubject.close();
    // didReceiveLocalNotificationSubject.close();
    WidgetsBinding.instance!.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.inactive:
        print('appLifeCycleState inactive');
        break;
      case AppLifecycleState.resumed:
        print('appLifeCycleState resumed');
        break;
      case AppLifecycleState.paused:
        print('appLifeCycleState paused');
        break;
      case AppLifecycleState.detached:
        print('appLifeCycleState detached');
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  void startTimer() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    bool check = pref.get('user_id') != null ? true : false;
    var userType = pref.get('user_type');

    print('user_type');
    print(pref.get('user_type'));

    Timer(
      const Duration(seconds: 5),
      () => Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => check
                ? userType == '0'
                    ? bottom_navigation()
                    : userType == '1'
                        ? super_admin_home_screen()
                        : admin_home_screen()
                : login(),
          ),
          (route) => false),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F4F5),
      body: Center(
        child: Image.asset('assets/images/login_image.png'),
      ),
    );
  }
}
