import 'dart:ffi';
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
import 'package:resarch_csv/main_screen/super_admin_screen/manage_admins_screen.dart';
import 'package:share_extend/share_extend.dart';
import 'package:shared_preferences/shared_preferences.dart';

class super_admin_home_screen extends StatefulWidget {
  @override
  _super_admin_home_screen createState() => _super_admin_home_screen();
}

class _super_admin_home_screen extends State<super_admin_home_screen> {
  List<dynamic> associateList = [];

  getDownloadData() async {
    associateList.clear();
    FirebaseFirestore.instance
        .collection('watchDataTable')
        .get()
        .then((QuerySnapshot querySnapshot) => {
              for (int i = 0; i < querySnapshot.docs.length; i++)
                {
                  setState(() {
                    associateList.add({
                      "Username": querySnapshot.docs[i]['userName'],
                      "W1 D1":
                      '${querySnapshot.docs[i]['W1 D1 time'] + '-' + querySnapshot.docs[i]['W1 D1 date']}',
                      "W1 D2":
                      '${querySnapshot.docs[i]['W1 D2 time'] + '-' + querySnapshot.docs[i]['W1 D2 date']}',
                      "W1 D3":
                      '${querySnapshot.docs[i]['W1 D3 time'] + '-' + querySnapshot.docs[i]['W1 D3 date']}',
                      "W1 D4":
                      '${querySnapshot.docs[i]['W1 D4 time'] + '-' + querySnapshot.docs[i]['W1 D4 date']}',
                      "W1 D5":
                      '${querySnapshot.docs[i]['W1 D5 time'] + '-' + querySnapshot.docs[i]['W1 D5 date']}',
                      "W1 D6":
                      '${querySnapshot.docs[i]['W1 D6 time'] + '-' + querySnapshot.docs[i]['W1 D6 date']}',
                      "W1 D7":
                      '${querySnapshot.docs[i]['W1 D7 time'] + '-' + querySnapshot.docs[i]['W1 D7 date']}',
                      "W2 D1":
                      '${querySnapshot.docs[i]['W2 D1 time'] + '-' + querySnapshot.docs[i]['W2 D1 date']}',
                      "W2 D2":
                      '${querySnapshot.docs[i]['W2 D2 time'] + '-' + querySnapshot.docs[i]['W2 D2 date']}',
                      "W2 D3":
                      '${querySnapshot.docs[i]['W2 D3 time'] + '-' + querySnapshot.docs[i]['W2 D3 date']}',
                      "W2 D4":
                      '${querySnapshot.docs[i]['W2 D4 time'] + '-' + querySnapshot.docs[i]['W2 D4 date']}',
                      "W2 D5":
                      '${querySnapshot.docs[i]['W2 D5 time'] + '-' + querySnapshot.docs[i]['W2 D5 date']}',
                      "W2 D6":
                      '${querySnapshot.docs[i]['W2 D6 time'] + '-' + querySnapshot.docs[i]['W2 D6 date']}',
                      "W2 D7":
                      '${querySnapshot.docs[i]['W2 D7 time'] + '-' + querySnapshot.docs[i]['W2 D7 date']}',
                      "W3 D1":
                      '${querySnapshot.docs[i]['W3 D1 time'] + '-' + querySnapshot.docs[i]['W3 D1 date']}',
                      "W3 D2":
                      '${querySnapshot.docs[i]['W3 D2 time'] + '-' + querySnapshot.docs[i]['W3 D2 date']}',
                      "W3 D3":
                      '${querySnapshot.docs[i]['W3 D3 time'] + '-' + querySnapshot.docs[i]['W3 D3 date']}',
                      "W3 D4":
                      '${querySnapshot.docs[i]['W3 D4 time'] + '-' + querySnapshot.docs[i]['W3 D4 date']}',
                      "W3 D5":
                      '${querySnapshot.docs[i]['W3 D5 time'] + '-' + querySnapshot.docs[i]['W3 D5 date']}',
                      "W3 D6":
                      '${querySnapshot.docs[i]['W3 D6 time'] + '-' + querySnapshot.docs[i]['W3 D6 date']}',
                      "W3 D7":
                      '${querySnapshot.docs[i]['W3 D7 time'] + '-' + querySnapshot.docs[i]['W3 D7 date']}',
                      "W4 D1":
                      '${querySnapshot.docs[i]['W4 D1 time'] + '-' + querySnapshot.docs[i]['W4 D1 date']}',
                      "W4 D2":
                      '${querySnapshot.docs[i]['W4 D2 time'] + '-' + querySnapshot.docs[i]['W4 D2 date']}',
                      "W4 D3":
                      '${querySnapshot.docs[i]['W4 D3 time'] + '-' + querySnapshot.docs[i]['W4 D3 date']}',
                      "W4 D4":
                      '${querySnapshot.docs[i]['W4 D4 time'] + '-' + querySnapshot.docs[i]['W4 D4 date']}',
                      "W4 D5":
                      '${querySnapshot.docs[i]['W4 D5 time'] + '-' + querySnapshot.docs[i]['W4 D5 date']}',
                      "W4 D6":
                      '${querySnapshot.docs[i]['W4 D6 time'] + '-' + querySnapshot.docs[i]['W4 D6 date']}',
                      "W4 D7":
                      '${querySnapshot.docs[i]['W4 D7 time'] + '-' + querySnapshot.docs[i]['W4 D7 date']}',
                      "W5 D1":
                      '${querySnapshot.docs[i]['W5 D1 time'] + '-' + querySnapshot.docs[i]['W5 D1 date']}',
                      "W5 D2":
                      '${querySnapshot.docs[i]['W5 D2 time'] + '-' + querySnapshot.docs[i]['W5 D2 date']}',
                      "W5 D3":
                      '${querySnapshot.docs[i]['W5 D3 time'] + '-' + querySnapshot.docs[i]['W5 D3 date']}',
                      "W5 D4":
                      '${querySnapshot.docs[i]['W5 D4 time'] + '-' + querySnapshot.docs[i]['W5 D4 date']}',
                      "W5 D5":
                      '${querySnapshot.docs[i]['W5 D5 time'] + '-' + querySnapshot.docs[i]['W5 D5 date']}',
                      "W5 D6":
                      '${querySnapshot.docs[i]['W5 D6 time'] + '-' + querySnapshot.docs[i]['W5 D6 date']}',
                      "W5 D7":
                      '${querySnapshot.docs[i]['W5 D7 time'] + '-' + querySnapshot.docs[i]['W5 D7 date']}',
                      "W6 D1":
                      '${querySnapshot.docs[i]['W6 D1 time'] + '-' + querySnapshot.docs[i]['W6 D1 date']}',
                      "W6 D2":
                      '${querySnapshot.docs[i]['W6 D2 time'] + '-' + querySnapshot.docs[i]['W6 D2 date']}',
                      "W6 D3":
                      '${querySnapshot.docs[i]['W6 D3 time'] + '-' + querySnapshot.docs[i]['W6 D3 date']}',
                      "W6 D4":
                      '${querySnapshot.docs[i]['W6 D4 time'] + '-' + querySnapshot.docs[i]['W6 D4 date']}',
                      "W6 D5":
                      '${querySnapshot.docs[i]['W6 D5 time'] + '-' + querySnapshot.docs[i]['W6 D5 date']}',
                      "W6 D6":
                      '${querySnapshot.docs[i]['W6 D6 time'] + '-' + querySnapshot.docs[i]['W6 D6 date']}',
                      "W6 D7":
                      '${querySnapshot.docs[i]['W6 D7 time'] + '-' + querySnapshot.docs[i]['W6 D7 date']}',
                      "W7 D1":
                      '${querySnapshot.docs[i]['W7 D1 time'] + '-' + querySnapshot.docs[i]['W7 D1 date']}',
                      "W7 D2":
                      '${querySnapshot.docs[i]['W7 D2 time'] + '-' + querySnapshot.docs[i]['W7 D2 date']}',
                      "W7 D3":
                      '${querySnapshot.docs[i]['W7 D3 time'] + '-' + querySnapshot.docs[i]['W7 D3 date']}',
                      "W7 D4":
                      '${querySnapshot.docs[i]['W7 D4 time'] + '-' + querySnapshot.docs[i]['W7 D4 date']}',
                      "W7 D5":
                      '${querySnapshot.docs[i]['W7 D5 time'] + '-' + querySnapshot.docs[i]['W7 D5 date']}',
                      "W7 D6":
                      '${querySnapshot.docs[i]['W7 D6 time'] + '-' + querySnapshot.docs[i]['W7 D6 date']}',
                      "W7 D7":
                      '${querySnapshot.docs[i]['W7 D7 time'] + '-' + querySnapshot.docs[i]['W7 D7 date']}',
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
    row.add("W1 D1");
    row.add("W1 D2");
    row.add("W1 D3");
    row.add("W1 D4");
    row.add("W1 D5");
    row.add("W1 D6");
    row.add("W1 D7");
    row.add("W2 D1");
    row.add("W2 D2");
    row.add("W2 D3");
    row.add("W2 D4");
    row.add("W2 D5");
    row.add("W2 D6");
    row.add("W2 D7");
    row.add("W3 D1");
    row.add("W3 D2");
    row.add("W3 D3");
    row.add("W3 D4");
    row.add("W3 D5");
    row.add("W3 D6");
    row.add("W3 D7");
    row.add("W4 D1");
    row.add("W4 D2");
    row.add("W4 D3");
    row.add("W4 D4");
    row.add("W4 D5");
    row.add("W4 D6");
    row.add("W4 D7");
    row.add("W5 D1");
    row.add("W5 D2");
    row.add("W5 D3");
    row.add("W5 D4");
    row.add("W5 D5");
    row.add("W5 D6");
    row.add("W5 D7");
    row.add("W6 D1");
    row.add("W6 D2");
    row.add("W6 D3");
    row.add("W6 D4");
    row.add("W6 D5");
    row.add("W6 D6");
    row.add("W6 D7");
    row.add("W7 D1");
    row.add("W7 D2");
    row.add("W7 D3");
    row.add("W7 D4");
    row.add("W7 D5");
    row.add("W7 D6");
    row.add("W7 D7");
    rows.add(row);
    for (int i = 0; i < associateList.length; i++) {
      List<dynamic> row = [];
      row.add(associateList[i]["Username"]);
      row.add(associateList[i]["W1 D1"]);
      row.add(associateList[i]["W1 D2"]);
      row.add(associateList[i]["W1 D3"]);
      row.add(associateList[i]["W1 D4"]);
      row.add(associateList[i]["W1 D5"]);
      row.add(associateList[i]["W1 D6"]);
      row.add(associateList[i]["W1 D7"]);
      row.add(associateList[i]["W2 D1"]);
      row.add(associateList[i]["W2 D2"]);
      row.add(associateList[i]["W2 D3"]);
      row.add(associateList[i]["W2 D4"]);
      row.add(associateList[i]["W2 D5"]);
      row.add(associateList[i]["W2 D6"]);
      row.add(associateList[i]["W2 D7"]);
      row.add(associateList[i]["W3 D1"]);
      row.add(associateList[i]["W3 D2"]);
      row.add(associateList[i]["W3 D3"]);
      row.add(associateList[i]["W3 D4"]);
      row.add(associateList[i]["W3 D5"]);
      row.add(associateList[i]["W3 D6"]);
      row.add(associateList[i]["W3 D7"]);
      row.add(associateList[i]["W4 D1"]);
      row.add(associateList[i]["W4 D2"]);
      row.add(associateList[i]["W4 D3"]);
      row.add(associateList[i]["W4 D4"]);
      row.add(associateList[i]["W4 D5"]);
      row.add(associateList[i]["W4 D6"]);
      row.add(associateList[i]["W4 D7"]);
      row.add(associateList[i]["W5 D1"]);
      row.add(associateList[i]["W5 D2"]);
      row.add(associateList[i]["W5 D3"]);
      row.add(associateList[i]["W5 D4"]);
      row.add(associateList[i]["W5 D5"]);
      row.add(associateList[i]["W5 D6"]);
      row.add(associateList[i]["W5 D7"]);
      row.add(associateList[i]["W6 D1"]);
      row.add(associateList[i]["W6 D2"]);
      row.add(associateList[i]["W6 D3"]);
      row.add(associateList[i]["W6 D4"]);
      row.add(associateList[i]["W6 D5"]);
      row.add(associateList[i]["W6 D6"]);
      row.add(associateList[i]["W6 D7"]);
      row.add(associateList[i]["W7 D1"]);
      row.add(associateList[i]["W7 D2"]);
      row.add(associateList[i]["W7 D3"]);
      row.add(associateList[i]["W7 D4"]);
      row.add(associateList[i]["W7 D5"]);
      row.add(associateList[i]["W7 D6"]);
      row.add(associateList[i]["W7 D7"]);
      rows.add(row);
    }

    String csv = const ListToCsvConverter().convert(rows);

    // String? dir = (Platform.isAndroid
    //     ? await ExtStorage.getExternalStoragePublicDirectory(
    //         ExtStorage.DIRECTORY_DOWNLOADS)
    //     : await getApplicationSupportDirectory()) as String?;
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

  _shareStorageFile() async {
    Directory? dir = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    File testFile = File("${dir!.path}/flutter/test.txt");
    if (!await testFile.exists()) {
      await testFile.create(recursive: true);
      testFile.writeAsStringSync("test for share documents file");
    }
    ShareExtend.share(testFile.path, "file");
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
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => configure_users_screen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Configure Users',
                        style: TextStyle(
                          color: Color(0xff485370),
                          fontFamily: 'Avenir',
                          fontWeight: FontWeight.w400,
                          fontSize: 30,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        elevation: 2, backgroundColor: const Color(0xffF8EEF9),
                        padding: const EdgeInsets.only(
                            left: 30, right: 30, top: 5, bottom: 5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          side: BorderSide(color: Color(0xffB993BC), width: 1),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        getDownloadData();
                        // _generateCsvFiles();
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => download_data(),
                        //   ),
                        // );
                      },
                      child: const Text(
                        'Download Data',
                        style: TextStyle(
                          color: Color(0xff485370),
                          fontFamily: 'Avenir',
                          fontWeight: FontWeight.w400,
                          fontSize: 30,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.only(
                            left: 30, right: 30, top: 5, bottom: 5), backgroundColor: const Color(0xffF8EEF9),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          side: BorderSide(color: Color(0xffB993BC), width: 1),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => manage_admins_screen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Manage Admins',
                        style: TextStyle(
                          color: Color(0xff485370),
                          fontFamily: 'Avenir',
                          fontWeight: FontWeight.w400,
                          fontSize: 30,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.only(
                            left: 30, right: 30, top: 5, bottom: 5), backgroundColor: const Color(0xffF8EEF9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          side: BorderSide(color: Color(0xffB993BC), width: 1),
                        ),
                        elevation: 2,
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        logout();
                      },
                      child: const Text(
                        'Log Out',
                        style: TextStyle(
                          color: Color(0xff485370),
                          fontFamily: 'Avenir',
                          fontWeight: FontWeight.w400,
                          fontSize: 30,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.only(
                          left: 80, right: 80, top: 5, bottom: 5),
                        backgroundColor: const Color(0xffF8EEF9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          side: BorderSide(
                              color: const Color(0xffB993BC), width: 1),
                        ),
                        elevation: 2,
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
