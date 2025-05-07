import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:resarch_csv/main_screen/user_screen/home_screen.dart';
import 'package:resarch_csv/main_screen/user_screen/profile_screen.dart';

class TabNavigationItem {
  final Widget? page;

  TabNavigationItem({this.page});

  static List<TabNavigationItem> get items => [
        TabNavigationItem(
          page: home_screen(),
        ),
        TabNavigationItem(
          page: profile_screen(),
        ),
      ];
}
