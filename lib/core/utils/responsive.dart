import 'package:flutter/material.dart';

class Responsive {
  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).shortestSide >= 600;

  static bool isLandscape(BuildContext context) =>
      MediaQuery.orientationOf(context) == Orientation.landscape;

  static bool isExpanded(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 840;

  static double maxContentWidth(BuildContext context) {
    if (isExpanded(context)) return 780;
    if (isTablet(context)) return 640;
    return double.infinity;
  }

  static double horizontalPadding(BuildContext context) {
    if (isExpanded(context)) return 48;
    if (isTablet(context)) return 40;
    if (isLandscape(context)) return 64;
    return 24;
  }

  static int gridColumns(BuildContext context) {
    if (isExpanded(context)) return 4;
    if (isTablet(context) || isLandscape(context)) return 3;
    return 2;
  }

  static bool useRail(BuildContext context) =>
      isTablet(context) || isLandscape(context);
}
