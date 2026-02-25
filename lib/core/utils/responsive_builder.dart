import 'package:flutter/material.dart';

class ResponsiveBuilder extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1024;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1024;

  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1024) {
          return desktop ?? tablet ?? mobile;
        } else if (constraints.maxWidth >= 600) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}

// Extension for responsive sizing
extension ResponsiveExtension on num {
  double responsive(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1024) {
      return toDouble() * 1.2;
    } else if (width >= 600) {
      return toDouble() * 1.1;
    }
    return toDouble();
  }
}

// Responsive padding helper
class ResponsivePadding {
  static EdgeInsets getScreenPadding(BuildContext context) {
    if (ResponsiveBuilder.isDesktop(context)) {
      return const EdgeInsets.symmetric(horizontal: 48, vertical: 24);
    } else if (ResponsiveBuilder.isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 20);
    }
    return const EdgeInsets.symmetric(horizontal: 16, vertical: 16);
  }

  static EdgeInsets getCardPadding(BuildContext context) {
    if (ResponsiveBuilder.isDesktop(context)) {
      return const EdgeInsets.all(24);
    } else if (ResponsiveBuilder.isTablet(context)) {
      return const EdgeInsets.all(20);
    }
    return const EdgeInsets.all(16);
  }
}

// Grid helper for responsive column count
class ResponsiveGrid {
  static int getColumnCount(BuildContext context) {
    if (ResponsiveBuilder.isDesktop(context)) {
      return 4;
    } else if (ResponsiveBuilder.isTablet(context)) {
      return 3;
    }
    return 2;
  }

  static double getChildAspectRatio(BuildContext context) {
    if (ResponsiveBuilder.isDesktop(context)) {
      return 1.4;
    } else if (ResponsiveBuilder.isTablet(context)) {
      return 1.3;
    }
    return 1.2;
  }
}

