import 'package:flutter/material.dart';

import 'widget_themes/TElevatedButtonTheme.dart';
import 'widget_themes/TOutlinedButtonTheme.dart';
import 'widget_themes/TTextFormFieldTheme.dart';
import 'widget_themes/TTextTheme.dart';

class TAppTheme {
  TAppTheme._();

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    elevatedButtonTheme: TElevatedButtonTheme.lightElevatedButtonTheme,
    textTheme: TTextTheme.lightTextTheme,
    outlinedButtonTheme: TOutlinedButtonTheme.lightOutlinedButtonTheme,
    inputDecorationTheme: TTextFormFieldTheme.lightInputDecorationTheme,
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    elevatedButtonTheme: TElevatedButtonTheme.darkelevatedButtonTheme,
    textTheme: TTextTheme.darkTextTheme,
    outlinedButtonTheme: TOutlinedButtonTheme.darkOutlinedButtonTheme,
    inputDecorationTheme: TTextFormFieldTheme.darkInputDecorationTheme,
  );
}
