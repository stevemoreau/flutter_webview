import 'package:flutter/material.dart';

import 'colors.dart';

/*
TextStyle
 */

TextStyle styleMenuItem(double lineHeight) {
  return TextStyle(
      color: MyColors.black.withOpacity(0.7),
      fontFamily: 'Regular',
      fontSize: 17,
      letterSpacing: 0,
      height: lineHeight);
}
