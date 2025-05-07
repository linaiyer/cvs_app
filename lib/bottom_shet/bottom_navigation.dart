import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:resarch_csv/bottom_shet/bottom_tabs.dart';
import 'package:resarch_csv/utils/styles.dart';
import 'package:shared_preferences/shared_preferences.dart';

class bottom_navigation extends StatefulWidget {
  @override
  _bottom_navigation createState() => _bottom_navigation();
}

class _bottom_navigation extends State<bottom_navigation> {
  int currentIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      currentIndex = index;
      print('_selectedIndex');
      print(currentIndex);
    });
  }

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  @override
  void dispose() {
    print("Dispose");
    super.dispose();
  }

  bool check = false;

  getUserData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      check = pref.get('user_id') != null ? true : false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Color greyColor = const Color(0xFF7F7F7F);
    return Scaffold(
      body: Scaffold(
        body: IndexedStack(
          index: currentIndex,
          children: [
            for (final tabItem in TabNavigationItem.items) tabItem.page!,
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: check
            ? (index) {
                _onItemTapped(index);
                // currentIndex = index;
                // if (mounted) setState(() {});
              }
            : (index) {
                Fluttertoast.showToast(
                    msg: 'Do login first',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 3,
                    backgroundColor: Color(0xffC299F6),
                    textColor: Colors.white);
              },
        unselectedIconTheme: IconThemeData(color: greyColor),
        selectedIconTheme: IconThemeData(color: appColor),
        selectedLabelStyle: multiRegular(size: 12, textColor: appColor),
        unselectedLabelStyle:
            multiRegular(size: 12, textColor: const Color(0xFF7F7F7F)),
        unselectedItemColor: greyColor,
        selectedItemColor: appColor,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 12.0,
        unselectedFontSize: 12.0,
        items: [
          BottomNavigationBarItem(
              icon: bottomIcon(
                currentIndex == 0
                    ? "assets/icons/home_selected.png"
                    : "assets/icons/home_unselected.png",
              ),
              label: ""),
          BottomNavigationBarItem(
            icon: bottomIcon(
              currentIndex == 1
                  ? "assets/icons/setting_selected.png"
                  : "assets/icons/setting_unselected.png",
            ),
            label: "",
          )
        ],
      ),
    );
  }

  Widget bottomIcon(String image) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5, top: 5),
      child: Image.asset(
        image,
        height: 20,
      ),
    );
  }
}
