import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';

class pick_avater extends StatefulWidget {
  @override
  _pick_avater createState() => _pick_avater();
}

class _pick_avater extends State<pick_avater> {
  var avaterImage = [];
  bool showLoader = true;

  @override
  void initState() {
    super.initState();
    getProfileImage();
  }

  getProfileImage() async {
    setState(() {
      showLoader = true;
    });
    FirebaseFirestore.instance
        .collection('profileImage')
        .get()
        .then((QuerySnapshot querySnapshot) => {
              setState(() {
                avaterImage = querySnapshot.docs.toList();
                showLoader = false;
              }),
              print(avaterImage),
            });
  }

  uploadImageOnProfile(image) async {
    context.loaderOverlay.show();

    SharedPreferences pref = await SharedPreferences.getInstance();
    FirebaseFirestore.instance
        .collection('user')
        .doc(pref.getString('user_id'))
        .update({'user_profile': image}).whenComplete(() => {
              context.loaderOverlay.hide(),
              Fluttertoast.showToast(
                  msg: 'Profile Update Successfully',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 3,
                  backgroundColor: Color(0xffC299F6),
                  textColor: Colors.white),
            });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoaderOverlay(
        useDefaultLoading: true,
        overlayWidget: const Center(
          child: SpinKitCubeGrid(
            color: Color(0xffC299F6),
            size: 50.0,
          ),
        ),
        overlayOpacity: 0.8,
        child: Padding(
          padding:
              const EdgeInsets.only(top: 40, left: 15, bottom: 15, right: 15),
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
                          'Pick Your Avatar',
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
                  ],
                ),
              ),
              Expanded(
                child: showLoader
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : avaterImage.isNotEmpty
                        ? GridView.builder(
                            padding: EdgeInsets.only(top: 5),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              childAspectRatio: 0.8,
                              crossAxisCount: 2,
                              mainAxisSpacing: 2,
                              crossAxisSpacing: 3,
                            ),
                            itemCount: avaterImage.length,
                            shrinkWrap: true,
                            itemBuilder: (BuildContext context, int index) {
                              return GestureDetector(
                                onTap: () {
                                  uploadImageOnProfile(
                                      avaterImage[index]['image']);
                                },
                                child: Image.network(
                                  avaterImage[index]['image'],
                                  height: 180,
                                ),
                              );
                            },
                          )
                        // ? ListView(
                        //     padding: const EdgeInsets.only(top: 15),
                        //     children: <Widget>[
                        //       Row(
                        //         children: <Widget>[
                        //           GestureDetector(
                        //             onTap: () {
                        //               widget.select!(1);
                        //               Navigator.of(context).pop();
                        //             },
                        //             child: Image.asset(
                        //               'assets/images/forest.png',
                        //               height: 150,
                        //             ),
                        //           ),
                        //           GestureDetector(
                        //             onTap: () {
                        //               widget.select!(2);
                        //               Navigator.of(context).pop();
                        //             },
                        //             child: Image.asset(
                        //               'assets/images/bonfire.png',
                        //               height: 150,
                        //             ),
                        //           ),
                        //         ],
                        //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //       ),
                        //       Row(
                        //         children: <Widget>[
                        //           GestureDetector(
                        //             onTap: () {
                        //               widget.select!(3);
                        //               Navigator.of(context).pop();
                        //             },
                        //             child: Image.asset(
                        //               'assets/images/air.png',
                        //               height: 150,
                        //             ),
                        //           ),
                        //           GestureDetector(
                        //             onTap: () {
                        //               widget.select!(4);
                        //               Navigator.of(context).pop();
                        //             },
                        //             child: Image.asset(
                        //               'assets/images/ocean.png',
                        //               height: 150,
                        //             ),
                        //           ),
                        //         ],
                        //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //       ),
                        //       Row(
                        //         children: <Widget>[
                        //           GestureDetector(
                        //             onTap: () {
                        //               widget.select!(5);
                        //               Navigator.of(context).pop();
                        //             },
                        //             child: Image.asset(
                        //               'assets/images/black_hole.png',
                        //               height: 150,
                        //             ),
                        //           ),
                        //         ],
                        //         mainAxisAlignment: MainAxisAlignment.center,
                        //       )
                        //     ],
                        //   )
                        : const Center(
                            child: Text(
                              'No Data Found!',
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 33,
                                fontFamily: 'Anaheim',
                              ),
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
