import 'dart:io';

import 'package:csv/csv.dart';
import 'package:ext_storage/ext_storage.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:resarch_csv/utils/LoadCsvDataScreen.dart';

class download_data extends StatefulWidget {
  @override
  _download_data createState() => _download_data();
}

class _download_data extends State<download_data> {
  @override
  void initState() {
    super.initState();
    generateCsvFile();
  }

  void generateCsvFile() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
    ].request();

    List<dynamic> associateList = [
      {"number": 1, "lat": "14.97534313396318", "lon": "101.22998536005622"},
      {"number": 2, "lat": "14.97534313396318", "lon": "101.22998536005622"},
      {"number": 3, "lat": "14.97534313396318", "lon": "101.22998536005622"},
      {"number": 4, "lat": "14.97534313396318", "lon": "101.22998536005622"}
    ];

    List<List<dynamic>> rows = [];

    List<dynamic> row = [];
    row.add("number");
    row.add("latitude");
    row.add("longitude");
    rows.add(row);
    for (int i = 0; i < associateList.length; i++) {
      List<dynamic> row = [];
      row.add(associateList[i]["number"] - 1);
      row.add(associateList[i]["lat"]);
      row.add(associateList[i]["lon"]);
      rows.add(row);
    }

    String csv = const ListToCsvConverter().convert(rows);

    String? dir = await ExtStorage.getExternalStoragePublicDirectory(
        ExtStorage.DIRECTORY_DOWNLOADS);
    print("dir $dir");
    String file = "$dir";

    File f = File(file + "/filename.csv");

    f.writeAsString(csv);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("All CSV Files")),
      body: FutureBuilder(
        builder: (context, AsyncSnapshot<List<FileSystemEntity>> snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Text("empty");
          }
          print('${snapshot.data!.length} ${snapshot.data}');
          if (snapshot.data!.length == 0) {
            return Center(
              child: Text('No Csv File found.'),
            );
          }
          return ListView.builder(
            itemBuilder: (context, index) => Card(
              child: ListTile(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            LoadCsvDataScreen(path: snapshot.data![index].path),
                      ),
                    );
                  },
                  title: Text(
                    snapshot.data![index].path.substring(44),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
            ),
            itemCount: snapshot.data!.length,
          );
        },
      ),
    );
  }
}
