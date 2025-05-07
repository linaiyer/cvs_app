import 'dart:io';

import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:resarch_csv/utils/LoadCsvDataScreen.dart';

class DownloadData extends StatefulWidget {
  @override
  _DownloadData createState() => _DownloadData();
}

class _DownloadData extends State<DownloadData> {
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

    Directory? dir = await getExternalStorageDirectory();
    if (dir != null) {
      String path = "${dir.path}/Downloads";
      Directory(path).createSync(recursive: true);
      File file = File("$path/filename.csv");

      await file.writeAsString(csv);
    } else {
      print("Unable to find the external storage directory");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("All CSV Files")),
      body: FutureBuilder(
        future: _getCsvFiles(),
        builder: (context, AsyncSnapshot<List<FileSystemEntity>> snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No CSV file found."));
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
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
                  snapshot.data![index].path.split('/').last,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<List<FileSystemEntity>> _getCsvFiles() async {
    Directory? dir = await getExternalStorageDirectory();
    if (dir != null) {
      String path = "${dir.path}/Downloads";
      Directory directory = Directory(path);
      return directory.listSync().where((item) => item.path.endsWith(".csv")).toList();
    } else {
      return [];
    }
  }
}
