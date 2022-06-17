import 'package:flutter/material.dart';

Color appColor = const Color(0xFFF48C7D);

TextStyle goldenRegular({required double size, required Color textColor}) {
  return TextStyle(
      fontFamily: "Goldenbook Regular", fontSize: size, color: textColor);
}

TextStyle goldenBold({required double size, required Color textColor}) {
  return TextStyle(
      fontFamily: "Goldenbook Bold",
      fontSize: size,
      color: textColor,
      fontWeight: FontWeight.bold);
}

TextStyle multiRegular({required double size, required Color textColor}) {
  return TextStyle(
      fontFamily: "Muli-Regular",
      fontSize: size,
      color: textColor,
      fontWeight: FontWeight.bold);
}

TextStyle muliSemiBold({required double size, required Color textColor}) {
  return TextStyle(
    fontFamily: "Muli-SemiBold",
    fontSize: size,
    color: textColor,
  );
}

TextStyle muliBold({required double size, required Color textColor}) {
  return TextStyle(
      fontFamily: "Muli-Bold",
      fontSize: size,
      color: textColor,
      fontWeight: FontWeight.bold);
}
