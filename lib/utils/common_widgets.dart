import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

SizedBox sizedBox({double? height, double? width}) {
  return SizedBox(
    height: height ?? 0,
    width: width ?? 0,
  );
}

Size getSize(context) {
  return MediaQuery.of(context).size;
}

Widget navBack(context) {
  return GestureDetector(
    onTap: () {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      } else {
        SystemNavigator.pop();
      }
    },
    child: Container(
      margin: const EdgeInsets.only(left: 8, top: 8),
      alignment: Alignment.center,
      child: const Icon(
        Icons.arrow_back_ios_outlined,
        color: Colors.black,
      ),
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(
            Radius.circular(30.0),
          ),
          border: Border.all(color: Colors.grey[200]!)),
    ),
  );
}
