import 'package:example/src/application/app_theme/app_theme.dart';
import 'package:flutter/material.dart';

class AppLightTheme implements AppTheme {
  @override
  Color basicColorGreen1 = const Color(0xff4ab336);

  @override
  Color basicColorRed1 = const Color(0xfffdeded);

  @override
  Color basicColorRed2 = const Color(0xfffbdadc);

  @override
  Color basicColorRed3 = const Color(0xfff5a3a7);

  @override
  Color basicColorRed4 = const Color(0xffef6b72);

  @override
  Color basicColorRed5 = const Color(0xffea3943);

  @override
  Color basicColorRed6 = const Color(0xffe8212b);

  @override
  Color basicColorRed7 = const Color(0xffcb151e);

  @override
  Color basicColorRed8 = const Color(0xff941016);

  @override
  Color darkColor = const Color(0xff000000);


  @override
  Gradient gradient8 = const LinearGradient(
    colors: [
      Color(0xffA9CDFF),
      Color(0xff72F6D1),
      Color(0xffA0ED8D),
      Color(0xffFED365),
      Color(0xffFAA49E),
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  @override
  Color lightColor = const Color(0xffFFFFFF);

  @override
  Color neutralColor1 = const Color(0xffF3F5F7);


  @override
  Color primaryColor1 = const Color(0xffE2F0FF);

  @override
  Color primaryColor2 = const Color(0xffC5DFFF);

  @override
  Color primaryColor3 = const Color(0xffA9CDFF);

  @override
  Color primaryColor4 = const Color(0xff93BDFF);

  @override
  Color primaryColor5 = const Color(0xff5f97ff);

  @override
  Color primaryColor6 = const Color(0xff517DDB);

  @override
  Color primaryColor7 = const Color(0xff385BB7);

  @override
  Color primaryColor8 = const Color(0xff233E93);
}