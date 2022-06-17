import 'dart:io';
import 'dart:typed_data';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:wakelock/wakelock.dart';

class play_video_outro_screen extends StatefulWidget {
  final title;
  final url;
  final week;
  final day;

  const play_video_outro_screen(
      {Key? key, this.title, this.url, this.week, this.day})
      : super(key: key);

  @override
  _play_video_outro_screen createState() => _play_video_outro_screen();
}

class _play_video_outro_screen extends State<play_video_outro_screen> {
  VideoPlayerController? _controller;

  Dio dio = Dio();

  bool play = true;
  bool check = false;
  bool showLoader = false;

  var userId;

  late Stream<DurationState> _durationState;
  AudioPlayer _player = AudioPlayer();
  Uint8List? bytes;

  final DateFormat formatter = DateFormat('dd/MM/yy');
  final DateFormat formatters = DateFormat('yyyy-dd-MM');
  final DateFormat formatterDone = DateFormat('yyyy-dd-MM');

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  String? dirPath;

  @override
  void initState() {
    super.initState();
    Wakelock.enable();
    setThubm();
    setData();
    // _durationState = Rx.combineLatest2<Duration, PlaybackEvent, DurationState>(
    //     _player.positionStream,
    //     _player.playbackEventStream,
    //     (position, playbackEvent) => DurationState(
    //           progress: position,
    //           buffered: playbackEvent.bufferedPosition,
    //           total: playbackEvent.duration,
    //         ));
    // _controller = VideoPlayerController.network(
    //   'https://firebasestorage.googleapis.com/v0/b/research-cvs.appspot.com/o/Free%20Online%20Meditation%20Masterclasses_%20%20English%20-%20Day%202.mp4?alt=media&token=0ff2c982-f1d5-47e7-989e-e2ffa22184df',
    //   videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    // )..initialize().then((_) {
    //     // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
    //
    //     getUserData();
    //   });
  }

  @override
  dispose() {
    Wakelock.disable();
    _controller!.dispose();
    super.dispose();
  }

  setThubm() async {
    setState(() {
      showLoader = true;
    });
    final fileName = await VideoThumbnail.thumbnailFile(
      video:
          'https://firebasestorage.googleapis.com/v0/b/research-cvs.appspot.com/o/outro.mp4?alt=media&token=9f9b7d8c-e06f-4332-8f8e-456761af1d89',
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.WEBP,
      maxHeight: 300,
      quality: 75,
    );

    final file = File(fileName!);
    if (mounted)
      setState(() {
        bytes = file.readAsBytesSync();
      });
  }

