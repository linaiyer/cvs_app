import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:resarch_csv/main.dart';
import 'package:resarch_csv/main_screen/super_admin_screen/add_manage_admin.dart';
import 'package:resarch_csv/model/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class manage_admins_screen extends StatefulWidget {
  @override
  _manage_admins_screen createState() => _manage_admins_screen();
}

class _manage_admins_screen extends State<manage_admins_screen>
    with RouteAware {
  List<user_model> userData = [];
  bool showLoader = true;

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
    getAdminData();
    super.initState();
  }

  @override
  void didPopNext() {
    getAdminData();
  }

  getAdminData() async {
    setState(() {
      showLoader = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    FirebaseFirestore.instance
        .collection('user')
        .where('user_type', isEqualTo: '2')
        .get()
        .then((QuerySnapshot querySnapshot) => {
              setState(() {
                userData = querySnapshot.docs
                    .map<user_model>((e) => user_model.fromJson(e))
                    .toList();
                // userData = querySnapshot.docs;
                showLoader = false;
              }),
            });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding:
            const EdgeInsets.only(left: 15, right: 15, bottom: 15, top: 40),
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
                      const Text(
                        'Manage Admins',
                        textAlign: TextAlign.center,
                        style: TextStyle(
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
                  SizedBox(
                    height: 5,
                  ),
                  Table(
                    // textDirection: TextDirection.rtl,
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    border:
                        TableBorder.all(width: 1.0, color: Color(0xff485370)),
                    children: [
                      TableRow(
                        children: [
                          Text(
                            "S. No.",
                            // textScaleFactor: 1.5,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Avenir',
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              color: Color(0xff485370),
                            ),
                          ),
                          Text(
                            "UserName",
                            // textScaleFactor: 1.5,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Avenir',
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              color: Color(0xff485370),
                            ),
                          ),
                          Text(
                            "Password",
                            // textScaleFactor: 1.5,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Avenir',
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              color: Color(0xff485370),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: const <Widget>[
                  //     Text(
                  //       'S. No.',
                  //       style: TextStyle(
                  //         fontFamily: 'Avenir',
                  //         fontSize: 18,
                  //         fontWeight: FontWeight.w400,
                  //         color: Color(0xff485370),
                  //       ),
                  //     ),
                  //     Text(
                  //       'userName',
                  //       style: TextStyle(
                  //         fontFamily: 'Avenir',
                  //         fontSize: 18,
                  //         fontWeight: FontWeight.w400,
                  //         color: Color(0xff485370),
                  //       ),
                  //     ),
                  //     Text(
                  //       'password',
                  //       style: TextStyle(
                  //         fontFamily: 'Avenir',
                  //         fontSize: 18,
                  //         fontWeight: FontWeight.w400,
                  //         color: Color(0xff485370),
                  //       ),
                  //     ),
                  //   ],
                  // )
                ],
              ),
            ),
            Expanded(
              child: showLoader
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : userData != null && userData.length != 0
                      ? ListView.builder(
                          itemCount: userData.length,
                          padding: const EdgeInsets.only(top: 0),
                          itemBuilder: (context, index) {
                            return Table(
                              // textDirection: TextDirection.rtl,
                              defaultVerticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              border: TableBorder.all(
                                  width: 1.0, color: Color(0xff485370)),
                              children: [
                                TableRow(
                                  children: [
                                    Text(
                                      '${index + 1}',
                                      // textScaleFactor: 1.5,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontFamily: 'Avenir',
                                        fontSize: 18,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xff485370),
                                      ),
                                    ),
                                    Text(
                                      userData[index].userName!,
                                      // textScaleFactor: 1.5,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontFamily: 'Avenir',
                                        fontSize: 18,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xff485370),
                                      ),
                                    ),
                                    Text(
                                      userData[index].password!,
                                      // textScaleFactor: 1.5,
                                      textAlign: TextAlign.center,

                                      style: const TextStyle(
                                        fontFamily: 'Avenir',
                                        fontSize: 18,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xff485370),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );

                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //   children: <Widget>[
                            //     Text(
                            //       '${index + 1}',
                            //       style: const TextStyle(
                            //         fontFamily: 'Avenir',
                            //         fontSize: 18,
                            //         fontWeight: FontWeight.w400,
                            //         color: Color(0xff485370),
                            //       ),
                            //     ),
                            //     Text(
                            //       userData[index].userName!,
                            //       style: const TextStyle(
                            //         fontFamily: 'Avenir',
                            //         fontSize: 18,
                            //         fontWeight: FontWeight.w400,
                            //         color: Color(0xff485370),
                            //       ),
                            //     ),
                            //     Text(
                            //       userData[index].password!,
                            //       style: const TextStyle(
                            //         fontFamily: 'Avenir',
                            //         fontSize: 18,
                            //         fontWeight: FontWeight.w400,
                            //         color: Color(0xff485370),
                            //       ),
                            //     ),
                            //   ],
                            // );
                          },
                        )
                      : const Center(
                          child: Text('No Data Found!'),
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => add_manage_admin(),
            ),
          );
        },
        icon: const Icon(
          Icons.add,
          color: Color(0xff485370),
          size: 18,
        ),
        label: const Text(
          "Add Admin",
          style: TextStyle(
            color: Color(0xff485370),
            fontFamily: 'Avenir',
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
