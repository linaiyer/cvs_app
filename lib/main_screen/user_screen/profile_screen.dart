import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:resarch_csv/auth_screen/login.dart';
import 'package:resarch_csv/main.dart';
import 'package:resarch_csv/main_screen/terms_of_use.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class profile_screen extends StatefulWidget {
  @override
  _profile_screen createState() => _profile_screen();
}

class _profile_screen extends State<profile_screen> with RouteAware {
  var profileData;

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
  void initState() {
    getUserData();
    super.initState();
  }

  @override
  void didPopNext() {
    getUserData();
  }

  bool check = false;

  getUserData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      check = pref.get('user_id') != null ? true : false;
    });
    if (pref.get('user_id') != null) {
      getUserProfile();
    }
  }

  void getUserProfile() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    FirebaseFirestore.instance
        .collection('user')
        .where('id', isEqualTo: pref.getString('user_id'))
        .get()
        .then((QuerySnapshot querySnapshot) => {
              setState(() {
                profileData = querySnapshot.docs;
              }),
            });
  }

  _launchURL() async {
    const url = 'https://www.heartfulnessinstitute.org/';
    if (await canLaunch(url)) {
      await launch(url, forceWebView: true);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(left: 15, right: 15, top: 30, bottom: 15),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Settings',
              style: TextStyle(
                  decoration: TextDecoration.underline,
                  color: Color(0xff744EC3),
                  fontSize: 40,
                  fontFamily: 'GoudyBookletterRegular',
                  fontWeight: FontWeight.w400),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.only(top: 15),
                children: <Widget>[
                  // GestureDetector(
                  //   // borderRadius: BorderRadius.circular(32.0),
                  //   onTap: () {
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //         builder: (context) => pick_avater(),
                  //       ),
                  //     );
                  //   },
                  //   child: profileData == null
                  //       ? const Text(
                  //           'Profile Loading..',
                  //           textAlign: TextAlign.center,
                  //           style: TextStyle(
                  //               color: Color(0xff485370),
                  //               fontSize: 30,
                  //               fontWeight: FontWeight.w400,
                  //               fontFamily: 'Anaheim'),
                  //         )
                  //       : profileData[0]['user_profile'].isEmpty
                  //           ?
                  // Container(
                  //   height: 180,
                  //   width: 180,
                  //   decoration: BoxDecoration(
                  //     shape: BoxShape.circle,
                  //     border: Border.all(
                  //       color: Color(0xffC299F6),
                  //       width: 1.5,
                  //     ),
                  //   ),
                  //   child: const Center(
                  //     child: Text(
                  //       'Pick Your\nAvatar',
                  //       textAlign: TextAlign.center,
                  //       maxLines: 2,
                  //       style: TextStyle(
                  //           fontFamily: 'Avenir',
                  //           color: Color(0xffC299F6),
                  //           fontWeight: FontWeight.w400,
                  //           fontSize: 30),
                  //     ),
                  //   ),
                  // ),
                  Image.asset(
                    'assets/images/profile_avater.png',
                    height: 180,
                    width: 180,
                  ),
                  // : Image.network(
                  //     profileData[0]['user_profile'],
                  //     width: 180,
                  //     height: 180,
                  //   ),
                  // ),
                  const SizedBox(
                    height: 8,
                  ),
                  profileData != null
                      ? Text(
                          profileData[0]['name'] ?? '',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Color(0xff485370),
                              fontSize: 30,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'Anaheim'),
                        )
                      : const SizedBox.shrink(),
                  const SizedBox(
                    height: 20,
                  ),
                  Card(
                    color: Color(0xffF8EEF9),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32.0)),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(32.0),
                      onTap: () {
                        logout();
                      },
                      child: Row(
                        children: <Widget>[
                          const Expanded(
                            child: SizedBox(
                              height: 60,
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: 20, top: 10, bottom: 10),
                                child: Text(
                                  'Log out',
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 30,
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
                            child: Image.asset(
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
                  /*Card(
                    color: Color(0xffF8EEF9),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32.0)),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(32.0),
                      onTap: () async {
                        await LocalNotification()
                            .scheduleDailyTenAMNotification();
                      },
                      child: Row(
                        children: <Widget>[
                          const Expanded(
                            child: SizedBox(
                              height: 60,
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: 20, top: 10, bottom: 10),
                                child: Text(
                                  'test',
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 26,
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
                            child: Image.asset(
                              'assets/icons/next_arrow.png',
                              height: 35,
                              width: 35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),*/
                  Card(
                    color: Color(0xffF8EEF9),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32.0)),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(32.0),
                      onTap: () {
                        _launchURL();
                      },
                      child: Row(
                        children: <Widget>[
                          const Expanded(
                            child: SizedBox(
                              height: 60,
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: 20, top: 10, bottom: 10),
                                child: Text(
                                  'Additional Resources',
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 26,
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
                            child: Image.asset(
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
                    color: Color(0xffF8EEF9),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32.0)),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TermsOfUse(),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(32.0),
                      child: Row(
                        children: <Widget>[
                          const Expanded(
                            child: SizedBox(
                              height: 60,
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: 20, top: 10, bottom: 10),
                                child: Text(
                                  'Terms and Conditions',
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 26,
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
                            child: Image.asset(
                              'assets/icons/next_arrow.png',
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

  logout() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.clear();
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => login(),
        ),
        (route) => false);
  }
}
