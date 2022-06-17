import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:resarch_csv/main.dart';
import 'package:resarch_csv/main_screen/user_screen/video/play_video_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class week_screen extends StatefulWidget {
  final title;
  final week;

  const week_screen({Key? key, this.title, this.week}) : super(key: key);

  @override
  _week_screen createState() => _week_screen();
}

class _week_screen extends State<week_screen> with RouteAware {
  var doneDay;

  bool showLoader = false;

  final DateFormat formatter = DateFormat('yyyy-dd-MM');

  @override
  void initState() {
    getDayData();
    super.initState();
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
    getDayData();
  }

  bool checkRestaurentStatus(String openTime, String closedTime) {
    TimeOfDay timeNow = TimeOfDay.now();
    String openHr = openTime.substring(0, 2);
    String openMin = openTime.substring(3, 5);
    String openAmPm = openTime.substring(5);
    print('openAmPm');
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

    if (closeAmPm == "PM") {
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

  bool checkCurrentStatus() {
    TimeOfDay timeNow = TimeOfDay.now();
    String openHr = '12';
    String openMin = '00';
    String openAmPm = 'AM';
    TimeOfDay timeOpen;
    timeOpen = TimeOfDay(hour: int.parse(openHr), minute: int.parse(openMin));

    String closeHr = DateTime.now().hour.toString();
    String closeMin = DateTime.now().minute.toString();
    String closeAmPm = DateFormat.jm().format(DateTime.now()).substring(5);
    TimeOfDay timeClose;

    timeClose =
        TimeOfDay(hour: int.parse(closeHr), minute: int.parse(closeMin));
    if (timeOpen.hour < timeClose.hour) {
      print('done');
      print(timeOpen.hour);
      print(timeClose.hour);
      return true;
    }
    return false;
  }

  getDayData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

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
                  print(documentData!['done_date']);
                  if (int.parse(documentData['done_week']) > widget.week) {
                    setState(() {
                      doneDay = 4;
                      showLoader = false;
                    });
                  } else {
                    // if (documentData['done_date'].trim().isNotEmpty) {
                    //   if (formatter.format(DateTime.now()).compareTo(documentData['done_date']) != 0) {
                    print('DateFormat().add_jm().format(DateTime.now())');
                    print(DateFormat().add_jm().format(DateTime.now()));
                    // checkCurrentStatus();

                    setState(() {
                      doneDay = int.parse(documentData['done_day']);
                      showLoader = false;
                    });
                    // } else {
                    //   setState(() {
                    //     doneDay = int.parse(documentData['done_day']) != 0
                    //         ? int.parse(documentData['done_day'])
                    //         : -1;
                    //     showLoader = false;
                    //   });
                    // }
                    // } else {
                    //   setState(() {
                    //     doneDay = int.parse(documentData['done_day']);
                    //     showLoader = false;
                    //   });
                    // }
                  }
                }
              }),
            });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding:
            const EdgeInsets.only(top: 40, left: 15, right: 15, bottom: 15),
        child: Column(
          children: <Widget>[
            SizedBox(
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Image.asset(
                          'assets/icons/back_arrow.png',
                          height: 30,
                          width: 30,
                        ),
                      ),
                      Text(
                        widget.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            // decoration: TextDecoration.underline,
                            color: Color(0xff744EC3),
                            fontSize: 30,
                            fontFamily: 'Avenir',
                            fontWeight: FontWeight.w400),
                      ),
                      const SizedBox(
                        width: 30,
                      )
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Divider(
                    color: Color(0xff485370),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: 30),
                children: <Widget>[
                  /*0*/
                  Card(
                    color: const Color(0xffF8EEF9),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32.0)),
                    child: InkWell(
                      onTap: doneDay != null && doneDay >= 0
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => play_video_screen(
                                    title: 'Day One',
                                    week: widget.week,
                                    day: 1,
                                  ),
                                ),
                              );
                            }
                          : () {
                              Fluttertoast.showToast(
                                  msg: 'Please wait till 12:00 Am for unlock',
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
                                  'Day One',
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
                            child: doneDay != null && doneDay > 0
                                ? Image.asset(
                                    'assets/icons/right.png',
                                    height: 35,
                                    width: 35,
                                  )
                                : doneDay == -1
                                    ? Image.asset(
                                        'assets/icons/lock.png',
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
                    height: 30,
                  ),
                  /*1*/
                  Card(
                    color: const Color(0xffF8EEF9),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32.0),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(32.0),
                      onTap: doneDay != null && doneDay >= 1
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => play_video_screen(
                                    title: 'Day Two',
                                    week: widget.week,
                                    day: 2,
                                  ),
                                ),
                              );
                            }
                          : () {
                              Fluttertoast.showToast(
                                  msg: 'Please wait till 12:00 Am for unlock',
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
                                  'Day Two',
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
                            child: doneDay != null && doneDay > 1
                                ? Image.asset(
                                    'assets/icons/right.png',
                                    height: 35,
                                    width: 35,
                                  )
                                : doneDay == 1
                                    ? Image.asset(
                                        'assets/icons/next_arrow.png',
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
                    height: 30,
                  ),
                  /*2*/
                  Card(
                    color: const Color(0xffF8EEF9),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32.0),
                    ),
                    child: InkWell(
                      onTap: doneDay != null && doneDay >= 2
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => play_video_screen(
                                    title: 'Day Three',
                                    week: widget.week,
                                    day: 3,
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
                                  'Day Three',
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
                            child: doneDay != null && doneDay > 2
                                ? Image.asset(
                                    'assets/icons/right.png',
                                    height: 35,
                                    width: 35,
                                  )
                                : doneDay == 2
                                    ? Image.asset(
                                        'assets/icons/next_arrow.png',
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
                    height: 30,
                  ),
                  /*3*/
                  Card(
                    color: const Color(0xffF8EEF9),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32.0),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(32.0),
                      onTap: doneDay != null && doneDay >= 3
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => play_video_screen(
                                    title: 'Additional Practice',
                                    week: widget.week,
                                    day: 4,
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
                                  'Additional Practice',
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 28,
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
                              padding:
                                  const EdgeInsets.only(left: 15, right: 15),
                              child: doneDay != null && doneDay > 3
                                  ? Image.asset(
                                      'assets/icons/right.png',
                                      height: 35,
                                      width: 35,
                                    )
                                  : doneDay == 3
                                      ? Image.asset(
                                          'assets/icons/next_arrow.png',
                                          height: 35,
                                          width: 35,
                                        )
                                      : Image.asset(
                                          'assets/icons/lock.png',
                                          height: 35,
                                          width: 35,
                                        )),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 12,
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
