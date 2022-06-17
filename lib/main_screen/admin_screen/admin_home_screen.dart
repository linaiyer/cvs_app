import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:resarch_csv/auth_screen/login.dart';
import 'package:resarch_csv/main_screen/admin_screen/configure_users_screen.dart';
import 'package:share_extend/share_extend.dart';
import 'package:shared_preferences/shared_preferences.dart';

class admin_home_screen extends StatefulWidget {
  @override
  _admin_home_screen createState() => _admin_home_screen();
}

class _admin_home_screen extends State<admin_home_screen> {
  List<dynamic> associateList = [];

  getDownloadData() async {
    associateList.clear();
    FirebaseFirestore.instance
        .collection('watchDataTable')
        .get()
        .then((QuerySnapshot querySnapshot) => {
              for (int i = 0; i < querySnapshot.docs.length; i++)
                {
                  //research-cvs
                  setState(() {
                    associateList.add({
                      "Username": querySnapshot.docs[i]['userName'],
                      "W1 AP":
                          '${querySnapshot.docs[i]['W1 AP time'] + '-' + querySnapshot.docs[i]['W1 AP date']}',
                      "W1 D1":
                          '${querySnapshot.docs[i]['W1 D1 time'] + '-' + querySnapshot.docs[i]['W1 D1 date']}',
                      "W1 D2":
                          '${querySnapshot.docs[i]['W1 D2 time'] + '-' + querySnapshot.docs[i]['W1 D2 date']}',
                      "W1 D3":
                          '${querySnapshot.docs[i]['W1 D3 time'] + '-' + querySnapshot.docs[i]['W1 D3 date']}',
                      "W2 AP":
                          '${querySnapshot.docs[i]['W2 AP time'] + '-' + querySnapshot.docs[i]['W2 AP date']}',
                      "W2 D1":
                          '${querySnapshot.docs[i]['W2 D1 time'] + '-' + querySnapshot.docs[i]['W2 D1 date']}',
                      "W2 D2":
                          '${querySnapshot.docs[i]['W2 D2 time'] + '-' + querySnapshot.docs[i]['W2 D2 date']}',
                      "W2 D3":
                          '${querySnapshot.docs[i]['W2 D3 time'] + '-' + querySnapshot.docs[i]['W2 D3 date']}',
                      "W3 AP":
                          '${querySnapshot.docs[i]['W3 AP time'] + '-' + querySnapshot.docs[i]['W3 AP date']}',
                      "W3 D1":
                          '${querySnapshot.docs[i]['W3 D1 time'] + '-' + querySnapshot.docs[i]['W3 D1 date']}',
                      "W3 D2":
                          '${querySnapshot.docs[i]['W3 D2 time'] + '-' + querySnapshot.docs[i]['W3 D2 date']}',
                      "W3 D3":
                          '${querySnapshot.docs[i]['W3 D3 time'] + '-' + querySnapshot.docs[i]['W3 D3 date']}',
                      "W4 AP":
                          '${querySnapshot.docs[i]['W4 AP time'] + '-' + querySnapshot.docs[i]['W4 AP date']}',
                      "W4 D1":
                          '${querySnapshot.docs[i]['W4 D1 time'] + '-' + querySnapshot.docs[i]['W4 D1 date']}',
                      "W4 D2":
                          '${querySnapshot.docs[i]['W4 D2 time'] + '-' + querySnapshot.docs[i]['W4 D2 date']}',
                      "W4 D3":
                          '${querySnapshot.docs[i]['W4 D3 time'] + '-' + querySnapshot.docs[i]['W4 D3 date']}',
                      "W5 AP":
                          '${querySnapshot.docs[i]['W5 AP time'] + '-' + querySnapshot.docs[i]['W5 AP date']}',
                      "W5 D1":
                          '${querySnapshot.docs[i]['W5 D1 time'] + '-' + querySnapshot.docs[i]['W5 D1 date']}',
                      "W5 D2":
                          '${querySnapshot.docs[i]['W5 D2 time'] + '-' + querySnapshot.docs[i]['W5 D2 date']}',
                      "W5 D3":
                          '${querySnapshot.docs[i]['W5 D3 time'] + '-' + querySnapshot.docs[i]['W5 D3 date']}',
                      "W6 AP":
                          '${querySnapshot.docs[i]['W6 AP time'] + '-' + querySnapshot.docs[i]['W6 AP date']}',
                      "W6 D1":
                          '${querySnapshot.docs[i]['W6 D1 time'] + '-' + querySnapshot.docs[i]['W6 D1 date']}',
                      "W6 D2":
                          '${querySnapshot.docs[i]['W6 D2 time'] + '-' + querySnapshot.docs[i]['W6 D2 date']}',
                      "W6 D3":
                          '${querySnapshot.docs[i]['W6 D3 time'] + '-' + querySnapshot.docs[i]['W6 D3 date']}',
                    });
                  }),
                }
            })
        .whenComplete(() async => {
              _generateCsvFile(),
              // Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //         builder: (context) =>
              //             printListOfPrintPDF(list: associateList)))
            });
  }

