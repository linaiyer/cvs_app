import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:resarch_csv/bottom_shet/bottom_navigation.dart';
import 'package:resarch_csv/main_screen/admin_screen/admin_home_screen.dart';
import 'package:resarch_csv/main_screen/super_admin_screen/super_admin_home_screen.dart';
import 'package:resarch_csv/notification/push_notification_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class login extends StatefulWidget {
  @override
  _login createState() => _login();
}

class _login extends State<login> {
  TextEditingController userNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final formKeyLogin = GlobalKey<FormState>();

  bool showLoader = false;

  userAccess() async {
    setState(() {
      showLoader = true;
    });

    SharedPreferences pref = await SharedPreferences.getInstance();

    FirebaseFirestore.instance
        .collection('user')
        .where('userName', isEqualTo: userNameController.text.trim())
        .where('password', isEqualTo: passwordController.text.trim())
        .get()
        .then((QuerySnapshot querySnapshot) => {
              if (querySnapshot.docs.isNotEmpty)
                {
                  querySnapshot.docs.forEach((doc) {
                    if (doc != null) {
                      Map<String, dynamic>? documentData = doc.data()
                          as Map<String, dynamic>?; //if it is a single document

                      print('documentData.toString()');
                      print(documentData.toString());

                      pref.setString('user_id', documentData!['id']);
                      pref.setString('user_type', documentData['user_type']);
                      if (documentData['user_type'] == '0') {
                        if (documentData['done_date'] == '') {
                          FirebaseFirestore.instance
                              .collection('user')
                              .doc(documentData['id'])
                              .update({
                            'done_date': DateFormat('yyyy-dd-MM')
                                .format(DateTime.now())
                                .toString()
                          }).whenComplete(() {
                            if (documentData['user_type'] == '1') {
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          super_admin_home_screen()),
                                  (route) => false);
                            } else if (documentData['user_type'] == '2') {
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          admin_home_screen()),
                                  (route) => false);
                            } else {
                              LocalNotification().showDailyAtTime();
                              // LocalNotification().repeatNotification();
                              // LocalNotification().zonedScheduleNotification();
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          bottom_navigation()),
                                  (route) => false);
                            }

                            setState(() {
                              showLoader = false;
                            });
                          });
                        } else {
                          if (documentData['user_type'] == '1') {
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        super_admin_home_screen()),
                                (route) => false);
                          } else if (documentData['user_type'] == '2') {
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => admin_home_screen()),
                                (route) => false);
                          } else {
                            LocalNotification().showDailyAtTime();
                            // LocalNotification().repeatNotification();
                            // LocalNotification().zonedScheduleNotification();
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => bottom_navigation()),
                                (route) => false);
                          }
                        }
                      } else {
                        if (documentData['user_type'] == '1') {
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      super_admin_home_screen()),
                              (route) => false);
                        } else if (documentData['user_type'] == '2') {
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => admin_home_screen()),
                              (route) => false);
                        } else {
                          LocalNotification().showDailyAtTime();
                          // LocalNotification().repeatNotification();
                          // LocalNotification().zonedScheduleNotification();
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => bottom_navigation()),
                              (route) => false);
                        }
                      }
                    } else {
                      setState(() {
                        showLoader = false;
                      });
                    }
                  }),
                }
              else
                {
                  setState(() {
                    showLoader = false;
                  }),
                  Fluttertoast.showToast(
                      msg: 'Login Credential Not Match',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 3,
                      backgroundColor: Color(0xffC299F6),
                      textColor: Colors.white),
                }
            });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F4F5),
      key: _scaffoldKey,
      body: SingleChildScrollView(
        child: Padding(
          child: Form(
            key: formKeyLogin,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.width / 3, bottom: 20),
                  child: Image.asset('assets/images/login_image.png'),
                ),
                const Text(
                  'Login',
                  style: TextStyle(
                    fontFamily: 'GoudyBookletterRegular',
                    color: Color(0xff744EC3),
                    fontWeight: FontWeight.w400,
                    fontSize: 48,
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0)),
                  child: TextFormField(
                    controller: userNameController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: const BorderSide(
                          color: Color(0xffFDFCFC),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: const BorderSide(
                          color: Color(0xffFDFCFC),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: const BorderSide(
                          color: Color(0xffFDFCFC),
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: const BorderSide(
                          color: Colors.transparent,
                        ),
                      ),
                      hintText: 'Username',
                      errorStyle: const TextStyle(color: Colors.red),
                      hintStyle: const TextStyle(
                        color: Color(0xff999999),
                        fontWeight: FontWeight.w300,
                        fontSize: 16,
                      ),
                    ),
                    validator: (String? s) {
                      if (s!.isEmpty) {
                        return 'Enter valid user name';
                      }
                    },
                    onSaved: (String? s) {
                      userNameController.text = s!.trim();
                    },
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0)),
                  child: TextFormField(
                    controller: passwordController,
                    keyboardType: TextInputType.visiblePassword,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: const BorderSide(
                          color: Color(0xffFDFCFC),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: const BorderSide(
                          color: Color(0xffFDFCFC),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: const BorderSide(
                          color: Color(0xffFDFCFC),
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: const BorderSide(
                          color: Colors.transparent,
                        ),
                      ),
                      hintText: 'Password',
                      errorStyle: const TextStyle(color: Colors.red),
                      hintStyle: const TextStyle(
                        color: Color(0xff999999),
                        fontWeight: FontWeight.w300,
                        fontSize: 16,
                      ),
                    ),
                    validator: (String? s) {
                      if (s!.isEmpty) {
                        return 'Enter valid password';
                      }
                    },
                    onSaved: (String? s) {
                      passwordController.text = s!.trim();
                    },
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                showLoader
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : RaisedButton(
                        onPressed: () {
                          if (formKeyLogin.currentState!.validate()) {
                            formKeyLogin.currentState!.save();
                            userAccess();
                          }
                        },
                        color: const Color(0xffC299F6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        padding: const EdgeInsets.only(
                            left: 30, right: 30, top: 3, bottom: 3),
                        child: const Text(
                          'Login',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                              fontSize: 20),
                        ),
                      ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => bottom_navigation(),
                      ),
                    );
                  },
                  child: const Text(
                    'Login as guest',
                    style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Color(0xffC299F6),
                        fontWeight: FontWeight.w400,
                        fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
          padding: const EdgeInsets.all(15),
        ),
      ),
    );
  }
}
