/*
 * File: custom_theme.dart
 * File Created: Friday, 8th January 2021 11:50:17 am
 * Author: Hieu Tran
 * -----
 * Last Modified: Friday, 8th January 2021 12:51:27 pm
 * Modified By: Hieu Tran
 */

import 'package:flutter/material.dart';

class CustomTheme {
  CustomTheme();

  ThemeData? appTheme;

  factory CustomTheme.fromContext(BuildContext context) {
    final CustomTheme theme = CustomTheme();

    theme.appTheme = ThemeData(
      scaffoldBackgroundColor: Colors.white,
      fontFamily: 'OLInter',
      buttonTheme: ButtonThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        height: 56.0,
      ),
    );

    return theme;
  }
}
