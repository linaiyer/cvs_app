import 'dart:async';
import 'dart:io';

// import 'dart:ui';

import 'package:bot_toast/bot_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications_plus/flutter_local_notifications_plus.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:resarch_csv/auth_screen/splash_screen.dart';
import 'package:resarch_csv/notification/NotificationPlugin.dart';
import 'package:resarch_csv/notification/push_notification_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';
import 'package:shared_preferences/shared_preferences.dart';

RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

final navigatorKey = GlobalKey<NavigatorState>();

final BehaviorSubject<String> selectNotificationSubject =
    BehaviorSubject<String>();

final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject =
    BehaviorSubject<ReceivedNotification>();

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

String? selectedNotificationPayload;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize timezone
  tz.initializeTimeZones();
  
  // Set local timezone
  String timeZoneName = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZoneName));
  
  LocalNotification().initialize();

  HttpOverrides.global = MyHttpOverrides();
  await Firebase.initializeApp();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(MyApp());
  });
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  Stopwatch watch = Stopwatch();
  Timer? timer;
  bool startStop = true;
  String elapsedTime = '';
  var userData;
  final DateFormat formatter = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    WidgetsBinding.instance!.addObserver(this);

    // startWatch();
    super.initState();
  }

  updateTime(Timer timer) {
    elapsedTime = transformMilliSeconds(watch.elapsedMilliseconds);
  }

  startWatch() async {
    setState(() {
      watch.reset();
      watch.start();
    });

    timer = Timer.periodic(Duration(milliseconds: 100), updateTime);
    // print('timer${timer!.tick}');
  }

  stopWatch() {
    setState(() {
      watch.stop();
      setTime();
    });
  }

  setTime() {
    var timeSoFar = watch.elapsedMilliseconds;
    setState(() {
      elapsedTime = transformMilliSeconds(timeSoFar);
    });
    updateDataInTable(elapsedTime);
    timer!.cancel();
  }

  transformMilliSeconds(int milliseconds) {
    int hundreds = (milliseconds / 10).truncate();
    int seconds = (hundreds / 100).truncate();
    int minutes = (seconds / 60).truncate();
    int hours = (minutes / 60).truncate();

    String hoursStr = (hours % 60).toString().padLeft(2, '0');
    String minutesStr = (minutes % 60).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');

    return "$hoursStr:$minutesStr:$secondsStr";
  }

  updateDataInTable(time) async {
    var param, curDay, curWeek;
    SharedPreferences pref = await SharedPreferences.getInstance();

    await FirebaseFirestore.instance
        .collection('user')
        .where('id', isEqualTo: pref.getString('user_id'))
        .where('user_type', isEqualTo: '0')
        .get()
        .then((QuerySnapshot querySnapshot) => {
              querySnapshot.docs.forEach((doc) {
                if (doc != null) {
                  Map<String, dynamic>? documentData = doc.data()
                      as Map<String, dynamic>?; //if it is a single document
                  // print('User Data');
                  // print(documentData.toString());

                  setState(() {
                    userData = documentData;
                  });
                  curWeek = (documentData!['start_date'].difference(DateTime.now()).inDays) / 7;
                  curDay = (documentData!['start_date'].difference(DateTime.now()).inDays) % 7;
                  param = 'W${curWeek + 1} D${curDay + 1}';
                }
              }),
            });

    // print('time $time');
    // print('param $param time');
    if (param != null && param != '') {
      FirebaseFirestore.instance
          .collection('watchDataTable')
          .where('user_id', isEqualTo: pref.getString('user_id'))
          .get()
          .then((QuerySnapshot query) {
        query.docs.forEach((element) {
          if (element != null) {
            Map<String, dynamic>? documentData =
                element.data() as Map<String, dynamic>?;
            if (documentData!['$param time'] != '') {
              time = parseDuration(time) +
                  parseDuration(
                      '${documentData['$param time'].substring(0, 1)}:${documentData['$param time'].substring(6, 8)}:${documentData['$param time'].substring(14, 16)}');
            } else {
              time = parseDuration(time);
            }
            FirebaseFirestore.instance
                .collection('watchDataTable')
                .doc(query.docs[0]['id'])
                .update({
              // 1:02:48
              "$param time":
                  '${time.toString().substring(0, 1)} Hr, ${time.toString().substring(2, 4)} Min, ${time.toString().substring(6, 7)} Sec',
              "$param date": formatter.format(DateTime.now()).toString()
            });
          }
        });
      });
    }
  }

  Duration parseDuration(String s) {
    int hours = 0;
    int minutes = 0;
    int micros;
    List<String> parts = s.split(':');
    if (parts.length > 2) {
      hours = int.parse(parts[parts.length - 3]);
    }
    if (parts.length > 1) {
      minutes = int.parse(parts[parts.length - 2]);
    }
    micros = (double.parse(parts[parts.length - 1]) * 1000000).round();
    return Duration(hours: hours, minutes: minutes, microseconds: micros);
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
        // startWatch();
        break;
      case AppLifecycleState.paused:
        print('appLifeCycleState paused');
        // stopWatch();
        break;
      case AppLifecycleState.detached:
        print('appLifeCycleState detached');
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final botToastBuilder = BotToastInit();
    return MultiProvider(
      providers: [
        StreamProvider(
          create: (_) => Connectivity().onConnectivityChanged,
          initialData: null,
        ),
        ListenableProvider(create: (_) => ValueNotifier<int>(0))
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Research CSV',
        builder: (context, child) {
          // SystemChrome.setPreferredOrientations([
          //   DeviceOrientation.portraitUp,
          //   DeviceOrientation.portraitDown,
          // ]);
          final noInternet = Provider.of<ConnectivityResult?>(context) ==
              ConnectivityResult.none;
          if (noInternet) {
            BotToast.showCustomNotification(
              duration: const Duration(milliseconds: 1500),
              align: Alignment.bottomCenter,
              enableSlideOff: false,
              toastBuilder: (_) => Container(
                margin: const EdgeInsets.symmetric(
                    vertical: 15.0, horizontal: 10.0),
                padding: const EdgeInsets.all(10.0),
                decoration: const BoxDecoration(
                  color: Color(0xffC299F6),
                  borderRadius: BorderRadius.all(
                    Radius.circular(5.0),
                  ),
                ),
                child: const Text(
                  'No internet connection',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 20.0,
                  ),
                ),
              ),
            );
            // Toast.showNoInternetToast(context);
          }
          ;
          return botToastBuilder(context, child!);
        },
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: createMaterialColor(const Color(0xffC299F6)),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        navigatorObservers: [routeObserver],
        home: splash_screen(),
      ),
    );
  }
}

MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  Map swatch = <int, Color>{};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  strengths.forEach((strength) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  });
  return MaterialColor(color.value, swatch as dynamic);
}

class FallbackCupertinoLocalisationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const FallbackCupertinoLocalisationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      DefaultCupertinoLocalizations.load(locale);

  @override
  bool shouldReload(FallbackCupertinoLocalisationsDelegate old) => false;
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
