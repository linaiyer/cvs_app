import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:resarch_csv/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class acivment_screen extends StatefulWidget {
  @override
  _acivment_screen createState() => _acivment_screen();
}

class _acivment_screen extends State<acivment_screen> with RouteAware {
  var doneAchivment;
  bool showLoader = false;

  @override
  void initState() {
    getUserData();

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
  void didUpdateWidget(covariant acivment_screen oldWidget) {
    super.didUpdateWidget(oldWidget);
    getUserData();
  }

  bool check = false;

  getUserData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      check = pref.get('user_id') != null ? true : false;
    });
    if (pref.get('user_id') != null) {
      getAchivmentData();
    }
  }

  // @override
  // void didPushNext() {
  //   print('didPushNext');
  //   // getUserProfile();
  // }

  getAchivmentData() async {
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
                  setState(() {
                    doneAchivment = int.parse(documentData!['achievement']);
                    showLoader = false;
                  });
                } else {
                  setState(() {
                    showLoader = false;
                  });
                }
              }),
            });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding:
            const EdgeInsets.only(left: 15, right: 15, bottom: 15, top: 30),
        child: Column(
          children: <Widget>[
            const Text(
              'Achievements',
              style: TextStyle(
                  decoration: TextDecoration.underline,
                  color: Color(0xff744EC3),
                  fontSize: 40,
                  fontFamily: 'GoudyBookletterRegular',
                  fontWeight: FontWeight.w400),
            ),
            Expanded(
              child: showLoader
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : GridView.builder(
                      padding: EdgeInsets.only(top: 5),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        childAspectRatio: 0.8,
                        crossAxisCount: 3,
                        mainAxisSpacing: 2,
                        crossAxisSpacing: 3,
                      ),
                      itemCount: 8,
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index) {
                        return InkWell(
                          onTap: null,
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              side: const BorderSide(
                                  color: Color(0xfff3e0f3), width: 1),
                            ),
                            elevation: 3,
                            color: const Color(0xffF8EEF9),
                            child: SizedBox(
                              width: 100,
                              child: Column(
                                children: <Widget>[
                                  doneAchivment != null
                                      ? index == 0
                                          ? doneAchivment >= 1
                                              ? Image.asset(
                                                  'assets/images/achivement_one.png',
                                                  height: 80,
                                                )
                                              : Image.asset(
                                                  'assets/images/achivement_lock.png',
                                                  height: 80,
                                                )
                                          : index == 1
                                              ? doneAchivment >= 2
                                                  ? Image.asset(
                                                      'assets/images/achivement_two.png',
                                                      height: 80,
                                                    )
                                                  : Image.asset(
                                                      'assets/images/achivement_lock.png',
                                                      height: 80,
                                                    )
                                              : index == 2
                                                  ? doneAchivment >= 3
                                                      ? Image.asset(
                                                          'assets/images/achivement_three.png',
                                                          height: 80,
                                                        )
                                                      : Image.asset(
                                                          'assets/images/achivement_lock.png',
                                                          height: 80,
                                                        )
                                                  : index == 3
                                                      ? doneAchivment >= 4
                                                          ? Image.asset(
                                                              'assets/images/achivement_four.png',
                                                              height: 80,
                                                            )
                                                          : Image.asset(
                                                              'assets/images/achivement_lock.png',
                                                              height: 80,
                                                            )
                                                      : index == 4
                                                          ? doneAchivment >= 5
                                                              ? Image.asset(
                                                                  'assets/images/achivement_five.png',
                                                                  height: 80,
                                                                )
                                                              : Image.asset(
                                                                  'assets/images/achivement_lock.png',
                                                                  height: 80,
                                                                )
                                                          : index == 5
                                                              ? doneAchivment >=
                                                                      6
                                                                  ? Image.asset(
                                                                      'assets/images/achivement_six.png',
                                                                      height:
                                                                          80,
                                                                    )
                                                                  : Image.asset(
                                                                      'assets/images/achivement_lock.png',
                                                                      height:
                                                                          80,
                                                                    )
                                                              : index == 6
                                                                  ? doneAchivment >=
                                                                          7
                                                                      ? Image
                                                                          .asset(
                                                                          'assets/images/achivement_saven.png',
                                                                          height:
                                                                              80,
                                                                        )
                                                                      : Image
                                                                          .asset(
                                                                          'assets/images/achivement_lock.png',
                                                                          height:
                                                                              80,
                                                                        )
                                                                  : index == 7
                                                                      ? doneAchivment >=
                                                                              8
                                                                          ? Image
                                                                              .asset(
                                                                              'assets/images/achivement_eight.png',
                                                                              height: 80,
                                                                            )
                                                                          : Image
                                                                              .asset(
                                                                              'assets/images/achivement_lock.png',
                                                                              height: 80,
                                                                            )
                                                                      : Image
                                                                          .asset(
                                                                          'assets/images/achivement_lock.png',
                                                                          height:
                                                                              80,
                                                                        )
                                      : Image.asset(
                                          'assets/images/achivement_lock.png',
                                          height: 80,
                                        ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    '${index == 0 ? 'Intro' : index == 1 ? 'Week One' : index == 2 ? 'Week Two' : index == 3 ? 'Week Three' : index == 4 ? 'Week Four' : index == 5 ? 'Week Five' : index == 6 ? 'Week Six' : index == 7 ? 'End' : 'Week One'}\nBadge'
                                    /*     index / 2 == 0
                                  ? 'Intro Badge'
                                  : 'asdewvcg dsfgrsvuv fgverw w'*/
                                    ,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        color: Color(0xff485370),
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14),
                                    maxLines: 2,
                                    overflow: TextOverflow.clip,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
