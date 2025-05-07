import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PickAvatar extends StatefulWidget {
  @override
  _PickAvatarState createState() => _PickAvatarState();
}

class _PickAvatarState extends State<PickAvatar> {
  var avatarImage = [];
  bool showLoader = true;
  bool isUploading = false;

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
        .then((QuerySnapshot querySnapshot) {
      setState(() {
        avatarImage = querySnapshot.docs.toList();
        showLoader = false;
      });
      print(avatarImage);
    });
  }

  uploadImageOnProfile(image) async {
    setState(() {
      isUploading = true;
    });

    SharedPreferences pref = await SharedPreferences.getInstance();
    FirebaseFirestore.instance
        .collection('user')
        .doc(pref.getString('user_id'))
        .update({'user_profile': image}).whenComplete(() {
      setState(() {
        isUploading = false;
      });
      Fluttertoast.showToast(
          msg: 'Profile Update Successfully',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 3,
          backgroundColor: Color(0xffC299F6),
          textColor: Colors.white);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 40, left: 15, bottom: 15, right: 15),
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
                      : avatarImage.isNotEmpty
                      ? GridView.builder(
                    padding: EdgeInsets.only(top: 5),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      childAspectRatio: 0.8,
                      crossAxisCount: 2,
                      mainAxisSpacing: 2,
                      crossAxisSpacing: 3,
                    ),
                    itemCount: avatarImage.length,
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {
                          uploadImageOnProfile(avatarImage[index]['image']);
                        },
                        child: Image.network(
                          avatarImage[index]['image'],
                          height: 180,
                        ),
                      );
                    },
                  )
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
          if (isUploading)
            Container(
              color: Colors.black.withOpacity(0.8),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xffC299F6)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
