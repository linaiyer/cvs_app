import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

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

  final DateFormat formatter = DateFormat('yyyy-MM-dd');

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  String? dirPath;

  late File thumbFile;
  bool setThumbFile = false;

  late Timer mytimer;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    setThubm();
    setData();
    mytimer = Timer.periodic(Duration(seconds: 10), (timer) {
      updateDataTables("10");
    });
  }

  @override
  dispose() {
    WakelockPlus.disable();
    _controller!.dispose();
    mytimer.cancel();
    super.dispose();
  }

  setThubm() async {
    setState(() {
      showLoader = true;
    });

    final byteData = await rootBundle.load("assets/videos/outronew.mp4");
    Directory tempDir = await getTemporaryDirectory();

    File tempVideo = File("${tempDir.path}/assets/videos/outronew.mp4")
      ..createSync(recursive: true)
      ..writeAsBytesSync(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    final fileName = await VideoThumbnail.thumbnailFile(
      video: tempVideo.path,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.PNG,
      maxHeight: 300,
      quality: 75,
    );

    thumbFile = File(fileName!);

    setState(() {
      setThumbFile = true;
      showLoader = false;
    });

    // final file = File(fileName!);
    // if (mounted)
    //   setState(() {
    //     bytes = file.readAsBytesSync();
    //   });
  }

  setData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    dirPath = 'assets/videos/outronew.mp4';
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
    _controller = VideoPlayerController.asset(
      dirPath!,
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    )..initialize().then((_) {
      // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
      setState(() {
        _player.setVolume(0);
        _player.setAsset(dirPath!);
      });
    });
  }

  int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }

  void showSnackBar(text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
      ),
    );
  }

  updateDataTables(time) async {
    var param;
    int curDay, curWeek;
    SharedPreferences pref = await SharedPreferences.getInstance();

    await FirebaseFirestore.instance
        .collection('user')
        .where('id', isEqualTo: pref.getString('user_id'))
        .where('user_type', isEqualTo: '0')
        .get()
        .then((QuerySnapshot querySnapshot) => {
      querySnapshot.docs.forEach((doc) {
        if (doc != null) {
          Map<String, dynamic>? documentData = doc.data()
          as Map<String, dynamic>?;

          curWeek = daysBetween(DateTime.parse(documentData!['start_date']), (DateTime.now())) ~/ 7;
          curDay = daysBetween(DateTime.parse(documentData!['start_date']), (DateTime.now())) % 7;
          if (curWeek >= 7) {
            return;
          }
          param = 'W${curWeek + 1} D${curDay + 1}';
        }
      }),
    });

    if (param != null && param != '') {
      FirebaseFirestore.instance
          .collection('watchDataTable')
          .where('user_id', isEqualTo: pref.getString('user_id'))
          .get()
          .then((QuerySnapshot query) {
        query.docs.forEach((element) {
          if (element != null) {
            Map<String, dynamic>? documentData =
            element.data() as Map<String, dynamic>?;
            if (documentData!['$param time'] != '') {
              time = parseDuration(time) +
                  parseDuration(
                      '${documentData['$param time'].substring(0, 1)}:${documentData['$param time'].substring(6, 8)}:${documentData['$param time'].substring(14, 16)}');
            } else {
              time = parseDuration(time);
            }
            FirebaseFirestore.instance
                .collection('watchDataTable')
                .doc(query.docs[0]['id'])
                .update({
              // 1:02:48
              "$param time":
              '${time.toString().substring(0, 1)} Hr, ${time.toString().substring(2, 4)} Min, ${time.toString().substring(5, 7)} Sec',
              "$param date": formatter.format(DateTime.now()).toString()
            });
          }
        });
      });
    }
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

  void checkVideo() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    // Implement your calls inside these conditions' bodies :
    if (_controller!.value.position ==
        Duration(seconds: 0, minutes: 0, hours: 0)) {
      print('video Started');
    }
    if (_controller!.value.position == _controller!.value.duration) {
      print('video Ended');
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
                                  : setThumbFile
                                      ? Image.file(thumbFile)
                                      : SizedBox.shrink()
                              : setThumbFile
                                  ? Image.file(thumbFile)
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
