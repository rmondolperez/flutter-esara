import 'package:esara/application/core/constants/colors.dart';
import 'package:flutter/material.dart';

class TTextFormFieldTheme {
  TTextFormFieldTheme._();

  static InputDecorationTheme lightInputDecorationTheme =
      const InputDecorationTheme(
          border: OutlineInputBorder(
              borderSide: BorderSide(width: 2, color: tBlackEditColor)),
          prefixIconColor: Colors.black,
          floatingLabelStyle: TextStyle(color: Colors.black),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 2, color: Colors.black)));

  static InputDecorationTheme darkInputDecorationTheme =
      const InputDecorationTheme(
          border: OutlineInputBorder(),
          prefixIconColor: tPrimaryColor,
          floatingLabelStyle: TextStyle(color: tPrimaryColor),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 2, color: tPrimaryColor)));
}