  void _generateCsvFile() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
    ].request();

    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }

    List<List<dynamic>> rows = [];

    List<dynamic> row = [];
    row.add("Username");
    row.add("W1 AP");
    row.add("W1 D1");
    row.add("W1 D2");
    row.add("W1 D3");
    row.add("W2 AP");
    row.add("W2 D1");
    row.add("W2 D2");
    row.add("W2 D3");
    row.add("W3 AP");
    row.add("W3 D1");
    row.add("W3 D2");
    row.add("W3 D3");
    row.add("W4 AP");
    row.add("W4 D1");
    row.add("W4 D2");
    row.add("W4 D3");
    row.add("W5 AP");
    row.add("W5 D1");
    row.add("W5 D2");
    row.add("W5 D3");
    row.add("W6 AP");
    row.add("W6 D1");
    row.add("W6 D2");
    row.add("W6 D3");
    rows.add(row);
    for (int i = 0; i < associateList.length; i++) {
      List<dynamic> row = [];
      row.add(associateList[i]["Username"]);
      row.add(associateList[i]["W1 AP"]);
      row.add(associateList[i]["W1 D1"]);
      row.add(associateList[i]["W1 D2"]);
      row.add(associateList[i]["W1 D3"]);
      row.add(associateList[i]["W2 AP"]);
      row.add(associateList[i]["W2 D1"]);
      row.add(associateList[i]["W2 D2"]);
      row.add(associateList[i]["W2 D3"]);
      row.add(associateList[i]["W3 AP"]);
      row.add(associateList[i]["W3 D1"]);
      row.add(associateList[i]["W3 D2"]);
      row.add(associateList[i]["W3 D3"]);
      row.add(associateList[i]["W4 AP"]);
      row.add(associateList[i]["W4 D1"]);
      row.add(associateList[i]["W4 D2"]);
      row.add(associateList[i]["W4 D3"]);
      row.add(associateList[i]["W5 AP"]);
      row.add(associateList[i]["W5 D1"]);
      row.add(associateList[i]["W5 D2"]);
      row.add(associateList[i]["W5 D3"]);
      row.add(associateList[i]["W6 AP"]);
      row.add(associateList[i]["W6 D1"]);
      row.add(associateList[i]["W6 D2"]);
      row.add(associateList[i]["W6 D3"]);
      rows.add(row);
    }

    String csv = const ListToCsvConverter().convert(rows);

    // String? dir = await ExtStorage.getExternalStoragePublicDirectory(
    //     ExtStorage.DIRECTORY_DOWNLOADS);

    Directory? dir = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    print("dir");
    print(dir);
    String file = dir!.path;

    File f = File(file + "/research-cvs.csv");

    f.writeAsString(csv);
    // if (!await f.exists()) {
    //   await f.create(recursive: true);
    //   f.writeAsStringSync("test for share documents file");
    // }
    ShareExtend.share(f.path, "file");
  }

  @override
  void initState() {

    super.initState();
  }

  @override
  void dispose() {

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding:
            const EdgeInsets.only(left: 15, right: 15, bottom: 15, top: 35),
        child: Column(
          children: <Widget>[
            const Text(
              'Home Page',
              style: TextStyle(
                  decoration: TextDecoration.underline,
                  color: Color(0xff744EC3),
                  fontSize: 40,
                  fontFamily: 'GoudyBookletterRegular',
                  fontWeight: FontWeight.w400),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  // padding: const EdgeInsets.only(top: 20),
                  children: <Widget>[
                    RaisedButton(
                      elevation: 2,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => configure_users_screen(),
                          ),
                        );
                      },
                      color: const Color(0xffF8EEF9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        side: BorderSide(color: Color(0xffB993BC), width: 1),
                      ),
                      padding: const EdgeInsets.only(
                          left: 30, right: 30, top: 5, bottom: 5),
                      child: const Text(
                        'Configure Users',
                        style: TextStyle(
                          color: Color(0xff485370),
                          fontFamily: 'Avenir',
                          fontWeight: FontWeight.w400,
                          fontSize: 30,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    RaisedButton(
                      elevation: 2,
                      onPressed: () {
                        getDownloadData();
                      },
                      color: const Color(0xffF8EEF9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        side: BorderSide(color: Color(0xffB993BC), width: 1),
                      ),
                      padding: const EdgeInsets.only(
                          left: 30, right: 30, top: 5, bottom: 5),
                      child: const Text(
                        'Download Data',
                        style: TextStyle(
                          color: Color(0xff485370),
                          fontFamily: 'Avenir',
                          fontWeight: FontWeight.w400,
                          fontSize: 30,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    RaisedButton(
                      elevation: 2,
                      onPressed: () {
                        logout();
                      },
                      color: const Color(0xffF8EEF9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        side: BorderSide(
                            color: const Color(0xffB993BC), width: 1),
                      ),
                      padding: const EdgeInsets.only(
                          left: 80, right: 80, top: 5, bottom: 5),
                      child: const Text(
                        'Log Out',
                        style: TextStyle(
                          color: Color(0xff485370),
                          fontFamily: 'Avenir',
                          fontWeight: FontWeight.w400,
                          fontSize: 30,
                        ),
                      ),
                    ),
                  ],
                ),
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
