/*fonts*/
import 'package:flutter/cupertino.dart';
import 'package:sizer/sizer.dart';

const fontRegular = 'Regular';
const fontMedium = 'Medium';
const fontSemibold = 'Semibold';
const fontBold = 'Bold';
/* font sizes*/
const textSizeSmall = 12.0;
const textSizeSMedium = 14.0;
const textSizeMedium = 16.0;
const textSizeLargeMedium = 18.0;
const textSizeNormal = 20.0;
const textSizeLarge = 24.0;
const textSizeXLarge = 34.0;

/* margin */

const spacing_control_half = 2.0;
const spacing_control = 4.0;
const spacing_standard = 8.0;
const spacing_middle = 10.0;
const spacing_standard_new = 16.0;
const spacing_large = 24.0;
const spacing_xlarge = 32.0;
const spacing_xxLarge = 40.0;

final int timeOut = 50;
const int perPage = 10;

String? curUserId;
String? curTikId = '';
String? fcmToken;

double getHeight(double height, mysize) {
  double tempHeight = 0.0;
  tempHeight = mysize.height * 150 / 1280;
  return tempHeight;
}

double getWidth(double width, mysize) {
  double tempWidth = 0.0;
  tempWidth = mysize.width * 150 / 1280;
  return tempWidth;
}

Widget boxhight(double width, mysize) {
  return SizedBox(
    height: getHeight(width, mysize),
  );
}