  setData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    if (pref.getString('outro_url') == null) {
      var path = await downloadFile(
          'https://firebasestorage.googleapis.com/v0/b/research-cvs.appspot.com/o/outro.mp4?alt=media&token=9f9b7d8c-e06f-4332-8f8e-456761af1d89');
      if (mounted)
        setState(() {
          dirPath = path;
        });
      pref.setString('outro_url', dirPath!);
      _durationState =
          Rx.combineLatest2<Duration, PlaybackEvent, DurationState>(
              _player.positionStream,
              _player.playbackEventStream,
              (position, playbackEvent) => DurationState(
                    progress: position,
                    buffered: playbackEvent.bufferedPosition,
                    total: playbackEvent.duration,
                  ));
      _controller = VideoPlayerController.file(
        File(dirPath!),
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      )..initialize().then((_) {
          // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
          getUserData();
        });
    } else {
      setState(() {
        dirPath = pref.getString('outro_url');
      });
      _durationState =
          Rx.combineLatest2<Duration, PlaybackEvent, DurationState>(
              _player.positionStream,
              _player.playbackEventStream,
              (position, playbackEvent) => DurationState(
                    progress: position,
                    buffered: playbackEvent.bufferedPosition,
                    total: playbackEvent.duration,
                  ));
      _controller = VideoPlayerController.file(
        File(dirPath!),
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      )..initialize().then((_) {
          // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
          getUserData();
        });
    }

/*    if (pref.getString(widget.title == ''
            ? 'intro_url'
            : widget.title == 'Outro'
                ? 'outro_url'
                : 'relax_url') ==
        null) {
      var path = await downloadFile(widget.url);
      if (mounted)
        setState(() {
          dirPath = path;
        });
      pref.setString(
          widget.title == 'Intro'
              ? 'intro_url'
              : widget.title == 'Outro'
                  ? 'outro_url'
                  : 'relax_url',
          dirPath!);
      _durationState =
          Rx.combineLatest2<Duration, PlaybackEvent, DurationState>(
              _player.positionStream,
              _player.playbackEventStream,
              (position, playbackEvent) => DurationState(
                    progress: position,
                    buffered: playbackEvent.bufferedPosition,
                    total: playbackEvent.duration,
                  ));
      _controller = VideoPlayerController.file(
        File(dirPath!),
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      )..initialize().then((_) {
          // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
          getUserData();
        });
    }
    else {
      setState(() {
        dirPath = pref.getString(widget.title == 'Intro'
            ? 'intro_url'
            : widget.title == 'Outro'
                ? 'outro_url'
                : 'relax_url');
      });
      _durationState =
          Rx.combineLatest2<Duration, PlaybackEvent, DurationState>(
              _player.positionStream,
              _player.playbackEventStream,
              (position, playbackEvent) => DurationState(
                    progress: position,
                    buffered: playbackEvent.bufferedPosition,
                    total: playbackEvent.duration,
                  ));
      _controller = VideoPlayerController.file(
        File(dirPath!),
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      )..initialize().then((_) {
          // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
          getUserData();
        });
    }*/
  }

  void showSnackBar(text) {
    _scaffoldKey.currentState!.showSnackBar(
      SnackBar(
        content: Text(text),
      ),
    );
  }

  getUserData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      check = pref.get('user_id') != null ? true : false;
      userId = pref.get('user_id');
      showLoader = false;
    });
    setState(() {
      _player.setVolume(0);
      _player.setFilePath(dirPath!);
    });
  }

  getVideoData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    FirebaseFirestore.instance
        .collection('watchDataTable')
        .where('user_id', isEqualTo: pref.getString('user_id'))
        .get()
        .then((QuerySnapshot querySnapshot) => {
              querySnapshot.docs.forEach((doc) {
                if (doc != null) {
                  Map<String, dynamic>? docsData =
                      doc.data() as Map<String, dynamic>?;
                  print('documentData.toString()');
                  print(docsData.toString());
                  setState(() {
                    _player.setVolume(0);
                    _player.setFilePath(dirPath!);
                    // 'https://firebasestorage.googleapis.com/v0/b/research-cvs.appspot.com/o/Free%20Online%20Meditation%20Masterclasses_%20%20English%20-%20Day%202.mp4?alt=media&token=0ff2c982-f1d5-47e7-989e-e2ffa22184df');
                  });
                  if (widget.week + 1 == 2) {
                    if (widget.day == 1) {
                      if (docsData!['W1 D1'].isNotEmpty) {
                        _player.seek(parseDuration(docsData['W1 D1']));
                        _controller!.seekTo(parseDuration(docsData['W1 D1']));
                        print(_player.duration);
                        print(_controller!.value.duration);
                      }
                    } else if (widget.day == 2) {
                      if (docsData!['W1 D2'].isNotEmpty) {
                        _player.seek(parseDuration(docsData['W1 D2']));
                        _controller!.seekTo(parseDuration(docsData['W1 D2']));
                      }
                    } else if (widget.day == 3) {
                      if (docsData!['W1 D3'].isNotEmpty) {
                        _player.seek(parseDuration(docsData['W1 D3']));
                        _controller!.seekTo(parseDuration(docsData['W1 D3']));
                      }
                    } else if (widget.day == 4) {
                      if (docsData!['W1 AP'].isNotEmpty) {
                        _player.seek(parseDuration(docsData['W1 AP']));
                        _controller!.seekTo(parseDuration(docsData['W1 AP']));
                      }
                    }
                  } else if (widget.week + 1 == 3) {
                    if (widget.day == 1) {
                      if (docsData!['W2 D1'].isNotEmpty) {
                        _player.seek(parseDuration(docsData['W2 D1']));
                        _controller!.seekTo(parseDuration(docsData['W2 D1']));
                      }
                    } else if (widget.day == 2) {
                      if (docsData!['W2 D2'].isNotEmpty) {
                        _player.seek(parseDuration(docsData['W2 D2']));
                        _controller!.seekTo(parseDuration(docsData['W2 D2']));
                      }
                    } else if (widget.day == 3) {
                      if (docsData!['W2 D3'].isNotEmpty) {
                        _player.seek(parseDuration(docsData['W2 D3']));
                        _controller!.seekTo(parseDuration(docsData['W2 D3']));
                      }
                    } else if (widget.day == 4) {
                      if (docsData!['W2 AP'].isNotEmpty) {
                        _player.seek(parseDuration(docsData['W2 AP']));
                        _controller!.seekTo(parseDuration(docsData['W2 AP']));
                      }
                    }
                  } else if (widget.week + 1 == 4) {
                    if (widget.day == 1) {
                      if (docsData!['W3 D1'].isNotEmpty) {
                        _player.seek(parseDuration(docsData['W3 D1']));
                        _controller!.seekTo(parseDuration(docsData['W3 D1']));
                      }
                    } else if (widget.day == 2) {
                      if (docsData!['W3 D2'].isNotEmpty) {
                        _player.seek(parseDuration(docsData['W3 D2']));
                        _controller!.seekTo(parseDuration(docsData['W3 D2']));
                      }
                    } else if (widget.day == 3) {
                      if (docsData!['W3 D3'].isNotEmpty) {
                        _player.seek(parseDuration(docsData['W3 D3']));
                        _controller!.seekTo(parseDuration(docsData['W3 D3']));
                      }
                    } else if (widget.day == 4) {
                      if (docsData!['W3 AP'].isNotEmpty) {
                        _player.seek(parseDuration(docsData['W3 AP']));
                        _controller!.seekTo(parseDuration(docsData['W3 AP']));
                      }
                    }
                  } else if (widget.week + 1 == 5) {
                    if (widget.day == 1) {
                      if (docsData!['W4 D1'].isNotEmpty) {
                        _player.seek(parseDuration(docsData['W4 D1']));
                        _controller!.seekTo(parseDuration(docsData['W4 D1']));
                      }
                    } else if (widget.day == 2) {
                      if (docsData!['W4 D2'].isNotEmpty) {
                        _player.seek(parseDuration(docsData['W4 D2']));
                        _controller!.seekTo(parseDuration(docsData['W4 D2']));
                      } else {}
                    } else if (widget.day == 3) {
                      if (docsData!['W4 D3'].isNotEmpty) {
                        _player.seek(parseDuration(docsData['W4 D3']));
                        _controller!.seekTo(parseDuration(docsData['W4 D3']));
                      }
                    } else if (widget.day == 4) {
                      if (docsData!['W4 AP'].isNotEmpty) {
                        _player.seek(parseDuration(docsData['W4 AP']));
                        _controller!.seekTo(parseDuration(docsData['W4 AP']));
                      }
                    }
                  } else if (widget.week + 1 == 6) {
                    if (widget.day == 1) {
                      if (docsData!['W5 D1'].isNotEmpty) {
                        _player.seek(parseDuration(docsData['W5 D1']));
                        _controller!.seekTo(parseDuration(docsData['W5 D1']));
                      }
                    } else if (widget.day == 2) {
                      if (docsData!['W5 D2'].isNotEmpty) {
                        _player.seek(parseDuration(docsData['W5 D2']));
                        _controller!.seekTo(parseDuration(docsData['W5 D2']));
                      }
                    } else if (widget.day == 3) {
                      if (docsData!['W5 D3'].isNotEmpty) {
                        _player.seek(parseDuration(docsData['W5 D3']));
                        _controller!.seekTo(parseDuration(docsData['W5 D3']));
                      }
                    } else if (widget.day == 4) {
                      if (docsData!['W5 AP'].isNotEmpty) {
                        _player.seek(parseDuration(docsData['W5 AP']));
                        _controller!.seekTo(parseDuration(docsData['W5 AP']));
                      }
                    }
                  } else if (widget.week + 1 == 7) {
                    if (widget.day == 1) {
                      if (docsData!['W6 D1'].isNotEmpty) {
                        _player.seek(parseDuration(docsData['W6 D1']));
                        _controller!.seekTo(parseDuration(docsData['W6 D1']));
                      }
                    } else if (widget.day == 2) {
                      if (docsData!['W6 D2'].isEmpty) {
                        _player.seek(parseDuration(docsData['W6 D2']));
                        _controller!.seekTo(parseDuration(docsData['W6 D2']));
                      }
                    } else if (widget.day == 3) {
                      if (docsData!['W6 D3'].isNotEmpty) {
                        _player.seek(parseDuration(docsData['W6 D3']));
                        _controller!.seekTo(parseDuration(docsData['W6 D3']));
                      }
                    } else if (widget.day == 4) {
                      if (docsData!['W6 AP'].isNotEmpty) {
                        _player.seek(parseDuration(docsData['W6 AP']));
                        _controller!.seekTo(parseDuration(docsData['W6 AP']));
                      }
                    }
                  }
                } else {}
              }),
            });
  }

  Duration parseDuration(String s) {
    int hours = 0;
    int minutes = 0;
    int micros;
    List<String> parts = s.split(':');
    if (parts.length > 2) {
      hours = int.parse(parts[parts.length - 3]);
    }
    if (parts.length > 1) {
      minutes = int.parse(parts[parts.length - 2]);
    }
    micros = (double.parse(parts[parts.length - 1]) * 1000000).round();
    return Duration(hours: hours, minutes: minutes, microseconds: micros);
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

  updateDataOfUserNew(time) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    FirebaseFirestore.instance
        .collection('user')
        .where('id', isEqualTo: pref.getString('user_id'))
        .get()
        .then((QuerySnapshot querySnapshot) => {
              querySnapshot.docs.forEach((doc) {
                if (doc != null) {
                  Map<String, dynamic>? userData =
                      doc.data() as Map<String, dynamic>?;
                  print('user data');
                  print(userData.toString());
                  if (int.parse(userData!['done_week']) == 0) {
                    FirebaseFirestore.instance
                        .collection('user')
                        .doc(pref.getString('user_id'))
                        .update({
                      'done_week': widget.day == null || widget.day == 4
                          ? (widget.week + 1).toString()
                          : widget.week.toString(),
                      // 'done_day': widget.day == null || widget.day == 4
                      //     ? '0'
                      //     : widget.day.toString(),
                      'achievement': widget.day == null || widget.day == 4
                          ? (widget.week + 1).toString()
                          : widget.week.toString(),
                      'done_date':
                          formatterDone.format(DateTime.now()).toString(),
                    });
                  } else if (int.parse(userData['done_week']) >= widget.week) {
                    if (int.parse(userData['done_day']) >= 3) {
                      FirebaseFirestore.instance
                          .collection('user')
                          .doc(pref.getString('user_id'))
                          .update({
                        // 'done_week': widget.day == null || widget.day == 4
                        //     ? (widget.week + 1).toString()
                        //     : widget.week.toString(),
                        'done_day':
                            int.parse(userData['done_week']) >= widget.week
                                ? int.parse(userData['done_day']) > widget.day
                                    ? userData['done_day']
                                    : widget.day.toString()
                                : "0",
                        // widget.day == null || widget.day == 4
                        // ? '0'
                        // : widget.day.toString(),

                        'achievement':
                            int.parse(userData['done_week']) >= widget.week
                                ? userData['achievement']
                                : widget.day == null || widget.day == 4
                                    ? (widget.week + 1).toString()
                                    : userData['achievement'],
                        // 'done_date': formatterDone.format(DateTime.now()).toString(),
                      });
                      // if (widget.week > 0) {
                      //   if (userData['done_date'].trim().isEmpty) {
                      //     setDtatOfParam(int.parse(userData['done_week']), int.parse(userData['done_day']), time, true);
                      // }
                      /*      else {
                          if (formatters.format(DateTime.now()).compareTo(userData['done_date']) == 0) {
                            if (int.parse(userData['done_day']) == 0) {
                              setDtatOfParam(int.parse(userData['done_week']) - 1, 3, time, true);
                            } else {
                              setDtatOfParam(int.parse(userData['done_week']), int.parse(userData['done_day']), time, true);
                            }
                          }else{
                            setDtatOfParam(int.parse(userData['done_week']), int.parse(userData['done_day']), time, true);
                          }
                        }*/
                      // if (int.parse(userData['done_day']) == 0) {
                      //   updateTableDataNew('W${userData['done_week']} D1', time, true);
                      // } else if (int.parse(userData['done_day']) == 1) {
                      //   updateTableDataNew('W${userData['done_week']} D2', time, true);
                      // } else if (int.parse(userData['done_day']) == 2) {
                      //   updateTableDataNew('W${userData['done_week']} D3', time, true);
                      // } else if (int.parse(userData['done_day']) == 3) {
                      //   updateTableDataNew('W${userData['done_week']} AP', time, true);
                      // }
                      // }
                    }
                    /*else {
                      if (userData['done_date'].trim().isEmpty) {
                        setDtatOfParam(int.parse(userData['done_week']), int.parse(userData['done_day']), time, false);
                      } else {
                        if (formatters.format(DateTime.now()).compareTo(userData['done_date']) == 0) {
                          if (int.parse(userData['done_day']) == 0) {
                            setDtatOfParam(int.parse(userData['done_week']) - 1, 3, time, false);
                          } else {
                            setDtatOfParam(int.parse(userData['done_week']), int.parse(userData['done_day']), time, false);
                          }
                        }else{
                          setDtatOfParam(int.parse(userData['done_week']), int.parse(userData['done_day']), time, false);
                        }
                        // if (int.parse(userData['done_day']) == 0) {
                        //   updateTableDataNew(
                        //       'W${userData['done_week']} D1', time, false);
                        // } else if (int.parse(userData['done_day']) == 1) {
                        //   updateTableDataNew(
                        //       'W${userData['done_week']} D2', time, false);
                        // } else if (int.parse(userData['done_day']) == 2) {
                        //   updateTableDataNew(
                        //       'W${userData['done_week']} D3', time, false);
                        // } else if (int.parse(userData['done_day']) == 3) {
                        //   updateTableDataNew(
                        //       'W${userData['done_week']} AP', time, false);
                        // }
                      }
                    }*/
                  }
                  /*    else {
                    updateDataOfTableNew(time);
                  }*/
                } else {
                  print('doc else');
                }
              }),
            });
  }

  setDateOfParam(done_week, done_day, time, check) {
    if (done_day == 0) {
      updateTableDataNew('W${done_week} D1', time, check);
    } else if (done_day == 1) {
      updateTableDataNew('W${done_week} D2', time, check);
    } else if (done_day == 2) {
      updateTableDataNew('W${done_week} D3', time, check);
    } else if (done_day == 3) {
      updateTableDataNew('W${done_week} AP', time, check);
    }
  }

  updateDataOfTableNew(time) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    FirebaseFirestore.instance
        .collection('user')
        .where('id', isEqualTo: pref.getString('user_id'))
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        if (doc != null) {
          Map<String, dynamic>? documentData =
              doc.data() as Map<String, dynamic>?;

          print('user data');
          print(documentData.toString());

          if (widget.week > 0) {
            if (documentData!['done_date'].trim().isEmpty) {
              print('empty');
              print(documentData['done_date'].trim().isEmpty);
              setDateOfParam(int.parse(documentData['done_week']),
                  int.parse(documentData['done_day']), time, false);
            } else {
              print('not empty');
              if (formatters
                      .format(DateTime.now())
                      .compareTo(documentData['done_date']) ==
                  0) {
                print('done_date 0');
                if (int.parse(documentData['done_day']) == 0) {
                  print('day 0');
                  setDateOfParam(
                      int.parse(documentData['done_week']) - 1, 3, time, false);
                } else {
                  print('day not');
                  setDateOfParam(int.parse(documentData['done_week']),
                      int.parse(documentData['done_day']), time, false);
                }
              } else {
                print('done_date not 0');
                setDateOfParam(int.parse(documentData['done_week']),
                    int.parse(documentData['done_day']), time, false);
              }
            }
            // if (int.parse(documentData!['done_day']) == 0) {
            //   updateTableDataNew('W${documentData['done_week']} D1', time, false);
            // } else if (int.parse(documentData['done_day']) == 1) {
            //   updateTableDataNew('W${documentData['done_week']} D2', time, false);
            // } else if (int.parse(documentData['done_day']) == 2) {
            //   updateTableDataNew('W${documentData['done_week']} D3', time, false);
            // } else if (int.parse(documentData['done_day']) == 3) {
            //   updateTableDataNew('W${documentData['done_week']} AP', time, false);
            // }
          }
        }
      });
      // FirebaseFirestore.instance
      //     .collection('watchDataTable')
      //     .where('user_id', isEqualTo: pref.getString('user_id'))
      //     .get()
      //     .then((QuerySnapshot querySnapshot) => {
      //           querySnapshot.docs.forEach((doc) {
      //             if (doc != null) {
      //               Map<String, dynamic>? docsData =
      //                   doc.data() as Map<String, dynamic>?;
      //
      //               print('documentData.toString()');
      //               print(docsData.toString());
      //               if (widget.week > 0) {
      //                 if (int.parse(docsData!['done_day']) > 0) {
      //                   updateTableDataNew(
      //                       'W${docsData['done_week']} D${docsData['done_day']}',
      //                       time);
      //                 }
      //               }
      //               // if (widget.week + 1 == 2) {
      //               //   if (widget.day == 1) {
      //               //     if (docsData!['W1 D1'].isEmpty) {
      //               //       addTableData('W1 D1', time);
      //               //     } else {
      //               //       if (time > parseDuration(docsData['W1 D1'])) {
      //               //         updateTableData('W1 D1', time);
      //               //       }
      //               //     }
      //               //   }
      //               //   else if (widget.day == 2) {
      //               //     if (docsData!['W1 D2'].isEmpty) {
      //               //       addTableData('W1 D2', time);
      //               //     } else {
      //               //       if (time > parseDuration(docsData['W1 D2'])) {
      //               //         updateTableData('W1 D2', time);
      //               //       }
      //               //     }
      //               //   }
      //               //   else if (widget.day == 3) {
      //               //     if (docsData!['W1 D3'].isEmpty) {
      //               //       addTableData('W1 D3', time);
      //               //     } else {
      //               //       if (time > parseDuration(docsData['W1 D3'])) {
      //               //         updateTableData('W1 D3', time);
      //               //       }
      //               //     }
      //               //   } else if (widget.day == 4) {
      //               //     if (docsData!['W1 AP'].isEmpty) {
      //               //       addTableData('W1 AP', time);
      //               //     } else {
      //               //       if (time > parseDuration(docsData['W1 AP'])) {
      //               //         updateTableData('W1 AP', time);
      //               //       }
      //               //     }
      //               //   }
      //               // }
      //               // else if (widget.week + 1 == 3) {
      //               //   if (widget.day == 1) {
      //               //     if (docsData!['W2 D1'].isEmpty) {
      //               //       addTableData('W2 D1', time);
      //               //     } else {
      //               //       if (time > parseDuration(docsData['W2 D1'])) {
      //               //         updateTableData('W2 D1', time);
      //               //       }
      //               //     }
      //               //   } else if (widget.day == 2) {
      //               //     if (docsData!['W2 D2'].isEmpty) {
      //               //       addTableData('W2 D2', time);
      //               //     } else {
      //               //       if (time > parseDuration(docsData['W2 D2'])) {
      //               //         updateTableData('W2 D2', time);
      //               //       }
      //               //     }
      //               //   } else if (widget.day == 3) {
      //               //     if (docsData!['W2 D3'].isEmpty) {
      //               //       addTableData('W2 D3', time);
      //               //     } else {
      //               //       if (time > parseDuration(docsData['W2 D3'])) {
      //               //         updateTableData('W2 D3', time);
      //               //       }
      //               //     }
      //               //   } else if (widget.day == 4) {
      //               //     if (docsData!['W2 AP'].isEmpty) {
      //               //       addTableData('W2 AP', time);
      //               //     } else {
      //               //       if (time > parseDuration(docsData['W2 AP'])) {
      //               //         updateTableData('W2 AP', time);
      //               //       }
      //               //     }
      //               //   }
      //               // }
      //               // else if (widget.week + 1 == 4) {
      //               //   if (widget.day == 1) {
      //               //     if (docsData!['W3 D1'].isEmpty) {
      //               //       addTableData('W3 D1', time);
      //               //     } else {
      //               //       if (time > parseDuration(docsData['W3 D1'])) {
      //               //         updateTableData('W3 D1', time);
      //               //       }
      //               //     }
      //               //   } else if (widget.day == 2) {
      //               //     if (docsData!['W3 D2'].isEmpty) {
      //               //       addTableData('W3 D2', time);
      //               //     } else {
      //               //       if (time > parseDuration(docsData['W3 D2'])) {
      //               //         updateTableData('W3 D2', time);
      //               //       }
      //               //     }
      //               //   } else if (widget.day == 3) {
      //               //     if (docsData!['W3 D3'].isEmpty) {
      //               //       addTableData('W3 D3', time);
      //               //     } else {
      //               //       if (time > parseDuration(docsData['W3 D3'])) {
      //               //         updateTableData('W3 D3', time);
      //               //       }
      //               //     }
      //               //   } else if (widget.day == 4) {
      //               //     if (docsData!['W3 AP'].isEmpty) {
      //               //       addTableData('W3 AP', time);
      //               //     } else {
      //               //       if (time > parseDuration(docsData['W3 AP'])) {
      //               //         updateTableData('W3 AP', time);
      //               //       }
      //               //     }
      //               //   }
      //               // }
      //               // else if (widget.week + 1 == 5) {
      //               //   if (widget.day == 1) {
      //               //     if (docsData!['W4 D1'].isEmpty) {
      //               //       addTableData('W4 D1', time);
      //               //     } else {
      //               //       if (time > parseDuration(docsData['W4 D1'])) {
      //               //         updateTableData('W4 D1', time);
      //               //       }
      //               //     }
      //               //   } else if (widget.day == 2) {
      //               //     if (docsData!['W4 D2'].isEmpty) {
      //               //       addTableData('W4 D2', time);
      //               //     } else {
      //               //       if (time > parseDuration(docsData['W4 D2'])) {
      //               //         updateTableData('W4 D2', time);
      //               //       }
      //               //     }
      //               //   } else if (widget.day == 3) {
      //               //     if (docsData!['W4 D3'].isEmpty) {
      //               //       addTableData('W4 D3', time);
      //               //     } else {
      //               //       if (time > parseDuration(docsData['W4 D3'])) {
      //               //         updateTableData('W4 D3', time);
      //               //       }
      //               //     }
      //               //   } else if (widget.day == 4) {
      //               //     if (docsData!['W4 AP'].isEmpty) {
      //               //       addTableData('W4 AP', time);
      //               //     } else {
      //               //       if (time > parseDuration(docsData['W4 AP'])) {
      //               //         updateTableData('W4 AP', time);
      //               //       }
      //               //     }
      //               //   }
      //               // }
      //               // else if (widget.week + 1 == 6) {
      //               //   if (widget.day == 1) {
      //               //     if (docsData!['W5 D1'].isEmpty) {
      //               //       addTableData('W5 D1', time);
      //               //     } else {
      //               //       if (time > parseDuration(docsData['W5 D1'])) {
      //               //         updateTableData('W5 D1', time);
      //               //       }
      //               //     }
      //               //   } else if (widget.day == 2) {
      //               //     if (docsData!['W5 D2'].isEmpty) {
      //               //       addTableData('W5 D2', time);
      //               //     } else {
      //               //       if (time > parseDuration(docsData['W5 D2'])) {
      //               //         updateTableData('W5 D2', time);
      //               //       }
      //               //     }
      //               //   } else if (widget.day == 3) {
      //               //     if (docsData!['W5 D3'].isEmpty) {
      //               //       addTableData('W5 D3', time);
      //               //     } else {
      //               //       if (time > parseDuration(docsData['W5 D3'])) {
      //               //         updateTableData('W5 D3', time);
      //               //       }
      //               //     }
      //               //   } else if (widget.day == 4) {
      //               //     if (docsData!['W5 AP'].isEmpty) {
      //               //       addTableData('W5 AP', time);
      //               //     } else {
      //               //       if (time > parseDuration(docsData['W5 AP'])) {
      //               //         updateTableData('W5 AP', time);
      //               //       }
      //               //     }
      //               //   }
      //               // }
      //               // else if (widget.week + 1 == 7) {
      //               //   if (widget.day == 1) {
      //               //     if (docsData!['W6 D1'].isEmpty) {
      //               //       addTableData('W6 D1', time);
      //               //     } else {
      //               //       if (time > parseDuration(docsData['W6 D1'])) {
      //               //         updateTableData('W6 D1', time);
      //               //       }
      //               //     }
      //               //   } else if (widget.day == 2) {
      //               //     if (docsData!['W6 D2'].isEmpty) {
      //               //       addTableData('W6 D2', time);
      //               //     } else {
      //               //       if (time > parseDuration(docsData['W6 D2'])) {
      //               //         updateTableData('W6 D2', time);
      //               //       }
      //               //     }
      //               //   } else if (widget.day == 3) {
      //               //     if (docsData!['W6 D3'].isEmpty) {
      //               //       addTableData('W6 D3', time);
      //               //     } else {
      //               //       if (time > parseDuration(docsData['W6 D3'])) {
      //               //         updateTableData('W6 D3', time);
      //               //       }
      //               //     }
      //               //   } else if (widget.day == 4) {
      //               //     if (docsData!['W6 AP'].isEmpty) {
      //               //       addTableData('W6 AP', time);
      //               //     } else {
      //               //       if (time > parseDuration(docsData['W6 AP'])) {
      //               //         updateTableData('W6 AP', time);
      //               //       }
      //               //     }
      //               //   }
      //               // }
      //             }
      //           }),
      //         });
    });
  }

  /*start old code*/

  // updateDataOfUser(time) async {
  //   SharedPreferences pref = await SharedPreferences.getInstance();
  //   FirebaseFirestore.instance
  //       .collection('user')
  //       .where('id', isEqualTo: pref.getString('user_id'))
  //       .get()
  //       .then((QuerySnapshot querySnapshot) => {
  //             querySnapshot.docs.forEach((doc) {
  //               if (doc != null) {
  //                 Map<String, dynamic>? documentData =
  //                     doc.data() as Map<String, dynamic>?;
  //                 print('documentData.toString()');
  //                 print(documentData.toString());
  //                 if (int.parse(documentData!['done_week']) <= widget.week) {
  //                   print('done_week');
  //                   if (widget.day != null) {
  //                     print('widget.day');
  //                     if (int.parse(documentData['done_day']) <= widget.day) {
  //                       print('done_day');
  //                       FirebaseFirestore.instance
  //                           .collection('user')
  //                           .doc(pref.getString('user_id'))
  //                           .update({
  //                         'done_week': widget.day == null || widget.day == 4
  //                             ? (widget.week + 1).toString()
  //                             : widget.week.toString(),
  //                         'done_day': widget.day == null || widget.day == 4
  //                             ? '0'
  //                             : widget.day.toString(),
  //                         'achievement': widget.day == null || widget.day == 4
  //                             ? (widget.week + 1).toString()
  //                             : widget.week.toString(),
  //                         'done_date':
  //                             formatterDone.format(DateTime.now()).toString(),
  //                       }).whenComplete(() => {
  //                                 if (widget.day != null)
  //                                   {
  //                                     FirebaseFirestore.instance
  //                                         .collection('watchDataTable')
  //                                         .where('user_id',
  //                                             isEqualTo:
  //                                                 pref.getString('user_id'))
  //                                         .get()
  //                                         .then((QuerySnapshot querySnapshot) =>
  //                                             {
  //                                               querySnapshot.docs
  //                                                   .forEach((doc) {
  //                                                 if (doc != null) {
  //                                                   Map<String, dynamic>?
  //                                                       docsData = doc.data()
  //                                                           as Map<String,
  //                                                               dynamic>?;
  //                                                   print(
  //                                                       'documentData.toString()');
  //                                                   print(docsData.toString());
  //                                                   if (widget.week + 1 == 2) {
  //                                                     if (widget.day == 1) {
  //                                                       if (docsData!['W1 D1']
  //                                                           .isEmpty) {
  //                                                         addTableData(
  //                                                             'W1 D1', time);
  //                                                       } else {
  //                                                         if (time >
  //                                                             parseDuration(
  //                                                                 docsData[
  //                                                                     'W1 D1'])) {
  //                                                           updateTableData(
  //                                                               'W1 D1', time);
  //                                                         }
  //                                                       }
  //                                                     } else if (widget.day ==
  //                                                         2) {
  //                                                       if (docsData!['W1 D2']
  //                                                           .isEmpty) {
  //                                                         addTableData(
  //                                                             'W1 D2', time);
  //                                                       } else {
  //                                                         if (time >
  //                                                             parseDuration(
  //                                                                 docsData[
  //                                                                     'W1 D2'])) {
  //                                                           updateTableData(
  //                                                               'W1 D2', time);
  //                                                         }
  //                                                       }
  //                                                     } else if (widget.day ==
  //                                                         3) {
  //                                                       if (docsData!['W1 D3']
  //                                                           .isEmpty) {
  //                                                         addTableData(
  //                                                             'W1 D3', time);
  //                                                       } else {
  //                                                         if (time >
  //                                                             parseDuration(
  //                                                                 docsData[
  //                                                                     'W1 D3'])) {
  //                                                           updateTableData(
  //                                                               'W1 D3', time);
  //                                                         }
  //                                                       }
  //                                                     } else if (widget.day ==
  //                                                         4) {
  //                                                       if (docsData!['W1 AP']
  //                                                           .isEmpty) {
  //                                                         addTableData(
  //                                                             'W1 AP', time);
  //                                                       } else {
  //                                                         if (time >
  //                                                             parseDuration(
  //                                                                 docsData[
  //                                                                     'W1 AP'])) {
  //                                                           updateTableData(
  //                                                               'W1 AP', time);
  //                                                         }
  //                                                       }
  //                                                     }
  //                                                   } else if (widget.week +
  //                                                           1 ==
  //                                                       3) {
  //                                                     if (widget.day == 1) {
  //                                                       if (docsData!['W2 D1']
  //                                                           .isEmpty) {
  //                                                         addTableData(
  //                                                             'W2 D1', time);
  //                                                       } else {
  //                                                         if (time >
  //                                                             parseDuration(
  //                                                                 docsData[
  //                                                                     'W2 D1'])) {
  //                                                           updateTableData(
  //                                                               'W2 D1', time);
  //                                                         }
  //                                                       }
  //                                                     } else if (widget.day ==
  //                                                         2) {
  //                                                       if (docsData!['W2 D2']
  //                                                           .isEmpty) {
  //                                                         addTableData(
  //                                                             'W2 D2', time);
  //                                                       } else {
  //                                                         if (time >
  //                                                             parseDuration(
  //                                                                 docsData[
  //                                                                     'W2 D2'])) {
  //                                                           updateTableData(
  //                                                               'W2 D2', time);
  //                                                         }
  //                                                       }
  //                                                     } else if (widget.day ==
  //                                                         3) {
  //                                                       if (docsData!['W2 D3']
  //                                                           .isEmpty) {
  //                                                         addTableData(
  //                                                             'W2 D3', time);
  //                                                       } else {
  //                                                         if (time >
  //                                                             parseDuration(
  //                                                                 docsData[
  //                                                                     'W2 D3'])) {
  //                                                           updateTableData(
  //                                                               'W2 D3', time);
  //                                                         }
  //                                                       }
  //                                                     } else if (widget.day ==
  //                                                         4) {
  //                                                       if (docsData!['W2 AP']
  //                                                           .isEmpty) {
  //                                                         addTableData(
  //                                                             'W2 AP', time);
  //                                                       } else {
  //                                                         if (time >
  //                                                             parseDuration(
  //                                                                 docsData[
  //                                                                     'W2 AP'])) {
  //                                                           updateTableData(
  //                                                               'W2 AP', time);
  //                                                         }
  //                                                       }
  //                                                     }
  //                                                   } else if (widget.week +
  //                                                           1 ==
  //                                                       4) {
  //                                                     if (widget.day == 1) {
  //                                                       if (docsData!['W3 D1']
  //                                                           .isEmpty) {
  //                                                         addTableData(
  //                                                             'W3 D1', time);
  //                                                       } else {
  //                                                         if (time >
  //                                                             parseDuration(
  //                                                                 docsData[
  //                                                                     'W3 D1'])) {
  //                                                           updateTableData(
  //                                                               'W3 D1', time);
  //                                                         }
  //                                                       }
  //                                                     } else if (widget.day ==
  //                                                         2) {
  //                                                       if (docsData!['W3 D2']
  //                                                           .isEmpty) {
  //                                                         addTableData(
  //                                                             'W3 D2', time);
  //                                                       } else {
  //                                                         if (time >
  //                                                             parseDuration(
  //                                                                 docsData[
  //                                                                     'W3 D2'])) {
  //                                                           updateTableData(
  //                                                               'W3 D2', time);
  //                                                         }
  //                                                       }
  //                                                     } else if (widget.day ==
  //                                                         3) {
  //                                                       if (docsData!['W3 D3']
  //                                                           .isEmpty) {
  //                                                         addTableData(
  //                                                             'W3 D3', time);
  //                                                       } else {
  //                                                         if (time >
  //                                                             parseDuration(
  //                                                                 docsData[
  //                                                                     'W3 D3'])) {
  //                                                           updateTableData(
  //                                                               'W3 D3', time);
  //                                                         }
  //                                                       }
  //                                                     } else if (widget.day ==
  //                                                         4) {
  //                                                       if (docsData!['W3 AP']
  //                                                           .isEmpty) {
  //                                                         addTableData(
  //                                                             'W3 AP', time);
  //                                                       } else {
  //                                                         if (time >
  //                                                             parseDuration(
  //                                                                 docsData[
  //                                                                     'W3 AP'])) {
  //                                                           updateTableData(
  //                                                               'W3 AP', time);
  //                                                         }
  //                                                       }
  //                                                     }
  //                                                   } else if (widget.week +
  //                                                           1 ==
  //                                                       5) {
  //                                                     if (widget.day == 1) {
  //                                                       if (docsData!['W4 D1']
  //                                                           .isEmpty) {
  //                                                         addTableData(
  //                                                             'W4 D1', time);
  //                                                       } else {
  //                                                         if (time >
  //                                                             parseDuration(
  //                                                                 docsData[
  //                                                                     'W4 D1'])) {
  //                                                           updateTableData(
  //                                                               'W4 D1', time);
  //                                                         }
  //                                                       }
  //                                                     } else if (widget.day ==
  //                                                         2) {
  //                                                       if (docsData!['W4 D2']
  //                                                           .isEmpty) {
  //                                                         addTableData(
  //                                                             'W4 D2', time);
  //                                                       } else {
  //                                                         if (time >
  //                                                             parseDuration(
  //                                                                 docsData[
  //                                                                     'W4 D2'])) {
  //                                                           updateTableData(
  //                                                               'W4 D2', time);
  //                                                         }
  //                                                       }
  //                                                     } else if (widget.day ==
  //                                                         3) {
  //                                                       if (docsData!['W4 D3']
  //                                                           .isEmpty) {
  //                                                         addTableData(
  //                                                             'W4 D3', time);
  //                                                       } else {
  //                                                         if (time >
  //                                                             parseDuration(
  //                                                                 docsData[
  //                                                                     'W4 D3'])) {
  //                                                           updateTableData(
  //                                                               'W4 D3', time);
  //                                                         }
  //                                                       }
  //                                                     } else if (widget.day ==
  //                                                         4) {
  //                                                       if (docsData!['W4 AP']
  //                                                           .isEmpty) {
  //                                                         addTableData(
  //                                                             'W4 AP', time);
  //                                                       } else {
  //                                                         if (time >
  //                                                             parseDuration(
  //                                                                 docsData[
  //                                                                     'W4 AP'])) {
  //                                                           updateTableData(
  //                                                               'W4 AP', time);
  //                                                         }
  //                                                       }
  //                                                     }
  //                                                   } else if (widget.week +
  //                                                           1 ==
  //                                                       6) {
  //                                                     if (widget.day == 1) {
  //                                                       if (docsData!['W5 D1']
  //                                                           .isEmpty) {
  //                                                         addTableData(
  //                                                             'W5 D1', time);
  //                                                       } else {
  //                                                         if (time >
  //                                                             parseDuration(
  //                                                                 docsData[
  //                                                                     'W5 D1'])) {
  //                                                           updateTableData(
  //                                                               'W5 D1', time);
  //                                                         }
  //                                                       }
  //                                                     } else if (widget.day ==
  //                                                         2) {
  //                                                       if (docsData!['W5 D2']
  //                                                           .isEmpty) {
  //                                                         addTableData(
  //                                                             'W5 D2', time);
  //                                                       } else {
  //                                                         if (time >
  //                                                             parseDuration(
  //                                                                 docsData[
  //                                                                     'W5 D2'])) {
  //                                                           updateTableData(
  //                                                               'W5 D2', time);
  //                                                         }
  //                                                       }
  //                                                     } else if (widget.day ==
  //                                                         3) {
  //                                                       if (docsData!['W5 D3']
  //                                                           .isEmpty) {
  //                                                         addTableData(
  //                                                             'W5 D3', time);
  //                                                       } else {
  //                                                         if (time >
  //                                                             parseDuration(
  //                                                                 docsData[
  //                                                                     'W5 D3'])) {
  //                                                           updateTableData(
  //                                                               'W5 D3', time);
  //                                                         }
  //                                                       }
  //                                                     } else if (widget.day ==
  //                                                         4) {
  //                                                       if (docsData!['W5 AP']
  //                                                           .isEmpty) {
  //                                                         addTableData(
  //                                                             'W5 AP', time);
  //                                                       } else {
  //                                                         if (time >
  //                                                             parseDuration(
  //                                                                 docsData[
  //                                                                     'W5 AP'])) {
  //                                                           updateTableData(
  //                                                               'W5 AP', time);
  //                                                         }
  //                                                       }
  //                                                     }
  //                                                   } else if (widget.week +
  //                                                           1 ==
  //                                                       7) {
  //                                                     if (widget.day == 1) {
  //                                                       if (docsData!['W6 D1']
  //                                                           .isEmpty) {
  //                                                         addTableData(
  //                                                             'W6 D1', time);
  //                                                       } else {
  //                                                         if (time >
  //                                                             parseDuration(
  //                                                                 docsData[
  //                                                                     'W6 D1'])) {
  //                                                           updateTableData(
  //                                                               'W6 D1', time);
  //                                                         }
  //                                                       }
  //                                                     } else if (widget.day ==
  //                                                         2) {
  //                                                       if (docsData!['W6 D2']
  //                                                           .isEmpty) {
  //                                                         addTableData(
  //                                                             'W6 D2', time);
  //                                                       } else {
  //                                                         if (time >
  //                                                             parseDuration(
  //                                                                 docsData[
  //                                                                     'W6 D2'])) {
  //                                                           updateTableData(
  //                                                               'W6 D2', time);
  //                                                         }
  //                                                       }
  //                                                     } else if (widget.day ==
  //                                                         3) {
  //                                                       if (docsData!['W6 D3']
  //                                                           .isEmpty) {
  //                                                         addTableData(
  //                                                             'W6 D3', time);
  //                                                       } else {
  //                                                         if (time >
  //                                                             parseDuration(
  //                                                                 docsData[
  //                                                                     'W6 D3'])) {
  //                                                           updateTableData(
  //                                                               'W6 D3', time);
  //                                                         }
  //                                                       }
  //                                                     } else if (widget.day ==
  //                                                         4) {
  //                                                       if (docsData!['W6 AP']
  //                                                           .isEmpty) {
  //                                                         addTableData(
  //                                                             'W6 AP', time);
  //                                                       } else {
  //                                                         if (time >
  //                                                             parseDuration(
  //                                                                 docsData[
  //                                                                     'W6 AP'])) {
  //                                                           updateTableData(
  //                                                               'W6 AP', time);
  //                                                         }
  //                                                       }
  //                                                     }
  //                                                   }
  //                                                 } else {}
  //                                               }),
  //                                             }),
  //                                   }
  //                               });
  //                     } else {
  //                       print('done_day else');
  //                       FirebaseFirestore.instance
  //                           .collection('watchDataTable')
  //                           .where('user_id',
  //                               isEqualTo: pref.getString('user_id'))
  //                           .get()
  //                           .then((QuerySnapshot querySnapshot) => {
  //                                 querySnapshot.docs.forEach((doc) {
  //                                   if (doc != null) {
  //                                     Map<String, dynamic>? docsData =
  //                                         doc.data() as Map<String, dynamic>?;
  //
  //                                     print('documentData.toString()');
  //                                     print(docsData.toString());
  //
  //                                     if (widget.week + 1 == 2) {
  //                                       if (widget.day == 1) {
  //                                         if (docsData!['W1 D1'].isEmpty) {
  //                                           addTableData('W1 D1', time);
  //                                         } else {
  //                                           if (time >
  //                                               parseDuration(
  //                                                   docsData['W1 D1'])) {
  //                                             updateTableData('W1 D1', time);
  //                                           }
  //                                         }
  //                                       } else if (widget.day == 2) {
  //                                         if (docsData!['W1 D2'].isEmpty) {
  //                                           addTableData('W1 D2', time);
  //                                         } else {
  //                                           if (time >
  //                                               parseDuration(
  //                                                   docsData['W1 D2'])) {
  //                                             updateTableData('W1 D2', time);
  //                                           }
  //                                         }
  //                                       } else if (widget.day == 3) {
  //                                         if (docsData!['W1 D3'].isEmpty) {
  //                                           addTableData('W1 D3', time);
  //                                         } else {
  //                                           if (time >
  //                                               parseDuration(
  //                                                   docsData['W1 D3'])) {
  //                                             updateTableData('W1 D3', time);
  //                                           }
  //                                         }
  //                                       } else if (widget.day == 4) {
  //                                         if (docsData!['W1 AP'].isEmpty) {
  //                                           addTableData('W1 AP', time);
  //                                         } else {
  //                                           if (time >
  //                                               parseDuration(
  //                                                   docsData['W1 AP'])) {
  //                                             updateTableData('W1 AP', time);
  //                                           }
  //                                         }
  //                                       }
  //                                     } else if (widget.week + 1 == 3) {
  //                                       if (widget.day == 1) {
  //                                         if (docsData!['W2 D1'].isEmpty) {
  //                                           addTableData('W2 D1', time);
  //                                         } else {
  //                                           if (time >
  //                                               parseDuration(
  //                                                   docsData['W2 D1'])) {
  //                                             updateTableData('W2 D1', time);
  //                                           }
  //                                         }
  //                                       } else if (widget.day == 2) {
  //                                         if (docsData!['W2 D2'].isEmpty) {
  //                                           addTableData('W2 D2', time);
  //                                         } else {
  //                                           if (time > docsData['W2 D2']) {
  //                                             updateTableData('W2 D2', time);
  //                                           }
  //                                         }
  //                                       } else if (widget.day == 3) {
  //                                         if (docsData!['W2 D3'].isEmpty) {
  //                                           addTableData('W2 D3', time);
  //                                         } else {
  //                                           if (time >
  //                                               parseDuration(
  //                                                   docsData['W2 D3'])) {
  //                                             updateTableData('W2 D3', time);
  //                                           }
  //                                         }
  //                                       } else if (widget.day == 4) {
  //                                         if (docsData!['W2 AP'].isEmpty) {
  //                                           addTableData('W2 AP', time);
  //                                         } else {
  //                                           if (time >
  //                                               parseDuration(
  //                                                   docsData['W2 AP'])) {
  //                                             updateTableData('W2 AP', time);
  //                                           }
  //                                         }
  //                                       }
  //                                     } else if (widget.week + 1 == 4) {
  //                                       if (widget.day == 1) {
  //                                         if (docsData!['W3 D1'].isEmpty) {
  //                                           addTableData('W3 D1', time);
  //                                         } else {
  //                                           if (time >
  //                                               parseDuration(
  //                                                   docsData['W3 D1'])) {
  //                                             updateTableData('W3 D1', time);
  //                                           }
  //                                         }
  //                                       } else if (widget.day == 2) {
  //                                         if (docsData!['W3 D2'].isEmpty) {
  //                                           addTableData('W3 D2', time);
  //                                         } else {
  //                                           if (time >
  //                                               parseDuration(
  //                                                   docsData['W3 D2'])) {
  //                                             updateTableData('W3 D2', time);
  //                                           }
  //                                         }
  //                                       } else if (widget.day == 3) {
  //                                         if (docsData!['W3 D3'].isEmpty) {
  //                                           addTableData('W3 D3', time);
  //                                         } else {
  //                                           if (time >
  //                                               parseDuration(
  //                                                   docsData['W3 D3'])) {
  //                                             updateTableData('W3 D3', time);
  //                                           }
  //                                         }
  //                                       } else if (widget.day == 4) {
  //                                         if (docsData!['W3 AP'].isEmpty) {
  //                                           addTableData('W3 AP', time);
  //                                         } else {
  //                                           if (time >
  //                                               parseDuration(
  //                                                   docsData['W3 AP'])) {
  //                                             updateTableData('W3 AP', time);
  //                                           }
  //                                         }
  //                                       }
  //                                     } else if (widget.week + 1 == 5) {
  //                                       if (widget.day == 1) {
  //                                         if (docsData!['W4 D1'].isEmpty) {
  //                                           addTableData('W4 D1', time);
  //                                         } else {
  //                                           if (time >
  //                                               parseDuration(
  //                                                   docsData['W4 D1'])) {
  //                                             updateTableData('W4 D1', time);
  //                                           }
  //                                         }
  //                                       } else if (widget.day == 2) {
  //                                         if (docsData!['W4 D2'].isEmpty) {
  //                                           addTableData('W4 D2', time);
  //                                         } else {
  //                                           if (time >
  //                                               parseDuration(
  //                                                   docsData['W4 D2'])) {
  //                                             updateTableData('W4 D2', time);
  //                                           }
  //                                         }
  //                                       } else if (widget.day == 3) {
  //                                         if (docsData!['W4 D3'].isEmpty) {
  //                                           addTableData('W4 D3', time);
  //                                         } else {
  //                                           if (time >
  //                                               parseDuration(
  //                                                   docsData['W4 D3'])) {
  //                                             updateTableData('W4 D3', time);
  //                                           }
  //                                         }
  //                                       } else if (widget.day == 4) {
  //                                         if (docsData!['W4 AP'].isEmpty) {
  //                                           addTableData('W4 AP', time);
  //                                         } else {
  //                                           if (time >
  //                                               parseDuration(
  //                                                   docsData['W4 AP'])) {
  //                                             updateTableData('W4 AP', time);
  //                                           }
  //                                         }
  //                                       }
  //                                     } else if (widget.week + 1 == 6) {
  //                                       if (widget.day == 1) {
  //                                         if (docsData!['W5 D1'].isEmpty) {
  //                                           addTableData('W5 D1', time);
  //                                         } else {
  //                                           if (time >
  //                                               parseDuration(
  //                                                   docsData['W5 D1'])) {
  //                                             updateTableData('W5 D1', time);
  //                                           }
  //                                         }
  //                                       } else if (widget.day == 2) {
  //                                         if (docsData!['W5 D2'].isEmpty) {
  //                                           addTableData('W5 D2', time);
  //                                         } else {
  //                                           if (time >
  //                                               parseDuration(
  //                                                   docsData['W5 D2'])) {
  //                                             updateTableData('W5 D2', time);
  //                                           }
  //                                         }
  //                                       } else if (widget.day == 3) {
  //                                         if (docsData!['W5 D3'].isEmpty) {
  //                                           addTableData('W5 D3', time);
  //                                         } else {
  //                                           if (time >
  //                                               parseDuration(
  //                                                   docsData['W5 D3'])) {
  //                                             updateTableData('W5 D3', time);
  //                                           }
  //                                         }
  //                                       } else if (widget.day == 4) {
  //                                         if (docsData!['W5 AP'].isEmpty) {
  //                                           addTableData('W5 AP', time);
  //                                         } else {
  //                                           if (time >
  //                                               parseDuration(
  //                                                   docsData['W5 AP'])) {
  //                                             updateTableData('W5 AP', time);
  //                                           }
  //                                         }
  //                                       }
  //                                     } else if (widget.week + 1 == 7) {
  //                                       if (widget.day == 1) {
  //                                         if (docsData!['W6 D1'].isEmpty) {
  //                                           addTableData('W6 D1', time);
  //                                         } else {
  //                                           if (time >
  //                                               parseDuration(
  //                                                   docsData['W6 D1'])) {
  //                                             updateTableData('W6 D1', time);
  //                                           }
  //                                         }
  //                                       } else if (widget.day == 2) {
  //                                         if (docsData!['W6 D2'].isEmpty) {
  //                                           addTableData('W6 D2', time);
  //                                         } else {
  //                                           if (time >
  //                                               parseDuration(
  //                                                   docsData['W6 D2'])) {
  //                                             updateTableData('W6 D2', time);
  //                                           }
  //                                         }
  //                                       } else if (widget.day == 3) {
  //                                         if (docsData!['W6 D3'].isEmpty) {
  //                                           addTableData('W6 D3', time);
  //                                         } else {
  //                                           if (time >
  //                                               parseDuration(
  //                                                   docsData['W6 D3'])) {
  //                                             updateTableData('W6 D3', time);
  //                                           }
  //                                         }
  //                                       } else if (widget.day == 4) {
  //                                         if (docsData!['W6 AP'].isEmpty) {
  //                                           addTableData('W6 AP', time);
  //                                         } else {
  //                                           if (time >
  //                                               parseDuration(
  //                                                   docsData['W6 AP'])) {
  //                                             updateTableData('W6 AP', time);
  //                                           }
  //                                         }
  //                                       }
  //                                     }
  //                                   }
  //                                 }),
  //                               });
  //                     }
  //                   } else {
  //                     print('widget.day else');
  //                     FirebaseFirestore.instance
  //                         .collection('user')
  //                         .doc(pref.getString('user_id'))
  //                         .update({
  //                       'done_week': widget.day == null || widget.day == 4
  //                           ? (widget.week + 1).toString()
  //                           : widget.week.toString(),
  //                       'done_day': widget.day == null || widget.day == 4
  //                           ? '0'
  //                           : widget.day.toString(),
  //                       'achievement': widget.day == null || widget.day == 4
  //                           ? (widget.week + 1).toString()
  //                           : widget.week.toString(),
  //                       'done_date':
  //                           formatterDone.format(DateTime.now()).toString(),
  //                     }).whenComplete(() => {
  //                               if (widget.day != null)
  //                                 {
  //                                   FirebaseFirestore.instance
  //                                       .collection('watchDataTable')
  //                                       .where('user_id',
  //                                           isEqualTo:
  //                                               pref.getString('user_id'))
  //                                       .get()
  //                                       .then((QuerySnapshot querySnapshot) => {
  //                                             querySnapshot.docs.forEach((doc) {
  //                                               if (doc != null) {
  //                                                 Map<String, dynamic>?
  //                                                     documentData = doc.data()
  //                                                         as Map<String,
  //                                                             dynamic>?;
  //
  //                                                 print(
  //                                                     'documentData.toString()');
  //                                                 print(
  //                                                     documentData.toString());
  //                                               } else {}
  //                                             }),
  //                                           }),
  //                                 }
  //                             });
  //                   }
  //                 } else {
  //                   FirebaseFirestore.instance
  //                       .collection('user')
  //                       .doc(pref.getString('user_id'))
  //                       .update({
  //                     'done_date':
  //                         formatterDone.format(DateTime.now()).toString(),
  //                   });
  //                   print('done_week else');
  //                 }
  //               } else {
  //                 print('doc else');
  //               }
  //             }),
  //           });
  // }
  //
  // updateDataOfTable(time) async {
  //   SharedPreferences pref = await SharedPreferences.getInstance();
  //   FirebaseFirestore.instance
  //       .collection('watchDataTable')
  //       .where('user_id', isEqualTo: pref.getString('user_id'))
  //       .get()
  //       .then((QuerySnapshot querySnapshot) => {
  //             querySnapshot.docs.forEach((doc) {
  //               if (doc != null) {
  //                 Map<String, dynamic>? docsData =
  //                     doc.data() as Map<String, dynamic>?;
  //
  //                 print('documentData.toString()');
  //                 print(docsData.toString());
  //                 if (widget.week + 1 == 2) {
  //                   if (widget.day == 1) {
  //                     if (docsData!['W1 D1'].isEmpty) {
  //                       addTableData('W1 D1', time);
  //                     } else {
  //                       if (time > parseDuration(docsData['W1 D1'])) {
  //                         updateTableData('W1 D1', time);
  //                       }
  //                     }
  //                   } else if (widget.day == 2) {
  //                     if (docsData!['W1 D2'].isEmpty) {
  //                       addTableData('W1 D2', time);
  //                     } else {
  //                       if (time > parseDuration(docsData['W1 D2'])) {
  //                         updateTableData('W1 D2', time);
  //                       }
  //                     }
  //                   } else if (widget.day == 3) {
  //                     if (docsData!['W1 D3'].isEmpty) {
  //                       addTableData('W1 D3', time);
  //                     } else {
  //                       if (time > parseDuration(docsData['W1 D3'])) {
  //                         updateTableData('W1 D3', time);
  //                       }
  //                     }
  //                   } else if (widget.day == 4) {
  //                     if (docsData!['W1 AP'].isEmpty) {
  //                       addTableData('W1 AP', time);
  //                     } else {
  //                       if (time > parseDuration(docsData['W1 AP'])) {
  //                         updateTableData('W1 AP', time);
  //                       }
  //                     }
  //                   }
  //                 } else if (widget.week + 1 == 3) {
  //                   if (widget.day == 1) {
  //                     if (docsData!['W2 D1'].isEmpty) {
  //                       addTableData('W2 D1', time);
  //                     } else {
  //                       if (time > parseDuration(docsData['W2 D1'])) {
  //                         updateTableData('W2 D1', time);
  //                       }
  //                     }
  //                   } else if (widget.day == 2) {
  //                     if (docsData!['W2 D2'].isEmpty) {
  //                       addTableData('W2 D2', time);
  //                     } else {
  //                       if (time > parseDuration(docsData['W2 D2'])) {
  //                         updateTableData('W2 D2', time);
  //                       }
  //                     }
  //                   } else if (widget.day == 3) {
  //                     if (docsData!['W2 D3'].isEmpty) {
  //                       addTableData('W2 D3', time);
  //                     } else {
  //                       if (time > parseDuration(docsData['W2 D3'])) {
  //                         updateTableData('W2 D3', time);
  //                       }
  //                     }
  //                   } else if (widget.day == 4) {
  //                     if (docsData!['W2 AP'].isEmpty) {
  //                       addTableData('W2 AP', time);
  //                     } else {
  //                       if (time > parseDuration(docsData['W2 AP'])) {
  //                         updateTableData('W2 AP', time);
  //                       }
  //                     }
  //                   }
  //                 } else if (widget.week + 1 == 4) {
  //                   if (widget.day == 1) {
  //                     if (docsData!['W3 D1'].isEmpty) {
  //                       addTableData('W3 D1', time);
  //                     } else {
  //                       if (time > parseDuration(docsData['W3 D1'])) {
  //                         updateTableData('W3 D1', time);
  //                       }
  //                     }
  //                   } else if (widget.day == 2) {
  //                     if (docsData!['W3 D2'].isEmpty) {
  //                       addTableData('W3 D2', time);
  //                     } else {
  //                       if (time > parseDuration(docsData['W3 D2'])) {
  //                         updateTableData('W3 D2', time);
  //                       }
  //                     }
  //                   } else if (widget.day == 3) {
  //                     if (docsData!['W3 D3'].isEmpty) {
  //                       addTableData('W3 D3', time);
  //                     } else {
  //                       if (time > parseDuration(docsData['W3 D3'])) {
  //                         updateTableData('W3 D3', time);
  //                       }
  //                     }
  //                   } else if (widget.day == 4) {
  //                     if (docsData!['W3 AP'].isEmpty) {
  //                       addTableData('W3 AP', time);
  //                     } else {
  //                       if (time > parseDuration(docsData['W3 AP'])) {
  //                         updateTableData('W3 AP', time);
  //                       }
  //                     }
  //                   }
  //                 } else if (widget.week + 1 == 5) {
  //                   if (widget.day == 1) {
  //                     if (docsData!['W4 D1'].isEmpty) {
  //                       addTableData('W4 D1', time);
  //                     } else {
  //                       if (time > parseDuration(docsData['W4 D1'])) {
  //                         updateTableData('W4 D1', time);
  //                       }
  //                     }
  //                   } else if (widget.day == 2) {
  //                     if (docsData!['W4 D2'].isEmpty) {
  //                       addTableData('W4 D2', time);
  //                     } else {
  //                       if (time > parseDuration(docsData['W4 D2'])) {
  //                         updateTableData('W4 D2', time);
  //                       }
  //                     }
  //                   } else if (widget.day == 3) {
  //                     if (docsData!['W4 D3'].isEmpty) {
  //                       addTableData('W4 D3', time);
  //                     } else {
  //                       if (time > parseDuration(docsData['W4 D3'])) {
  //                         updateTableData('W4 D3', time);
  //                       }
  //                     }
  //                   } else if (widget.day == 4) {
  //                     if (docsData!['W4 AP'].isEmpty) {
  //                       addTableData('W4 AP', time);
  //                     } else {
  //                       if (time > parseDuration(docsData['W4 AP'])) {
  //                         updateTableData('W4 AP', time);
  //                       }
  //                     }
  //                   }
  //                 } else if (widget.week + 1 == 6) {
  //                   if (widget.day == 1) {
  //                     if (docsData!['W5 D1'].isEmpty) {
  //                       addTableData('W5 D1', time);
  //                     } else {
  //                       if (time > parseDuration(docsData['W5 D1'])) {
  //                         updateTableData('W5 D1', time);
  //                       }
  //                     }
  //                   } else if (widget.day == 2) {
  //                     if (docsData!['W5 D2'].isEmpty) {
  //                       addTableData('W5 D2', time);
  //                     } else {
  //                       if (time > parseDuration(docsData['W5 D2'])) {
  //                         updateTableData('W5 D2', time);
  //                       }
  //                     }
  //                   } else if (widget.day == 3) {
  //                     if (docsData!['W5 D3'].isEmpty) {
  //                       addTableData('W5 D3', time);
  //                     } else {
  //                       if (time > parseDuration(docsData['W5 D3'])) {
  //                         updateTableData('W5 D3', time);
  //                       }
  //                     }
  //                   } else if (widget.day == 4) {
  //                     if (docsData!['W5 AP'].isEmpty) {
  //                       addTableData('W5 AP', time);
  //                     } else {
  //                       if (time > parseDuration(docsData['W5 AP'])) {
  //                         updateTableData('W5 AP', time);
  //                       }
  //                     }
  //                   }
  //                 } else if (widget.week + 1 == 7) {
  //                   if (widget.day == 1) {
  //                     if (docsData!['W6 D1'].isEmpty) {
  //                       addTableData('W6 D1', time);
  //                     } else {
  //                       if (time > parseDuration(docsData['W6 D1'])) {
  //                         updateTableData('W6 D1', time);
  //                       }
  //                     }
  //                   } else if (widget.day == 2) {
  //                     if (docsData!['W6 D2'].isEmpty) {
  //                       addTableData('W6 D2', time);
  //                     } else {
  //                       if (time > parseDuration(docsData['W6 D2'])) {
  //                         updateTableData('W6 D2', time);
  //                       }
  //                     }
  //                   } else if (widget.day == 3) {
  //                     if (docsData!['W6 D3'].isEmpty) {
  //                       addTableData('W6 D3', time);
  //                     } else {
  //                       if (time > parseDuration(docsData['W6 D3'])) {
  //                         updateTableData('W6 D3', time);
  //                       }
  //                     }
  //                   } else if (widget.day == 4) {
  //                     if (docsData!['W6 AP'].isEmpty) {
  //                       addTableData('W6 AP', time);
  //                     } else {
  //                       if (time > parseDuration(docsData['W6 AP'])) {
  //                         updateTableData('W6 AP', time);
  //                       }
  //                     }
  //                   }
  //                 }
  //               }
  //             }),
  //           });
  // }

  /*end old code*/

  updateTableDataNew(param, data, type) async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    FirebaseFirestore.instance
        .collection('user')
        .doc(pref.getString('user_id'))
        .update({
      'done_date': formatterDone.format(DateTime.now()).toString(),
    }).whenComplete(() => {
              FirebaseFirestore.instance
                  .collection('watchDataTable')
                  .where('user_id', isEqualTo: pref.getString('user_id'))
                  .get()
                  .then((QuerySnapshot querySnapshot) => {
                        data =
                            data + parseDuration(querySnapshot.docs[0][param]),
                        FirebaseFirestore.instance
                            .collection('watchDataTable')
                            .doc(querySnapshot.docs[0]['id'])
                            .update({
                          param: data.toString(),
                          "$param date":
                              formatter.format(DateTime.now()).toString()
                        }),
                      })
                  .whenComplete(() => {
                        showSnackBar('Your to-day time Add successfully'),
                        FirebaseFirestore.instance
                            .collection('user')
                            .where('id', isEqualTo: pref.getString('user_id'))
                            .get()
                            .then((QuerySnapshot querySnapshot) {
                          querySnapshot.docs.forEach((doc) {
                            if (doc != null) {
                              Map<String, dynamic>? userData =
                                  doc.data() as Map<String, dynamic>?;
                              if (type) {
                                FirebaseFirestore.instance
                                    .collection('user')
                                    .doc(pref.getString('user_id'))
                                    .update({
                                  'done_week':
                                      widget.day == null || widget.day == 4
                                          ? (widget.week + 1).toString()
                                          : widget.week.toString(),
                                  'done_day':
                                      widget.day == null || widget.day == 4
                                          ? '0'
                                          : widget.day.toString(),
                                  'achievement':
                                      widget.day == null || widget.day == 4
                                          ? (widget.week + 1).toString()
                                          : widget.week.toString(),
                                  'done_date': formatterDone
                                      .format(DateTime.now())
                                      .toString(),
                                });
                              } else {
                                if (_controller!.value.position ==
                                    _controller!.value.duration) {
                                  FirebaseFirestore.instance
                                      .collection('user')
                                      .doc(pref.getString('user_id'))
                                      .update({
                                    'done_day':
                                        widget.day == null || widget.day == 4
                                            ? '0'
                                            : widget.day.toString(),
                                    'done_date': formatterDone
                                        .format(DateTime.now())
                                        .toString(),
                                  });
                                }
                              }
                            }
                          });
                        })
                      }),
            });

    print('updateTableData');
  }

  // updateTableData(param, data) async {
  //   SharedPreferences pref = await SharedPreferences.getInstance();
  //   FirebaseFirestore.instance
  //       .collection('user')
  //       .doc(pref.getString('user_id'))
  //       .update({
  //     'done_date': formatterDone.format(DateTime.now()).toString(),
  //   }).whenComplete(() => {
  //             FirebaseFirestore.instance
  //                 .collection('watchDataTable')
  //                 .where('user_id', isEqualTo: pref.getString('user_id'))
  //                 .get()
  //                 .then((QuerySnapshot querySnapshot) => {
  //                       FirebaseFirestore.instance
  //                           .collection('watchDataTable')
  //                           .doc(querySnapshot.docs[0]['id'])
  //                           .update({
  //                         param: data.toString(),
  //                         "$param date": formatter.format(DateTime.now()).toString()
  //                       }),
  //                     })
  //                 .whenComplete(() => {
  //                       showSnackBar('Your to-day time Add successfully'),
  //                     }),
  //           });
  //
  //   print('updateTableData');
  // }
  //
  // addTableData(param, data) async {
  //   SharedPreferences pref = await SharedPreferences.getInstance();
  //   FirebaseFirestore.instance
  //       .collection('user')
  //       .doc(pref.getString('user_id'))
  //       .update({
  //     'done_date': formatterDone.format(DateTime.now()).toString(),
  //   }).whenComplete(() => {
  //             FirebaseFirestore.instance
  //                 .collection('watchDataTable')
  //                 .where('user_id', isEqualTo: pref.getString('user_id'))
  //                 .get()
  //                 .then((QuerySnapshot querySnapshot) => {
  //                       FirebaseFirestore.instance
  //                           .collection('watchDataTable')
  //                           .doc(querySnapshot.docs[0]['id'])
  //                           .update({
  //                         param: data.toString(),
  //                         "$param date":
  //                             formatter.format(DateTime.now()).toString()
  //                       }),
  //                     })
  //                 .whenComplete(() => {
  //                       showSnackBar('Your to-day task complete successfully'),
  //                     }),
  //           });
  //
  //   print('addTableData');
  // }

  void checkVideo() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    // Implement your calls inside these conditions' bodies :
    if (_controller!.value.position ==
        Duration(seconds: 0, minutes: 0, hours: 0)) {
      print('video Started');
    }
    if (_controller!.value.position == _controller!.value.duration) {
      print('video Ended');
      if (check) {
        if (widget.week + 1 == 8) {
          FirebaseFirestore.instance
              .collection('user')
              .doc(pref.getString('user_id'))
              .update({
            'done_week': '0',
            'done_day': '0',
            'achievement': '0',
            'done_date': '',
          });
        } else {
          updateDataOfUserNew(_controller!.value.position);
        }
      }
    }
  }

  Future<String> downloadFile(String url) async {
    final Directory extDir = await getApplicationDocumentsDirectory();

    HttpClient httpClient = new HttpClient();
    File file;
    String filePath = '';
    String myUrl = '';

    // String fileName = 'cvs.mp4';
    String fileName = 'outrocvs.mp4';

    print('start');
    try {
      myUrl = url + '/' + fileName;
      var request = await httpClient.getUrl(Uri.parse(myUrl));
      var response = await request.close();
      if (response.statusCode == 200) {
        var bytes = await consolidateHttpClientResponseBytes(response);
        filePath = '${extDir.path}/$fileName';
        file = File(filePath);
        await file.writeAsBytes(bytes);
      } else
        filePath = 'Error code: ' + response.statusCode.toString();
    } catch (ex) {
      filePath = 'Can not fetch url';
    }
    print('end');

    return filePath;
  }

  back() {
    Navigator.of(context).pop();
    _player.stop();
    _controller!.pause();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          key: _scaffoldKey,
          body: Stack(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                    top: 40, left: 15, right: 15, bottom: 15),
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
                                  _player.stop();
                                  _controller!.pause();
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
                        children: <Widget>[
                          _controller != null
                              ? _controller!.value.isInitialized
                                  ? AspectRatio(
                                      aspectRatio:
                                          _controller!.value.aspectRatio,
                                      // aspectRatio:
                                      //     _controller!.value.aspectRatio / 2,
                                      child: VideoPlayer(_controller!),
                                    )
                                  // : const Text(
                                  //     'Loading...',
                                  //     textAlign: TextAlign.center,
                                  //     style: TextStyle(
                                  //         // decoration: TextDecoration.underline,
                                  //         color: Color(0xff744EC3),
                                  //         fontSize: 30,
                                  //         fontFamily: 'Avenir',
                                  //         fontWeight: FontWeight.w400),
                                  //   )
                                  : bytes != null
                                      ? Image.memory(bytes!)
                                      : SizedBox.shrink()
                              : bytes != null
                                  ? Image.memory(bytes!)
                                  : SizedBox.shrink(),
                          _controller != null
                              ? _controller!.value.isInitialized
                                  ? Row(
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.all(5),
                                          child: _playButton(),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                top: 10, right: 5, left: 5),
                                            child: _progressBar(),
                                          ),
                                        ),
                                      ],
                                    )
                                  : const SizedBox.shrink()
                              : const SizedBox.shrink(),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Visibility(
                visible: showLoader,
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    margin: const EdgeInsets.all(8.0),
                    width: 32.0,
                    height: 32.0,
                    child: const CircularProgressIndicator(),
                  ),
                ),
              ),
            ],
          ),
        ),
        onWillPop: () => back());
  }

  StreamBuilder<DurationState> _progressBar() {
    return StreamBuilder<DurationState>(
      stream: _durationState,
      builder: (context, snapshot) {
        final durationState = snapshot.data;
        final progress = durationState?.progress ?? Duration.zero;
        final buffered = durationState?.buffered ?? Duration.zero;
        final total = durationState?.total ?? Duration.zero;
        if (_player.duration == _player.position) {
          print('end end');
          if (check) {
            if (widget.week + 1 == 8) {
              FirebaseFirestore.instance.collection('user').doc(userId).update({
                'done_week': '0',
                'done_day': '0',
                'achievement': '0',
                'done_date': '',
              });
            } else {
              updateDataOfUserNew(_controller!.value.position);
            }
          }
        }
        return ProgressBar(
          progress: progress,
          buffered: buffered,
          total: total,
          // onSeek: null,
          onSeek: (duration) {
            _player.seek(duration);
            _controller!.seekTo(duration);
            if (_controller!.value.isPlaying) {
            } else {
              _controller!.play();
            }
          },

          // onDragUpdate: (details) {
          //   debugPrint('${details.timeStamp}, ${details.localPosition}');
          // },
          // onDragUpdate: null,
        );
      },
    );
  }

  StreamBuilder<PlayerState> _playButton() {
    return StreamBuilder<PlayerState>(
      stream: _player.playerStateStream,
      builder: (context, snapshot) {
        final playerState = snapshot.data;
        final processingState = playerState?.processingState;
        final playing = playerState?.playing;
        if (processingState == ProcessingState.loading ||
            processingState == ProcessingState.buffering) {
          return Container(
            margin: const EdgeInsets.all(8.0),
            width: 32.0,
            height: 32.0,
            child: const CircularProgressIndicator(),
          );
        } else if (playing != true) {
          return IconButton(
            icon: const Icon(
              Icons.play_circle_outline,
              color: Color(0xffC299F6),
            ),
            iconSize: 32.0,
            onPressed: () {
              if (_player.position == _player.duration) {
                _player.seek(Duration.zero);
                _controller!.seekTo(Duration.zero);
                _player.play();
                _controller!.play();
                setState(() {});
              } else {
                setState(() {
                  _player.play();
                  _controller!.play();
                });
              }
            },
          );
        } else if (processingState != ProcessingState.completed) {
          return IconButton(
            icon: const Icon(
              Icons.pause_circle_outline,
              color: Color(0xffC299F6),
            ),
            iconSize: 32.0,
            onPressed: () {
              if (check) {
                _player.pause();
                _controller!.pause();
                // updateDataOfTableNew(_controller!.value.position);
              }
              setState(() {
                _player.pause();
                _controller!.pause();
              });
            },
          );
        } else {
          // if (_player.duration == _player.position) {
          print('end end');
          if (check) {
            if (widget.week + 1 == 8) {
              FirebaseFirestore.instance.collection('user').doc(userId).update({
                'done_week': '0',
                'done_day': '0',
                'achievement': '0',
                'done_date': '',
              });
            } else {
              updateDataOfUserNew(_controller!.value.position);
            }
          }
          // }
          return IconButton(
              icon: const Icon(
                Icons.replay,
                color: Color(0xffC299F6),
              ),
              iconSize: 32.0,
              onPressed: () {
                // setState(() {
                _controller!.seekTo(Duration.zero);
                _player.seek(Duration.zero);
                _controller!.pause();
                _player.pause();
                // _controller!.play();
                // });
              });
        }
      },
    );
  }
}

class DurationState {
  const DurationState({this.progress, this.buffered, this.total});

  final Duration? progress;
  final Duration? buffered;
  final Duration? total;
}
