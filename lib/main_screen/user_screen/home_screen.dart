import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:resarch_csv/auth_screen/login.dart';
import 'package:resarch_csv/main.dart';
import 'package:resarch_csv/main_screen/user_screen/video/play_video_intro_screen.dart';
import 'package:resarch_csv/main_screen/user_screen/video/play_video_outro_screen.dart';
import 'package:resarch_csv/main_screen/user_screen/week/week_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class home_screen extends StatefulWidget {
  @override
  _home_screen createState() => _home_screen();
}

class _home_screen extends State<home_screen> with RouteAware {
  var doneWeek;
  bool showLoader = false;
  bool check = false;

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
    super.didChangeDependencies();
  }

  @override
  void didPopNext() {
    updateDayAndWeek();
  }

  getUserData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      check = pref.get('user_id') != null ? true : false;
    });
    if (pref.get('user_id') != null) {
      updateDayAndWeek();
    } else {}
  }

  updateDayAndWeek() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    FirebaseFirestore.instance
        .collection('user')
        .where('id', isEqualTo: pref.getString('user_id'))
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        if (doc != null) {
          Map<String, dynamic>? documentData =
              doc.data() as Map<String, dynamic>?; //if it is a single document

          print('user Update');
          print(documentData.toString());

          pref.setString('user_id', documentData!['id']);
          pref.setString('user_type', documentData['user_type']);

          if (DateFormat('yyyy-dd-MM')
                  .format(DateTime.now())
                  .compareTo(documentData['done_date']) !=
              0) {
            FirebaseFirestore.instance
                .collection('user')
                .doc(documentData['id'])
                .update({
              'done_date':
                  DateFormat('yyyy-dd-MM').format(DateTime.now()).toString(),
              'done_week':
                  '${documentData['done_week'] == '6' ? '6' : documentData['done_day'] == '4' ? int.parse(documentData['done_week']) + 1 : int.parse(documentData['done_week'])}',
              'done_day':
                  '${documentData['done_week'] == '0' || documentData['done_day'] == '4' ? '0' : int.parse(documentData['done_day']) + 1}',
              'achievement':
                  '${documentData['done_week'] == '0' || documentData['done_day'] == '4' ? int.parse(documentData['achievement']) + 1 : int.parse(documentData['achievement'])}',
            }).whenComplete(() {
              setState(() {
                showLoader = false;
              });
            });
          }
        } else {
          setState(() {
            showLoader = false;
          });
        }
      });
    }).whenComplete(() {
      FirebaseFirestore.instance
          .collection('user')
          .where('id', isEqualTo: pref.getString('user_id'))
          .get()
          .then((QuerySnapshot querySnapshot) => {
                querySnapshot.docs.forEach((doc) {
                  if (doc != null) {
                    Map<String, dynamic>? documentData = doc.data()
                        as Map<String, dynamic>?; //if it is a single document
                    print('documentData.toString()');
                    print(documentData.toString());

                    setState(() {
                      doneWeek = int.parse(documentData!['done_week']);
                      showLoader = false;
                    });
                  } else {
                    setState(() {
                      showLoader = false;
                    });
                  }
                }),
              });
    });
  }

  bool checkRestaurentStatus(String openTime, String closedTime) {
    TimeOfDay timeNow = TimeOfDay.now();
    String openHr = openTime.substring(0, 2);
    String openMin = openTime.substring(3, 5);
    String openAmPm = openTime.substring(5);
    TimeOfDay timeOpen;
    if (openAmPm == "AM") {
      //am case
      if (openHr == "12") {
        //if 12AM then time is 00
        timeOpen = TimeOfDay(hour: 00, minute: int.parse(openMin));
      } else {
        timeOpen =
            TimeOfDay(hour: int.parse(openHr), minute: int.parse(openMin));
      }
    } else {
      //pm case
      if (openHr == "12") {
//if 12PM means as it is
        timeOpen =
            TimeOfDay(hour: int.parse(openHr), minute: int.parse(openMin));
      } else {
//add +12 to conv time to 24hr format
        timeOpen =
            TimeOfDay(hour: int.parse(openHr) + 12, minute: int.parse(openMin));
      }
    }

    String closeHr = closedTime.substring(0, 2);
    String closeMin = closedTime.substring(3, 5);
    String closeAmPm = closedTime.substring(5);

    TimeOfDay timeClose;

    if (closeAmPm == "AM") {
      //am case
      if (closeHr == "12") {
        timeClose = TimeOfDay(hour: 0, minute: int.parse(closeMin));
      } else {
        timeClose =
            TimeOfDay(hour: int.parse(closeHr), minute: int.parse(closeMin));
      }
    } else {
      //pm case
      if (closeHr == "12") {
        timeClose =
            TimeOfDay(hour: int.parse(closeHr), minute: int.parse(closeMin));
      } else {
        timeClose = TimeOfDay(
            hour: int.parse(closeHr) + 12, minute: int.parse(closeMin));
      }
    }

    int nowInMinutes = timeNow.hour * 60 + timeNow.minute;
    int openTimeInMinutes = timeOpen.hour * 60 + timeOpen.minute;
    int closeTimeInMinutes = timeClose.hour * 60 + timeClose.minute;

//handling day change ie pm to am
    if ((closeTimeInMinutes - openTimeInMinutes) < 0) {
      closeTimeInMinutes = closeTimeInMinutes + 1440;
      if (nowInMinutes >= 0 && nowInMinutes < openTimeInMinutes) {
        nowInMinutes = nowInMinutes + 1440;
      }
      if (openTimeInMinutes < nowInMinutes &&
          nowInMinutes < closeTimeInMinutes) {
        return true;
      }
    } else if (openTimeInMinutes < nowInMinutes &&
        nowInMinutes < closeTimeInMinutes) {
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding:
            const EdgeInsets.only(left: 15, right: 15, bottom: 15, top: 35),
        child: Column(
          children: <Widget>[
            check
                ? const Text(
                    'Home Page',
                    style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Color(0xff744EC3),
                        fontSize: 40,
                        fontFamily: 'GoudyBookletterRegular',
                        fontWeight: FontWeight.w400),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      SizedBox(
                        width: 30,
                      ),
                      const Text(
                        'Home Page',
                        style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Color(0xff744EC3),
                            fontSize: 40,
                            fontFamily: 'GoudyBookletterRegular',
                            fontWeight: FontWeight.w400),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => login(),
                              ),
                              (route) => false);
                        },
                        child: const Text(
                          'Login',
                          style: TextStyle(
                              decoration: TextDecoration.underline,
                              color: Color(0xff744EC3),
                              fontSize: 25,
                              fontFamily: 'GoudyBookletterRegular',
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                    ],
                  ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: 20),
                children: <Widget>[
                  Card(
                    color: const Color(0xffF8EEF9),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32.0),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(32.0),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => play_video_intro_screen(
                              title: 'Intro',
                              week: 0,
                            ),
                          ),
                        );
                      },
                      child: Row(
                        children: <Widget>[
                          const Expanded(
                            child: SizedBox(
                              height: 60,
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: 30, top: 10, bottom: 10),
                                child: Text(
                                  'Intro',
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 33,
                                      fontFamily: 'Anaheim'),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 50,
                            color: const Color(0xffB993BC),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 15, right: 15),
                            child: doneWeek != null && doneWeek > 0
                                ? Image.asset(
                                    'assets/icons/right.png',
                                    height: 35,
                                    width: 35,
                                  )
                                : Image.asset(
                                    'assets/icons/next_arrow.png',
                                    height: 35,
                                    width: 35,
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Card(
                    color: const Color(0xffF8EEF9),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32.0),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(32.0),
                      onTap: doneWeek != null && doneWeek >= 1
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => week_screen(
                                    title: 'Week One',
                                    week: 1,
                                  ),
                                ),
                              );
                            }
                          : () {
                              Fluttertoast.showToast(
                                  msg: 'First Complete Previous Step',
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 3,
                                  backgroundColor: Color(0xffC299F6),
                                  textColor: Colors.white);
                            },
                      child: Row(
                        children: <Widget>[
                          const Expanded(
                            child: SizedBox(
                              height: 60,
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: 30, top: 10, bottom: 10),
                                child: Text(
                                  'Week One',
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 33,
                                      fontFamily: 'Anaheim'),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 50,
                            color: const Color(0xffB993BC),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 15, right: 15),
                            child: doneWeek != null && doneWeek == 1
                                ? Image.asset(
                                    'assets/icons/next_arrow.png',
                                    height: 35,
                                    width: 35,
                                  )
                                : doneWeek != null && doneWeek > 1
                                    ? Image.asset(
                                        'assets/icons/right.png',
                                        height: 35,
                                        width: 35,
                                      )
                                    : Image.asset(
                                        'assets/icons/lock.png',
                                        height: 35,
                                        width: 35,
                                      ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Card(
                    color: const Color(0xffF8EEF9),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32.0),
                    ),
                    child: InkWell(
                      onTap: doneWeek != null && doneWeek >= 2
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => week_screen(
                                    title: 'Week Two',
                                    week: 2,
                                  ),
                                ),
                              );
                            }
                          : () {
                              Fluttertoast.showToast(
                                  msg: 'First Complete Previous Step',
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 3,
                                  backgroundColor: Color(0xffC299F6),
                                  textColor: Colors.white);
                            },
                      borderRadius: BorderRadius.circular(32.0),
                      child: Row(
                        children: <Widget>[
                          const Expanded(
                            child: SizedBox(
                              height: 60,
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: 30, top: 10, bottom: 10),
                                child: Text(
                                  'Week Two',
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 33,
                                      fontFamily: 'Anaheim'),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 50,
                            color: Color(0xffB993BC),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 15, right: 15),
                            child: doneWeek != null && doneWeek == 2
                                ? Image.asset(
                                    'assets/icons/next_arrow.png',
                                    height: 35,
                                    width: 35,
                                  )
                                : doneWeek != null && doneWeek > 2
                                    ? Image.asset(
                                        'assets/icons/right.png',
                                        height: 35,
                                        width: 35,
                                      )
                                    : Image.asset(
                                        'assets/icons/lock.png',
                                        height: 35,
                                        width: 35,
                                      ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Card(
                    color: const Color(0xffF8EEF9),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32.0),
                    ),
                    child: InkWell(
                      onTap: doneWeek != null && doneWeek >= 3
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => week_screen(
                                    title: 'Week Three',
                                    week: 3,
                                  ),
                                ),
                              );
                            }
                          : () {
                              Fluttertoast.showToast(
                                  msg: 'First Complete Previous Step',
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 3,
                                  backgroundColor: Color(0xffC299F6),
                                  textColor: Colors.white);
                            },
                      borderRadius: BorderRadius.circular(32.0),
                      child: Row(
                        children: <Widget>[
                          const Expanded(
                            child: SizedBox(
                              height: 60,
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: 30, top: 10, bottom: 10),
                                child: Text(
                                  'Week Three',
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 33,
                                      fontFamily: 'Anaheim'),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 50,
                            color: const Color(0xffB993BC),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 15, right: 15),
                            child: doneWeek != null && doneWeek == 3
                                ? Image.asset(
                                    'assets/icons/next_arrow.png',
                                    height: 35,
                                    width: 35,
                                  )
                                : doneWeek != null && doneWeek > 3
                                    ? Image.asset(
                                        'assets/icons/right.png',
                                        height: 35,
                                        width: 35,
                                      )
                                    : Image.asset(
                                        'assets/icons/lock.png',
                                        height: 35,
                                        width: 35,
                                      ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Card(
                    color: const Color(0xffF8EEF9),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32.0),
                    ),
                    child: InkWell(
                      onTap: doneWeek != null && doneWeek >= 4
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => week_screen(
                                    title: 'Week Four',
                                    week: 4,
                                  ),
                                ),
                              );
                            }
                          : () {
                              Fluttertoast.showToast(
                                  msg: 'First Complete Previous Step',
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 3,
                                  backgroundColor: Color(0xffC299F6),
                                  textColor: Colors.white);
                            },
                      borderRadius: BorderRadius.circular(32.0),
                      child: Row(
                        children: <Widget>[
                          const Expanded(
                            child: SizedBox(
                              height: 60,
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: 30, top: 10, bottom: 10),
                                child: Text(
                                  'Week Four',
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 33,
                                      fontFamily: 'Anaheim'),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 50,
                            color: Color(0xffB993BC),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 15, right: 15),
                            child: doneWeek != null && doneWeek == 4
                                ? Image.asset(
                                    'assets/icons/next_arrow.png',
                                    height: 35,
                                    width: 35,
                                  )
                                : doneWeek != null && doneWeek > 4
                                    ? Image.asset(
                                        'assets/icons/right.png',
                                        height: 35,
                                        width: 35,
                                      )
                                    : Image.asset(
                                        'assets/icons/lock.png',
                                        height: 35,
                                        width: 35,
                                      ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Card(
                    color: const Color(0xffF8EEF9),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32.0),
                    ),
                    child: InkWell(
                      onTap: doneWeek != null && doneWeek >= 5
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => week_screen(
                                    title: 'Week Four',
                                    week: 5,
                                  ),
                                ),
                              );
                            }
                          : () {
                              Fluttertoast.showToast(
                                  msg: 'First Complete Previous Step',
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 3,
                                  backgroundColor: Color(0xffC299F6),
                                  textColor: Colors.white);
                            },
                      borderRadius: BorderRadius.circular(32.0),
                      child: Row(
                        children: <Widget>[
                          const Expanded(
                            child: SizedBox(
                              height: 60,
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: 30, top: 10, bottom: 10),
                                child: Text(
                                  'Week Five',
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 33,
                                      fontFamily: 'Anaheim'),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 50,
                            color: Color(0xffB993BC),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 15, right: 15),
                            child: doneWeek != null && doneWeek == 5
                                ? Image.asset(
                                    'assets/icons/next_arrow.png',
                                    height: 35,
                                    width: 35,
                                  )
                                : doneWeek != null && doneWeek > 5
                                    ? Image.asset(
                                        'assets/icons/right.png',
                                        height: 35,
                                        width: 35,
                                      )
                                    : Image.asset(
                                        'assets/icons/lock.png',
                                        height: 35,
                                        width: 35,
                                      ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Card(
                    color: const Color(0xffF8EEF9),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32.0),
                    ),
                    child: InkWell(
                      onTap: doneWeek != null && doneWeek >= 6
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => week_screen(
                                    title: 'Week Six',
                                    week: 6,
                                  ),
                                ),
                              );
                            }
                          : () {
                              Fluttertoast.showToast(
                                  msg: 'First Complete Previous Step',
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 3,
                                  backgroundColor: Color(0xffC299F6),
                                  textColor: Colors.white);
                            },
                      borderRadius: BorderRadius.circular(32.0),
                      child: Row(
                        children: <Widget>[
                          const Expanded(
                            child: SizedBox(
                              height: 60,
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: 30, top: 10, bottom: 10),
                                child: Text(
                                  'Week Six',
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 33,
                                      fontFamily: 'Anaheim'),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 50,
                            color: Color(0xffB993BC),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 15, right: 15),
                            child: doneWeek != null && doneWeek == 6
                                ? Image.asset(
                                    'assets/icons/next_arrow.png',
                                    height: 35,
                                    width: 35,
                                  )
                                : doneWeek != null && doneWeek > 6
                                    ? Image.asset(
                                        'assets/icons/right.png',
                                        height: 35,
                                        width: 35,
                                      )
                                    : Image.asset(
                                        'assets/icons/lock.png',
                                        height: 35,
                                        width: 35,
                                      ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Card(
                    color: const Color(0xffF8EEF9),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32.0),
                    ),
                    child: InkWell(
                      onTap: doneWeek != null && doneWeek >= 7
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => play_video_outro_screen(
                                    title: 'Outro',
                                    week: 7,
                                  ),
                                ),
                              );
                            }
                          : () {
                              Fluttertoast.showToast(
                                  msg: 'First Complete Previous Step',
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 3,
                                  backgroundColor: Color(0xffC299F6),
                                  textColor: Colors.white);
                            },
                      borderRadius: BorderRadius.circular(32.0),
                      child: Row(
                        children: <Widget>[
                          const Expanded(
                            child: SizedBox(
                              height: 60,
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: 30, top: 10, bottom: 10),
                                child: Text(
                                  'Outro',
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 33,
                                      fontFamily: 'Anaheim'),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 50,
                            color: Color(0xffB993BC),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 15, right: 15),
                            child: doneWeek != null && doneWeek == 7
                                ? Image.asset(
                                    'assets/icons/next_arrow.png',
                                    height: 35,
                                    width: 35,
                                  )
                                : doneWeek != null && doneWeek > 7
                                    ? Image.asset(
                                        'assets/icons/right.png',
                                        height: 35,
                                        width: 35,
                                      )
                                    : Image.asset(
                                        'assets/icons/lock.png',
                                        height: 35,
                                        width: 35,
                                      ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
